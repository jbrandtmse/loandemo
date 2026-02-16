---
stepsCompleted: [1, 2, 3, 4, 5]
inputDocuments:
  - docs/context.md
  - docs/initial-prompt.md
date: 2026-01-19
author: Developer
---

# Product Brief: LoanDemo

## Executive Summary

LoanDemo is a conference demonstration showcasing InterSystems IRIS Interoperability and REST API capabilities through a relatable loan broker scenario. Beyond the technical demo itself, LoanDemo serves as a live proof-of-concept for the BMAD (BMad Method for AI-assisted Development) methodology—demonstrating that a complete, polished full-stack application can be built in under 60 minutes.

The target audience is architects and developers evaluating IRIS for integration projects and exploring AI-assisted development workflows. The demo prioritizes clarity, visual polish, and reliability to create a memorable conference experience.

---

## Core Vision

### Problem Statement

Existing InterSystems IRIS demonstrations often lack modern AI-assisted development approaches, making it difficult for technical audiences to envision rapid application development with the platform. Conference attendees want to see not just what IRIS can do, but how quickly they could build similar solutions themselves.

### Problem Impact

Without compelling, modern demos that showcase both capabilities AND development velocity, potential adopters may underestimate IRIS's value proposition for rapid integration projects. The gap between "impressive demo" and "I could do this" remains too wide.

### Why Existing Solutions Fall Short

Current IRIS demos typically:
- Focus only on the finished product, not the development journey
- Don't leverage AI-assisted development methodologies
- May feel disconnected from real-world scenarios developers encounter
- Don't demonstrate the speed possible with modern tooling

### Proposed Solution

LoanDemo is a "Smart Loan Broker" application featuring:
- **Angular 17+ frontend** — Modern, polished UI for loan application submission
- **REST API layer** — Clean integration between frontend and backend
- **IRIS Interoperability Production** — Business Process broker pattern demonstrating:
  - Loan application persistence
  - Simulated Credit Bureau integration
  - Automated business rules (Score-based decisioning: >700 Approved, <500 Rejected, else Manual Review)

The demo will be built live using the BMAD methodology, proving that a complete working application can be developed in under 60 minutes.

### Key Differentiators

1. **AI-Assisted Development** — Built using BMAD method, showcasing modern development velocity
2. **Live Build Experience** — Audience watches the entire development process, not just the result
3. **Dual Value Proposition** — Demonstrates both IRIS capabilities AND development methodology
4. **Relatable Scenario** — Loan processing is universally understood by financial services audiences
5. **Full-Stack Completeness** — End-to-end from UI to backend integration in one cohesive demo

---

## Target Users

### Primary Users

#### Conference Attendee: "The Skeptical Architect"

**Profile:**
- Developers and architects attending the conference session
- Mixed technical backgrounds—some familiar with IRIS, others evaluating it for the first time
- Interested in AI-assisted development and modern tooling
- Time-conscious professionals looking for ways to accelerate their own development

**Motivation:**
- Wants to see if BMAD method delivers on its promise of rapid development
- Skeptical that a real, working full-stack application can be built in under 60 minutes
- Looking for practical approaches they can apply to their own projects

**Success Criteria:**
- Walks away thinking "I could do this myself"
- Understands both IRIS capabilities AND the BMAD methodology
- Has a clear mental model of how the pieces fit together

### Secondary Users

#### Simulated User: "Sam the Small Business Owner"

**Profile:**
- Small business owner needing capital for expansion
- Not technically sophisticated—wants a simple, clear loan application process
- Values speed and transparency in financial decisions

**Demo Interaction:**
- Fills out a simple loan application form (Name, Requested Amount, Tax ID)
- Submits the application and waits for a decision
- Receives immediate feedback: Approved, Rejected, or Manual Review

*Note: Sam is a fictional persona used within the demo to create a relatable scenario for the audience.*

### User Journey

#### Conference Attendee Journey

1. **Discovery:** Sees session title promising a full-stack app built in under 60 minutes—intrigued but skeptical
2. **Engagement:** Watches the live build using BMAD method, sees structured approach
3. **Wow Moment:** Sees the completed loan application flow AND the IRIS workflow trace showing messages flowing through the Production
4. **Validation:** Understands this isn't smoke and mirrors—it's a real, working application
5. **Takeaway:** Leaves with confidence that IRIS + BMAD can accelerate their projects

#### Demo Scenario Journey (Sam's Story)

1. **Application:** Sam fills out the loan form with basic information
2. **Submission:** Application is sent via REST API to IRIS backend
3. **Processing:** IRIS Interoperability Production orchestrates the workflow:
   - Persists the application
   - Calls simulated Credit Bureau for score
   - Applies business rules (>700 Approved, <500 Rejected, else Manual Review)
4. **Result:** Sam sees the decision on screen
5. **Behind the Scenes:** Presenter shows IRIS workflow trace—the real "wow" moment for the technical audience

---

## Success Metrics

### Demo Success Criteria

#### Technical Success
| Criterion | Target |
|-----------|--------|
| Build Time | Complete within 60 minutes |
| Form Functionality | Loan application form accepts and submits data |
| REST Integration | Frontend successfully calls IRIS backend |
| Workflow Execution | Business Process runs without errors |
| Decision Logic | Correct outcomes (Approved/Rejected/Manual Review based on score) |
| Visual Trace | IRIS workflow trace displays message flow |

#### Presentation Success
| Criterion | Indicator |
|-----------|-----------|
| Audience Engagement | Attendees visibly following along, taking notes/photos |
| Live Interaction | Questions during or immediately after the session |
| Positive Response | Applause and verbal affirmation at demo completion |
| Follow-up Interest | Post-session conversations about BMAD and IRIS development |

### Business Objectives

#### Primary Objective
Demonstrate that the BMAD methodology enables rapid, reliable development of full-stack IRIS applications—converting skeptics into believers who want to try it themselves.

#### Secondary Objectives
- Showcase IRIS Interoperability and REST API capabilities to technical decision-makers
- Generate interest in AI-assisted development approaches
- Position IRIS as a modern, developer-friendly platform

### Key Performance Indicators

#### Audience Impact KPIs
| KPI | Success Target |
|-----|----------------|
| Engagement Level | Majority of attendees visibly engaged throughout |
| Comprehension | Attendees can articulate how the demo worked |
| Intent to Act | Attendees express desire to try BMAD themselves |
| Follow-up Rate | Multiple post-session conversations or contact requests |

#### Demo Execution KPIs
| KPI | Success Target |
|-----|----------------|
| Completion Rate | 100% of planned features demonstrated |
| Error Rate | Zero critical failures during live demo |
| Time Performance | Completed within 60-minute window |
| Wow Moment Delivery | Workflow trace successfully shown and explained |

---

## MVP Scope

### Core Features

The following features constitute the complete demo deliverable:

#### Frontend (Angular 17+)
| Feature | Description |
|---------|-------------|
| Loan Application Form | Simple form with Name, Requested Amount, Tax ID fields |
| Form Submission | Submit button triggers REST API call |
| Result Display | Shows loan decision (Approved/Rejected/Manual Review) |

#### REST API Layer
| Feature | Description |
|---------|-------------|
| Submit Endpoint | POST endpoint receives loan application JSON |
| CORS Support | Enabled for Angular frontend integration |
| Response Handling | Returns decision result to frontend |

#### IRIS Interoperability Production
| Component | Description |
|-----------|-------------|
| Business Service | Receives REST request, creates message |
| Business Process | Orchestrates the loan decision workflow |
| Data Persistence | Stores loan application in IRIS |
| Credit Bureau Simulation | Generates randomized credit score |
| Business Rules | Score-based decisioning (>700 Approved, <500 Rejected, else Manual Review) |
| Business Operation | Returns decision response |

#### Demo Visualization
| Feature | Description |
|---------|-------------|
| Workflow Trace | Visual message trace in IRIS Management Portal |

### Out of Scope for MVP

The following are explicitly excluded from the demo:

| Excluded Feature | Rationale |
|------------------|-----------|
| User Authentication/Login | Adds complexity without demonstrating core IRIS capabilities |
| Application History/List View | Not essential for showing the workflow pattern |
| Admin Dashboard | Beyond scope of 60-minute build |
| Multiple Loan Types | Single loan type sufficient for demo |
| Real External API Calls | Simulated Credit Bureau achieves same demo effect |
| Error Handling UI | Basic error handling only; no elaborate UX |
| Database Migrations | Use simple persistent class structure |
| Unit Tests | Demo focus is on working application, not test coverage |

### MVP Success Criteria

The demo MVP is successful when:

| Criterion | Validation |
|-----------|------------|
| Form Submission | User can enter data and submit without errors |
| End-to-End Flow | Data flows from Angular → REST → IRIS Production → Response |
| Decision Logic | Correct decision returned based on credit score rules |
| Workflow Visibility | Message trace visible in IRIS Management Portal |
| Build Time | Completed within 60-minute window |
| Live Execution | Zero critical failures during demonstration |

### Future Vision

While not part of the conference demo, potential extensions include:

| Future Enhancement | Description |
|--------------------|-------------|
| Application Dashboard | View all submitted applications and their statuses |
| Real Credit Bureau Integration | Connect to actual credit scoring APIs |
| Multiple Loan Products | Support different loan types with varying rules |
| Document Upload | Allow supporting document attachment |
| Notification System | Email/SMS notifications for application status |
| Reporting & Analytics | Loan approval rates, processing times |
| Multi-tenant Support | Support multiple lending institutions |

*These extensions demonstrate how the demo foundation could evolve into a production system.*
