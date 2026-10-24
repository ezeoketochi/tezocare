import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  /* config options here */
  cacheComponents: true,
  partialPrefetching: true,
  experimental: {
    instantInsights: {
      // This app is fully client-rendered: every page/layout under (app) is a Client
      // Component reading session state from Redux, so no segment can export `instant`
      // (illegal in Client Components) and each one "drops" its children until hydrated —
      // which the default validation flags on every route. Validate only explicit opt-ins.
      validationLevel: "manual-warning",
    },
  },
  turbopack: {
    rules: {
      "*.css": {
        loaders: ["@tailwindcss/turbopack"],
        as: "*.css",
      },
    },
  },
};

export default nextConfig;
