# Story 1.1: IRIS Backend Foundation

Status: done

## Story

As a developer,
I want the IRIS backend infrastructure with message classes, persistent data storage, Business Service, and REST API,
so that the frontend can submit loan applications via HTTP and the Production can receive them.

## Acceptance Criteria

1. **AC1:** A POST request to `/loandemo/api/loan/apply` with a valid JSON payload returns HTTP 200 and a JSON success response.
2. **AC2:** CORS preflight (`OPTIONS`) on the same endpoint returns proper `Access-Control-Allow-*` headers (`HandleCorsRequest = 1`).
3. **AC3:** A malformed JSON body or missing required fields returns HTTP 400 with `{"status":"error","message":"..."}`.
4. **AC4:** `LoanDemo.Message.LoanRequest`, `LoanDemo.Message.LoanResponse`, `LoanDemo.Message.CreditCheckRequest`, and `LoanDemo.Message.CreditCheckResponse` compile cleanly and carry the documented properties.
5. **AC5:** `LoanDemo.Data.LoanApplication` is a persistent class with the schema from architecture.md and stores a row when given a populated request.
6. **AC6:** `LoanDemo.Service.LoanService` extends `Ens.BusinessService`, implements `OnProcessInput`, and is registered as a Production component in `LoanDemo.Production`.
7. **AC7:** `LoanDemo.Production` compiles, starts cleanly, and shows the `LoanService` business service in `Ens.Director.GetProductionStatus`-style queries.
8. **AC8:** `LoanDemo.REST.Dispatcher` extends `%CSP.REST`, declares `HandleCorsRequest = 1`, and routes `POST /loan/apply` to a handler that creates a `LoanRequest` and submits it to `LoanService` via `Ens.Director::CreateBusinessService`.
9. **AC9:** A web application `/loandemo/api` is created in `%SYS` namespace mapped to `HSCUSTOM`, dispatching to `LoanDemo.REST.Dispatcher`, with unauthenticated access enabled for the demo.

> Note: This story stops at the wiring level. The `LoanService` may stub the response (e.g. echo the request with a placeholder decision/score) — the BPL Process and Operations are scoped to Story 1.2.

## Tasks / Subtasks

- [x] **Task 1: Create message classes** (AC: 4)
  - [x] Create `LoanDemo.Message.LoanRequest` extending `Ens.Request` with properties: `ApplicantName As %String`, `RequestedAmount As %Numeric`, `TaxId As %String`
  - [x] Create `LoanDemo.Message.LoanResponse` extending `Ens.Response` with properties: `ApplicationId As %Integer`, `Decision As %String`, `CreditScore As %Integer`, `Status As %String`, `Message As %String`
  - [x] Create `LoanDemo.Message.CreditCheckRequest` extending `Ens.Request` with property `TaxId As %String`
  - [x] Create `LoanDemo.Message.CreditCheckResponse` extending `Ens.Response` with property `CreditScore As %Integer`
  - [x] Compile each class via `mcp__iris-execute-mcp__compile_objectscript_class` (note: project uses iris-dev-mcp `iris_doc_load` followed by `iris_doc_compile`)

- [x] **Task 2: Create persistent data class** (AC: 5)
  - [x] Create `LoanDemo.Data.LoanApplication` extending `%Persistent` with the architecture-specified schema (ApplicationId %AutoIncrement, ApplicantName %String, RequestedAmount %Numeric, TaxId %String, CreditScore %Integer, Decision %String, CreatedDate %TimeStamp)
  - [x] Compile and verify storage definition is generated

- [x] **Task 3: Create Business Service** (AC: 6)
  - [x] Create `LoanDemo.Service.LoanService` extending `Ens.BusinessService` with `Parameter ADAPTER = "Ens.InboundAdapter"`
  - [x] Implement `OnProcessInput(pInput As LoanDemo.Message.LoanRequest, Output pOutput As LoanDemo.Message.LoanResponse, ByRef pHint As %String) As %Status`
  - [x] In Story 1.1, the OnProcessInput body may stub: build a LoanResponse with `Status="success"`, `Decision="Pending"`, `CreditScore=0`, persist the LoanApplication directly (so AC5 is testable without the BPL), and return `$$$OK`. Story 1.2 will replace this with `SendRequestSync` to the LoanBroker process.
  - [x] Define a target config name (e.g. `LoanService`) for Production registration

- [x] **Task 4: Create REST Dispatcher with CORS** (AC: 1, 2, 3, 8)
  - [x] Create `LoanDemo.REST.Dispatcher` extending `%CSP.REST`
  - [x] Declare `Parameter HandleCorsRequest = 1;`
  - [x] Define `XData UrlMap` with route: `<Route Url="/loan/apply" Method="POST" Call="ApplyLoan"/>`
  - [x] Implement `ClassMethod ApplyLoan() As %Status`:
    - Read `%request.Content` and parse with `##class(%DynamicObject).%FromJSON()`
    - Validate required fields (applicantName, requestedAmount, taxId); on validation failure write JSON error and return 400
    - Build a `LoanDemo.Message.LoanRequest`, populate properties
    - Call `##class(Ens.Director).CreateBusinessService("LoanService", .tService)` and `tService.OnProcessInput(tRequest, .tResponse)`
    - Serialize `tResponse` to a `%DynamicObject` and `WriteJSONFromObject` to `%response`
    - Wrap in Try/Catch, return `%Status`
  - [x] Use the standard %Status pattern (no `Quit tSC` inside Try)

- [x] **Task 5: Create Production class** (AC: 7)
  - [x] Create `LoanDemo.Production` extending `Ens.Production`
  - [x] Define `XData ProductionDefinition` registering `LoanDemo.Service.LoanService` as a Business Service named `LoanService`
  - [x] Compile, then call `##class(Ens.Director).StartProduction("LoanDemo.Production")` via `mcp__iris-dev-mcp__iris_execute_classmethod`
  - [x] Verify status with `Ens.Director::GetProductionStatus`

- [x] **Task 6: Create web application in %SYS** (AC: 9)
  - [x] Use `mcp__iris-admin-mcp__iris_webapp_manage` to create `/loandemo/api` in HSCUSTOM with DispatchClass=`LoanDemo.REST.Dispatcher`, AutheEnabled=96 (password+unauthenticated), MatchRoles=`:%All` per project memory
  - [x] Verify with `mcp__iris-admin-mcp__iris_webapp_get`

- [x] **Task 7: Smoke test via curl/IRIS REST execute** (AC: 1, 2, 3)
  - [x] POST a valid payload through `mcp__iris-data-mcp__iris_rest_manage` (or curl localhost:8880) and confirm 200 with success JSON and a saved LoanApplication row
  - [x] POST a malformed payload and confirm 400 + error JSON
  - [x] OPTIONS preflight returns CORS headers

## Dev Notes

### Source-tree placement
- `src/LoanDemo/Message/{LoanRequest,LoanResponse,CreditCheckRequest,CreditCheckResponse}.cls`
- `src/LoanDemo/Data/LoanApplication.cls`
- `src/LoanDemo/Service/LoanService.cls`
- `src/LoanDemo/REST/Dispatcher.cls`
- `src/LoanDemo/Production.cls`

The project's auto-load (folder trigger) will sync `.cls` files into IRIS, but compile is still explicit — use the iris-dev-mcp tools.

### Compile/load tooling
This project uses the **iris-dev-mcp** server (not iris-execute-mcp). Use:
- `mcp__iris-dev-mcp__iris_doc_load` to load classes
- `mcp__iris-dev-mcp__iris_doc_compile` with flags `bckry` for compilation
- `mcp__iris-dev-mcp__iris_execute_classmethod` for invoking ObjectScript class methods (preferred over `iris_execute_command` which can't use `$$$` macros directly)
- `mcp__iris-data-mcp__iris_rest_manage` to invoke REST endpoints

### Critical conventions (from CLAUDE.md and architecture.md)
- **NO underscores** anywhere in class names, methods, parameters
- Method pattern: `Set tSC = $$$OK` → `Try { ... } Catch ex { Set tSC = ex.AsStatus() }` → `Quit tSC`
- Never `Quit` with arguments inside Try/Catch — set a variable and quit after
- Class size <700 lines (none of these will approach that)
- `Parameter HandleCorsRequest = 1;` is **MANDATORY** on the dispatcher
- JSON field names use `camelCase`; ObjectScript properties use `CamelCase`

### REST request/response shape (from architecture)
**Request:** `{ "applicantName": "string", "requestedAmount": number, "taxId": "string" }`
**Success response:** `{ "status": "success", "applicationId": <num>, "decision": "Pending|Approved|Rejected|Manual Review", "creditScore": <num> }`
**Error response:** `{ "status": "error", "message": "<reason>" }`

### Ens.Director invocation pattern
For Story 1.1 the dispatcher invokes the Business Service synchronously via `Ens.Director::CreateBusinessService`. Story 1.2 will not change the dispatcher — it will swap the body of `LoanService.OnProcessInput` to call the BPL via `SendRequestSync`.

### Project memory — IRIS specifics
- Web app creation must run in `%SYS` namespace via `Security.Applications` API (the iris-admin-mcp wraps this).
- For unauthenticated demo access set `AutheEnabled=96` (password+unauthenticated) and `MatchRoles=:%All`.
- `execute_command` cannot use `$$$` macros directly — call `iris_execute_classmethod` for status-returning calls.
- After recompiling Operation/BPL classes you may need a full Production stop+start (relevant in 1.2, not 1.1).

### Testing standards
Unit tests are scoped to Story 1.4 (DecisionLogicTest). For 1.1, validate via REST smoke test only.

### Project Structure Notes
Aligns with the package structure in architecture.md (Data/Message/Service/Process/Operation/REST/Rule/Test). No structural conflicts.

### References
- [Architecture: REST endpoint, CORS, request/response](_bmad-output/planning-artifacts/architecture.md)
- [Architecture: LoanApplication schema](_bmad-output/planning-artifacts/architecture.md)
- [Architecture: Production component table](_bmad-output/planning-artifacts/architecture.md)
- [PRD: FR7 — REST API receives data](_bmad-output/planning-artifacts/prd.md)
- [CLAUDE.md: ObjectScript conventions and IRIS connection details](CLAUDE.md)
- [Memory: web-app config requires %SYS, AutheEnabled=96](_bmad-output/../.claude/projects/-Users-jbrandt-ready26-loandemo-4a/memory/MEMORY.md)

## Dev Agent Record

### Agent Model Used

claude-opus-4-7 (1M)

### Debug Log References

### Completion Notes List

- All 8 LoanDemo classes compiled cleanly with flags `bckry` (`success: true`).
- Production `LoanDemo.Production` is running in HSCUSTOM (`Ens.Director.GetProductionStatus` returned name=`LoanDemo.Production`, state=1 Running).
- Web app `/loandemo/api` was already present from a prior session; verified via `iris_webapp_get` it has `dispatchClass=LoanDemo.REST.Dispatcher`, `authEnabled=96`, `matchRoles=:%All`, `enabled=true`, `cspZenEnabled=true`, `namespace=HSCUSTOM` — matches AC9 requirements, no changes needed.
- Smoke tests (curl http://localhost:8880 with basic auth `_SYSTEM:_SYSTEM`):
  - Valid POST `{applicantName,requestedAmount,taxId}` → HTTP 200 with `{"status":"success","applicationId":274,"decision":"Pending","creditScore":0,...}`. Verified row persisted via `SELECT FROM LoanDemo_Data.LoanApplication`.
  - Malformed JSON → HTTP 400 with `{"status":"error","message":"Malformed JSON body"}`.
  - Missing required fields → HTTP 400 with `{"status":"error","message":"Missing required field ..."}`.
  - OPTIONS preflight → HTTP 200 with `Access-Control-Allow-Methods: POST`, `Access-Control-Allow-Origin: http://localhost:4200`, `Access-Control-Allow-Credentials: true`.
- Per Story 1.1 scope, `LoanService.OnProcessInput` persists the LoanApplication directly and returns a stub `LoanResponse` (Status=`success`, Decision=`Pending`, CreditScore=0). Story 1.2 will replace this body with `SendRequestSync` to the BPL — the dispatcher → service contract is unchanged so the swap is local to the service.
- Initial dispatcher compile failed once with `#1033: Expected literal` because a dynamic-object literal embedded `$System.Status.GetErrorText(...)` (function call inside `{...}`). Fixed by splitting into `Set tErr = {"status":"error"}` then `Set tErr.message = $System.Status.GetErrorText(tProcessSC)`. All subsequent compiles succeeded.

### File List

- src/LoanDemo/Message/LoanRequest.cls (new)
- src/LoanDemo/Message/LoanResponse.cls (new)
- src/LoanDemo/Message/CreditCheckRequest.cls (new)
- src/LoanDemo/Message/CreditCheckResponse.cls (new)
- src/LoanDemo/Data/LoanApplication.cls (new)
- src/LoanDemo/Service/LoanService.cls (new)
- src/LoanDemo/REST/Dispatcher.cls (new, modified during code review)
- src/LoanDemo/Production.cls (new)

## Code Review Notes

Adversarial Senior Developer review performed 2026-04-28. Three real defects confirmed via live REST exercises against the running production. All HIGH/MEDIUM findings were auto-fixed in `LoanDemo.REST.Dispatcher` and verified with re-run smoke tests. Story now satisfies all acceptance criteria.

### Findings

| # | Severity | File:Line | Description | Resolution |
|---|----------|-----------|-------------|------------|
| 1 | HIGH | `src/LoanDemo/REST/Dispatcher.cls:33-43` | Body type was not validated. A JSON array (e.g. `[1,2,3]`) parsed without error, slipped past the `%Get` calls, and produced a real `LoanApplication` row with junk data (`ApplicantName="1"`, `RequestedAmount=1`, `TaxId="1"`). Reproduced on live endpoint — got HTTP 200 + `applicationId:276`. Violates AC3 (malformed/invalid body must return 400). | Added explicit type guard `If '$IsObject(tJson) || (tJson.%Extends("%Library.DynamicArray"))` before extracting fields. Bogus rows 276, 277 were cleaned from the table. |
| 2 | HIGH | `src/LoanDemo/REST/Dispatcher.cls:68, 85` | Internal error text was leaked verbatim to clients on HTTP 500 — including `$System.Status.GetErrorText` output and `ex.DisplayString()`. Reproduced: a long `applicantName` triggered MAXLEN validation and the response body included internal class+property names like `LoanDemo.Data.LoanApplication:ApplicantName`. CLAUDE.md security guidance: "no leaking of internal errors". | Both 500 paths now return a generic `"Internal server error"` / `"Service unavailable"` JSON message. The detailed status text is logged via `Ens.Util.Log.LogError` for operator diagnosis. The outer `Catch ex` is fixed the same way. |
| 3 | MEDIUM | `src/LoanDemo/REST/Dispatcher.cls:47` | `requestedAmount` was only checked for empty/null; values of `0` and negative numbers were accepted as valid loans. Confirmed via live test: `{"requestedAmount":0,...}` returned HTTP 200 with `applicationId:277`. | Added `If '$IsValidNum(tRequestedAmount) || (tRequestedAmount <= 0)` guard returning a 400 with a clear message. |
| 4 | MEDIUM | `src/LoanDemo/REST/Dispatcher.cls:47` | No length validation at the API boundary — oversized inputs propagated to `%Save()` and surfaced as a 500 (compounding finding 2). | Added `$Length(tApplicantName) > 200` and `$Length(tTaxId) > 50` guards mirroring the storage MAXLENs, returning 400 with a descriptive message. |
| 5 | LOW | `src/LoanDemo/Data/LoanApplication.cls:18` | `Index ApplicationIdIdx On ApplicationId [ Unique ]` is redundant for an `%AutoIncrement` ID property; the system already maintains uniqueness on the ID. Cosmetic, no behavior impact. | Left as-is; no breakage and removing it would alter the saved storage map. |
| 6 | LOW | `src/LoanDemo/Service/LoanService.cls:16` | Service explicitly sets `tApp.CreatedDate = $ZDateTime($Horolog,3)` even though `LoanApplication.CreatedDate` already has an `InitialExpression` doing the same. Duplication only. | Left as-is; harmless and Story 1.2 will move persistence out of the service. |
| 7 | LOW | `src/LoanDemo/Message/*.cls` | All four message classes carry hand-written `Storage Default` blocks with arbitrary `<Subscript>` names. `Ens.Request`/`Ens.Response` would auto-generate compatible storage. Compiles cleanly, so no functional defect — flagged for future cleanup. | Left as-is. |
| 8 | LOW | `src/LoanDemo/Production.cls:9` | `<Item ... Comment="">` for LoanService is empty; minor documentation gap. | Left as-is. |

### Auto-Fix Summary

- **HIGH:** 2 found, 2 resolved
- **MEDIUM:** 2 found, 2 resolved
- **LOW:** 4 found, 0 resolved (cosmetic only, accepted as-is)

### Re-run Smoke Tests (post-fix)

| Scenario | Expected | Result |
|----------|----------|--------|
| Valid POST | 200 + success JSON | 200, `applicationId:278` |
| Malformed JSON | 400 + error JSON | 400, "Malformed JSON body" |
| Missing required fields | 400 + error JSON | 400, "Missing required field..." |
| JSON array body (regression test for finding 1) | 400 + error JSON | 400, "Request body must be a JSON object" |
| `requestedAmount: 0` (regression test for finding 3) | 400 + error JSON | 400, "requestedAmount must be a positive number" |
| `requestedAmount: -100` | 400 + error JSON | 400, "requestedAmount must be a positive number" |
| Oversized `applicantName` (regression test for finding 2 + 4) | 400 + generic error JSON, no internal leak | 400, "applicantName exceeds maximum length of 200" |
| OPTIONS preflight | 200 + Access-Control-Allow-* headers | 200, headers present |

### Acceptance Criteria Verdict

All AC1-AC9 satisfied. Production state confirmed `Running` with `LoanService` registered (`Ens.Director.GetProductionStatus` returned name=`LoanDemo.Production`, state=1). Web app `/loandemo/api` confirmed in HSCUSTOM with `dispatchClass=LoanDemo.REST.Dispatcher`, `authEnabled=96`, `matchRoles=:%All`.
