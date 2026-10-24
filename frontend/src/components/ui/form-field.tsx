"use client";

import * as React from "react";
import {
  Controller,
  type Control,
  type ControllerRenderProps,
  type FieldError,
  type FieldPath,
  type FieldValues,
  type UseFormReturn,
} from "react-hook-form";
import { cn } from "@/lib/utils";
import { Label } from "@/components/ui/label";

interface FormFieldContextValue {
  id: string;
  error?: FieldError;
}

const FormFieldContext = React.createContext<FormFieldContextValue | null>(null);

function useFormFieldContext() {
  return React.useContext(FormFieldContext);
}

// Context-only wrapper (mirrors shadcn's Form): the actual <form> element is
// rendered by callers, so this must not emit one itself.
export function Form<T extends FieldValues>({
  children,
}: UseFormReturn<T> & React.HTMLAttributes<HTMLFormElement>) {
  return <>{children}</>;
}

export function FormField<T extends FieldValues, TName extends FieldPath<T>>({
  control,
  name,
  render,
  children,
}: {
  control: Control<T>;
  name: TName;
  render?: (props: {
    field: ControllerRenderProps<T, TName>;
    fieldState: { error?: FieldError };
  }) => React.ReactNode;
  children?: React.ReactNode;
}) {
  const id = `field-${name.replace(/\./g, "-")}`;
  return (
    <Controller
      control={control}
      name={name}
      render={(controllerProps) => (
        <FormFieldContext.Provider value={{ id, error: controllerProps.fieldState.error as FieldError }}>
          {render
            ? render({ field: controllerProps.field, fieldState: controllerProps.fieldState })
            : children}
        </FormFieldContext.Provider>
      )}
    />
  );
}

export function FormItem({ className, children, ...props }: React.ComponentProps<"div">) {
  return (
    <div data-slot="form-item" className={cn("grid gap-1.5", className)} {...props}>
      {children}
    </div>
  );
}

export function FormLabel({ className, children, ...props }: React.ComponentProps<typeof Label>) {
  const ctx = useFormFieldContext();
  return (
    <Label htmlFor={ctx?.id} className={className} {...props}>
      {children}
    </Label>
  );
}

export function FormControl({ children }: { children: React.ReactNode }) {
  const ctx = useFormFieldContext();
  if (!React.isValidElement(children)) return <>{children}</>;
  return React.cloneElement(children as React.ReactElement<Record<string, unknown>>, {
    id: ctx?.id,
    "aria-invalid": ctx?.error ? true : undefined,
    "aria-describedby": ctx?.error ? `${ctx.id}-error` : undefined,
  });
}

export function FormDescription({ className, ...props }: React.ComponentProps<"p">) {
  return <p className={cn("text-sm text-muted-foreground", className)} {...props} />;
}

export function FieldError({
  error,
  message,
  className,
}: {
  error?: { message?: string };
  message?: string;
  className?: string;
}) {
  const ctx = useFormFieldContext();
  const text = error?.message ?? message ?? ctx?.error?.message;
  if (!text) return null;
  return (
    <p id={ctx ? `${ctx.id}-error` : undefined} className={cn("text-sm text-destructive", className)}>
      {text}
    </p>
  );
}
