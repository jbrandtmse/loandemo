# Smart Loan Broker — Presenter Walkthrough

A one-page cheat sheet for demoing the loan workflow end-to-end and showing the message trace in the IRIS Management Portal.

## 1. Pre-flight check (60 seconds before the demo)

| Check | Expected | How |
|---|---|---|
| IRIS Production running | `LoanDemo.Production` state = Running, 4 items enabled (LoanService, LoanBroker, CreditBureau, LoanPersistence) | Portal: *Interoperability → Configure → Production* |
| Web app live | `/loandemo/api` dispatches to `LoanDemo.REST.Dispatcher` in HSCUSTOM | Portal: *System Administration → Security → Applications → Web Applications* |
| Frontend up | `http://localhost:4200/` returns the Smart Loan Broker form | `cd frontend && npm start` (or `ng serve`) |
| Smoke test | A POST returns `{ "decision": "Approved\|Rejected\|Manual Review", "creditScore": 300–850 }` | `curl -u _SYSTEM:_SYSTEM -X POST -H "Content-Type: application/json" -d '{"applicantName":"Demo","requestedAmount":15000,"taxId":"123-45-6789"}' http://localhost:8880/loandemo/api/loan/apply` |

## 2. The applicant flow (the "Sam" story)

1. **Open** `http://localhost:4200/` in the browser.
2. **Fill in** the form: any name (≥ 2 chars), any positive amount, a Tax ID like `123-45-6789` or `987-65-4321`.
3. **Click Submit.** The button disables, a spinner runs, and within a second the result panel renders with the decision (color-coded), the credit score, and the application ID.
4. **Click "Submit another application"** to reset and try a different Tax ID — the score is deterministic per Tax ID, so the same Tax ID always returns the same score.

Three Tax IDs guaranteed to hit each branch (deterministic via `$ZCRC`):
- `Decision: Approved` → score > 700
- `Decision: Rejected` → score < 500
- `Decision: Manual Review` → 500–700 inclusive

(Run a few in advance and remember the ones that hit each branch.)

## 3. The "wow moment" — workflow trace

1. Open the **Management Portal** at `http://localhost:8880/csp/sys/UtilHome.csp` and log in as `_SYSTEM` / `_SYSTEM`.
2. Switch to **HSCUSTOM** namespace (top-right namespace selector).
3. Navigate to **Interoperability → View → Messages** — direct URL: `http://localhost:8880/csp/healthshare/hscustom/EnsPortal.MessageViewer.zen`.
4. **Filter** Source = `LoanBroker` (or set Date range to "Last 5 minutes"). Click *Search*.
5. Click the most recent session in the results.
6. The trace panel shows the message flow:
   - `LoanService` → `LoanBroker` (LoanRequest in)
   - `LoanBroker` → `LoanPersistence` (initial save — captures ApplicationId)
   - `LoanBroker` → `CreditBureau` (credit check — returns score)
   - `LoanBroker` → `LoanPersistence` (update with score + decision)
   - `LoanBroker` → `LoanService` (LoanResponse out)
7. **Click any message** to inspect the header (timestamps, source/target config name, message body class) and the body (property values).

This is the architectural payoff: a single REST call decomposed into a fully traceable, replayable, observable workflow.

## 4. Talking points

- **Decoupling**: the Angular SPA never knows about the BPL or Operations — it just hits a REST endpoint.
- **Observability**: every internal call is persisted (`Ens.MessageHeader`) and replayable.
- **Testability**: `DecisionLogic` is a pure rule class with no dependency on the production framework — see `LoanDemo.Test.DecisionLogicTest` (5/5 pass).
- **Determinism**: `CreditBureau` uses `$ZCRC` on the Tax ID, so the same input always yields the same output — perfect for live demos with no flakiness.

## 5. Reset state for next demo

```objectscript
// Truncate stored applications:
Do ##class(LoanDemo.Data.LoanApplication).%KillExtent()

// Restart the production cleanly:
Do ##class(Ens.Director).StopProduction(10, 1)
Do ##class(Ens.Director).StartProduction("LoanDemo.Production")
```

(Or via MCP: `mcp__iris-dev-mcp__iris_execute_classmethod` with the same calls.)

## 6. Running the unit tests

```objectscript
// All 5 DecisionLogic tests, expected: 5 passed, 0 failed
Do ##class(%UnitTest.Manager).RunTest("LoanDemo.Test.DecisionLogicTest")
```

Or via MCP: `mcp__iris-dev-mcp__iris_execute_tests` with `target="LoanDemo.Test.DecisionLogicTest", level="class"`.
