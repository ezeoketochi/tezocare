import type { Metadata } from "next";
import { Manrope, Public_Sans } from "next/font/google";
import { Providers } from "@/lib/providers";
import { AUTH_SENTINEL_COOKIE } from "@/lib/api/client";
import "./globals.css";

// Public Sans carries body/nav/labels; Manrope is the display face for titles.
const publicSans = Public_Sans({
  subsets: ["latin"],
  weight: ["300", "400", "500", "600", "700"],
  variable: "--font-public-sans",
  display: "swap",
});

const manrope = Manrope({
  subsets: ["latin"],
  weight: ["500", "600"],
  variable: "--font-manrope",
  display: "swap",
});

export const metadata: Metadata = {
  title: { default: "TezoCare", template: "%s | TezoCare" },
  description: "Pharmacy care management — patients, visits, refills and follow-ups.",
};

// Sync localStorage session presence into a sentinel cookie before first paint
// so middleware can gate routes without a flash. The token itself is never stored here.
const sentinelScript = `try{var has=!!localStorage.getItem('tezocare_refresh_token');document.cookie=has?'${AUTH_SENTINEL_COOKIE}=1; path=/; max-age=604800; SameSite=Lax':'${AUTH_SENTINEL_COOKIE}=; path=/; max-age=0; SameSite=Lax';document.documentElement.setAttribute('data-auth',has?'yes':'no');}catch(e){}`;

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className={`${publicSans.variable} ${manrope.variable}`} suppressHydrationWarning>
      <head>
        <script dangerouslySetInnerHTML={{ __html: sentinelScript }} />
      </head>
      <body className="antialiased">
        <Providers>{children}</Providers>
      </body>
    </html>
  );
}
