Class LoanDemo.REST.Dispatcher Extends %CSP.REST
{

Parameter HandleCorsRequest = 1;

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
<Route Url="/loan/apply" Method="POST" Call="ApplyLoan"/>
</Routes>
}

ClassMethod ApplyLoan() As %Status
{
    Set tSC = $$$OK
    Try {
        Set %response.ContentType = "application/json"
        Set tContent = ""
        If $IsObject(%request.Content) {
            Do %request.Content.Rewind()
            Set tContent = %request.Content.Read($$$MaxStringLength)
        } Else {
            Set tContent = %request.Content
        }
        If tContent = "" {
            Set %response.Status = "400 Bad Request"
            Set tErr = {"status":"error","message":"Empty request body"}
            Write tErr.%ToJSON()
            Quit
        }
        Set tParsed = 0
        Try {
            Set tJson = ##class(%DynamicObject).%FromJSON(tContent)
            Set tParsed = 1
        } Catch parseEx {
            Set tParsed = 0
        }
        If 'tParsed {
            Set %response.Status = "400 Bad Request"
            Set tErr = {"status":"error","message":"Malformed JSON body"}
            Write tErr.%ToJSON()
            Quit
        }
        If '$IsObject(tJson) || (tJson.%Extends("%Library.DynamicArray")) {
            Set %response.Status = "400 Bad Request"
            Set tErr = {"status":"error","message":"Request body must be a JSON object"}
            Write tErr.%ToJSON()
            Quit
        }
        Set tApplicantName = tJson.%Get("applicantName")
        Set tRequestedAmount = tJson.%Get("requestedAmount")
        Set tTaxId = tJson.%Get("taxId")
        If (tApplicantName = "") || (tApplicantName = $$$NULLOREF) || (tTaxId = "") || (tTaxId = $$$NULLOREF) || (tRequestedAmount = "") || (tRequestedAmount = $$$NULLOREF) {
            Set %response.Status = "400 Bad Request"
            Set tErr = {"status":"error","message":"Missing required field (applicantName, requestedAmount, taxId)"}
            Write tErr.%ToJSON()
            Quit
        }
        If '$IsValidNum(tRequestedAmount) || (tRequestedAmount <= 0) {
            Set %response.Status = "400 Bad Request"
            Set tErr = {"status":"error","message":"requestedAmount must be a positive number"}
            Write tErr.%ToJSON()
            Quit
        }
        If $Length(tApplicantName) > 200 {
            Set %response.Status = "400 Bad Request"
            Set tErr = {"status":"error","message":"applicantName exceeds maximum length of 200"}
            Write tErr.%ToJSON()
            Quit
        }
        If $Length(tTaxId) > 50 {
            Set %response.Status = "400 Bad Request"
            Set tErr = {"status":"error","message":"taxId exceeds maximum length of 50"}
            Write tErr.%ToJSON()
            Quit
        }
        Set tRequest = ##class(LoanDemo.Message.LoanRequest).%New()
        Set tRequest.ApplicantName = tApplicantName
        Set tRequest.RequestedAmount = tRequestedAmount
        Set tRequest.TaxId = tTaxId
        Set tCreateSC = ##class(Ens.Director).CreateBusinessService("LoanService", .tService)
        If $$$ISERR(tCreateSC) {
            Do ##class(Ens.Util.Log).LogError("LoanDemo.REST.Dispatcher", "ApplyLoan", $System.Status.GetErrorText(tCreateSC))
            Set %response.Status = "500 Internal Server Error"
            Set tErr = {"status":"error","message":"Service unavailable"}
            Write tErr.%ToJSON()
            Quit
        }
        Set tProcessSC = tService.OnProcessInput(tRequest, .tResponse)
        If $$$ISERR(tProcessSC) {
            Do ##class(Ens.Util.Log).LogError("LoanDemo.REST.Dispatcher", "ApplyLoan", $System.Status.GetErrorText(tProcessSC))
            Set %response.Status = "500 Internal Server Error"
            Set tErr = {"status":"error","message":"Internal server error"}
            Write tErr.%ToJSON()
            Quit
        }
        Set tOut = {}
        Set tOut.status = tResponse.Status
        Set tOut.applicationId = tResponse.ApplicationId
        Set tOut.decision = tResponse.Decision
        Set tOut.creditScore = tResponse.CreditScore
        If tResponse.Message '= "" {
            Set tOut.message = tResponse.Message
        }
        Write tOut.%ToJSON()
    }
    Catch ex {
        Do ##class(Ens.Util.Log).LogError("LoanDemo.REST.Dispatcher", "ApplyLoan", ex.DisplayString())
        Set %response.Status = "500 Internal Server Error"
        Set tErrOut = {"status":"error","message":"Internal server error"}
        Write tErrOut.%ToJSON()
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

}
