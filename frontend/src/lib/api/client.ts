import { API_BASE_URL, API_PREFIX } from "@/lib/config/env";
import { NetworkError, parseErrorBody } from "./errors";
import { notifySessionExpired } from "./session-events";

export interface PaginationMeta {
  page: number;
  per_page: number;
  total: number;
  total_pages: number;
}

export interface ApiEnvelope<T> {
  success: boolean;
  message: string;
  data: T;
  meta?: PaginationMeta | null;
}

export interface ApiResult<T> {
  data: T;
  meta?: PaginationMeta | null;
}

interface RequestOptions {
  method?: "GET" | "POST" | "PUT" | "PATCH" | "DELETE";
  body?: unknown;
  query?: Record<string, string | number | boolean | undefined | null>;
  skipAuth?: boolean;
  signal?: AbortSignal;
}

const REFRESH_TOKEN_KEY = "tezocare_refresh_token";
export const AUTH_SENTINEL_COOKIE = "tezo_auth";

// Access token lives in module memory only — never in Redux, never in localStorage.
let accessToken: string | null = null;

const isBrowser = () => typeof window !== "undefined";

function setSentinelCookie(present: boolean) {
  if (!isBrowser()) return;
  document.cookie = present
    ? `${AUTH_SENTINEL_COOKIE}=1; path=/; max-age=604800; SameSite=Lax`
    : `${AUTH_SENTINEL_COOKIE}=; path=/; max-age=0; SameSite=Lax`;
}

export function getAccessToken(): string | null {
  return accessToken;
}

export function getStoredRefreshToken(): string | null {
  if (!isBrowser()) return null;
  try {
    return window.localStorage.getItem(REFRESH_TOKEN_KEY);
  } catch {
    return null;
  }
}

export function hasStoredSession(): boolean {
  return getStoredRefreshToken() !== null;
}

export function setTokens(tokens: { access_token: string; refresh_token?: string | null }) {
  accessToken = tokens.access_token;
  if (isBrowser() && tokens.refresh_token) {
    try {
      window.localStorage.setItem(REFRESH_TOKEN_KEY, tokens.refresh_token);
    } catch {
      /* storage unavailable */
    }
  }
  setSentinelCookie(true);
}

export function clearTokens() {
  accessToken = null;
  if (isBrowser()) {
    try {
      window.localStorage.removeItem(REFRESH_TOKEN_KEY);
    } catch {
      /* storage unavailable */
    }
  }
  setSentinelCookie(false);
}

// Sync tokens across tabs: another tab refreshing/clearing storage should update this one.
if (isBrowser()) {
  window.addEventListener("storage", (event) => {
    if (event.key === REFRESH_TOKEN_KEY) {
      if (event.newValue === null) {
        accessToken = null;
        setSentinelCookie(false);
      } else {
        setSentinelCookie(true);
      }
    }
  });
}

// 401s on these paths are real credential failures — never trigger the refresh flow.
const NO_REFRESH_PATHS = new Set([
  "/auth/login",
  "/auth/register",
  "/auth/register-pharmacy",
  "/auth/refresh-token",
  "/auth/forgot-password",
  "/auth/verify-otp",
  "/auth/reset-password",
]);

let refreshPromise: Promise<boolean> | null = null;

async function doRefresh(): Promise<boolean> {
  const refreshToken = getStoredRefreshToken();
  if (!refreshToken) return false;
  try {
    const res = await fetch(`${API_BASE_URL}${API_PREFIX}/auth/refresh-token`, {
      method: "POST",
      headers: { "Content-Type": "application/json", Accept: "application/json" },
      body: JSON.stringify({ refresh_token: refreshToken }),
      signal: AbortSignal.timeout(20_000),
    });
    if (!res.ok) return false;
    const body = await res.json();
    const data = body?.data ?? body;
    if (!data?.access_token) return false;
    setTokens({ access_token: data.access_token, refresh_token: data.refresh_token ?? null });
    return true;
  } catch {
    return false;
  }
}

// Single-flight: concurrent 401s all await the same refresh attempt.
function refreshOnce(): Promise<boolean> {
  refreshPromise ??= doRefresh().finally(() => {
    refreshPromise = null;
  });
  return refreshPromise;
}

function buildUrl(path: string, query?: RequestOptions["query"]): string {
  const url = new URL(`${API_BASE_URL}${API_PREFIX}${path}`);
  if (query) {
    for (const [key, value] of Object.entries(query)) {
      if (value !== undefined && value !== null && value !== "") {
        url.searchParams.set(key, String(value));
      }
    }
  }
  return url.toString();
}

const DEV = process.env.NODE_ENV === "development";

async function rawRequest<T>(
  path: string,
  options: RequestOptions & { _retried?: boolean } = {}
): Promise<ApiEnvelope<T>> {
  const { method = "GET", body, query, skipAuth, _retried, signal } = options;
  const headers: Record<string, string> = { Accept: "application/json" };
  if (body !== undefined) headers["Content-Type"] = "application/json";
  if (!skipAuth && accessToken) headers.Authorization = `Bearer ${accessToken}`;

  if (DEV) console.debug(`[api] ${method} ${path}`);

  let res: Response;
  try {
    res = await fetch(buildUrl(path, query), {
      method,
      headers,
      body: body === undefined ? undefined : JSON.stringify(body),
      signal: signal ?? AbortSignal.timeout(20_000),
    });
  } catch (error) {
    if (error instanceof Error && (error.name === "TimeoutError" || error.name === "AbortError")) {
      throw new NetworkError("The request timed out. Please try again.");
    }
    throw new NetworkError();
  }

  if (res.status === 401 && !skipAuth && !_retried && !NO_REFRESH_PATHS.has(path)) {
    const refreshed = await refreshOnce();
    if (refreshed) {
      return rawRequest<T>(path, { ...options, _retried: true });
    }
    clearTokens();
    notifySessionExpired();
  }

  let parsed: unknown = null;
  const text = await res.text();
  if (text) {
    try {
      parsed = JSON.parse(text);
    } catch {
      parsed = null;
    }
  }

  if (!res.ok) {
    // 4xx responses are expected outcomes the UI already shows inline (bad credentials,
    // validation, permissions). Logging them at error level makes the Next dev overlay
    // treat them as unhandled crashes; only server-side faults deserve console.error.
    if (DEV) {
      const detail = `status=${res.status} body=${text.slice(0, 500)}`;
      if (res.status >= 500) console.error(`[api] ${method} ${path} ${detail}`);
      else console.warn(`[api] ${method} ${path} ${detail}`);
    }
    throw parseErrorBody(res.status, parsed);
  }

  const envelope = (parsed ?? {}) as Partial<ApiEnvelope<T>>;
  if (typeof envelope.success === "boolean" && "data" in envelope) {
    return { success: envelope.success, message: envelope.message ?? "", data: envelope.data as T, meta: envelope.meta };
  }
  return { success: true, message: "", data: parsed as T, meta: null };
}

export async function apiRequest<T>(
  path: string,
  options: RequestOptions = {}
): Promise<ApiResult<T>> {
  const envelope = await rawRequest<T>(path, options);
  return { data: envelope.data, meta: envelope.meta ?? null };
}

export const api = {
  get: <T>(path: string, query?: RequestOptions["query"], options?: Omit<RequestOptions, "method" | "query">) =>
    apiRequest<T>(path, { ...options, method: "GET", query }),
  post: <T>(path: string, body?: unknown, query?: RequestOptions["query"], options?: Omit<RequestOptions, "method" | "query" | "body">) =>
    apiRequest<T>(path, { ...options, method: "POST", body, query }),
  put: <T>(path: string, body?: unknown, options?: Omit<RequestOptions, "method" | "body">) =>
    apiRequest<T>(path, { ...options, method: "PUT", body }),
  patch: <T>(path: string, body?: unknown, options?: Omit<RequestOptions, "method" | "body">) =>
    apiRequest<T>(path, { ...options, method: "PATCH", body }),
  del: <T>(path: string, body?: unknown) => apiRequest<T>(path, { method: "DELETE", body }),
};
