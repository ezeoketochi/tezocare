import { NextRequest, NextResponse } from "next/server";

const PUBLIC_PATHS = ["/login", "/register", "/forgot-password", "/verify-otp", "/reset-password"];
const SENTINEL = "tezo_auth";

// Cosmetic gate only: the sentinel cookie is a presence flag, never a trust boundary.
// Real auth is enforced by the API's 401/403 and the client-side AuthGuard.
export function proxy(request: NextRequest) {
  const { pathname } = request.nextUrl;
  const hasSession = request.cookies.get(SENTINEL)?.value === "1";
  const isPublic = PUBLIC_PATHS.some((p) => pathname === p || pathname.startsWith(`${p}/`));

  if (!hasSession && !isPublic) {
    const url = new URL("/login", request.url);
    if (pathname !== "/") url.searchParams.set("next", pathname);
    return NextResponse.redirect(url);
  }
  if (hasSession && isPublic) {
    const next = request.nextUrl.searchParams.get("next");
    return NextResponse.redirect(new URL(next && next.startsWith("/") ? next : "/dashboard", request.url));
  }
  return NextResponse.next();
}

export const config = {
  matcher: ["/((?!api|_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp|ico)$).*)"],
};
