Class LoanDemo.Operation.LoanPersistence Extends Ens.BusinessOperation
{

Parameter INVOCATION = "Queue";

/// Saves a new LoanApplication row from the incoming LoanRequest. Sets ApplicationId on the response.
Method SaveLoan(pRequest As LoanDemo.Message.LoanRequest, Output pResponse As LoanDemo.Message.LoanResponse) As %Status
{
    Set tSC = $$$OK
    Try {
        Set tApp = ##class(LoanDemo.Data.LoanApplication).%New()
        Set tApp.ApplicantName = pRequest.ApplicantName
        Set tApp.RequestedAmount = pRequest.RequestedAmount
        Set tApp.TaxId = pRequest.TaxId
        Set tApp.CreditScore = 0
        Set tApp.Decision = "Pending"
        Set tApp.CreatedDate = $ZDateTime($Horolog, 3)
        Set tSaveSC = tApp.%Save()
        If $$$ISERR(tSaveSC) {
            Set tSC = tSaveSC
            Quit
        }
        Set pResponse = ##class(LoanDemo.Message.LoanResponse).%New()
        Set pResponse.ApplicationId = tApp.ApplicationId
        Set pResponse.Status = "success"
        Set pResponse.Decision = "Pending"
        Set pResponse.CreditScore = 0
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

/// Updates an existing LoanApplication row with the credit score and decision.
Method UpdateLoan(pRequest As LoanDemo.Message.LoanUpdateRequest, Output pResponse As Ens.Response) As %Status
{
    Set tSC = $$$OK
    Try {
        Set tApp = ##class(LoanDemo.Data.LoanApplication).ApplicationIdIdxOpen(pRequest.ApplicationId)
        If '$IsObject(tApp) {
            Set tSC = $$$ERROR($$$GeneralError, "LoanApplication not found for ApplicationId " _ pRequest.ApplicationId)
            Quit
        }
        Set tApp.CreditScore = pRequest.CreditScore
        Set tApp.Decision = pRequest.Decision
        Set tSaveSC = tApp.%Save()
        If $$$ISERR(tSaveSC) {
            Set tSC = tSaveSC
            Quit
        }
        Set pResponse = ##class(Ens.Response).%New()
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

XData MessageMap
{
<MapItems>
  <MapItem MessageType="LoanDemo.Message.LoanRequest">
    <Method>SaveLoan</Method>
  </MapItem>
  <MapItem MessageType="LoanDemo.Message.LoanUpdateRequest">
    <Method>UpdateLoan</Method>
  </MapItem>
</MapItems>
}

}
