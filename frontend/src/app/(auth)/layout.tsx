import Link from "next/link";
import { HeartPulse } from "lucide-react";

export default function AuthLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="gold-wash flex min-h-svh flex-col items-center justify-center bg-ink px-4 py-10">
      <Link href="/login" className="mb-8 flex items-center gap-2.5">
        <span className="flex size-[45px] items-center justify-center rounded-nav bg-gold text-ink">
          <HeartPulse className="size-6" />
        </span>
        <span className="font-heading text-[24px] leading-[30px] font-semibold tracking-tight text-title">
          Tezo<span className="text-gold">Care</span>
        </span>
      </Link>
      <div className="w-full max-w-md">{children}</div>
    </div>
  );
}
