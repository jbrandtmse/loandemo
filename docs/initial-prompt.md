Build a "Smart Loan Broker" application.   Follow the architectural patters in context.md.  The system consists of an Angular frontend that submits loan applications (fields: Name, Requested Amount, Tax ID) via a REST API to an InterSystems IRIS backend.

The backend logic must be implemented using an Interoperability Production. The workflow requires a Business Process that acts as a broker: it persists the application, simulates a call to an external Credit Bureau (randomized score), and applies business rules (Score > 700 is "Approved", < 500 is "Rejected", else "Manual Review").

Create ObjectScript code in src/LoanDemo