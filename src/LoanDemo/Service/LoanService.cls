Class LoanDemo.Service.LoanService Extends Ens.BusinessService
{

Parameter ADAPTER = "Ens.InboundAdapter";

Method OnProcessInput(pInput As LoanDemo.Message.LoanRequest, Output pOutput As LoanDemo.Message.LoanResponse, ByRef pHint As %String) As %Status
{
    Set tSC = $$$OK
    Try {
        Set tApp = ##class(LoanDemo.Data.LoanApplication).%New()
        Set tApp.ApplicantName = pInput.ApplicantName
        Set tApp.RequestedAmount = pInput.RequestedAmount
        Set tApp.TaxId = pInput.TaxId
        Set tApp.CreditScore = 0
        Set tApp.Decision = "Pending"
        Set tApp.CreatedDate = $ZDateTime($Horolog, 3)
        Set tSaveSC = tApp.%Save()
        If $$$ISERR(tSaveSC) {
            Set tSC = tSaveSC
            Quit
        }
        Set pOutput = ##class(LoanDemo.Message.LoanResponse).%New()
        Set pOutput.ApplicationId = tApp.ApplicationId
        Set pOutput.Decision = "Pending"
        Set pOutput.CreditScore = 0
        Set pOutput.Status = "success"
        Set pOutput.Message = "Application received"
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

}
