"use client";

import { Tabs, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { cn } from "cn";
import type { LucideIcon } from "lucide-react";

export interface PillTab {
  value: string;
  label: string;
  icon?: LucideIcon;
}

/** The Figma tab group: a `panel` pill rail whose active item is a `line` pill. */
export function PillTabs({
  tabs,
  value,
  defaultValue,
  onValueChange,
  children,
  className,
  ariaLabel,
}: {
  tabs: PillTab[];
  value?: string;
  defaultValue?: string;
  onValueChange?: (value: string) => void;
  children: React.ReactNode;
  className?: string;
  ariaLabel?: string;
}) {
  return (
    <Tabs
      value={value}
      defaultValue={defaultValue}
      onValueChange={onValueChange}
      className={cn("gap-5", className)}
    >
      <TabsList
        aria-label={ariaLabel}
        className="h-[34px] w-full max-w-full justify-start gap-1 sm:w-fit"
      >
        {tabs.map((tab) => (
          <TabsTrigger key={tab.value} value={tab.value}>
            {tab.icon && <tab.icon className="size-3.5" />}
            {tab.label}
          </TabsTrigger>
        ))}
      </TabsList>
      {children}
    </Tabs>
  );
}
