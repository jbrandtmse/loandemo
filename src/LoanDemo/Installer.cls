/// Idempotent installer for the LoanDemo REST web application.
/// Creates (or updates) /loandemo/api dispatching to LoanDemo.REST.Dispatcher
/// with password + unauthenticated access enabled for the demo.
/// 
/// Usage (from any namespace):
///   Do ##class(LoanDemo.Installer).Setup()
///   Do ##class(LoanDemo.Installer).Uninstall()
/// 
/// Or via MCP:
///   mcp__iris-dev-mcp__iris_execute_classmethod className=LoanDemo.Installer methodName=Setup
Class LoanDemo.Installer Extends %RegisteredObject
{

Parameter WEBAPPNAME = "/loandemo/api";

Parameter DISPATCHCLASS = "LoanDemo.REST.Dispatcher";

Parameter TARGETNAMESPACE = "HSCUSTOM";

/// AutheEnabled = 96 = password (32) + unauthenticated (64). See project memory.
Parameter AUTHEENABLED = 96;

Parameter MATCHROLES = ":%All";

/// Run the full setup: install the REST web application. Returns %Status.
/// Safe to run multiple times — existing web apps are updated in place.
ClassMethod Setup() As %Status
{
    Set tSC = $$$OK
    Try {
        Set tSC = ..InstallWebApp()
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Create or update the REST web application in %SYS.
ClassMethod InstallWebApp() As %Status
{
    Set tSC = $$$OK
    Try {
        New $Namespace
        Set $Namespace = "%SYS"

        Set tName = ..#WEBAPPNAME

        Kill tProps
        Set tProps("DispatchClass") = ..#DISPATCHCLASS
        Set tProps("NameSpace") = ..#TARGETNAMESPACE
        Set tProps("AutheEnabled") = ..#AUTHEENABLED
        Set tProps("MatchRoles") = ..#MATCHROLES
        Set tProps("Enabled") = 1
        Set tProps("CSPZENEnabled") = 1
        Set tProps("DeepSeeEnabled") = 0
        Set tProps("IsNameSpaceDefault") = 0

        Set tExists = ##class(Security.Applications).Exists(tName)

        If tExists {
            Set tSC = ##class(Security.Applications).Modify(tName, .tProps)
        } Else {
            Set tSC = ##class(Security.Applications).Create(tName, .tProps)
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Remove the REST web application. Safe to run when the app does not exist.
ClassMethod Uninstall() As %Status
{
    Set tSC = $$$OK
    Try {
        New $Namespace
        Set $Namespace = "%SYS"

        Set tName = ..#WEBAPPNAME

        If ##class(Security.Applications).Exists(tName) {
            Set tSC = ##class(Security.Applications).Delete(tName)
        }
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Report current install state as a JSON string with the live web app properties.
/// Returns a JSON object: {installed, name, dispatchClass, namespace, autheEnabled, matchRoles, enabled}.
/// Safe to call via MCP — no Write side effects.
ClassMethod Status() As %String
{
    Set tInfo = {}
    Try {
        New $Namespace
        Set $Namespace = "%SYS"

        Set tName = ..#WEBAPPNAME
        Set tInfo.name = tName

        If '##class(Security.Applications).Exists(tName) {
            Set tInfo.installed = 0
            Quit
        }

        Kill tProps
        Set tSC = ##class(Security.Applications).Get(tName, .tProps)
        If $$$ISERR(tSC) {
            Set tInfo.installed = 1
            Set tInfo.error = $System.Status.GetErrorText(tSC)
            Quit
        }

        Set tInfo.installed = 1
        Set tInfo.dispatchClass = $Get(tProps("DispatchClass"))
        Set tInfo.namespace = $Get(tProps("NameSpace"))
        Set tInfo.autheEnabled = +$Get(tProps("AutheEnabled"))
        Set tInfo.matchRoles = $Get(tProps("MatchRoles"))
        Set tInfo.enabled = +$Get(tProps("Enabled"))
    }
    Catch ex {
        Set tInfo.error = ex.DisplayString()
    }
    Quit tInfo.%ToJSON()
}

}
