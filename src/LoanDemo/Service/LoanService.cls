Class LoanDemo.Service.LoanService Extends Ens.BusinessService
{

Parameter ADAPTER = "Ens.InboundAdapter";

Method OnProcessInput(pInput As LoanDemo.Message.LoanRequest, Output pOutput As LoanDemo.Message.LoanResponse, ByRef pHint As %String) As %Status
{
    Set tSC = $$$OK
    Try {
        Set tSC = ..SendRequestSync("LoanBroker", pInput, .pOutput)
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

}
