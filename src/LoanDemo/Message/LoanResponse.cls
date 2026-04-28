Class LoanDemo.Message.LoanResponse Extends Ens.Response
{

Property ApplicationId As %Integer;

Property Decision As %String(MAXLEN = 50);

Property CreditScore As %Integer;

Property Status As %String(MAXLEN = 20);

Property Message As %String(MAXLEN = 500);

Storage Default
{
<Data name="LoanResponseDefaultData">
<Subscript>"LoanResponse"</Subscript>
<Value name="1">
<Value>ApplicationId</Value>
</Value>
<Value name="2">
<Value>Decision</Value>
</Value>
<Value name="3">
<Value>CreditScore</Value>
</Value>
<Value name="4">
<Value>Status</Value>
</Value>
<Value name="5">
<Value>Message</Value>
</Value>
</Data>
<DefaultData>LoanResponseDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
