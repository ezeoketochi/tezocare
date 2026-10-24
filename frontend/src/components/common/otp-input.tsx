"use client";

import { useEffect, useRef } from "react";
import { cn } from "cn";

const DIGITS = 6;

/** Figma one-time-code row: six fixed boxes, 55px tall, 20px apart. */
export function OtpInput({
  value,
  onChange,
  onComplete,
  disabled,
  autoFocus,
  id,
  className,
}: {
  value: string;
  onChange: (value: string) => void;
  onComplete?: (value: string) => void;
  disabled?: boolean;
  autoFocus?: boolean;
  id?: string;
  className?: string;
}) {
  const refs = useRef<(HTMLInputElement | null)[]>([]);

  useEffect(() => {
    if (autoFocus) refs.current[0]?.focus();
  }, [autoFocus]);

  function commit(next: string) {
    onChange(next);
    if (next.length === DIGITS) onComplete?.(next);
  }

  function handleChange(index: number, raw: string) {
    const digits = raw.replace(/\D/g, "");
    // The code is a prefix of the value, so editing a box replaces everything from there on.
    commit((value.slice(0, index) + digits).slice(0, DIGITS));
    refs.current[Math.min(index + digits.length, DIGITS - 1)]?.focus();
  }

  function handleKeyDown(index: number, event: React.KeyboardEvent<HTMLInputElement>) {
    if (event.key === "Backspace") {
      event.preventDefault();
      const at = value[index] ? index : Math.max(0, index - 1);
      commit(value.slice(0, at));
      refs.current[at]?.focus();
    } else if (event.key === "ArrowLeft" && index > 0) {
      refs.current[index - 1]?.focus();
    } else if (event.key === "ArrowRight" && index < DIGITS - 1) {
      refs.current[index + 1]?.focus();
    }
  }

  return (
    <div className={cn("grid grid-cols-6 items-center gap-5", className)}>
      {Array.from({ length: DIGITS }, (_, index) => (
        <input
          key={index}
          id={index === 0 ? id : undefined}
          ref={(node) => {
            refs.current[index] = node;
          }}
          value={value[index] ?? ""}
          onChange={(event) => handleChange(index, event.target.value)}
          onKeyDown={(event) => handleKeyDown(index, event)}
          inputMode="numeric"
          maxLength={DIGITS}
          autoComplete={index === 0 ? "one-time-code" : "off"}
          disabled={disabled}
          aria-label={`Digit ${index + 1}`}
          className="h-[55px] w-full min-w-0 rounded-btn border border-line bg-field text-center text-[24px] leading-[30px] font-medium text-title outline-none transition-colors focus-visible:border-gold focus-visible:ring-3 focus-visible:ring-ring/30 disabled:opacity-60"
        />
      ))}
    </div>
  );
}
