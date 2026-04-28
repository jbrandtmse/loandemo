Class LoanDemo.Production Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="LoanDemo.Production">
  <Description>Smart Loan Broker Production</Description>
  <ActorPoolSize>2</ActorPoolSize>
  <Item Name="LoanService" Category="" ClassName="LoanDemo.Service.LoanService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="LoanBroker" Category="" ClassName="LoanDemo.Process.LoanBroker" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="CreditBureau" Category="" ClassName="LoanDemo.Operation.CreditBureau" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="LoanPersistence" Category="" ClassName="LoanDemo.Operation.LoanPersistence" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
</Production>
}

}
