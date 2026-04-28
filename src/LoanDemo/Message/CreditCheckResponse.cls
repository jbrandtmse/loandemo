Class LoanDemo.Message.CreditCheckResponse Extends Ens.Response
{

Property CreditScore As %Integer;

Storage Default
{
<Data name="CreditCheckResponseDefaultData">
<Subscript>"CreditCheckResponse"</Subscript>
<Value name="1">
<Value>CreditScore</Value>
</Value>
</Data>
<DefaultData>CreditCheckResponseDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
