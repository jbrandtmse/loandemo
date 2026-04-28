# Story 1.2: Loan Processing Logic

Status: done

## Story

As a system,
I want to process loan applications through a BPL workflow that checks credit scores and applies decision rules,
so that applicants receive accurate loan decisions (Approved/Rejected/Manual Review).

## Acceptance Criteria

1. **AC1:** `LoanDemo.Rule.DecisionLogic` exposes a class method `GetDecision(pCreditScore As %Integer) As %String` that returns: `"Approved"` for scores > 700, `"Rejected"` for scores < 500, and `"Manual Review"` for scores between 500 and 700 (inclusive).
2. **AC2:** `LoanDemo.Operation.CreditBureau` extends `Ens.BusinessOperation`, implements `OnMessage(pRequest As LoanDemo.Message.CreditCheckRequest, Output pResponse As LoanDemo.Message.CreditCheckResponse) As %Status`, and returns a deterministic-but-randomized credit score in the range 300–850 derived from the TaxId.
3. **AC3:** `LoanDemo.Operation.LoanPersistence` extends `Ens.BusinessOperation`, implements `OnMessage(pRequest As LoanDemo.Message.LoanRequest, Output pResponse As LoanDemo.Message.LoanResponse) As %Status`, and persists a `LoanDemo.Data.LoanApplication` row populated from the request, returning the new ApplicationId on the response.
4. **AC4:** `LoanDemo.Process.LoanBroker` is a BPL Business Process (extends `Ens.BusinessProcessBPL`) that on receipt of a `LoanRequest`: (a) sends sync to `LoanPersistence` to save the application, (b) sends sync to `CreditBureau` to retrieve a credit score, (c) calls `DecisionLogic.GetDecision` against the score, (d) updates the persisted row with the score and decision, and (e) returns a populated `LoanResponse` containing applicationId, decision, creditScore, status="success".
5. **AC5:** `LoanDemo.Service.LoanService.OnProcessInput` is updated to invoke the LoanBroker process via `SendRequestSync(..ConfigName, pInput, .pOutput, ...)` (target name `"LoanBroker"`) instead of persisting directly. The dispatcher/REST contract is unchanged.
6. **AC6:** `LoanDemo.Production` registers `LoanBroker` (BusinessProcess), `CreditBureau` (BusinessOperation), and `LoanPersistence` (BusinessOperation) alongside `LoanService`. The Production restarts cleanly and `Ens.Director.GetProductionStatus` shows all four items running.
7. **AC7:** End-to-end smoke test: POST a valid payload to `/loandemo/api/loan/apply` returns HTTP 200 with `decision` ∈ {Approved, Rejected, Manual Review} and a populated `creditScore` between 300 and 850, and a row exists in `LoanDemo.Data.LoanApplication` with the same ApplicationId, decision, and credit score.
8. **AC8:** Decision boundaries verified: a TaxId chosen to seed a score of 750 yields "Approved"; 450 yields "Rejected"; 600 yields "Manual Review". (Achievable by allowing the dev to override the score via a back-door class method `GetDecision(score)` invocation rather than driving end-to-end — formal unit tests are scoped to Story 1.4.)
9. **AC9:** Production message trace shows the message flow Service → Process → CreditBureau → LoanPersistence → Process → Service for each request. (Visible in IRIS Management Portal — formal portal validation is Story 1.4.)

## Tasks / Subtasks

- [x] **Task 1: Decision logic** (AC: 1)
  - [x] Create `src/LoanDemo/Rule/DecisionLogic.cls` extending `%RegisteredObject`
  - [x] Implement `ClassMethod GetDecision(pCreditScore As %Integer) As %String` with the threshold rules. Use the `Set tDecision = ""; Try { ... } Catch ex { ... }; Quit tDecision` pattern (or simpler — return value, not %Status). Document the boundary semantics inline.
  - [x] Compile via `mcp__iris-dev-mcp__iris_doc_compile` flags `bckry`

- [x] **Task 2: Credit Bureau Operation** (AC: 2)
  - [x] Create `src/LoanDemo/Operation/CreditBureau.cls` extending `Ens.BusinessOperation`
  - [x] No adapter needed (in-process simulation). Set `Parameter INVOCATION = "Queue"`.
  - [x] Implement `Method OnMessage(pRequest As LoanDemo.Message.CreditCheckRequest, Output pResponse As LoanDemo.Message.CreditCheckResponse) As %Status` (named `CheckCredit` and routed via MessageMap)
  - [x] Score generation: use `$ZCRC(pRequest.TaxId, 7)` modulo 551 + 300, giving a deterministic score in [300, 850]. Per project memory, **do not** use `$ZHash` (causes `<SYNTAX>`). Use `$ZCRC` with mode 7 instead.
  - [x] Define MessageMap to route `LoanDemo.Message.CreditCheckRequest` → `CheckCredit`
  - [x] Compile

- [x] **Task 3: Loan Persistence Operation** (AC: 3)
  - [x] Create `src/LoanDemo/Operation/LoanPersistence.cls` extending `Ens.BusinessOperation`
  - [x] Implement `SaveLoan(pRequest As LoanDemo.Message.LoanRequest, pResponse As LoanDemo.Message.LoanResponse)` that creates a new `LoanDemo.Data.LoanApplication`, populates name/amount/taxId/createdDate, calls `%Save()`, sets `pResponse.ApplicationId` to the new ID, and returns `tSC`.
  - [x] Added second message type `LoanDemo.Message.LoanUpdateRequest` (Ens.Request) carrying ApplicationId, CreditScore, Decision; routed to `UpdateLoan` via MessageMap. UpdateLoan opens the existing row via the unique index `ApplicationIdIdxOpen` (because `%ID` ≠ `ApplicationId` — the AutoIncrement counter is independent from the ROWID counter).
  - [x] Compile

- [x] **Task 4: BPL Business Process** (AC: 4, 9)
  - [x] Create `src/LoanDemo/Process/LoanBroker.cls` extending `Ens.BusinessProcessBPL`
  - [x] Define `Parameter REQUESTCLASSLIST = "LoanDemo.Message.LoanRequest"` and `Parameter RESPONSECLASSLIST = "LoanDemo.Message.LoanResponse"`
  - [x] Define `XData BPL` with the workflow: `SaveInitial` (per-property assigns into callrequest, capture ApplicationId) → `CreditCheck` (assign TaxId, capture CreditScore) → `EvaluateDecision` (assign context.Decision via DecisionLogic.GetDecision) → `Update` (assign ApplicationId/CreditScore/Decision into a LoanUpdateRequest) → `BuildResponse`/`SetDecision`/`SetScore`/`SetStatus` (populate the response)
  - [x] Compile (Production fully stopped + restarted, not UpdateProduction).

- [x] **Task 5: Update Business Service** (AC: 5)
  - [x] Modify `src/LoanDemo/Service/LoanService.cls` `OnProcessInput` to call `Set tSC = ..SendRequestSync("LoanBroker", pInput, .pOutput)`. Direct LoanApplication persistence and stub LoanResponse from Story 1.1 removed.
  - [x] Reload + recompile

- [x] **Task 6: Production wiring** (AC: 6)
  - [x] Update `src/LoanDemo/Production.cls` `XData ProductionDefinition` to add: `LoanBroker`, `CreditBureau`, `LoanPersistence`.
  - [x] Reload + recompile
  - [x] **Restart Production** via `Ens.Director::StopProduction(10,1)` then `Ens.Director::StartProduction("LoanDemo.Production")`.
  - [x] Verified all 4 components running via `iris_production_status` (state: Running, all four items enabled).

- [x] **Task 7: End-to-end smoke test** (AC: 7, 8)
  - [x] POSTed valid payload to `/loandemo/api/loan/apply` → HTTP 200, `{"status":"success","applicationId":282,"decision":"Rejected","creditScore":420}`. Multiple variants exercised all three decisions (Approved 786/774, Rejected 366/420/461/472/395, Manual Review 690/550).
  - [x] SQL-verified the row in `LoanDemo.Data.LoanApplication` (ApplicationId=282, CreditScore=420, Decision=Rejected) matches the response.
  - [x] Direct invocation: `iris_execute_classmethod` `LoanDemo.Rule.DecisionLogic::GetDecision`(750)→"Approved", (450)→"Rejected", (600)→"Manual Review". All three pass.
  - [x] Inspected Production message trace via `iris_production_messages` for sessionId 922909 — confirmed full Service → Process → LoanPersistence (SaveInitial) → Process → CreditBureau → Process → LoanPersistence (Update) → Process → Service flow with 8 messages, all status=9 (OK).

## Dev Notes

### Source-tree placement
- `src/LoanDemo/Rule/DecisionLogic.cls`
- `src/LoanDemo/Operation/CreditBureau.cls`
- `src/LoanDemo/Operation/LoanPersistence.cls`
- `src/LoanDemo/Process/LoanBroker.cls`
- `src/LoanDemo/Message/LoanUpdateRequest.cls` (new)
- `src/LoanDemo/Service/LoanService.cls` (modified)
- `src/LoanDemo/Production.cls` (modified)

### Critical project-memory rules
- **Use `$ZCRC(s, 7)` not `$ZHash(s)`.** $ZHash returns binary and throws `<SYNTAX>` when used with `#` modulo. The deterministic score formula is `(($ZCRC(pRequest.TaxId, 7) # 551) + 300)` for [300, 850].
- **Restart Production after recompiling BPL/Operation classes.** `UpdateProduction` does not pick up new method bodies — running jobs log "continuing to run using code from previous version" and use stale logic until restart. If `RestartProduction` returns `ErrProductionNotQuiescent`, use `StopProduction(10, 1)` then `StartProduction`.
- `execute_command` cannot use `$$$` macros directly — use `iris_execute_classmethod` for status calls.

### BPL visualization tip
This BPL is the demo "wow factor" — keep activity names human-readable: `SaveInitial`, `CreditCheck`, `EvaluateDecision`, `Update`, `BuildResponse`. The Management Portal trace will display these.

### Story 1.1 contract preservation
The dispatcher (`LoanDemo.REST.Dispatcher`) and the request/response shape remain unchanged. Only `LoanService.OnProcessInput` body changes — from a direct persistence stub to `SendRequestSync` to LoanBroker. The signature `OnProcessInput(pInput As LoanDemo.Message.LoanRequest, Output pOutput As LoanDemo.Message.LoanResponse, ByRef pHint As %String) As %Status` stays identical.

### Boundary semantics for DecisionLogic
- `score > 700` → Approved
- `score < 500` → Rejected
- `500 <= score <= 700` → Manual Review

Note `score == 700` is **Manual Review** (because the Approved condition is strictly `> 700`); `score == 500` is **Manual Review** (because Rejected is strictly `< 500`). Document this in code comment so reviewers know it's intentional.

### Testing standards
Formal unit tests for DecisionLogic are scoped to Story 1.4. For 1.2, validate via:
- Direct `iris_execute_classmethod` invocations of `LoanDemo.Rule.DecisionLogic::GetDecision`
- End-to-end REST smoke test with at least one TaxId of each decision class

### References
- [Architecture: BPL Business Process pattern](_bmad-output/planning-artifacts/architecture.md)
- [Architecture: Production component table](_bmad-output/planning-artifacts/architecture.md)
- [Architecture: Decision rules](_bmad-output/planning-artifacts/architecture.md)
- [Memory: $ZCRC vs $ZHash](_bmad-output/../.claude/projects/-Users-jbrandt-ready26-loandemo-4a/memory/iris_zhash_vs_zcrc.md)
- [Memory: restart production after recompile](_bmad-output/../.claude/projects/-Users-jbrandt-ready26-loandemo-4a/memory/iris_op_restart_after_recompile.md)
- [Story 1.1 file list](_bmad-output/implementation-artifacts/1-1-iris-backend-foundation.md)

## Dev Agent Record

### Agent Model Used

claude-opus-4-7 (1M)

### Debug Log References

- First end-to-end smoke test failed with `LoanApplication not found for ID <id>` and `No MessageBody classname for MessageHeader`. Root cause: (1) `%OpenId` on `LoanDemo.Data.LoanApplication` opens by ROWID, but the request carried `ApplicationId` (the AutoIncrement property value), and the AutoIncrement counter (`^LoanDemo.Data.LoanApplicationC`) is independent from the ROWID counter — they had drifted out of sync from prior data. Fix: open via the unique index `ApplicationIdIdxOpen(pRequest.ApplicationId)`. (2) The original BPL used `<assign property="callrequest" value="request" action="set"/>` to clone the LoanRequest into the SaveInitial call request, which produced an empty MessageBodyClassName on the outbound header. Fix: replaced the bulk OREF assign with three per-property assigns (ApplicantName, RequestedAmount, TaxId), so the BPL instantiates a fresh `LoanDemo.Message.LoanRequest` for the call.

### Completion Notes List

- All 7 tasks completed. End-to-end smoke test returns real decisions (Approved/Rejected/Manual Review) with credit scores in [300, 850]. Persisted rows match. Boundary class-method tests at 750/450/600 pass. 8-message trace confirmed via `iris_production_messages` for one full session.
- Production was fully stopped and restarted (StopProduction(10,1) + StartProduction) after each recompile, per project memory.
- The BPL uses per-property assigns into `callrequest` rather than a single OREF assign — see Debug Log References for why.
- LoanPersistence opens existing rows via `ApplicationIdIdxOpen` (not `%OpenId`) because `%ID` ≠ `ApplicationId` in the existing data.

### File List

- `src/LoanDemo/Rule/DecisionLogic.cls` (new)
- `src/LoanDemo/Operation/CreditBureau.cls` (new)
- `src/LoanDemo/Operation/LoanPersistence.cls` (new)
- `src/LoanDemo/Process/LoanBroker.cls` (new)
- `src/LoanDemo/Message/LoanUpdateRequest.cls` (new)
- `src/LoanDemo/Service/LoanService.cls` (modified — body replaced with SendRequestSync to LoanBroker)
- `src/LoanDemo/Production.cls` (modified — added LoanBroker, CreditBureau, LoanPersistence items)

## Code Review Notes

Adversarial Senior Developer review performed on 2026-04-28 by `code-reviewer-1-2`.

### Verification Summary

- **Production state:** `Ens.Director.GetProductionStatus` returns `state=Running` with all 4 items enabled (LoanService, LoanBroker, CreditBureau, LoanPersistence). AC6 verified.
- **DecisionLogic boundaries (AC1, AC8):** Direct `iris_execute_classmethod` invocations confirmed: 700→Manual Review, 500→Manual Review, 701→Approved, 499→Rejected, 750→Approved, 450→Rejected, 600→Manual Review. All seven boundary cases pass.
- **CreditBureau formula (AC2):** Formula `($ZCRC(taxId, 7) # 551) + 300` mathematically yields [300, 850]. `$ZCRC` mode 7 returns 32-bit hash; modulo 551 distributes uniformly. Empirical sample of 10,000 random TaxIds: ~27% Approved, ~36% Rejected, ~37% Manual Review. `$ZCRC` is used (not `$ZHash`), per project memory. No hard-coded scores.
- **LoanPersistence safety (AC3):** Both `SaveLoan` and `UpdateLoan` Try/Catch wrap `%Save()`, check `$$$ISERR(tSaveSC)` and propagate via `tSC` (not silently swallowed). `UpdateLoan` opens via `ApplicationIdIdxOpen(pRequest.ApplicationId)`, not `%OpenId`, correctly addressing the `%ID` ≠ `ApplicationId` divergence. `'$IsObject(tApp)` guard returns a useful error.
- **BPL workflow (AC4, AC9):** SaveInitial → CreditCheck → EvaluateDecision → Update → BuildResponse/SetDecision/SetScore/SetStatus. Per-property `<assign>` into `callrequest` (not bulk OREF assign — fixed in dev per Debug Log). Fresh end-to-end POST yielded sessionId 923222 with the expected 8-message trace: Service→Broker (LoanRequest) → Broker→Persistence (LoanRequest) → Persistence→Broker (LoanResponse) → Broker→CreditBureau (CreditCheckRequest) → CreditBureau→Broker (CreditCheckResponse) → Broker→Persistence (LoanUpdateRequest) → Persistence→Broker (Ens.Response) → Broker→Service (LoanResponse). All 8 messages status=9.
- **LoanService delegation (AC5):** `OnProcessInput` body is exactly `..SendRequestSync("LoanBroker", pInput, .pOutput)` inside a Try/Catch. No leftover Story 1.1 stub persistence. Signature unchanged. `%Status` pattern preserved with `Quit tSC` outside the Try.
- **Production wiring (AC6):** Production.cls registers all 4 items. ConfigName `"LoanBroker"` matches what `LoanService` and the BPL `<call target="...">` look up.
- **Naming conventions:** Grep confirmed no underscores in Method/ClassMethod/Property/Parameter/Class/Index identifiers across all reviewed files. p-prefix params (`pCreditScore`, `pRequest`, etc.) and t-prefix locals (`tSC`, `tApp`, `tSaveSC`) consistent. `%Status` returns with `Quit tSC` outside Try.
- **Class size:** All classes well under 700 lines (largest: `LoanBroker.cls` at 76, `LoanPersistence.cls` at 72).
- **Concurrency:** Sync calls (`async='0'`) ensure SaveInitial commits before Update opens the row — no race exposure.
- **End-to-end smoke (AC7):** `POST /loandemo/api/loan/apply` with `{applicantName: "Reviewer Test", requestedAmount: 50000, taxId: "abc"}` returned HTTP 200 `{"status":"success","applicationId":291,"decision":"Approved","creditScore":737}`. SQL row 291 matches: `(291, "Reviewer Test", 737, "Approved")`. A second POST (taxId "trace-test-1") returned `{applicationId:292, decision:"Rejected", creditScore:392}` with the matching SQL row and full 8-message trace as above.

### Findings

| # | Severity | File:Line | Description | Resolution |
|---|----------|-----------|-------------|------------|
| 1 | LOW | `Rule/DecisionLogic.cls:11-26` | Try/Catch in `GetDecision` is dead code — the only operations are integer comparisons against an `%Integer` parameter and string assignments, none of which can throw. The Catch returns `"Manual Review"` defensively, which is reasonable, so the construct does no harm. | Not fixed. Auto-fix policy is HIGH/MEDIUM only; defensive Try/Catch matches the project pattern. |
| 2 | LOW | `Operation/LoanPersistence.cls:7-33` | `SaveLoan` reuses `LoanDemo.Message.LoanResponse` (the outbound REST-facing contract) as the BPL `callresponse` for the initial save acknowledgment. A dedicated `LoanSaveResponse` (Ens.Response) would keep message ontology cleaner — the current shape forces SaveLoan to populate `Status`/`Decision`/`CreditScore` fields the BPL then overwrites at the final BuildResponse stage. | Not fixed. Working as designed; introducing a new message class would touch the BPL's request type and is out of scope for a non-defect refactor. |

### Severity Counts

- HIGH: 0
- MEDIUM: 0
- LOW: 2
- Auto-resolved: 0 (LOW issues are stylistic and out of scope for the HIGH/MEDIUM auto-fix policy)

### Acceptance Criteria Coverage

All AC1–AC9 demonstrably satisfied. AC8 verified by direct class-method invocation at the 750/450/600 boundaries (and confirmed at the strict edges 700/701/500/499). AC9 verified by inspecting the live 8-message session 923222.

### Final Status

`done` — production running clean, all ACs green, no HIGH/MEDIUM defects.
