--�����ɲ���Ա��ʱ��
DROP TABLE fsboss_operators;
CREATE TABLE fsboss_operators AS 
SELECT eu.*,
       org.operationroleid,
       org.operationrolename,
       transfer_dvb_utils_pkg.fun_md5(nvl(eu.password, '123456')) new_password
  FROM huiju.organizationunitinfos     org,
       huiju.employee_organizationunit eu
 WHERE org.id = eu.organizationunit_id;
--����Ա��Ӫ������
ALTER TABLE fsboss_operators add starboss_salechannel_id NUMBER(8);

--Bossϵͳ��Ӫ����������ϵͳ����֯����һ��
UPDATE fsboss_operators o
   SET o.starboss_salechannel_id =
       (SELECT s.salechannelid_pk
          FROM salechannelen s
         WHERE s.salechannelnamestr = o.organizationunit_name);
-- ����Ӫҵ������Ա�󶨵�Ĭ��Ӫҵ������������Աʱ�������κν�ɫ
UPDATE fsboss_operators o
   SET o.starboss_salechannel_id = 1
 WHERE o.starboss_salechannel_id IS NULL;
--����Ա����

ALTER TABLE fsboss_operators add(starboss_operid_pk NUMBER(8));

--Bossϵͳ�Ĳ�������ϵͳ����֯����һ��
UPDATE fsboss_operators o
   SET o.starboss_operid_pk =
       (SELECT s.deptid_pk
          FROM depten s
         WHERE s.deptnamestr = o.organizationunit_name);
COMMIT;
