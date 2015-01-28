---1.创建中间表,保存需要导入的押金余额账本以及账目类型，剔除账户小于0与缴纳押金后又退出的情况
DROP TABLE fsboss_cash_deposit;
CREATE TABLE fsboss_cash_deposit AS
SELECT pi.customeraccountbalanceid, pi.pricetypeid
  FROM fsboss.paymentitems_fs pi, fsboss.customeraccountbalances_fs accb
 WHERE accb.id = pi.customeraccountbalanceid
   AND accb.balancetypeid = 9223372030852305573
   AND accb.amount > 0
 GROUP BY pi.customeraccountbalanceid, pi.pricetypeid
HAVING SUM(pi.amount) > 0;

-- 增加索引
CREATE INDEX index_deposit_1 ON fsboss_cash_deposit(customeraccountbalanceid);
CREATE INDEX index_deposit_2 ON fsboss_cash_deposit(pricetypeid);

DROP TABLE fsboss_cash_deposit_detail;
CREATE TABLE fsboss_cash_deposit_detail AS
SELECT acc.customerid,
       pi.pricetypeid,
       pi.startlifecycle,
       pi.amount,
       eu.employee_id,
       eu.organizationunit_id,
       eu.employee_name
  FROM fsboss.payments_fs               pay,
       fsboss.paymentitems_fs           pi,
       fsboss.customeraccounts_fs       acc,
       fsboss.employee_organizationunit eu,
       fsboss_cash_deposit              dp
 WHERE pi.paymentid = pay.id
   AND pay.customeraccountid = acc.id
   AND eu.employee_id(+) = pay.acceptemployeeid
   AND dp.customeraccountbalanceid = pi.customeraccountbalanceid
   AND pi.pricetypeid = dp.pricetypeid;
   
-- 增加索引
CREATE INDEX index_deposit_detail_1 ON fsboss_cash_deposit_detail(customerid);
CREATE INDEX index_deposit_detail_2 ON fsboss_cash_deposit_detail(pricetypeid);
COMMIT;
