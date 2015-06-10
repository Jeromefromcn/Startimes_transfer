--创建旧操作员临时表
DROP TABLE fsboss_operators;
CREATE TABLE fsboss_operators AS 
SELECT eu.*,
       org.operationroleid,
       org.operationrolename,
       transfer_dvb_utils_pkg.fun_md5(nvl(eu.password, '123456')) new_password
  FROM huiju.organizationunitinfos     org,
       huiju.employee_organizationunit eu
 WHERE org.id = eu.organizationunit_id;
--操作员与营销渠道
ALTER TABLE fsboss_operators add starboss_salechannel_id NUMBER(8);

--Boss系统的营销渠道与汇巨系统的组织名称一致
UPDATE fsboss_operators o
   SET o.starboss_salechannel_id =
       (SELECT s.salechannelid_pk
          FROM salechannelen s
         WHERE s.salechannelnamestr = o.organizationunit_name);
-- 将非营业厅操作员绑定到默认营业厅，创建操作员时不分配任何角色
UPDATE fsboss_operators o
   SET o.starboss_salechannel_id = 1
 WHERE o.starboss_salechannel_id IS NULL;
--操作员部门

ALTER TABLE fsboss_operators add(starboss_operid_pk NUMBER(8));

--Boss系统的部门与汇巨系统的组织名称一致
UPDATE fsboss_operators o
   SET o.starboss_operid_pk =
       (SELECT s.deptid_pk
          FROM depten s
         WHERE s.deptnamestr = o.organizationunit_name);
COMMIT;
