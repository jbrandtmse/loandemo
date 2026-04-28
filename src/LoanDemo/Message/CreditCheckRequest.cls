Class LoanDemo.Message.CreditCheckRequest Extends Ens.Request
{

Property TaxId As %String(MAXLEN = 50);

Storage Default
{
<Data name="CreditCheckRequestDefaultData">
<Subscript>"CreditCheckRequest"</Subscript>
<Value name="1">
<Value>TaxId</Value>
</Value>
</Data>
<DefaultData>CreditCheckRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
