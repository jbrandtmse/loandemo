---
stepsCompleted: [1, 2, 3, 4, 5, 6, 7, 8]
status: 'complete'
completedAt: '2026-01-19'
inputDocuments:
  - _bmad-output/planning-artifacts/product-brief-LoanDemo-2026-01-19.md
  - _bmad-output/planning-artifacts/prd.md
  - docs/context.md
  - docs/initial-prompt.md
workflowType: 'architecture'
project_name: 'loandemo-1'
user_name: 'Developer'
date: '2026-01-19'
---

# Architecture Decision Document

_This document builds collaboratively through step-by-step discovery. Sections are appended as we work through each architectural decision together._

## Project Context Analysis

### Requirements Overview

**Functional Requirements:**
18 requirements spanning loan submission, decision processing, workflow visualization, and testing. The core flow is straightforward: form submission → orchestrated processing → decision display. No authentication, no complex state management, no multi-step workflows.

**Non-Functional Requirements:**
- Performance: <3s page load, <2s submission response
- Reliability: Zero critical failures during demo, graceful error handling
- Integration: CORS enabled, continuous Production operation, proper error responses

**Scale & Complexity:**

- Primary domain: Full-stack (Angular SPA + IRIS backend)
- Complexity level: Low (demo scope)
- Estimated architectural components: ~8-10 classes

### Technical Constraints & Dependencies

| Constraint | Impact |
|------------|--------|
| 60-minute build limit | Architecture must be minimal but complete |
| ObjectScript conventions | CamelCase, p/t prefixes, no underscores |
| CORS requirement | REST layer must enable HandleCorsRequest |
| %UnitTest macros only | No method-style assertions |
| Class size <700 lines | May need to split if logic grows |

### Cross-Cutting Concerns Identified

1. **Error Handling:** Consistent pattern from REST layer through Production to frontend display
2. **CORS Configuration:** Single point of configuration in REST dispatcher
3. **Message Tracing:** Production must be configured for visible workflow traces
4. **Decision Logic Testability:** Business rules must be isolated for unit testing

## Starter Template Evaluation

### Primary Technology Domain

Full-stack with specialized backend - Angular 17+ SPA communicating with InterSystems IRIS via REST API to Interoperability Production.

### Technology Stack (Pre-determined)

This project uses a mandated technology stack based on the demo requirements:

| Layer | Technology | Rationale |
|-------|------------|-----------|
| Frontend | Angular 17+ | Modern SPA framework, standalone components |
| Backend | InterSystems IRIS | Demo target platform |
| Language (FE) | TypeScript | Angular default |
| Language (BE) | ObjectScript | IRIS native language |
| API | %CSP.REST | IRIS REST framework with CORS support |
| Orchestration | Interoperability Production | Core demo capability |

### Initialization Commands

**Frontend:**
```bash
ng new loan-demo --style=scss --routing=false --standalone
cd loan-demo && ng add @angular/material
```

**Backend:**
ObjectScript classes created directly in `src/LoanDemo/` package, compiled to HSCUSTOM namespace.

### Architectural Decisions Provided by Stack

**Frontend (Angular CLI):**
- TypeScript strict mode
- Component-based architecture
- HttpClient for REST calls
- Environment-based configuration

**Backend (IRIS):**
- %Status return pattern with Try/Catch
- Message-based interoperability
- Persistent class data storage
- Built-in workflow tracing

## Core Architectural Decisions

### Decision Priority Analysis

**Critical Decisions (Block Implementation):**
- Data model structure for LoanApplication
- IRIS Production component architecture
- Message class design
- REST endpoint structure

**Important Decisions (Shape Architecture):**
- Validation strategy
- Error response format
- Credit Bureau simulation pattern

**Deferred Decisions (Post-MVP):**
- Authentication (explicitly out of scope)
- Application history/list views
- Real external API integration

### Data Architecture

| Decision | Choice | Rationale |
|----------|--------|-----------|
| **Storage** | IRIS Persistent Classes | Native platform capability |
| **Primary Entity** | `LoanDemo.Data.LoanApplication` | Single persistent class |
| **Validation** | Frontend-only | Demo simplicity, trusted input |
| **ID Generation** | IRIS %AutoIncrement | Automatic unique IDs |

**LoanApplication Schema:**

| Property | Type | Description |
|----------|------|-------------|
| ApplicationId | %AutoIncrement | Primary key |
| ApplicantName | %String | Applicant's name |
| RequestedAmount | %Numeric | Loan amount requested |
| TaxId | %String | Tax identification |
| CreditScore | %Integer | Populated after credit check |
| Decision | %String | Approved/Rejected/Manual Review |
| CreatedDate | %TimeStamp | Application timestamp |

### Authentication & Security

| Decision | Choice | Rationale |
|----------|--------|-----------|
| **Authentication** | None | Demo scope - explicitly excluded |
| **Authorization** | None | No user context required |
| **CORS** | Enabled via HandleCorsRequest=1 | Angular integration requirement |

### API & Communication Patterns

| Decision | Choice | Rationale |
|----------|--------|-----------|
| **API Style** | REST | Stack requirement (%CSP.REST) |
| **Endpoint** | POST /loan/apply | Single submission endpoint |
| **Content Type** | application/json | Standard JSON payloads |
| **Error Format** | Simple JSON | `{"status":"error","message":"..."}` |

**Request Payload:**
```json
{
  "applicantName": "string",
  "requestedAmount": number,
  "taxId": "string"
}
```

**Success Response:**
```json
{
  "status": "success",
  "applicationId": number,
  "decision": "Approved|Rejected|Manual Review",
  "creditScore": number
}
```

### IRIS Production Architecture

| Decision | Choice | Rationale |
|----------|--------|-----------|
| **Business Process** | BPL (Visual) | Demo "wow" factor - visible workflow |
| **Message Pattern** | Single Request/Response | Minimal complexity |
| **Credit Bureau** | Dedicated Business Operation | Demonstrates proper integration pattern |

**Production Components:**

| Component | Class | Role |
|-----------|-------|------|
| Business Service | `LoanDemo.Service.LoanService` | Receives REST request, creates message |
| Business Process | `LoanDemo.Process.LoanBroker` | BPL orchestration of loan workflow |
| Business Operation | `LoanDemo.Operation.CreditBureau` | Simulates external credit check |
| Business Operation | `LoanDemo.Operation.LoanPersistence` | Saves application to database |

**Message Classes:**

| Class | Direction | Purpose |
|-------|-----------|---------|
| `LoanDemo.Message.LoanRequest` | Inbound | Carries application data |
| `LoanDemo.Message.LoanResponse` | Outbound | Carries decision result |
| `LoanDemo.Message.CreditCheckRequest` | Internal | Request to Credit Bureau |
| `LoanDemo.Message.CreditCheckResponse` | Internal | Credit score result |

### Frontend Architecture

| Decision | Choice | Rationale |
|----------|--------|-----------|
| **State Management** | Component-level | Single form, no complex state |
| **HTTP Client** | Angular HttpClient | Framework standard |
| **Forms** | Reactive Forms | Type-safe form handling |
| **Styling** | Angular Material | Professional appearance, fast setup |

### Decision Impact Analysis

**Implementation Sequence:**
1. Create message classes (foundation for all communication)
2. Create persistent data class
3. Create Business Operations (Credit Bureau, Persistence)
4. Create BPL Business Process
5. Create Business Service
6. Create REST endpoint with CORS
7. Create Angular form component
8. Wire up HTTP service
9. Create unit tests for decision logic

**Cross-Component Dependencies:**
- REST layer depends on Business Service registration in Production
- Business Process depends on all message classes being compiled
- Angular HttpClient depends on CORS being enabled
- Unit tests depend on decision logic being in testable location

## Implementation Patterns & Consistency Rules

### Pattern Categories Defined

**Critical Conflict Points Identified:** 5 areas where AI agents could make different choices

### Naming Patterns

**ObjectScript Naming Conventions:**

| Element | Convention | Example |
|---------|------------|---------|
| Package | CamelCase, dot-separated | `LoanDemo.Message` |
| Class | CamelCase | `LoanRequest` |
| Method | CamelCase | `GetCreditScore` |
| Parameter | p-prefix, CamelCase | `pRequest` |
| Local Variable | t-prefix, CamelCase | `tStatus` |
| Property | CamelCase | `ApplicantName` |

**Angular Naming Conventions:**

| Element | Convention | Example |
|---------|------------|---------|
| Component class | PascalCase | `LoanFormComponent` |
| Component file | kebab-case | `loan-form.component.ts` |
| Service | PascalCase + Service suffix | `LoanService` |
| Interface/Model | PascalCase | `LoanRequest` |

**JSON Field Convention:** camelCase for all API payloads

### Structure Patterns

**ObjectScript Package Layout:**
- `LoanDemo.Data.*` - Persistent classes
- `LoanDemo.Message.*` - Message classes
- `LoanDemo.Service.*` - Business Services
- `LoanDemo.Process.*` - Business Processes
- `LoanDemo.Operation.*` - Business Operations
- `LoanDemo.REST.*` - REST endpoints
- `LoanDemo.Rule.*` - Testable business logic
- `LoanDemo.Test.*` - Unit tests

**Angular Project Layout:**
- `src/app/components/` - UI components
- `src/app/services/` - HTTP and business services
- `src/app/models/` - TypeScript interfaces

### Format Patterns

**API Response Structure:**

Success: `{ "status": "success", ...data fields }`
Error: `{ "status": "error", "message": "description" }`

**Date Format:** ISO 8601 in JSON, locale display in UI

### Process Patterns

**ObjectScript Method Pattern:**
- Always return `%Status`
- Use Try/Catch with `ex.AsStatus()`
- Never use `Quit` with arguments inside Try block

**Angular HTTP Pattern:**
- Return `Observable<T>` from services
- Use environment.apiUrl for base URL
- Handle errors in service with `catchError`

### Enforcement Guidelines

**All AI Agents MUST:**
- Follow ObjectScript naming conventions (no underscores anywhere)
- Use %Status return pattern with Try/Catch
- Use only `$$$Assert*` macros in tests (never method calls)
- Use camelCase for JSON fields
- Place classes in correct package by type

**Anti-Patterns to Avoid:**
- `user_name` (use `UserName` or `userName`)
- `Quit tSC` inside Try block
- `..AssertEquals()` in tests
- Direct mutation of component state

## Project Structure & Boundaries

### Complete Project Directory Structure

```
loandemo-3/
├── src/                                # ObjectScript Backend
│   └── LoanDemo/
│       ├── Data/
│       │   └── LoanApplication.cls     # Persistent class
│       ├── Message/
│       │   ├── LoanRequest.cls         # Inbound message
│       │   ├── LoanResponse.cls        # Outbound message
│       │   ├── CreditCheckRequest.cls  # Internal request
│       │   └── CreditCheckResponse.cls # Internal response
│       ├── Service/
│       │   └── LoanService.cls         # Business Service
│       ├── Process/
│       │   └── LoanBroker.cls          # BPL Business Process
│       ├── Operation/
│       │   ├── CreditBureau.cls        # Credit check simulation
│       │   └── LoanPersistence.cls     # Database operations
│       ├── REST/
│       │   └── Dispatcher.cls          # REST endpoint
│       ├── Rule/
│       │   └── DecisionLogic.cls       # Business rules
│       ├── Test/
│       │   └── DecisionLogicTest.cls   # Unit tests
│       └── Production.cls              # Production config
│
└── frontend/                           # Angular Frontend
    └── src/app/
        ├── components/loan-form/       # Form component
        ├── services/loan.service.ts    # HTTP service
        └── models/                     # TypeScript interfaces
```

### Architectural Boundaries

**API Boundary:**
- Single REST endpoint: `POST /loandemo/api/loan/apply`
- CORS enabled via `HandleCorsRequest = 1`
- JSON request/response

**Production Boundary:**
- All business logic inside Production components
- Service receives external requests
- Process orchestrates workflow
- Operations handle external calls and persistence

**Data Boundary:**
- Single persistent class for all loan data
- Database access only through LoanPersistence operation

### Integration Points

**External Integration:**
- Angular → REST Dispatcher (HTTP POST)
- REST → Business Service (direct call)

**Internal Production Flow:**
- Service → Process (async message)
- Process → Operations (sync calls)
- Process → DecisionLogic (direct method call)

### Requirements Mapping

| FR Category | Primary Components |
|-------------|-------------------|
| Loan Submission | `loan-form.component`, `Dispatcher`, `LoanService` |
| Decision Processing | `LoanBroker`, `CreditBureau`, `DecisionLogic` |
| Data Persistence | `LoanApplication`, `LoanPersistence` |
| Workflow Trace | `Production.cls` configuration |
| Unit Testing | `DecisionLogicTest` |

## Architecture Validation Results

### Coherence Validation ✅

**Decision Compatibility:** All technology choices (Angular 17+, IRIS, ObjectScript, %CSP.REST) work together without conflicts. CORS integration between Angular and IRIS REST is properly configured.

**Pattern Consistency:** Naming conventions, return patterns, and communication patterns are consistent across frontend and backend.

**Structure Alignment:** Project structure supports all architectural decisions with clear boundaries.

### Requirements Coverage Validation ✅

**Functional Requirements:** All 18 FRs mapped to specific architectural components.
- Loan Submission (FR1-FR6): Frontend form → REST → Production
- Decision Processing (FR7-FR14): BPL orchestration with business rules
- Workflow Visualization (FR15-FR16): IRIS Production trace
- Testing (FR17-FR18): Unit tests with macro assertions

**Non-Functional Requirements:** All 9 NFRs architecturally addressed.
- Performance targets achievable with simple synchronous flow
- Reliability through Try/Catch patterns and error handling
- Integration via CORS and continuous Production operation

### Implementation Readiness Validation ✅

**Decision Completeness:** All critical decisions documented with specific class names, packages, and patterns.

**Structure Completeness:** Full directory tree with all 10+ ObjectScript classes and Angular components defined.

**Pattern Completeness:** Comprehensive naming, structure, and process patterns with anti-pattern guidance.

### Architecture Completeness Checklist

**✅ Requirements Analysis**
- [x] Project context thoroughly analyzed
- [x] Scale and complexity assessed (Low - demo scope)
- [x] Technical constraints identified (60-min build, ObjectScript conventions)
- [x] Cross-cutting concerns mapped (error handling, CORS, tracing, testability)

**✅ Architectural Decisions**
- [x] Critical decisions documented (data model, Production architecture, API)
- [x] Technology stack fully specified (Angular 17+, IRIS, ObjectScript)
- [x] Integration patterns defined (REST → Production → Operations)
- [x] Performance considerations addressed (<2s response)

**✅ Implementation Patterns**
- [x] Naming conventions established (CamelCase, p/t prefixes, camelCase JSON)
- [x] Structure patterns defined (package layout, Angular structure)
- [x] Communication patterns specified (message classes, API contract)
- [x] Process patterns documented (%Status, Try/Catch, Observable)

**✅ Project Structure**
- [x] Complete directory structure defined
- [x] Component boundaries established (API, Production, Data)
- [x] Integration points mapped
- [x] Requirements to structure mapping complete

### Architecture Readiness Assessment

**Overall Status:** READY FOR IMPLEMENTATION

**Confidence Level:** High - All validation checks passed

**Key Strengths:**
- Clear separation of concerns (REST → Service → Process → Operations)
- Testable business logic isolated in DecisionLogic class
- Simple, achievable architecture for 60-minute demo
- Comprehensive patterns prevent AI agent conflicts

**Implementation Handoff:**

AI agents should follow this sequence:
1. Create message classes (LoanRequest, LoanResponse, CreditCheckRequest, CreditCheckResponse)
2. Create persistent class (LoanApplication)
3. Create DecisionLogic with testable GetDecision method
4. Create Business Operations (CreditBureau, LoanPersistence)
5. Create BPL Business Process (LoanBroker)
6. Create Business Service (LoanService)
7. Create REST Dispatcher with CORS
8. Configure and start Production
9. Create Angular frontend
10. Run unit tests

## Architecture Completion Summary

### Workflow Completion

**Architecture Decision Workflow:** COMPLETED ✅
**Total Steps Completed:** 8
**Date Completed:** 2026-01-19
**Document Location:** `_bmad-output/planning-artifacts/architecture.md`

### Final Architecture Deliverables

**Complete Architecture Document**
- All architectural decisions documented with specific class names and packages
- Implementation patterns ensuring AI agent consistency
- Complete project structure with all files and directories
- Requirements to architecture mapping
- Validation confirming coherence and completeness

**Implementation Ready Foundation**
- 15+ architectural decisions made
- 5 implementation pattern categories defined
- 12 ObjectScript classes + Angular components specified
- 27 requirements (18 FR + 9 NFR) fully supported

**AI Agent Implementation Guide**
- Technology stack: Angular 17+ / IRIS / ObjectScript / %CSP.REST
- Consistency rules that prevent implementation conflicts
- Project structure with clear boundaries
- Integration patterns and communication standards

---

**Architecture Status:** READY FOR IMPLEMENTATION ✅

**Next Phase:** Begin implementation using the architectural decisions and patterns documented herein.

