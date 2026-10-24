"use client";

import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";

export default function GlobalNotFound() {
  return (
    <div className="flex min-h-svh items-center justify-center p-4">
      <Card className="w-full max-w-sm text-center">
        <CardHeader>
          <CardTitle>Page not found</CardTitle>
          <CardDescription>The page you are looking for doesn&apos;t exist or you don&apos;t have access.</CardDescription>
        </CardHeader>
        <CardContent>
          <Button render={<a href="/dashboard" />}>Back to dashboard</Button>
        </CardContent>
      </Card>
    </div>
  );
}
