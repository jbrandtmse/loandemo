Class LoanDemo.Test.DecisionLogicTest Extends %UnitTest.TestCase
{

Method TestApprovedAtBoundary() As %Status
{
    Set tDecision = ##class(LoanDemo.Rule.DecisionLogic).GetDecision(750)
    Set tAssert = $$$AssertEquals(tDecision, "Approved", "Score 750 should yield Approved")
    Quit $$$OK
}

Method TestRejected() As %Status
{
    Set tDecision = ##class(LoanDemo.Rule.DecisionLogic).GetDecision(450)
    Set tAssert = $$$AssertEquals(tDecision, "Rejected", "Score 450 should yield Rejected")
    Quit $$$OK
}

Method TestManualReview() As %Status
{
    Set tDecision = ##class(LoanDemo.Rule.DecisionLogic).GetDecision(600)
    Set tAssert = $$$AssertEquals(tDecision, "Manual Review", "Score 600 should yield Manual Review")
    Quit $$$OK
}

Method TestBoundaryHigh() As %Status
{
    Set tDecisionHigh = ##class(LoanDemo.Rule.DecisionLogic).GetDecision(701)
    Set tAssert = $$$AssertEquals(tDecisionHigh, "Approved", "Score 701 should yield Approved")
    Set tDecisionEdge = ##class(LoanDemo.Rule.DecisionLogic).GetDecision(700)
    Set tAssert = $$$AssertEquals(tDecisionEdge, "Manual Review", "Score 700 should yield Manual Review")
    Quit $$$OK
}

Method TestBoundaryLow() As %Status
{
    Set tDecisionEdge = ##class(LoanDemo.Rule.DecisionLogic).GetDecision(500)
    Set tAssert = $$$AssertEquals(tDecisionEdge, "Manual Review", "Score 500 should yield Manual Review")
    Set tDecisionLow = ##class(LoanDemo.Rule.DecisionLogic).GetDecision(499)
    Set tAssert = $$$AssertEquals(tDecisionLow, "Rejected", "Score 499 should yield Rejected")
    Quit $$$OK
}

}
