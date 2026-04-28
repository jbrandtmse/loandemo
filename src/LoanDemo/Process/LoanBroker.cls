Class LoanDemo.Process.LoanBroker Extends Ens.BusinessProcessBPL
{

Parameter REQUESTCLASSLIST = "LoanDemo.Message.LoanRequest";

Parameter RESPONSECLASSLIST = "LoanDemo.Message.LoanResponse";

Property ApplicationId As %Integer;

Property CreditScore As %Integer;

Property Decision As %String(MAXLEN = 50);

XData BPL [ XMLNamespace = "http://www.intersystems.com/bpl" ]
{
<process language='objectscript' request='LoanDemo.Message.LoanRequest' response='LoanDemo.Message.LoanResponse' contextsuperclass='Ens.BP.Context' height='2000' width='2000' >
<context>
<property name='ApplicationId' type='%Integer' instantiate='0' />
<property name='CreditScore' type='%Integer' instantiate='0' />
<property name='Decision' type='%String' instantiate='0' />
</context>
<sequence xend='200' yend='1500' >
<call name='SaveInitial' target='LoanPersistence' async='0' xpos='200' ypos='250' >
<request type='LoanDemo.Message.LoanRequest' >
<assign property="callrequest.ApplicantName" value="request.ApplicantName" action="set" />
<assign property="callrequest.RequestedAmount" value="request.RequestedAmount" action="set" />
<assign property="callrequest.TaxId" value="request.TaxId" action="set" />
</request>
<response type='LoanDemo.Message.LoanResponse' >
<assign property="context.ApplicationId" value="callresponse.ApplicationId" action="set" />
</response>
</call>
<call name='CreditCheck' target='CreditBureau' async='0' xpos='200' ypos='400' >
<request type='LoanDemo.Message.CreditCheckRequest' >
<assign property="callrequest.TaxId" value="request.TaxId" action="set" />
</request>
<response type='LoanDemo.Message.CreditCheckResponse' >
<assign property="context.CreditScore" value="callresponse.CreditScore" action="set" />
</response>
</call>
<assign name='EvaluateDecision' property="context.Decision" value='##class(LoanDemo.Rule.DecisionLogic).GetDecision(context.CreditScore)' action="set" xpos='200' ypos='550' />
<call name='Update' target='LoanPersistence' async='0' xpos='200' ypos='700' >
<request type='LoanDemo.Message.LoanUpdateRequest' >
<assign property="callrequest.ApplicationId" value="context.ApplicationId" action="set" />
<assign property="callrequest.CreditScore" value="context.CreditScore" action="set" />
<assign property="callrequest.Decision" value="context.Decision" action="set" />
</request>
<response type='Ens.Response' />
</call>
<assign name='BuildResponse' property="response.ApplicationId" value="context.ApplicationId" action="set" xpos='200' ypos='850' />
<assign name='SetDecision' property="response.Decision" value="context.Decision" action="set" xpos='200' ypos='1000' />
<assign name='SetScore' property="response.CreditScore" value="context.CreditScore" action="set" xpos='200' ypos='1150' />
<assign name='SetStatus' property="response.Status" value='"success"' action="set" xpos='200' ypos='1300' />
</sequence>
</process>
}

Storage Default
{
<Data name="LoanBrokerDefaultData">
<Subscript>"LoanBroker"</Subscript>
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
<DefaultData>LoanBrokerDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
