# LoanDemo

A Smart Loan Broker demo built end-to-end with the **BMAD Method** during the
**"Agentic Engineering Live on Stage"** session at the **InterSystems READY 2026**
conference on **Tuesday, April 28, 2026**.

The demo shows an Angular 21 single-page application submitting loan applications
through a **REST API** to an **InterSystems IRIS** Interoperability Production. The
Production decomposes each request into a visible **BPL workflow** that persists
the application, calls a (simulated) Credit Bureau, applies decision rules, and
returns one of three outcomes — **Approved**, **Rejected**, or **Manual Review** —
to the user.

The companion talk slides are in this repository at the project root:

- [Agentic Engineering Live on Stage using the BMAD method.pptx](Agentic%20Engineering%20Live%20on%20Stage%20using%20the%20BMAD%20method.pptx)

---

## What you get

| Layer | Technology | Path |
|---|---|---|
| Frontend SPA | Angular 21 + Angular Material | [`frontend/`](frontend/) |
| REST dispatcher | `%CSP.REST` with CORS | [`src/LoanDemo/REST/Dispatcher.cls`](src/LoanDemo/REST/Dispatcher.cls) |
| Business Service | `Ens.BusinessService` | [`src/LoanDemo/Service/LoanService.cls`](src/LoanDemo/Service/LoanService.cls) |
| BPL Process | `Ens.BusinessProcessBPL` (visible in Management Portal) | [`src/LoanDemo/Process/LoanBroker.cls`](src/LoanDemo/Process/LoanBroker.cls) |
| Operations | Credit Bureau (simulated) + Persistence | [`src/LoanDemo/Operation/`](src/LoanDemo/Operation/) |
| Decision Rule | Pure ObjectScript class — testable in isolation | [`src/LoanDemo/Rule/DecisionLogic.cls`](src/LoanDemo/Rule/DecisionLogic.cls) |
| Persistent class | `LoanDemo.Data.LoanApplication` | [`src/LoanDemo/Data/LoanApplication.cls`](src/LoanDemo/Data/LoanApplication.cls) |
| Installer | Idempotent web-app setup | [`src/LoanDemo/Installer.cls`](src/LoanDemo/Installer.cls) |
| Unit tests | `%UnitTest` for the decision rule | [`src/LoanDemo/Test/DecisionLogicTest.cls`](src/LoanDemo/Test/DecisionLogicTest.cls) |

---

## BMAD planning artifacts

The entire backlog was generated from a single product brief using the BMAD Method.
Read these in order to follow how requirements flowed into stories:

1. [Product Brief](_bmad-output/planning-artifacts/product-brief-LoanDemo-2026-01-19.md)
2. [Product Requirements Document (PRD)](_bmad-output/planning-artifacts/prd.md)
3. [Architecture Decision Document](_bmad-output/planning-artifacts/architecture.md)
4. [Epic Breakdown](_bmad-output/planning-artifacts/epics.md)

Implementation stories (each with acceptance criteria, dev notes, completion notes,
and code-review findings):

- [Story 1.1 — IRIS Backend Foundation](_bmad-output/implementation-artifacts/1-1-iris-backend-foundation.md)
- [Story 1.2 — Loan Processing Logic](_bmad-output/implementation-artifacts/1-2-loan-processing-logic.md)
- [Story 1.3 — Angular Frontend](_bmad-output/implementation-artifacts/1-3-angular-frontend.md)
- [Story 1.4 — Visualization & Testing](_bmad-output/implementation-artifacts/1-4-visualization-and-testing.md)

A [presenter cheat sheet](docs/demo-walkthrough.md) covers the runtime flow and
the IRIS Management Portal trace navigation.

---

## About the BMAD Method

The **BMAD Method** (Brian Madison Agentic Development) is a workflow framework for
running an agentic software-engineering pipeline — Product Brief → PRD → Architecture
→ Epics → Stories → Dev → Code Review → QA — with each phase optionally driven by
specialized AI agents.

- **Repository:** https://github.com/bmad-code-org/BMAD-METHOD

### Installing BMAD

> **This repo already ships with BMAD pre-installed** under [`_bmad/`](_bmad/),
> with agent registrations for **Claude Code** in [`.claude/`](.claude/) plus
> mirrored configs for [`.cline/`](.clinerules/) and [`.roo/`](.roo/). If you
> use **Claude Code** there is **nothing to install** — the slash commands
> (`/bmad-bmm-create-story`, `/bmad-bmm-dev-story`, `/bmad-bmm-code-review`,
> `/bmad-epic-cycle`, etc.) are picked up automatically when you open the
> project. You only need the steps below if you want to wire BMAD up for a
> different agent (Cursor, Windsurf, plain CLI, etc.) or refresh to a newer
> BMAD release.

BMAD installs into a target project as a self-contained `_bmad/` directory plus
configuration. The bundled installer is invoked from the BMAD repo:

```bash
# Clone the BMAD method
git clone https://github.com/bmad-code-org/BMAD-METHOD.git
cd BMAD-METHOD

# Run the installer against your project root
node tools/installer/install.js --target /path/to/your/project
```

After install, your project gets:

- `_bmad/` — workflow engine, agent definitions, slash-command templates
- `_bmad-output/` — where planning and implementation artifacts are written
- `.claude/agents/` (and equivalents for `.cline/`, `.roo/`) — IDE-specific agent
  registrations

This repo was bootstrapped against **BMAD v6.0.0-Beta.8** with the **BMM** module
(Brian Madison Method) for the planning and implementation workflows, and the
**TestArch** module for QA.

For the slash commands used in this project, see `.claude/commands/` (or run
`/bmad-help` inside Claude Code).

---

## Prerequisites

- **InterSystems IRIS** with the **HSCUSTOM** namespace available
  - The demo was built against IRIS for Health 2024.x; any modern IRIS with
    Interoperability features should work
  - Server URL: `http://localhost:8880` (the default for `localhost-healthshare`)
  - Credentials: `_SYSTEM` / `_SYSTEM` (default — change for non-demo use)
- **Node.js 20+** and **npm** for the Angular frontend
- A REST client (curl) or a browser for end-to-end testing

---

## Quick start

> All commands assume the project root `/path/to/loandemo`. The IRIS commands can
> be issued either from the IRIS Terminal in the **HSCUSTOM** namespace, or via
> the Atelier API / VS Code ObjectScript extension / iris-dev-mcp tooling.

### 1. Clone the repository

```bash
git clone https://github.com/jbrandtmse/loandemo.git
cd loandemo
```

### 2. Import and compile the ObjectScript classes

The `src/LoanDemo/` directory mirrors the IRIS class hierarchy. Use any of these
options to load and compile:

**Option A — VS Code with InterSystems ObjectScript extension**

1. Open the folder in VS Code.
2. The extension picks up the `loandemo.code-workspace` settings and the
   `objectscript.conn` block in `.vscode/settings.json` (point it at your IRIS
   server / HSCUSTOM namespace).
3. Right-click the `src/LoanDemo` folder → **Import and Compile** with flags
   `bckry`.

**Option B — IRIS Terminal**

```objectscript
// In the HSCUSTOM namespace:
Set tSC = $System.OBJ.ImportDir("/path/to/loandemo/src/LoanDemo", "*.cls", "bckry", , 1)
Write $System.Status.GetErrorText(tSC)
```

**Option C — REST (Atelier API) or the iris-dev-mcp tools**

```bash
# With iris-dev-mcp configured against HSCUSTOM:
mcp__iris-dev-mcp__iris_doc_load \
    path="/path/to/loandemo/src/**/*.cls" \
    compile=true \
    flags="bckry" \
    namespace="HSCUSTOM"
```

You should now see the following classes in HSCUSTOM:

- `LoanDemo.Data.LoanApplication`
- `LoanDemo.Message.{LoanRequest,LoanResponse,CreditCheckRequest,CreditCheckResponse,LoanUpdateRequest}`
- `LoanDemo.Service.LoanService`
- `LoanDemo.Process.LoanBroker`
- `LoanDemo.Operation.{CreditBureau,LoanPersistence}`
- `LoanDemo.Rule.DecisionLogic`
- `LoanDemo.REST.Dispatcher`
- `LoanDemo.Production`
- `LoanDemo.Installer`
- `LoanDemo.Test.DecisionLogicTest`

### 3. Create the REST web application

The installer is idempotent and self-contained — it switches into `%SYS`
internally, creates (or updates) `/loandemo/api`, and configures the dispatch
class plus authentication settings the demo expects.

```objectscript
// In any namespace:
Set tSC = ##class(LoanDemo.Installer).Setup()
Write $System.Status.GetErrorText(tSC)
```

Or via MCP:

```bash
mcp__iris-dev-mcp__iris_execute_classmethod \
    className="LoanDemo.Installer" \
    methodName="Setup"
```

Verify with:

```objectscript
Write ##class(LoanDemo.Installer).Status()
```

You should get a JSON line like:

```json
{
  "name": "/loandemo/api",
  "installed": 1,
  "dispatchClass": "LoanDemo.REST.Dispatcher",
  "namespace": "HSCUSTOM",
  "autheEnabled": 96,
  "matchRoles": ":%All",
  "enabled": 1
}
```

`autheEnabled: 96` means **password + unauthenticated** access (suitable for the
live demo; tighten before any non-demo deployment). `matchRoles: ":%All"` grants
the application all roles for the duration of a request.

To remove later:

```objectscript
Do ##class(LoanDemo.Installer).Uninstall()
```

### 4. Start the Interoperability Production

```objectscript
Do ##class(Ens.Director).StartProduction("LoanDemo.Production")

// Verify:
Write ##class(Ens.Director).GetProductionStatus()  // 1 = Running
```

You should see four items running:

| Item | Class | Role |
|---|---|---|
| `LoanService` | `LoanDemo.Service.LoanService` | Receives the LoanRequest from the dispatcher |
| `LoanBroker` | `LoanDemo.Process.LoanBroker` | BPL orchestration |
| `CreditBureau` | `LoanDemo.Operation.CreditBureau` | Simulated credit-score lookup |
| `LoanPersistence` | `LoanDemo.Operation.LoanPersistence` | Saves and updates the application row |

> **If you recompile any BPL or Operation class, fully stop and start the Production**
> — `UpdateProduction` does not pick up new method bodies. Use:
>
> ```objectscript
> Do ##class(Ens.Director).StopProduction(10, 1)
> Do ##class(Ens.Director).StartProduction("LoanDemo.Production")
> ```

### 5. Smoke-test the REST endpoint

```bash
curl -u _SYSTEM:_SYSTEM \
     -X POST \
     -H "Content-Type: application/json" \
     -d '{"applicantName":"Sam","requestedAmount":15000,"taxId":"123-45-6789"}' \
     http://localhost:8880/loandemo/api/loan/apply
```

Expected: HTTP 200 with a body shaped like

```json
{"status":"success","applicationId":42,"decision":"Approved","creditScore":761}
```

Credit scores are deterministic per Tax ID via `$ZCRC`, so the same input always
produces the same decision — handy for live demos.

### 6. Start the Angular frontend

```bash
cd frontend
npm install
npm start
```

The dev server runs at **http://localhost:4200/** (the IRIS dispatcher's CORS
config explicitly whitelists this origin). Submit a loan application, watch the
spinner, and see the decision panel render with the result.

### 7. View the workflow trace (the "wow moment")

Open the Management Portal at
`http://localhost:8880/csp/sys/UtilHome.csp` (login `_SYSTEM`/`_SYSTEM`),
switch to **HSCUSTOM**, then go to **Interoperability → View → Messages** and
filter by **Source = `LoanBroker`**. Click the most recent session to see the
8-message flow:

```
LoanService → LoanBroker (LoanRequest)
  LoanBroker → LoanPersistence  (initial save)
  LoanBroker → CreditBureau     (credit check)
  LoanBroker → LoanPersistence  (update with score + decision)
LoanBroker → LoanService (LoanResponse)
```

Each message header and body is browsable. See
[`docs/demo-walkthrough.md`](docs/demo-walkthrough.md) for the full presenter
cheat sheet.

---

## Running the tests

```objectscript
// All tests (5 methods, all should pass):
Do ##class(%UnitTest.Manager).RunTest("LoanDemo.Test.DecisionLogicTest")
```

Or via MCP:

```bash
mcp__iris-dev-mcp__iris_execute_tests \
    target="LoanDemo.Test.DecisionLogicTest" \
    level="class"
```

Tests cover the three decision branches plus the four boundary edges
(701/700, 500/499) so the documented thresholds are locked into a regression test.

---

## Decision rule

The `DecisionLogic.GetDecision(score)` rule is intentionally simple and isolated
so it can be unit-tested without the Production framework:

| Score | Decision |
|---|---|
| `> 700` | Approved |
| `500 ≤ score ≤ 700` | Manual Review |
| `< 500` | Rejected |

Note the strict inequalities at the edges: `score = 700` is **Manual Review**,
not Approved; `score = 500` is **Manual Review**, not Rejected.

---

## REST contract

```
POST /loandemo/api/loan/apply
Content-Type: application/json

Request:
{
  "applicantName": "string",     // ≥ 2 chars
  "requestedAmount": <number>,   // > 0
  "taxId": "string"              // pattern ^[0-9-]{4,15}$
}

Success response (HTTP 200):
{
  "status": "success",
  "applicationId": <int>,
  "decision": "Approved" | "Rejected" | "Manual Review" | "Pending",
  "creditScore": <int 300–850>
}

Error response (HTTP 400):
{
  "status": "error",
  "message": "<reason>"
}
```

CORS is enabled on the dispatcher (`HandleCorsRequest = 1`) and the response
echoes `Access-Control-Allow-Origin: http://localhost:4200` for the Angular dev
server.

---

## Project layout

```
loandemo/
├── README.md                          # this file
├── LICENSE                            # MIT
├── Agentic Engineering Live on Stage  # READY 2026 talk slides
│   using the BMAD method.pptx
├── CLAUDE.md                          # agent guidance for Claude Code
├── _bmad/                             # BMAD workflow engine + agents
├── _bmad-output/
│   ├── planning-artifacts/            # brief, PRD, architecture, epics
│   └── implementation-artifacts/      # per-story files, sprint status
├── docs/
│   └── demo-walkthrough.md            # presenter cheat sheet
├── src/LoanDemo/                      # ObjectScript backend
│   ├── Data/
│   ├── Message/
│   ├── Service/
│   ├── Process/
│   ├── Operation/
│   ├── Rule/
│   ├── REST/
│   ├── Test/
│   ├── Installer.cls
│   └── Production.cls
└── frontend/                          # Angular 21 SPA
    └── src/app/
        ├── components/loan-form/
        ├── services/loan.service.ts
        └── models/
```

---

## License

Released under the [MIT License](LICENSE).
