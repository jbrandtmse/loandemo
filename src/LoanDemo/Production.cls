Class LoanDemo.Production Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="LoanDemo.Production">
  <Description>Smart Loan Broker Production</Description>
  <ActorPoolSize>2</ActorPoolSize>
  <Item Name="LoanService" Category="" ClassName="LoanDemo.Service.LoanService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
</Production>
}

}
