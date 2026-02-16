---
project_name: 'loandemo-1'
user_name: 'Developer'
date: '2026-01-19'
sections_completed: [technology_stack, objectscript_rules, iris_rules, testing_rules, code_quality, critical_rules]
existing_patterns_found: 8
status: 'complete'
---

# Project Context for AI Agents

_This file contains critical rules and patterns that AI agents must follow when implementing code in this project. Focus on unobvious details that agents might otherwise miss._

---

## Technology Stack & Versions

| Layer | Technology | Version/Notes |
|-------|------------|---------------|
| Backend Platform | InterSystems IRIS | HSCUSTOM namespace |
| Backend Language | ObjectScript | Native IRIS |
| API Framework | %CSP.REST | With CORS support |
| Orchestration | Interoperability Production | BPL for Business Process |
| Frontend Framework | Angular | 17+ (standalone components) |
| Frontend Language | TypeScript | Strict mode |
| UI Components | Angular Material | Latest |
| Forms | Reactive Forms | Type-safe |

---

## ObjectScript Language Rules

### Naming Conventions (CRITICAL)
- **Classes/Methods:** CamelCase only - `GetCreditScore`, `LoanApplication`
- **Parameters:** MUST start with `p` - `pRequest`, `pInput`, `pOutput`
- **Local Variables:** MUST start with `t` - `tSC`, `tStatus`, `tResult`
- **NO UNDERSCORES:** Never use underscores anywhere in ObjectScript code

### Method Pattern (MANDATORY)
Every method returning status MUST follow this pattern:
```objectscript
Method MyMethod(pInput As %String) As %Status
{
    Set tSC = $$$OK
    Try {
        // Logic here
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}
```

### Try/Catch Limitations
- **NEVER** use `Quit` with arguments inside a Try block
- Set a variable inside Try, Quit after Catch block
- Use `ex.AsStatus()` to convert exceptions to %Status

### Macros
- Use `$$$OK` for success status
- Use `$$$ISERR(tSC)` to check for errors
- Use `$$$LOGERROR` for logging errors

---

## IRIS Interoperability Rules

### Business Service Pattern
```objectscript
Class MyPackage.Service.MyService Extends Ens.BusinessService
{
    Method OnProcessInput(pInput As %RegisteredObject, Output pOutput As %RegisteredObject, ByRef pHint As %String) As %Status
    {
        // Implementation
    }
}
```

### Business Operation Pattern
```objectscript
Class MyPackage.Operation.MyOperation Extends Ens.BusinessOperation
{
    Parameter ADAPTER = "EnsLib.HTTP.OutboundAdapter";

    Method OnMessage(pRequest As MyRequest, Output pResponse As MyResponse) As %Status
    {
        // Implementation
    }
}
```

### Message Classes
- Extend `Ens.Request` or `Ens.Response`
- Properties use CamelCase: `ApplicantName`, `RequestedAmount`
- Use appropriate types: `%String`, `%Integer`, `%Numeric`, `%TimeStamp`

### REST Integration
- MANDATORY: `Parameter HandleCorsRequest = 1;` for Angular
- Use `%DynamicObject` for JSON handling
- Define routes in `XData UrlMap`

---

## Testing Rules (%UnitTest)

### Test Class Structure
- Extend `%UnitTest.TestCase`
- Test methods start with `Test`: `TestApprovedDecision`

### Assertion Macros (CRITICAL)
**ONLY USE THESE MACROS:**
- `$$$AssertEquals(actual, expected, "message")`
- `$$$AssertTrue(condition, "message")`
- `$$$AssertStatusOK(sc, "message")`

**NEVER USE:**
- `..AssertEquals()` - method calls don't work
- `$$$AssertFalse` - doesn't exist
- `$$$AssertCondition` - doesn't exist
- `Do ..Assert...` - wrong syntax

### Example Test
```objectscript
Method TestApprovedDecision()
{
    Set tScore = 750
    Set tDecision = ##class(LoanDemo.Rule.DecisionLogic).GetDecision(tScore)
    $$$AssertEquals(tDecision, "Approved", "Score 750 should be Approved")
}
```

---

## Code Quality & Style Rules

### Class Size
- Keep classes under 700 lines
- Split large classes into smaller focused classes

### Property Declarations
- MultiDimensional properties: NO datatype
  - WRONG: `Property Data As %String [ MultiDimensional ];`
  - RIGHT: `Property Data [ MultiDimensional ];`

### Abstract Methods
- Must have body with `{}` even if abstract
- Must return a value: `Quit $$$OK` or `Quit ""`

### JSON Field Naming
- Use camelCase for all JSON fields: `applicantName`, `requestedAmount`
- Match TypeScript interface property names

### Angular Patterns
- Component files: kebab-case (`loan-form.component.ts`)
- Component classes: PascalCase (`LoanFormComponent`)
- Services: PascalCase + Service suffix (`LoanService`)
- Use `environment.ts` for API URL configuration
- Return `Observable<T>` from HTTP services

---

## Critical Don't-Miss Rules

### Anti-Patterns to AVOID

| DON'T | DO |
|-------|-----|
| `user_name` | `UserName` or `userName` |
| `Quit tSC` inside Try | Set variable, Quit after Catch |
| `..AssertEquals()` | `$$$AssertEquals()` |
| `$$$AssertFalse` | Use `$$$AssertTrue('condition)` |
| `##class(%SYS.Python).IsAvailable()` | Use `Import` then `GetPythonVersion` |

### Production Configuration
- Business Service must be registered in Production
- Enable workflow tracing for demo visibility
- CORS must be enabled before Angular can connect

### Decision Logic (Business Rules)
- Score > 700: "Approved"
- Score < 500: "Rejected"
- Score 500-700: "Manual Review"
- Isolate in `LoanDemo.Rule.DecisionLogic` for testability

---

**Document Status:** COMPLETE
**Last Updated:** 2026-01-19
