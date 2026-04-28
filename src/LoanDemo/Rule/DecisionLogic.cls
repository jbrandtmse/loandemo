Class LoanDemo.Rule.DecisionLogic Extends %RegisteredObject
{

/// Returns the loan decision based on a credit score.
/// Boundary semantics:
///   score > 700           -> "Approved"
///   score < 500           -> "Rejected"
///   500 <= score <= 700   -> "Manual Review"  (score=500 and score=700 are intentionally Manual Review)
ClassMethod GetDecision(pCreditScore As %Integer) As %String
{
    Set tDecision = "Manual Review"
    Try {
        If pCreditScore > 700 {
            Set tDecision = "Approved"
        }
        ElseIf pCreditScore < 500 {
            Set tDecision = "Rejected"
        }
        Else {
            Set tDecision = "Manual Review"
        }
    }
    Catch ex {
        Set tDecision = "Manual Review"
    }
    Quit tDecision
}

}
