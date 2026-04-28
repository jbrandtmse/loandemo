Class LoanDemo.Message.LoanUpdateRequest Extends Ens.Request
{

Property ApplicationId As %Integer;

Property CreditScore As %Integer;

Property Decision As %String(MAXLEN = 50);

Storage Default
{
<Data name="LoanUpdateRequestDefaultData">
<Subscript>"LoanUpdateRequest"</Subscript>
<Value name="1">
<Value>ApplicationId</Value>
</Value>
<Value name="2">
<Value>CreditScore</Value>
</Value>
<Value name="3">
<Value>Decision</Value>
</Value>
</Data>
<DefaultData>LoanUpdateRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
