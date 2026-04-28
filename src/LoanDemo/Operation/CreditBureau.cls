Class LoanDemo.Operation.CreditBureau Extends Ens.BusinessOperation
{

Parameter INVOCATION = "Queue";

/// Simulated credit bureau lookup. Returns a deterministic credit score in [300, 850]
/// derived from the TaxId via $ZCRC mode 7. We use $ZCRC (not $ZHash) per project memory:
/// $ZHash returns binary and throws <SYNTAX> when used with the # modulo operator.
Method CheckCredit(pRequest As LoanDemo.Message.CreditCheckRequest, Output pResponse As LoanDemo.Message.CreditCheckResponse) As %Status
{
    Set tSC = $$$OK
    Try {
        Set pResponse = ##class(LoanDemo.Message.CreditCheckResponse).%New()
        Set tScore = (($ZCRC(pRequest.TaxId, 7) # 551) + 300)
        Set pResponse.CreditScore = tScore
    }
    Catch ex {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

XData MessageMap
{
<MapItems>
  <MapItem MessageType="LoanDemo.Message.CreditCheckRequest">
    <Method>CheckCredit</Method>
  </MapItem>
</MapItems>
}

}
