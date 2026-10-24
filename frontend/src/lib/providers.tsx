"use client";

import { Suspense, useEffect, useRef, useState } from "react";
import { useRouter } from "next/navigation";
import { Provider } from "react-redux";
import { useAppStore } from "@/lib/redux/hooks";
import { QueryClientProvider, useQueryClient } from "@tanstack/react-query";
import { Toaster } from "@/components/ui/sonner";
import { clearTokens, hasStoredSession } from "@/lib/api/client";
import { onSessionExpired } from "@/lib/api/session-events";
import { createQueryClient } from "@/lib/api/query-client";
import { clearAuth, hydrateSession } from "@/lib/redux/authSlice";
import { makeStore } from "@/lib/redux/store";

function AuthHydration() {
  const store = useAppStore();
  const queryClient = useQueryClient();
  const router = useRouter();
  const started = useRef(false);

  useEffect(() => {
    if (started.current) return;
    started.current = true;
    if (hasStoredSession()) {
      store.dispatch(hydrateSession());
    } else {
      store.dispatch(clearAuth());
    }
  }, [store]);

  useEffect(
    () =>
      onSessionExpired(() => {
        clearTokens();
        store.dispatch(clearAuth());
        queryClient.clear();
        const next = window.location.pathname;
        router.replace(`/login?expired=1${next !== "/login" ? `&next=${encodeURIComponent(next)}` : ""}`);
      }),
    [store, queryClient, router]
  );

  return null;
}

function ClientProviders({ children }: { children: React.ReactNode }) {
  const [store] = useState(makeStore);
  const [queryClient] = useState(createQueryClient);

  return (
    <Provider store={store}>
      <QueryClientProvider client={queryClient}>
        <AuthHydration />
        {children}
        <Toaster position="top-right" richColors closeButton />
      </QueryClientProvider>
    </Provider>
  );
}

// Store creation is client-only (RTK uses Math.random internally, which Next's
// prerender treats as an unstable value), so the tree is streamed behind Suspense.
export function Providers({ children }: { children: React.ReactNode }) {
  return (
    <Suspense fallback={<div className="min-h-svh bg-background" />}>
      <ClientProviders>{children}</ClientProviders>
    </Suspense>
  );
}
