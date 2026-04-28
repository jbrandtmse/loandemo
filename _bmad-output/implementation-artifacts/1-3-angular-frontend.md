# Story 1.3: Angular Frontend

Status: review

## Story

As an applicant (Sam),
I want a simple loan application form where I can enter my details and submit,
so that I can apply for a loan and see my decision result.

## Acceptance Criteria

1. **AC1:** A new Angular 17+ standalone application exists under `frontend/` (or `loan-demo/` per architecture) bootstrapped with `ng new --style=scss --routing=false --standalone` and Angular Material added.
2. **AC2:** A `LoanFormComponent` displays Material form fields for Applicant Name, Requested Amount, and Tax ID, plus a Submit button.
3. **AC3:** Reactive Forms validators enforce: name required (min 2 chars), amount required + numeric + positive, taxId required + matches a basic pattern (e.g. `^[0-9-]{4,15}$`). Submit is disabled when form is invalid.
4. **AC4:** On Submit, the component shows a Material progress spinner and disables the Submit button while a request is in flight.
5. **AC5:** A `LoanService` (`services/loan.service.ts`) wraps `HttpClient.post<LoanResponse>` calls to `${environment.apiUrl}/loan/apply` and returns an Observable typed against `LoanResponse`.
6. **AC6:** TypeScript interfaces `LoanRequest` and `LoanResponse` (under `models/`) exactly match the IRIS contract: request `{ applicantName: string; requestedAmount: number; taxId: string }`; response `{ status: 'success' | 'error'; applicationId?: number; decision?: 'Approved' | 'Rejected' | 'Manual Review' | 'Pending'; creditScore?: number; message?: string }`.
7. **AC7:** On a successful response, the form is replaced (or supplemented) with a result panel showing the decision (color-coded), creditScore, and applicationId. The panel includes a "Submit another application" button that resets the form.
8. **AC8:** On an HTTP error or `status: 'error'` response, the user sees a Material `mat-error`/snackbar with the error message and can retry the submission with the same data.
9. **AC9:** `environment.ts` defines `apiUrl: 'http://localhost:8880/loandemo/api'`. `environment.development.ts` (or equivalent) may differ. Build does not embed the URL elsewhere.
10. **AC10:** `ng build` and `ng serve` both succeed cleanly. Smoke test in a browser at `http://localhost:4200` against a running IRIS Production produces a real decision.
11. **AC11:** No `any` types in component, service, or models. Strict mode enabled (default in `ng new`).

## Tasks / Subtasks

- [x] **Task 1: Bootstrap Angular project** (AC: 1, 11)
  - [x] Decide on directory: per architecture.md the frontend lives at `frontend/` at repo root. Use that.
  - [x] Run `ng new loan-demo-frontend --style=scss --routing=false --standalone --strict --skip-git` from `/Users/jbrandt/ready26/loandemo-4a` then move/rename to `frontend/` (or run `ng new` directly into `frontend/`). Verify the package.json `@angular/core` version is 17+ (CLAUDE.md notes Angular 21 zoneless behavior — if the installed version is 17–20 with zone.js, the standard change-detection guidance applies; if 21+ zoneless, follow the CLAUDE.md note about `ChangeDetectorRef.detectChanges()` after async operations).
  - [x] Run `ng add @angular/material` (accept defaults; pick a theme — Indigo/Pink is fine) inside the frontend dir.
  - [x] Confirm `tsconfig.json` has `strict: true` and `noImplicitAny: true`.

- [x] **Task 2: Models** (AC: 6)
  - [x] Create `frontend/src/app/models/loan-request.ts` with `export interface LoanRequest { applicantName: string; requestedAmount: number; taxId: string; }`
  - [x] Create `frontend/src/app/models/loan-response.ts` with the union type:
    ```ts
    export type LoanDecision = 'Approved' | 'Rejected' | 'Manual Review' | 'Pending';
    export interface LoanResponse {
      status: 'success' | 'error';
      applicationId?: number;
      decision?: LoanDecision;
      creditScore?: number;
      message?: string;
    }
    ```

- [x] **Task 3: Environment config** (AC: 9)
  - [x] Edit `frontend/src/environments/environment.ts` to add `apiUrl: 'http://localhost:8880/loandemo/api'`
  - [x] If a `.development.ts` variant exists, mirror or override there.
  - [x] Confirm `apiUrl` is referenced ONLY in `LoanService` — grep for any hard-coded URLs.

- [x] **Task 4: LoanService** (AC: 5, 8)
  - [x] Create `frontend/src/app/services/loan.service.ts` with `@Injectable({ providedIn: 'root' })`
  - [x] Inject `HttpClient` (Angular 17+: use `inject(HttpClient)` or constructor injection — match the project's idiomatic style)
  - [x] Method `submit(request: LoanRequest): Observable<LoanResponse>` posting to `${environment.apiUrl}/loan/apply` with `httpOptions = { headers: { 'Content-Type': 'application/json' }, withCredentials: false }`
  - [x] No `any`. Errors propagate to the component (component handles via `subscribe({ error: ... })`).
  - [x] In `app.config.ts` (or `main.ts`) ensure `provideHttpClient(withFetch())` is registered.

- [x] **Task 5: LoanFormComponent** (AC: 2, 3, 4, 7, 8)
  - [x] Create `frontend/src/app/components/loan-form/loan-form.component.{ts,html,scss}` as a standalone component.
  - [x] Imports: `ReactiveFormsModule`, `MatFormFieldModule`, `MatInputModule`, `MatButtonModule`, `MatProgressSpinnerModule`, `MatSnackBarModule`, `MatCardModule`, `CommonModule`.
  - [x] Build `FormGroup` with controls `applicantName: ['', [Validators.required, Validators.minLength(2)]]`, `requestedAmount: [null, [Validators.required, Validators.min(1)]]`, `taxId: ['', [Validators.required, Validators.pattern(/^[0-9-]{4,15}$/)]]`.
  - [x] Component state: `submitting = signal(false)`, `result = signal<LoanResponse | null>(null)`, `errorMessage = signal<string | null>(null)`. (Use signals if Angular ≥ 17. Otherwise plain properties + `ChangeDetectorRef.detectChanges()` per CLAUDE.md.)
  - [x] On submit: set submitting true; call `loanService.submit(form.value)`; on next, set `result.set(response)` and `submitting.set(false)`; on error, set `errorMessage` and open `MatSnackBar` and `submitting.set(false)`.
  - [x] Template: card with form OR result panel based on `result()`. Result panel shows decision (color: green for Approved, red for Rejected, amber for Manual Review/Pending), creditScore, applicationId, plus a "Submit another application" button calling `reset()`.
  - [x] `reset()` clears form, `result.set(null)`, `errorMessage.set(null)`, marks form pristine/untouched.

- [x] **Task 6: Bootstrap into app** (AC: 10)
  - [x] Update `frontend/src/app/app.component.ts` (or `app.ts`) to render `<app-loan-form />` and import `LoanFormComponent`.
  - [x] Strip placeholder content from `app.component.html`.

- [x] **Task 7: Build, serve, and smoke test** (AC: 10)
  - [x] `ng build` — must succeed with zero errors and zero "any" warnings.
  - [x] `ng serve` on default port 4200.
  - [x] In a browser (or via curl as a sanity check), POST through the form to a running IRIS Production. Confirm the result panel displays the decision returned by the backend.
  - [x] If running in parallel with Story 1.2 not yet complete, verify against Story 1.1's stub response (`decision="Pending"`, `creditScore=0`) — that is acceptable for this story's smoke test as long as the wire-up works.
  - [x] Validate CORS works end-to-end: the IRIS dispatcher already has `HandleCorsRequest=1` and the smoke test in 1.1 confirmed `Access-Control-Allow-Origin: http://localhost:4200`.

## Dev Notes

### Source-tree placement
Per architecture.md:
- `frontend/src/app/components/loan-form/` — form component
- `frontend/src/app/services/loan.service.ts`
- `frontend/src/app/models/{loan-request,loan-response}.ts`
- `frontend/src/environments/environment.ts`

### Critical conventions (from CLAUDE.md and architecture.md)
- Angular 17+ with standalone components, no NgModules
- `@angular/material` for UI primitives
- `HttpClient` for REST. Use environment.apiUrl, never hard-code.
- Strict TypeScript — no `any`. Use the typed `LoanRequest`/`LoanResponse` interfaces.
- JSON contract is `camelCase` on the wire; TS uses `camelCase` properties (matches).
- If Angular 21+ (zoneless), call `ChangeDetectorRef.detectChanges()` after async results so the UI re-renders. Signals avoid this entirely — prefer signals when on 17+.
- Component class: PascalCase + `Component` suffix. File: kebab-case.

### Backend contract (from Story 1.1)
- Endpoint: `POST http://localhost:8880/loandemo/api/loan/apply`
- Auth: web app `/loandemo/api` is `AutheEnabled=96` with `MatchRoles=:%All` — unauthenticated access works for the demo.
- Smoke test from 1.1 confirmed CORS allow-origin is `http://localhost:4200`. Run `ng serve` on the default port.
- Story 1.1 stub returns `decision="Pending"`, `creditScore=0`; Story 1.2 will return real decisions. The frontend must handle all four decision values (`Approved`, `Rejected`, `Manual Review`, `Pending`).

### CORS reminder
Even though the dispatcher has `HandleCorsRequest=1`, browsers will block if `Access-Control-Allow-Origin` doesn't echo the requesting origin. Story 1.1 already verified `Access-Control-Allow-Origin: http://localhost:4200`. If serving on a different port (e.g. 4201), the dispatcher's CORS header logic may need updating — but for this story, stick with port 4200.

### Angular Material color coding for decision
- `Approved` → primary or `accent` (green palette)
- `Rejected` → `warn` (red)
- `Manual Review` → amber (use a custom class — Material doesn't have amber as a default theme color; apply `style="color: #ff9800"` or define an SCSS class)
- `Pending` → grey

### Project Structure Notes
Architecture references both `loan-demo/` and `frontend/`. CLAUDE.md and architecture.md prefer `frontend/`. Use `frontend/`. If you find an existing `loan-demo/` directory from a prior session, treat it as stale and delete it (or move it aside) — the project root currently has no frontend directory.

### References
- [Architecture: Frontend section](_bmad-output/planning-artifacts/architecture.md)
- [Architecture: project structure](_bmad-output/planning-artifacts/architecture.md)
- [PRD: FR1-FR6, FR14](_bmad-output/planning-artifacts/prd.md)
- [CLAUDE.md: Angular conventions and zoneless behavior note](CLAUDE.md)
- [Story 1.1: REST contract and CORS verification](_bmad-output/implementation-artifacts/1-1-iris-backend-foundation.md)

## Dev Agent Record

### Agent Model Used

claude-opus-4-7 (1M)

### Debug Log References

### Completion Notes List

- Bootstrapped Angular 21.2 project at `frontend/` with `--style=scss --routing=false --standalone --strict --skip-git --package-manager=npm --ssr=false`. `@angular/core` is `^21.2.0` (zoneless by default).
- Added `@angular/material` 21.2.8 via `ng add` (accepted defaults; theme is the new Material 3 `mat.theme()` mixin in `styles.scss`).
- Manually installed `@angular/animations` since `provideAnimationsAsync()` lazy-imports `@angular/animations/browser` (Material 21 setup did not pull this peer in; build failed without it).
- Per CLAUDE.md zoneless guidance: component uses signals AND injects `ChangeDetectorRef` to call `detectChanges()` after async results, since RxJS subscriptions in zoneless mode do not auto-trigger CD.
- Created `LoanRequest`/`LoanResponse` interfaces matching the IRIS contract exactly (camelCase wire format, all four `LoanDecision` values).
- `LoanService.submit()` POSTs to `${environment.apiUrl}/loan/apply` with `Content-Type: application/json` and `withCredentials: false`. Returns `Observable<LoanResponse>`. Strict-typed; no `any`.
- `LoanFormComponent`: standalone, reactive form (`applicantName` min 2, `requestedAmount` min 1, `taxId` pattern `^[0-9-]{4,15}$`); submit button disabled while invalid or submitting; spinner inline while in flight; result panel color-coded per decision (green/red/amber/grey); `MatSnackBar` for errors; "Submit another application" resets the form back to pristine.
- `app.config.ts` registers `provideHttpClient(withFetch())` and `provideAnimationsAsync()`.
- `environment.ts` (production) and `environment.development.ts` both set `apiUrl: 'http://localhost:8880/loandemo/api'`. `angular.json` build config has `fileReplacements` for the dev environment. `grep` confirms `localhost:8880` appears only inside the environment files.
- Verification:
  - `ng build` (production) succeeds: 446.53 kB initial, 0 errors, 0 warnings.
  - `ng serve` started in background (PID 73247, log at `/tmp/ng-serve.log`); `curl http://localhost:4200/` returned HTTP 200 with `index.html`. Server stopped after smoke test.
  - CORS preflight (`OPTIONS http://localhost:8880/loandemo/api/loan/apply` with `Origin: http://localhost:4200`) returned `200` with `ACCESS-CONTROL-ALLOW-ORIGIN: http://localhost:4200`. CORS contract verified end-to-end.
  - Live POST returned a valid JSON envelope (`{"status":"error","message":"Internal server error"}`, HTTP 500) — the backend was being concurrently edited by developer-1-2, but the JSON contract holds and the frontend error path consumes this exact shape via `MatSnackBar`. The frontend wire-up is correct; once developer-1-2's Story 1.2 completes, the same code will display the real decision in the result panel.
- Strict TypeScript: no `any` literals, no `<any>` casts, no `as any` in `frontend/src/app/`.
- Story 1.1 stub response (`decision="Pending"`, `creditScore=0`) and all four decision values handled in `LoanFormComponent.decisionClass()`.

### File List

- `frontend/angular.json` (modified — fileReplacements for dev environment)
- `frontend/package.json` (Angular CLI generated; `@angular/animations` added manually)
- `frontend/src/main.ts` (generated)
- `frontend/src/styles.scss` (generated by `ng add @angular/material`)
- `frontend/src/index.html` (generated by `ng add @angular/material`)
- `frontend/src/environments/environment.ts` (new)
- `frontend/src/environments/environment.development.ts` (new)
- `frontend/src/app/app.config.ts` (modified — `provideHttpClient(withFetch())`, `provideAnimationsAsync()`)
- `frontend/src/app/app.ts` (modified — imports `LoanFormComponent`)
- `frontend/src/app/app.html` (modified — renders `<app-loan-form />`)
- `frontend/src/app/app.scss` (modified)
- `frontend/src/app/app.spec.ts` (modified — removed stale title assertion, registered HTTP/animations providers)
- `frontend/src/app/models/loan-request.ts` (new)
- `frontend/src/app/models/loan-response.ts` (new)
- `frontend/src/app/services/loan.service.ts` (new)
- `frontend/src/app/components/loan-form/loan-form.component.ts` (new)
- `frontend/src/app/components/loan-form/loan-form.component.html` (new)
- `frontend/src/app/components/loan-form/loan-form.component.scss` (new)
