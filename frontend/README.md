# TezoCare Web

Responsive web client for TezoCare pharmacy care — a Next.js port of the `tezocare_mobile` Flutter app.

## Stack

- **Next.js 16** (App Router, TypeScript, Turbopack) — all screens are client components; no server data fetching
- **shadcn/ui** (base-ui variant) + Tailwind v4
- **TanStack Query v5** — all server state (lists, details, mutations, cache invalidation)
- **Redux Toolkit** — client state only: auth/session (`authSlice`) and UI (`uiSlice`)
- **react-hook-form + zod** — forms mirror backend Pydantic schemas (snake_case keys so 422 field errors map inline)

## Getting started

```bash
npm install
cp .env.example .env.local   # set NEXT_PUBLIC_API_URL
npm run dev                  # http://localhost:3000
```

`NEXT_PUBLIC_API_URL` points at the FastAPI backend root (e.g. `http://16.170.208.96`); the client appends `/api/v1`.

> **Mixed content**: if you deploy this site over HTTPS, the browser cannot call an HTTP API.
> Either put TLS on the backend or route through a Next route handler — the seam is a single
> `baseUrl` change in `src/lib/config/env.ts` / `src/lib/api/client.ts`.

## Architecture

```
src/
├── app/
│   ├── (auth)/            login, register, forgot-password, verify-otp, reset-password
│   └── (app)/             AuthGuard + AppShell
│       ├── dashboard  patients  refills  follow-ups  medications
│       ├── notifications  profile  settings (admin: pharmacy + staff CRUD)
├── lib/
│   ├── api/               client.ts (fetch + token refresh), errors.ts, query-client.ts
│   ├── features/<name>/   api.ts + hooks.ts + keys.ts + types.ts per feature
│   ├── redux/             store, authSlice (session), uiSlice (sidebar/nav)
│   ├── schemas/           zod mirrors of backend request bodies
│   └── config/            nav.ts, roles.ts, env.ts
├── components/            ui/ (shadcn), layout/, guards/, common/, patients/, visits/
└── proxy.ts               cosmetic sentinel-cookie redirects (Next 16 middleware successor)
```

### Auth model

- Access token lives in **module memory only**; refresh token in `localStorage`
  (`tezocare_refresh_token`). A non-secret sentinel cookie (`tezo_auth=1`) exists purely so
  `proxy.ts` can redirect unauthenticated requests before the app boots.
- On 401, `client.ts` performs a **single-flight refresh** (`POST /auth/refresh-token`) and
  replays the original request once; concurrent 401s share the same refresh promise.
- Refresh failure clears tokens + query cache, resets the Redux session, and redirects to
  `/login?expired=1`.
- Trust boundary is the API itself (401/403). Multi-tenancy is resolved server-side from the
  JWT `pharmacy_id` — the client sends no tenant header.

### Roles

`super_admin > admin > pharmacist > data_entry`. Action gating lives in `src/lib/config/roles.ts`
(`can(role, action)`); route gating in `RoleGuard`. Visits are editable **only by their creator
while active**; medications are read-only projections of dispensed visit medications.

### Data flow conventions

- One query-key hierarchy per feature (`features/<name>/keys.ts`); mutations invalidate through it.
- `GET /refills` triggers a server-side sync from `visit.medications_dispensed` — visit writes
  therefore also invalidate the refills and dashboard caches.
- Lists use `placeholderData: keepPreviousData` with debounced search; notifications poll every 60 s.

## Scripts

| Command          | Purpose                          |
| ---------------- | -------------------------------- |
| `npm run dev`    | dev server (Turbopack)           |
| `npm run build`  | production build                 |
| `npm run start`  | serve the production build       |
| `npm run lint`   | ESLint (incl. react-hooks rules) |
| `npx tsc --noEmit` | strict type check              |
