Class LoanDemo.Service.LoanService Extends Ens.BusinessService
{

Parameter ADAPTER = "Ens.InboundAdapter";

Method OnProcessInput(pInput As LoanDemo.Message.LoanRequest, Output pOutput As LoanDemo.Message.LoanResponse, ByRef pHint As %String) As %Status
{
    Set tSC = $$$OK
    Try {
        // Ens.InboundAdapter polls every CallInterval seconds with no real input.
        // Only forward to LoanBroker when invoked via the REST dispatcher with a real LoanRequest.
        If '$IsObject($Get(pInput)) Quit
        If 'pInput.%IsA("LoanDemo.Message.LoanRequest") Quit
        Set tSC = ..SendRequestSync("LoanBroker", pInput, .pOutput)
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

}
