# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Smart Loan Broker** - Full-stack decoupled application with Angular 17+ frontend and InterSystems IRIS backend (ObjectScript). Communication via REST API layer connecting to Interoperability Productions.

## IRIS Connection

- **Namespace:** HSCUSTOM
- **Server:** localhost-healthshare (http://localhost:8880)
- **Credentials:** _SYSTEM/_SYSTEM
- **Compile flags:** bckry

## Build & Test Commands

```bash
# Compile a class via MCP tool
mcp__iris-execute-mcp__compile_objectscript_class --class_names "MyPackage.MyClass.cls"

# Compile entire package
mcp__iris-execute-mcp__compile_objectscript_package --package_name "MyPackage"

# Run unit tests
mcp__iris-execute-mcp__execute_unit_tests --test_spec "MyPackage.Test"

# Run single test method
mcp__iris-execute-mcp__execute_unit_tests --test_spec "MyPackage.Test.MyTestClass:TestMethodName"

# Execute ObjectScript class method
mcp__iris-execute-mcp__execute_classmethod --class_name "MyClass" --method_name "MyMethod"
```

## ObjectScript Conventions

### Naming (NO underscores anywhere)
- **Classes/Methods:** CamelCase (`UpdateLoanStatus`)
- **Parameters:** Prefix with `p` (`pInput`, `pRequest`)
- **Local Variables:** Prefix with `t` (`tStatus`, `tSC`)
- **Macros:** `$$$` syntax (`$$$OK`, `$$$ISERR`)

### Method Pattern
Always return `%Status` with Try/Catch:
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

### REST API
- Extend `%CSP.REST`
- **MANDATORY:** `Parameter HandleCorsRequest = 1` for Angular integration
- Use `%DynamicObject` for JSON, routes in `XData UrlMap`

### Interoperability
- **Business Services:** Extend `Ens.BusinessService`, implement `OnProcessInput(pInput, Output pOutput, ByRef pHint)`
- **Business Operations:** Extend `Ens.BusinessOperation`, implement `OnMessage(pRequest, Output pResponse)`
- Define adapters explicitly: `Parameter ADAPTER = "EnsLib.HTTP.OutboundAdapter"`

## ObjectScript Unit Testing (%UnitTest)

Extend `%UnitTest.TestCase`. **Use macros only, not methods:**
```objectscript
$$$AssertEquals(actual, expected, "message")
$$$AssertTrue(condition, "message")
$$$AssertStatusOK(sc, "message")
```

**WRONG:** `..AssertEquals`, `$$$AssertFalse`, `$$$AssertCondition`, `Do ..Assert...`

ObjectScript Unit tests must return a %Status value, such as `QUIT $$$$OK`

## Critical Constraints

1. **NO underscores** in class names, method names, or parameter names
2. **Try/Catch:** Do NOT use `Quit` with arguments inside Try/Catch - set a variable and quit after the catch block
3. **Class size:** Keep under 700 lines, split if larger
4. **MultiDimensional properties:** No datatype - `Property Data [ MultiDimensional ];` not `Property Data As %String [ MultiDimensional ];`
5. **Abstract methods:** Must have body with `{}` and return value, even if abstract
6. **Python check:** Do NOT use `##class(%SYS.Python).IsAvailable()` - use `Import` then `GetPythonVersion`

## IRIS File Sync & Compilation

- **Auto-load:** ObjectScript `.cls` files are automatically loaded to the IRIS server when saved (folder trigger)
- **Compile:** Use the MCP server tool to compile classes — files auto-load but still need explicit compilation
- **Unit tests:** Use the MCP server tool to execute unit tests — cannot run tests via bash

## Angular Frontend

- Use `HttpClient`, configure API URL via `environment.ts`
- TypeScript interfaces must match Swagger/OpenAPI JSON structure
- Avoid `any` - use typed interfaces