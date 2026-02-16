---
stepsCompleted: [step-01-init, step-02-discovery, step-03-success, step-04-journeys, step-05-domain, step-06-innovation, step-07-project-type, step-08-scoping, step-09-functional, step-10-nonfunctional, step-11-polish]
inputDocuments:
  - _bmad-output/planning-artifacts/product-brief-LoanDemo-2026-01-19.md
  - docs/context.md
  - docs/initial-prompt.md
workflowType: 'prd'
documentCounts:
  briefs: 1
  research: 0
  projectDocs: 2
classification:
  projectType: web_app
  domain: fintech
  complexity: low
  projectContext: greenfield
date: 2026-01-19
author: Developer
project_name: loandemo-1
---

# Product Requirements Document - loandemo-1

**Author:** Developer
**Date:** 2026-01-19

## Executive Summary

**LoanDemo** is a conference demonstration application showcasing InterSystems IRIS Interoperability and REST API capabilities through a loan broker scenario. The primary goal is proving the BMAD methodology can build a complete, working full-stack application in under 60 minutes. This PRD defines a minimal but complete demo: Angular 17+ frontend → REST API → IRIS Production (Business Service → Process → Operation) → loan decision display, with workflow trace visualization as the technical "wow moment."

## Success Criteria

### User Success

**Demo Persona (Sam):**
- Completes loan application form without confusion
- Submits application and receives clear decision (Approved/Rejected/Manual Review)
- Understands the outcome immediately

**Conference Attendee:**
- Follows the live build process and understands each step
- Experiences the "it all works" moment when end-to-end flow executes
- Leaves believing "I could do this myself"

### Business Success

| Metric | Target |
|--------|--------|
| Build Completion | ≤60 minutes (hard constraint - 65 minutes = failure) |
| Demo Execution | Zero critical failures during presentation |
| Audience Conversion | Skeptics become interested in BMAD methodology |
| Follow-up Interest | Post-session conversations or contact requests |

### Technical Success

| Criterion | Requirement |
|-----------|-------------|
| End-to-End Flow | Form → REST → IRIS Production → Response works without errors |
| Decision Logic | Correct outcomes: >700 Approved, <500 Rejected, else Manual Review |
| Workflow Trace | Message flow visible in IRIS Management Portal |
| Unit Tests | Core logic covered with passing tests |

### Measurable Outcomes

- **Primary:** Complete working demo in ≤60 minutes
- **Secondary:** All three decision paths (Approved/Rejected/Manual Review) demonstrated
- **Tertiary:** Workflow trace clearly shows message routing

## User Journeys

### Journey 1: The Skeptical Architect (Conference Attendee)

**Persona:** Technical professional attending the conference session - could be a developer, architect, or tech lead. They've seen plenty of demos that look polished but don't reflect real development. They're curious about IRIS and AI-assisted development but won't be convinced by slides.

**Opening Scene:**
The Skeptical Architect sees the session title: "Build a Full-Stack App in Under 60 Minutes." They're intrigued but skeptical. They've heard these claims before. They decide to attend, expecting to see either smoke and mirrors or a trivial toy application.

**Rising Action:**
The live build begins. They watch the BMAD methodology in action - structured, methodical, but moving fast. Angular components appear. REST endpoints connect. IRIS Production components wire together. They start taking notes. This isn't a pre-built demo being revealed - it's actual development happening in real-time.

**Climax:**
The presenter submits a loan application through the UI. The form data flows to IRIS. The workflow trace appears on screen, showing:
- Loan request received by Business Service
- Application persisted to database
- Credit Bureau simulation called
- Score returned, decision logic evaluated
- Response sent back to frontend

The decision appears: "Approved." The entire end-to-end flow works. The audience sees the message routing in the IRIS Management Portal - proof that this is real integration, not fake.

**Resolution:**
The Skeptical Architect leaves thinking "I could do this." They understand both what IRIS can do AND how BMAD accelerates development. They're no longer skeptical - they're planning how to try this on their next project.

---

### Journey 2: Sam the Small Business Owner (Demo Persona)

**Persona:** Sam runs a growing small business and needs capital to expand. Not technical - just wants a straightforward loan application process without jumping through hoops.

**Opening Scene:**
Sam needs $50,000 to expand inventory for the busy season. Traditional bank processes are slow and opaque. Sam finds the Smart Loan Broker application.

**Rising Action:**
Sam opens the loan application form. Three simple fields: Name, Requested Amount, Tax ID. No account creation, no complex forms, no uploading 47 documents. Sam enters the information and clicks Submit.

**Climax:**
The system processes the application. Behind the scenes (invisible to Sam, visible to the conference audience), IRIS orchestrates the workflow - persisting the application, checking the credit score, applying decision rules.

**Resolution:**
Within seconds, Sam sees the result: "Approved" (or "Rejected" or "Manual Review" depending on the simulated credit score). The decision is immediate and clear. Sam knows exactly where they stand.

*Note: Sam is a fictional persona used to create a relatable demo scenario. The real audience is the Conference Attendee watching Sam's journey unfold.*

---

### Journey Requirements Summary

| Journey | Reveals Requirements For |
|---------|-------------------------|
| **Skeptical Architect** | Live build capability, workflow visualization, IRIS Management Portal trace, clear architecture that can be explained during demo |
| **Sam (Demo Persona)** | Simple 3-field form, immediate response, clear decision display (Approved/Rejected/Manual Review) |

**Capabilities Required:**
- Frontend: Clean, simple form with instant feedback
- Backend: Fast processing, clear workflow stages
- Visualization: IRIS trace that tells a story (not just technical logs)
- Demo Flow: Ability to narrate each step as it happens

## Web App Specific Requirements

### Project-Type Overview

**Architecture:** Single Page Application (SPA) built with Angular 17+

This is a conference demo application - technical requirements are optimized for live presentation clarity rather than production deployment.

### Technical Architecture Considerations

| Aspect | Requirement |
|--------|-------------|
| **Frontend Framework** | Angular 17+ with standalone components |
| **Build System** | Angular CLI standard configuration |
| **State Management** | Component-level state (no NgRx needed for 3-field form) |
| **HTTP Client** | Angular HttpClient with typed interfaces |
| **Styling** | Angular Material or basic CSS (clean, professional appearance) |

### Browser Support

| Browser | Support Level |
|---------|---------------|
| **Chrome/Edge (latest)** | Primary - presenter's laptop |
| **Other browsers** | Not required for demo |

*Note: Demo runs on presenter's controlled environment. Cross-browser testing is out of scope.*

### Responsive Design

| Requirement | Status |
|-------------|--------|
| **Desktop display** | Required - conference projection |
| **Mobile/tablet** | Not required for demo |
| **Minimum width** | 1024px (typical projector resolution) |

### Performance Targets

See **Non-Functional Requirements > Performance** (NFR1-NFR3) for specific targets and validation methods.

### SEO Strategy

**Not applicable.** This is a demo application, not a public-facing website.

### Accessibility Level

| Requirement | Implementation |
|-------------|----------------|
| **Target** | Reasonable defaults from Angular |
| **Form labels** | Proper `<label>` associations |
| **Focus management** | Standard Angular behavior |
| **WCAG compliance** | Not a demo requirement |

### Implementation Considerations

- **CORS:** Must be enabled on IRIS REST endpoint (critical for Angular integration)
- **Environment config:** API URL configured via `environment.ts`
- **Error handling:** Basic - display error message if submission fails
- **Loading state:** Show spinner/indicator during form submission

## Project Scoping & Phased Development

### MVP Strategy & Philosophy

**MVP Approach:** Demo MVP - the minimum viable demonstration that proves BMAD methodology can build a working full-stack IRIS application in under 60 minutes.

**Scope Constraint:** The 60-minute time limit is the primary scope limiter. Features are included only if they contribute to the demo narrative and can be built within the time constraint.

### MVP Feature Set (Phase 1)

**Core User Journeys Supported:**
- Sam's loan application flow (form → submit → decision)
- Conference Attendee's understanding flow (watch build → see it work → believe it's real)

**Must-Have Capabilities:**

| Component | Must-Have | Rationale |
|-----------|-----------|-----------|
| Loan Form | 3 fields (Name, Amount, Tax ID) | Minimum viable input |
| REST API | Single POST endpoint with CORS | Frontend-backend connection |
| IRIS Production | Service → Process → Operation | Core demo of Interoperability |
| Credit Bureau | Simulated score generator | Demonstrates external integration pattern |
| Decision Logic | Score-based rules (>700/500/<500) | Business logic showcase |
| Workflow Trace | Visible in Management Portal | The "wow" moment |
| Unit Tests | Core business logic coverage | Safety net for live build |

### Post-MVP Features

**Phase 2 (Growth):**
- Application history/list view
- Real Credit Bureau API integration
- Multiple loan types with different rules
- Admin dashboard

**Phase 3 (Vision):**
- Multi-tenant support
- Document upload and verification
- Notification system (email/SMS)
- Reporting and analytics

### Risk Mitigation Strategy

**Technical Risk: Live build fails during demo**
- *Mitigation:* Pre-built backup version ready to deploy
- *Trigger:* If at 50+ minutes and not on track to finish
- *Recovery:* Switch to backup, narrate "here's the completed version"

**Technical Risk: IRIS connection issues**
- *Mitigation:* Test full flow before demo, have local IRIS instance
- *Recovery:* Show workflow trace from previous successful run

**Presentation Risk: Audience loses engagement**
- *Mitigation:* Keep narration active, explain what's happening at each step
- *Recovery:* Jump to workflow trace "wow moment" if attention wanes

## Functional Requirements

### Loan Application Submission

- **FR1:** Applicant can enter their name in a text field
- **FR2:** Applicant can enter their requested loan amount
- **FR3:** Applicant can enter their Tax ID
- **FR4:** Applicant can submit a completed loan application
- **FR5:** Applicant can see a loading indicator while application is processing
- **FR6:** Applicant can see an error message if submission fails

### Loan Decision Processing

- **FR7:** System can receive loan application data via REST API
- **FR8:** System can persist loan application to database
- **FR9:** System can request credit score from Credit Bureau (simulated)
- **FR10:** System can evaluate credit score against decision rules
- **FR11:** System can return "Approved" decision for scores >700
- **FR12:** System can return "Rejected" decision for scores <500
- **FR13:** System can return "Manual Review" decision for scores 500-700
- **FR14:** Applicant can see their loan decision result on screen

### Workflow Visualization

- **FR15:** Presenter can view workflow message trace in IRIS Management Portal
- **FR16:** Presenter can see each processing step (receive, persist, credit check, decision, respond)

### Testing

- **FR17:** Developer can run unit tests for credit score decision logic
- **FR18:** Developer can verify correct decision outcomes via automated tests

## Non-Functional Requirements

### Performance

| Requirement | Target | Validation |
|-------------|--------|------------|
| **NFR1:** Page initial load | <3 seconds | Manual test on presenter laptop |
| **NFR2:** Form submission response | <2 seconds | Stopwatch during demo rehearsal |
| **NFR3:** Workflow trace refresh | Real-time | Visual confirmation in Management Portal |

### Reliability

| Requirement | Target | Validation |
|-------------|--------|------------|
| **NFR4:** Zero critical failures during demo | 100% success rate | Complete 3+ rehearsal runs without error |
| **NFR5:** Graceful error handling | User sees friendly message on failure | Test with IRIS disconnected |
| **NFR6:** Pre-built backup available | Deployable in <2 minutes | Rehearse backup deployment |

### Integration

| Requirement | Target | Validation |
|-------------|--------|------------|
| **NFR7:** CORS enabled for Angular | All endpoints return proper headers | Browser dev tools check |
| **NFR8:** IRIS Production runs continuously | No manual restarts during demo | Test 1-hour continuous operation |
| **NFR9:** REST API responds to malformed input | Returns 400 with clear error | Send invalid JSON payload
