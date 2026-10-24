"use client"

import { Toaster as Sonner, type ToasterProps } from "sonner"
import { CircleCheckIcon, InfoIcon, TriangleAlertIcon, OctagonXIcon, Loader2Icon } from "lucide-react"

// Dark-only design system: no theme provider exists, so the toast is pinned to dark
// and tinted with the Figma's surface colours instead of sonner's own defaults.
const toastVars = {
  "--normal-bg": "#1f1a0e",
  "--normal-text": "#ffffff",
  "--normal-border": "#ffffff",
  "--success-bg": "#0f2118",
  "--success-text": "#ffffff",
  "--success-border": "#ffffff",
  "--error-bg": "#240c0d",
  "--error-text": "#ffffff",
  "--error-border": "#ffffff",
  "--warning-bg": "#1f1a0e",
  "--warning-text": "#ffffff",
  "--warning-border": "#ffffff",
  "--info-bg": "#141a24",
  "--info-text": "#ffffff",
  "--info-border": "#ffffff",
  "--border-radius": "8px",
} as React.CSSProperties

const Toaster = ({ ...props }: ToasterProps) => {
  return (
    <Sonner
      theme="dark"
      className="toaster group"
      icons={{
        success: (
          <CircleCheckIcon className="size-4" />
        ),
        info: (
          <InfoIcon className="size-4" />
        ),
        warning: (
          <TriangleAlertIcon className="size-4" />
        ),
        error: (
          <OctagonXIcon className="size-4" />
        ),
        loading: (
          <Loader2Icon className="size-4 animate-spin" />
        ),
      }}
      style={toastVars}
      toastOptions={{
        classNames: {
          toast: "cn-toast !border-2 !border-white/85 !min-h-[45px] !text-[15px] !leading-[22px]",
          success: "!text-white",
          error: "!text-white",
          warning: "!text-white",
          info: "!text-white",
          closeButton: "!bg-transparent !text-white !border-none",
        },
      }}
      {...props}
    />
  )
}

export { Toaster }
