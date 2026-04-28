Class LoanDemo.Message.LoanRequest Extends Ens.Request
{

Property ApplicantName As %String(MAXLEN = 200);

Property RequestedAmount As %Numeric;

Property TaxId As %String(MAXLEN = 50);

Storage Default
{
<Data name="LoanRequestDefaultData">
<Subscript>"LoanRequest"</Subscript>
<Value name="1">
<Value>ApplicantName</Value>
</Value>
<Value name="2">
<Value>RequestedAmount</Value>
</Value>
<Value name="3">
<Value>TaxId</Value>
</Value>
</Data>
<DefaultData>LoanRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
