-- �������е���ַ
-- ��ԭ��ַ���Ʒ���originalname�ֶ�,���Ƿ���Ϸ����ʽ����isformated�ֶ�,Ĭ��Ϊ0 ,1Ϊ����
ALTER TABLE MUROTOEN MODIFY (mem Varchar2(150));
DROP TABLE fsboss_manageaddresses_fs;
CREATE TABLE fsboss_manageaddresses_fs AS
SELECT t.*, t.name originalname, 0 isformated
  FROM manageaddresses_fs@fsboss t, fsboss_places p
 WHERE t.managesectionid = p.id;
 
 -- ���ӵ�Ԫ����
ALTER TABLE fsboss_manageaddresses_fs add unitnum NUMBER(3);
-- ����¥�����
ALTER TABLE fsboss_manageaddresses_fs add floornum NUMBER(3);
-- ���ӻ�������
ALTER TABLE fsboss_manageaddresses_fs add murotonum NUMBER(3);

-- �����뷽���Ӧ�ֶ�
ALTER TABLE fsboss_manageaddresses_fs add connectioncode VARCHAR2(16);

-- ������������
CREATE INDEX index_fsboss_ma_fs_id ON fsboss_manageaddresses_fs(id);
-- ���ӵ�ַ�������
CREATE INDEX index_fsboss_ma_fs_maid ON fsboss_manageaddresses_fs(managesectionid);

-- ��������
CREATE INDEX index_fsboss_conncode ON fsboss_manageaddresses_fs(connectioncode);



-- �������Ե������ַ��ʱ�� temp_manageaddresses_fs,�����޸���ַΪ��ȷ��ַ
DROP TABLE temp_manageaddresses_fs;
CREATE TABLE temp_manageaddresses_fs AS
SELECT t.id, t.name
  FROM manageaddresses_fs@fsboss t
 WHERE regexp_like(t.name, '^[0-9]-[0-9]{3}$')

UNION

SELECT t.id, t.name
  FROM manageaddresses_fs@fsboss t
 WHERE regexp_like(t.name, '^[0-9]-[0-9]{4}$')

UNION

SELECT t.id, t.name
  FROM manageaddresses_fs@fsboss t
 WHERE regexp_like(t.name, '^[0-9]{2}-[0-9]{3}$')

UNION

SELECT t.id, t.name
  FROM manageaddresses_fs@fsboss t
 WHERE regexp_like(t.name, '^[0-9]{2}-[0-9]{4}$')

UNION

SELECT t.id, regexp_substr(t.name, '[0-9]-[0-9]{3}')
  FROM manageaddresses_fs@fsboss t
 WHERE regexp_like(t.name, '.*\D[0-9]-[0-9]{3}$')
   AND regexp_count(t.name, '[0-9]-[0-9]{3}') = 1
   AND regexp_count(t.name, '[0-9]-[0-9]{4}') = 0
   AND regexp_count(t.name, '[0-9]{2}-[0-9]{3}') = 0
   AND regexp_count(t.name, '[0-9]{2}-[0-9]{4}') = 0

UNION

SELECT t.id, regexp_substr(t.name, '[0-9]-[0-9]{3}')
  FROM manageaddresses_fs@fsboss t
 WHERE regexp_like(t.name, '^[0-9]-[0-9]{3}\D.*')
   AND regexp_count(t.name, '[0-9]-[0-9]{3}') = 1
   AND regexp_count(t.name, '[0-9]-[0-9]{4}') = 0
   AND regexp_count(t.name, '[0-9]{2}-[0-9]{3}') = 0
   AND regexp_count(t.name, '[0-9]{2}-[0-9]{4}') = 0;

-- ������������
CREATE INDEX index_temp_ma_fs_id ON temp_manageaddresses_fs(id);

--����fsboss_manageaddresses_fs�в���ȷ����ַ����
UPDATE fsboss_manageaddresses_fs t
   SET t.name =
       (SELECT tma.name FROM temp_manageaddresses_fs tma WHERE tma.id = t.id)
 WHERE EXISTS
 (SELECT 'x' FROM temp_manageaddresses_fs ma WHERE t.id = ma.id);

-- ƥ�����������ַ����,���ϱ�׼������isformatedΪ 1 ���Ե���,�ų�0¥��0��Ԫ
UPDATE fsboss_manageaddresses_fs t
   SET t.isformated = 1
 WHERE regexp_like(t.name,
                   '^([1-9]|[1-9]\d)-([1-9]|[1-9]\d)(\d[1-9]|[1-9]\d)$');

-- ��� ��Ԫ ¥�� ���� ��������
UPDATE fsboss_manageaddresses_fs t
   SET t.unitnum   = transfer_dvb_utils_pkg.fun_get_unitnum(t.name),
       t.floornum  = transfer_dvb_utils_pkg.fun_get_floornum(t.name),
       t.murotonum = transfer_dvb_utils_pkg.fun_get_murotonum(t.name)
 WHERE t.isformated = 1;

-- �ϳ��뷽���Ӧ���ֶ�

UPDATE fsboss_manageaddresses_fs t
   SET t.connectioncode = t.unitnum || '-' || t.floornum || '-' ||
                          t.murotonum
 WHERE t.isformated = 1;
 
-- Ϊ���ܸ�ֻ�����з���ĵ�ַ��������ͼ������isformated�ֶ�Ϊ0����ַ�ĵ�Ԫ��¥�㡢�����ֶ�Ϊ1
-- �������ɷ���ͼʱ���������еķ��񣬻�������һ�������ķ��񣬵������ڶ�Ӧ������ַ���ᱻ��Ϊ��Ч״̬
UPDATE fsboss_manageaddresses_fs t
   SET t.unitnum = 1, t.floornum = 1, t.murotonum = 1
 WHERE t.isformated = 0;

-- ����¥ַ��¥����������ʱ�� temp_building_parameters,ͳ��ÿ��¥���з��������  
DROP TABLE temp_building_parameters;
CREATE TABLE temp_building_parameters AS
SELECT t.managesectionid,
       MAX(t.unitnum) unitnum,
       MAX(t.floornum) floornum,
       MAX(t.murotonum) murotonum,
       (SELECT COUNT(*)
          FROM fsboss_manageaddresses_fs ma
         WHERE ma.isformated = 0
           AND ma.managesectionid = t.managesectionid) attachementnum
  FROM fsboss_manageaddresses_fs t
 GROUP BY t.managesectionid;
-- ������������
CREATE INDEX index_temp_b_p_id ON temp_building_parameters(managesectionid);

-- �����ֶδ��starboss�е�ַ��id
ALTER TABLE temp_building_parameters add id_in_starboss NUMBER(10);

COMMIT;
/*SELECT p.fullname,t.unitnum from temp_building_parameters t,fsboss_places p
WHERE t.managesectionid = p.id 
AND t.unitnum> 9;
SELECT p.fullname,t.floornum from temp_building_parameters t,fsboss_places p
WHERE t.managesectionid = p.id
AND t.floornum > 31;
SELECT p.fullname,t.murotonum from temp_building_parameters t,fsboss_places p 
WHERE t.managesectionid = p.id
AND t.murotonum > 10;

SELECT SUM( t.unitnum*t.floornum*t.murotonum) from temp_building_parameters t*/
-- ��ѯ��ַ����
/*SELECT 0 ���, '��ַ����' ����, '' ����, COUNT(*) ����
  FROM fsboss.manageaddresses_fs t

UNION

SELECT 1 ���, '^[0-9]-[0-9]{3}$' ����, '1-101' ����, COUNT(*) ����
  FROM fsboss.manageaddresses_fs t
 WHERE regexp_like(t.name, '^[0-9]-[0-9]{3}$')

UNION

SELECT 2 ���, '^[0-9]-[0-9]{4}$' ����, '1-1101' ����, COUNT(*) ����
  FROM fsboss.manageaddresses_fs t
 WHERE regexp_like(t.name, '^[0-9]-[0-9]{4}$')

UNION

SELECT 3 ���, '^[0-9]{2}-[0-9]{3}$' ����, '11-101' ����, COUNT(*) ����
  FROM fsboss.manageaddresses_fs t
 WHERE regexp_like(t.name, '^[0-9]{2}-[0-9]{3}$')

UNION

SELECT 4 ���, '^[0-9]{2}-[0-9]{4}$' ����, '11-1101' ����, COUNT(*) ����
  FROM fsboss.manageaddresses_fs t
 WHERE regexp_like(t.name, '^[0-9]{2}-[0-9]{4}$')

UNION

SELECT 5 ���, '.*\D[0-9]-[0-9]{3}$' ����, '��¥3-302' ����, COUNT(*) ����
  FROM fsboss.manageaddresses_fs t
 WHERE regexp_like(t.name, '.*\D[0-9]-[0-9]{3}$')
   AND regexp_count(t.name, '[0-9]-[0-9]{3}') = 1
   AND regexp_count(t.name, '[0-9]-[0-9]{4}') = 0
   AND regexp_count(t.name, '[0-9]{2}-[0-9]{3}') = 0
   AND regexp_count(t.name, '[0-9]{2}-[0-9]{4}') = 0

UNION

SELECT 6 ���, '^[0-9]-[0-9]{3}\D.*' ����, '9-802(1)' ����, COUNT(*) ����
  FROM fsboss.manageaddresses_fs t
 WHERE regexp_like(t.name, '^[0-9]-[0-9]{3}\D.*')
   AND regexp_count(t.name, '[0-9]-[0-9]{3}') = 1
   AND regexp_count(t.name, '[0-9]-[0-9]{4}') = 0
   AND regexp_count(t.name, '[0-9]{2}-[0-9]{3}') = 0
   AND regexp_count(t.name, '[0-9]{2}-[0-9]{4}') = 0

UNION

SELECT 7 ���,
       '.*\D[0-9]-[0-9]{3}\D.*' ����,
       '�Ż�¥-4-4-202-2' ����,
       COUNT(*) ����
  FROM fsboss.manageaddresses_fs t
 WHERE regexp_like(t.name, '.*\D[0-9]-[0-9]{3}\D.*')
   AND regexp_count(t.name, '[0-9]-[0-9]{3}') = 1
   AND regexp_count(t.name, '[0-9]-[0-9]{4}') = 0
   AND regexp_count(t.name, '[0-9]{2}-[0-9]{3}') = 0
   AND regexp_count(t.name, '[0-9]{2}-[0-9]{4}') = 0

UNION

SELECT 8 ���,
       '.*\D[0-9]-[0-9]{4}$' ����,
       '�����ֱ���6#(��̨SOHO)2-1907' ����,
       COUNT(*) ����
  FROM fsboss.manageaddresses_fs t
 WHERE regexp_like(t.name, '.*\D[0-9]-[0-9]{4}$')
   AND regexp_count(t.name, '[0-9]-[0-9]{3}') = 1
   AND regexp_count(t.name, '[0-9]-[0-9]{4}') = 1
   AND regexp_count(t.name, '[0-9]{2}-[0-9]{3}') = 0
   AND regexp_count(t.name, '[0-9]{2}-[0-9]{4}') = 0

UNION

SELECT 9 ���, '^[0-9]-[0-9]{4}\D.*' ����, '6-1502-1' ����, COUNT(*) ����
  FROM fsboss.manageaddresses_fs t
 WHERE regexp_like(t.name, '^[0-9]-[0-9]{4}\D.*')
   AND regexp_count(t.name, '[0-9]-[0-9]{3}') = 1
   AND regexp_count(t.name, '[0-9]-[0-9]{4}') = 1
   AND regexp_count(t.name, '[0-9]{2}-[0-9]{3}') = 0
   AND regexp_count(t.name, '[0-9]{2}-[0-9]{4}') = 0

UNION

SELECT 10 ���,
       '.*\D[0-9]-[0-9]{4}\D.*' ����,
       '�����ֱ���6��(��̨SOHOA��B��2-1403)' ����,
       COUNT(*) ����
  FROM fsboss.manageaddresses_fs t
 WHERE regexp_like(t.name, '.*\D[0-9]-[0-9]{4}\D.*')
   AND regexp_count(t.name, '[0-9]-[0-9]{3}') = 1
   AND regexp_count(t.name, '[0-9]-[0-9]{4}') = 1
   AND regexp_count(t.name, '[0-9]{2}-[0-9]{3}') = 0
   AND regexp_count(t.name, '[0-9]{2}-[0-9]{4}') = 0

UNION

SELECT 11 ���,
       '.*\D[0-9]{2}-[0-9]{3}$' ����,
       'ӭ��·90����10-201' ����,
       COUNT(*) ����
  FROM fsboss.manageaddresses_fs t
 WHERE regexp_like(t.name, '.*\D[0-9]{2}-[0-9]{3}$')
   AND regexp_count(t.name, '[0-9]-[0-9]{3}') = 1
   AND regexp_count(t.name, '[0-9]-[0-9]{4}') = 0
   AND regexp_count(t.name, '[0-9]{2}-[0-9]{3}') = 1
   AND regexp_count(t.name, '[0-9]{2}-[0-9]{4}') = 0

UNION

SELECT 12 ���,
       '^[0-9]{2}-[0-9]{3}\D.*' ����,
       '10-101(1)' ����,
       COUNT(*) ����
  FROM fsboss.manageaddresses_fs t
 WHERE regexp_like(t.name, '^[0-9]{2}-[0-9]{3}\D.*')
   AND regexp_count(t.name, '[0-9]-[0-9]{3}') = 1
   AND regexp_count(t.name, '[0-9]-[0-9]{4}') = 0
   AND regexp_count(t.name, '[0-9]{2}-[0-9]{3}') = 1
   AND regexp_count(t.name, '[0-9]{2}-[0-9]{4}') = 0

UNION

SELECT 13 ���, '.*\D[0-9]{2}-[0-9]{3}\D.*' ����, '' ����, COUNT(*) ����
  FROM fsboss.manageaddresses_fs t
 WHERE regexp_like(t.name, '.*\D[0-9]{2}-[0-9]{3}\D.*')
   AND regexp_count(t.name, '[0-9]-[0-9]{3}') = 1
   AND regexp_count(t.name, '[0-9]-[0-9]{4}') = 0
   AND regexp_count(t.name, '[0-9]{2}-[0-9]{3}') = 1
   AND regexp_count(t.name, '[0-9]{2}-[0-9]{4}') = 0

UNION

SELECT 14 ���, '.*\D[0-9]{2}-[0-9]{4}$' ����, '' ����, COUNT(*) ����
  FROM fsboss.manageaddresses_fs t
 WHERE regexp_like(t.name, '.*\D[0-9]{2}-[0-9]{4}$')
   AND regexp_count(t.name, '[0-9]-[0-9]{3}') = 1
   AND regexp_count(t.name, '[0-9]-[0-9]{4}') = 1
   AND regexp_count(t.name, '[0-9]{2}-[0-9]{3}') = 1
   AND regexp_count(t.name, '[0-9]{2}-[0-9]{4}') = 1

UNION

SELECT 15 ���, '^[0-9]{2}-[0-9]{4}\D.*' ����, '' ����, COUNT(*) ����
  FROM fsboss.manageaddresses_fs t
 WHERE regexp_like(t.name, '^[0-9]{2}-[0-9]{4}\D.*')
   AND regexp_count(t.name, '[0-9]-[0-9]{3}') = 1
   AND regexp_count(t.name, '[0-9]-[0-9]{4}') = 1
   AND regexp_count(t.name, '[0-9]{2}-[0-9]{3}') = 1
   AND regexp_count(t.name, '[0-9]{2}-[0-9]{4}') = 1

UNION

SELECT 16 ���, '.*\D[0-9]{2}-[0-9]{4}\D.*' ����, '' ����, COUNT(*) ����
  FROM fsboss.manageaddresses_fs t
 WHERE regexp_like(t.name, '.*\D[0-9]{2}-[0-9]{4}\D.*')
   AND regexp_count(t.name, '[0-9]-[0-9]{3}') = 1
   AND regexp_count(t.name, '[0-9]-[0-9]{4}') = 1
   AND regexp_count(t.name, '[0-9]{2}-[0-9]{3}') = 1
   AND regexp_count(t.name, '[0-9]{2}-[0-9]{4}') = 1;
*/
