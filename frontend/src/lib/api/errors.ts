export class ApiError extends Error {
  readonly status: number;
  readonly code?: string;
  readonly fieldErrors: Record<string, string>;

  constructor(
    status: number,
    message: string,
    options?: { code?: string; fieldErrors?: Record<string, string> }
  ) {
    super(message);
    this.name = "ApiError";
    this.status = status;
    this.code = options?.code;
    this.fieldErrors = options?.fieldErrors ?? {};
  }
}

export class ValidationError extends ApiError {
  constructor(message: string, fieldErrors: Record<string, string>, code?: string) {
    super(422, message, { fieldErrors, code });
    this.name = "ValidationError";
  }
}

export class AuthError extends ApiError {
  constructor(message: string, code?: string) {
    super(401, message, { code });
    this.name = "AuthError";
  }
}

export class ForbiddenError extends ApiError {
  constructor(message: string, code?: string) {
    super(403, message, { code });
    this.name = "ForbiddenError";
  }
}

export class NotFoundError extends ApiError {
  constructor(message: string) {
    super(404, message);
    this.name = "NotFoundError";
  }
}

export class ConflictError extends ApiError {
  constructor(message: string) {
    super(409, message);
    this.name = "ConflictError";
  }
}

export class ServerError extends ApiError {
  constructor(message: string, status = 500) {
    super(status, message);
    this.name = "ServerError";
  }
}

export class NetworkError extends ApiError {
  constructor(message = "A network error occurred. Check your connection.") {
    super(0, message);
    this.name = "NetworkError";
  }
}

interface ErrorBodyShape {
  message?: string;
  detail?: string | { message?: string; code?: string };
  errors?: { field?: string; message?: string; loc?: (string | number)[] }[];
  code?: string;
}

const FALLBACK_MESSAGES: Record<number, string> = {
  400: "The request was invalid.",
  401: "Your session has expired. Please sign in again.",
  403: "You are not authorized to perform this action.",
  404: "The requested resource was not found.",
  409: "This conflicts with existing data.",
  422: "Please correct the errors in the form.",
  429: "Too many requests. Please try again shortly.",
  500: "Something went wrong on the server.",
  502: "The server is temporarily unavailable.",
  503: "The server is temporarily unavailable.",
};

function fieldLabel(field: string): string {
  const parts = field.split(".");
  return parts[parts.length - 1] ?? field;
}

export function parseErrorBody(status: number, raw: unknown): ApiError {
  const body = (raw ?? {}) as ErrorBodyShape;

  const fieldErrors: Record<string, string> = {};
  for (const issue of body.errors ?? []) {
    const field =
      issue.field ?? (issue.loc ? issue.loc.filter((p) => p !== "body").join(".") : undefined);
    if (field && issue.message) fieldErrors[fieldLabel(field)] = issue.message;
  }

  let message = "";
  let code: string | undefined;
  if (typeof body.detail === "string") {
    message = body.detail;
  } else if (body.detail && typeof body.detail === "object") {
    message = body.detail.message ?? "";
    code = body.detail.code ?? body.code;
  }
  if (!message) message = body.message ?? FALLBACK_MESSAGES[status] ?? `Request failed (${status}).`;
  if (!code) code = body.code;

  if (status === 422 && Object.keys(fieldErrors).length > 0) {
    return new ValidationError(message, fieldErrors, code);
  }
  if (status === 400 && Object.keys(fieldErrors).length > 0) {
    return new ValidationError(message, fieldErrors, code);
  }
  if (status === 401) return new AuthError(message, code);
  if (status === 403) return new ForbiddenError(message, code);
  if (status === 404) return new NotFoundError(message);
  if (status === 409) return new ConflictError(message);
  if (status >= 500) return new ServerError(message, status);
  return new ApiError(status, message, { code, fieldErrors });
}

export function getErrorMessage(error: unknown): string {
  if (error instanceof ApiError) return error.message;
  if (error instanceof Error) return error.message;
  return "An unexpected error occurred.";
}
