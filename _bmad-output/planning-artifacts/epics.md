---
stepsCompleted: [step-01-validate-prerequisites, step-02-design-epics, step-03-create-stories, step-04-final-validation]
status: complete
completedAt: '2026-01-19'
inputDocuments:
  - _bmad-output/planning-artifacts/prd.md
  - _bmad-output/planning-artifacts/architecture.md
---

# loandemo-1 - Epic Breakdown

## Overview

This document provides the complete epic and story breakdown for loandemo-1, decomposing the requirements from the PRD, UX Design if it exists, and Architecture requirements into implementable stories.

## Requirements Inventory

### Functional Requirements

**Loan Application Submission:**
- FR1: Applicant can enter their name in a text field
- FR2: Applicant can enter their requested loan amount
- FR3: Applicant can enter their Tax ID
- FR4: Applicant can submit a completed loan application
- FR5: Applicant can see a loading indicator while application is processing
- FR6: Applicant can see an error message if submission fails

**Loan Decision Processing:**
- FR7: System can receive loan application data via REST API
- FR8: System can persist loan application to database
- FR9: System can request credit score from Credit Bureau (simulated)
- FR10: System can evaluate credit score against decision rules
- FR11: System can return "Approved" decision for scores >700
- FR12: System can return "Rejected" decision for scores <500
- FR13: System can return "Manual Review" decision for scores 500-700
- FR14: Applicant can see their loan decision result on screen

**Workflow Visualization:**
- FR15: Presenter can view workflow message trace in IRIS Management Portal
- FR16: Presenter can see each processing step (receive, persist, credit check, decision, respond)

**Testing:**
- FR17: Developer can run unit tests for credit score decision logic
- FR18: Developer can verify correct decision outcomes via automated tests

### NonFunctional Requirements

**Performance:**
- NFR1: Page initial load <3 seconds
- NFR2: Form submission response <2 seconds
- NFR3: Workflow trace refresh - Real-time

**Reliability:**
- NFR4: Zero critical failures during demo - 100% success rate
- NFR5: Graceful error handling - User sees friendly message on failure
- NFR6: Pre-built backup available - Deployable in <2 minutes

**Integration:**
- NFR7: CORS enabled for Angular - All endpoints return proper headers
- NFR8: IRIS Production runs continuously - No manual restarts during demo
- NFR9: REST API responds to malformed input - Returns 400 with clear error

### Additional Requirements

**From Architecture - Starter Template:**
- Frontend: Angular CLI initialization (`ng new loan-demo --style=scss --routing=false --standalone` + Angular Material)
- Backend: ObjectScript classes created in `src/LoanDemo/` package, compiled to HSCUSTOM namespace

**From Architecture - Technical Requirements:**
- BPL (Visual) Business Process for demo "wow" factor - visible workflow
- CORS enabled via `HandleCorsRequest = 1` parameter on REST dispatcher
- Package structure: Data, Message, Service, Process, Operation, REST, Rule, Test subpackages
- Unit testing uses `$$$Assert*` macros only (no method-style assertions)
- All classes follow %Status return pattern with Try/Catch
- ObjectScript naming: CamelCase, p-prefix for parameters, t-prefix for local variables
- JSON fields use camelCase
- Class size limit: <700 lines

**From Architecture - Implementation Sequence:**
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

### FR Coverage Map

| FR | Story | Description |
|----|-------|-------------|
| FR1 | Story 1.3 | Name input field |
| FR2 | Story 1.3 | Amount input field |
| FR3 | Story 1.3 | Tax ID input field |
| FR4 | Story 1.3 | Submit application |
| FR5 | Story 1.3 | Loading indicator |
| FR6 | Story 1.3 | Error message display |
| FR7 | Story 1.1 | REST API receives data |
| FR8 | Story 1.2 | Persist to database |
| FR9 | Story 1.2 | Credit Bureau request |
| FR10 | Story 1.2 | Evaluate decision rules |
| FR11 | Story 1.2 | Approved decision (>700) |
| FR12 | Story 1.2 | Rejected decision (<500) |
| FR13 | Story 1.2 | Manual Review (500-700) |
| FR14 | Story 1.3 | Display decision result |
| FR15 | Story 1.4 | View workflow trace |
| FR16 | Story 1.4 | See processing steps |
| FR17 | Story 1.4 | Run unit tests |
| FR18 | Story 1.4 | Verify decision outcomes |

**Coverage:** 18/18 FRs mapped (100%)

## Epic List

### Epic 1: Smart Loan Broker Demo
Deliver a complete, working loan broker demonstration showcasing Angular frontend, IRIS REST API, Interoperability Production with workflow visualization, and automated tests.
**FRs covered:** FR1-FR18 (all requirements)
**Stories:** 4

## Epic 1: Smart Loan Broker Demo

**Goal:** Deliver a complete, working loan broker demonstration showcasing Angular frontend, IRIS REST API, Interoperability Production with workflow visualization, and automated tests - all buildable in under 60 minutes.

**User Outcomes:**
- Sam can submit a loan application and see a decision (Approved/Rejected/Manual Review)
- Presenter can show the end-to-end flow and message trace in IRIS Management Portal
- Tests validate decision logic correctness

**Stories:**
- Story 1.1: IRIS Backend Foundation
- Story 1.2: Loan Processing Logic
- Story 1.3: Angular Frontend
- Story 1.4: Visualization & Testing

---

### Story 1.1: IRIS Backend Foundation

**As a** developer,
**I want** the IRIS backend infrastructure with message classes, persistent data storage, Business Service, and REST API,
**So that** the frontend can submit loan applications via HTTP and the Production can receive them.

**Acceptance Criteria:**

**Given** the IRIS HSCUSTOM namespace is available
**When** a POST request is sent to `/loandemo/api/loan/apply` with valid JSON payload
**Then** the REST Dispatcher receives the request and returns a 200 response
**And** CORS headers are present for Angular integration

**Given** the Production is configured
**When** a loan application message is created
**Then** LoanRequest and LoanResponse message classes handle the data correctly
**And** LoanApplication persistent class can store application data

**FRs Addressed:** FR7 (REST API receives data)

**Technical Scope:**
- `LoanDemo.Message.LoanRequest` - Inbound message class
- `LoanDemo.Message.LoanResponse` - Outbound message class
- `LoanDemo.Message.CreditCheckRequest` - Internal request
- `LoanDemo.Message.CreditCheckResponse` - Internal response
- `LoanDemo.Data.LoanApplication` - Persistent class
- `LoanDemo.Service.LoanService` - Business Service
- `LoanDemo.REST.Dispatcher` - REST endpoint with CORS
- `LoanDemo.Production` - Production configuration

---

### Story 1.2: Loan Processing Logic

**As a** system,
**I want** to process loan applications through a BPL workflow that checks credit scores and applies decision rules,
**So that** applicants receive accurate loan decisions (Approved/Rejected/Manual Review).

**Acceptance Criteria:**

**Given** a loan application is received by the Business Service
**When** the BPL Business Process orchestrates the workflow
**Then** the application is persisted to the database
**And** a credit score is retrieved from the Credit Bureau operation
**And** decision logic evaluates the score

**Given** the credit score is greater than 700
**When** decision logic is evaluated
**Then** the decision is "Approved"

**Given** the credit score is less than 500
**When** decision logic is evaluated
**Then** the decision is "Rejected"

**Given** the credit score is between 500 and 700 (inclusive)
**When** decision logic is evaluated
**Then** the decision is "Manual Review"

**Given** the Credit Bureau operation is called
**When** a TaxId is provided
**Then** a simulated credit score between 300-850 is returned

**FRs Addressed:** FR8-FR13 (persist, credit check, decision rules)

**Technical Scope:**
- `LoanDemo.Process.LoanBroker` - BPL Business Process
- `LoanDemo.Operation.CreditBureau` - Credit score simulation
- `LoanDemo.Operation.LoanPersistence` - Database save operation
- `LoanDemo.Rule.DecisionLogic` - Testable business rules

---

### Story 1.3: Angular Frontend

**As an** applicant (Sam),
**I want** a simple loan application form where I can enter my details and submit,
**So that** I can apply for a loan and see my decision result.

**Acceptance Criteria:**

**Given** the Angular application is loaded
**When** the user views the loan form
**Then** input fields are displayed for Name, Requested Amount, and Tax ID
**And** a Submit button is available

**Given** the user has entered valid data in all fields
**When** the user clicks Submit
**Then** a loading indicator is displayed
**And** the form data is sent to the REST API

**Given** the API returns a successful response
**When** the response is received
**Then** the loan decision (Approved/Rejected/Manual Review) is displayed
**And** the credit score is shown
**And** the application ID is displayed

**Given** the API returns an error
**When** the error response is received
**Then** a user-friendly error message is displayed
**And** the user can retry submission

**Given** the form fields are empty or invalid
**When** the user attempts to submit
**Then** validation messages indicate required fields

**FRs Addressed:** FR1-FR6, FR14 (form entry, submit, loading, error, result display)

**Technical Scope:**
- `loan-form.component.ts` - Form component with reactive forms
- `loan.service.ts` - HTTP service for API calls
- `models/loan-request.ts` - Request interface
- `models/loan-response.ts` - Response interface
- `environment.ts` - API URL configuration

---

### Story 1.4: Visualization & Testing

**As a** presenter,
**I want** to view the workflow message trace in IRIS Management Portal and have unit tests validate the decision logic,
**So that** I can demonstrate the "wow moment" of message routing and have confidence in code correctness.

**Acceptance Criteria:**

**Given** a loan application has been processed through the Production
**When** the presenter opens the IRIS Management Portal
**Then** the workflow message trace is visible
**And** each processing step is shown: receive → persist → credit check → decision → respond

**Given** the Production is configured for tracing
**When** messages flow through Service → Process → Operations
**Then** the message headers and bodies are viewable in the trace

**Given** the DecisionLogic class exists
**When** unit tests are executed for credit score 750
**Then** the test asserts decision equals "Approved"

**Given** the DecisionLogic class exists
**When** unit tests are executed for credit score 450
**Then** the test asserts decision equals "Rejected"

**Given** the DecisionLogic class exists
**When** unit tests are executed for credit score 600
**Then** the test asserts decision equals "Manual Review"

**Given** the test runner is invoked
**When** all tests are executed
**Then** all decision logic tests pass

**FRs Addressed:** FR15-FR18 (workflow trace, unit tests)

**Technical Scope:**
- Production trace configuration (already in Production.cls)
- `LoanDemo.Test.DecisionLogicTest` - Unit test class with $$$Assert macros
