Class LoanDemo.Data.LoanApplication Extends %Persistent
{

Property ApplicationId As %AutoIncrement;

Property ApplicantName As %String(MAXLEN = 200);

Property RequestedAmount As %Numeric;

Property TaxId As %String(MAXLEN = 50);

Property CreditScore As %Integer;

Property Decision As %String(MAXLEN = 50);

Property CreatedDate As %TimeStamp [ InitialExpression = {$ZDateTime($Horolog, 3)} ];

Index ApplicationIdIdx On ApplicationId [ Unique ];

Storage Default
{
<CounterLocation>^LoanDemo.Data.LoanApplicationC</CounterLocation>
<Data name="LoanApplicationDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>ApplicationId</Value>
</Value>
<Value name="3">
<Value>ApplicantName</Value>
</Value>
<Value name="4">
<Value>RequestedAmount</Value>
</Value>
<Value name="5">
<Value>TaxId</Value>
</Value>
<Value name="6">
<Value>CreditScore</Value>
</Value>
<Value name="7">
<Value>Decision</Value>
</Value>
<Value name="8">
<Value>CreatedDate</Value>
</Value>
</Data>
<DataLocation>^LoanDemo.Data.LoanApplicationD</DataLocation>
<DefaultData>LoanApplicationDefaultData</DefaultData>
<IdLocation>^LoanDemo.Data.LoanApplicationD</IdLocation>
<IndexLocation>^LoanDemo.Data.LoanApplicationI</IndexLocation>
<StreamLocation>^LoanDemo.Data.LoanApplicationS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
