export type LoanDecision = 'Approved' | 'Rejected' | 'Manual Review' | 'Pending';

export interface LoanResponse {
  status: 'success' | 'error';
  applicationId?: number;
  decision?: LoanDecision;
  creditScore?: number;
  message?: string;
}
