"use client";

import { SidebarInset, SidebarProvider } from "@/components/ui/sidebar";
import { AuthGuard } from "@/components/guards/auth-guard";
import { AppSidebar } from "@/components/layout/app-sidebar";
import { AppTopbar } from "@/components/layout/app-topbar";
import { BottomNav } from "@/components/layout/bottom-nav";

export default function AppLayout({ children }: { children: React.ReactNode }) {
  return (
    <AuthGuard>
      <SidebarProvider>
        <AppSidebar />
        <SidebarInset className="min-w-0">
          <AppTopbar />
          <main className="mx-auto flex w-full max-w-[1240px] min-w-0 flex-1 flex-col gap-5 px-3.5 pt-5 pb-24 md:px-6 md:pb-8">
            {children}
          </main>
          <BottomNav />
        </SidebarInset>
      </SidebarProvider>
    </AuthGuard>
  );
}
