-- ��ȡ��Ч�ĵ�ַ 
 DROP TABLE fsboss_places;
 CREATE TABLE fsboss_places AS
SELECT *
  FROM fsboss.places p
 WHERE p.endlifecycle =
       to_date('9999/12/31 23:59:59', 'yyyy/MM/dd hh24:mi:ss');
-- ������������
CREATE INDEX index_places_id ON fsboss_places(id);
CREATE INDEX index_places_operationroleid ON fsboss_places(operationroleid);
-- ���ӵ�ַ�ȼ��ֶ�
ALTER TABLE fsboss_places add address_level NUMBER(1);
-- ����starboss�е��ϼ���ַid
ALTER TABLE fsboss_places add parentid_in_starboss NUMBER(19);
-- ���ӵ�ַ�ȼ�����
ALTER TABLE fsboss_places add add_level_code_length NUMBER(1);
-- �����ϼ���ַȫ�Ʊ���
ALTER TABLE fsboss_places add parent_full_name_code VARCHAR2(1024);
-- �����ϼ���ַȫ��
ALTER TABLE fsboss_places add parent_full_name VARCHAR2(1024);
-- ���Ӷ�Ӧstarboss�е�ַ��id
ALTER TABLE fsboss_places add id_in_starboss NUMBER(19);

-- ��˳���� Ϊ�ڶ�����ַ,����Ϊ ��˳��
UPDATE fsboss_places fp
   SET fp.name                  = '��˳��',
       fp.address_level         = 2,
       fp.parentid_in_starboss  = 1, --��ʼ�����ݿⴴ�� ����ʡ ��idΪ 1
       fp.add_level_code_length = 2,
       fp.parent_full_name_code = '01',
       fp.parent_full_name      = '����ʡ'
 WHERE fp.id = 9223372030202793149 -- "��˳����" ��ַ��id
;

-- �����غ� ����˾������ Ϊ��������ַ
-- ԭϵͳ�и�����û���ϼ���ַid������
UPDATE fsboss_places fp
   SET fp.address_level         = 3,
       fp.add_level_code_length = 2,
       fp.parentid              = 9223372030202793149 -- "��˳����" ��ַ��id
 WHERE fp.id IN (9223372030202793040,
                 9223372030202792765,
                 9223372030202792985,
                 9223372030202793095,
                 9223372030202792710,
                 9223372030202792820,
                 9223372030202792930,
                 9223372030202792875,
                 9223372030102414318) -- ����������ַ��id
;
UPDATE fsboss_places fp
   SET fp.address_level = 4, fp.add_level_code_length = 3
 WHERE fp.parentid IN
       (SELECT t.id FROM fsboss_places t WHERE t.address_level = 3);

UPDATE fsboss_places fp
   SET fp.address_level = 5, fp.add_level_code_length = 4
 WHERE fp.parentid IN
       (SELECT t.id FROM fsboss_places t WHERE t.address_level = 4);

UPDATE fsboss_places fp
   SET fp.address_level = 6, fp.add_level_code_length = 5
 WHERE fp.parentid IN
       (SELECT t.id FROM fsboss_places t WHERE t.address_level = 5);

UPDATE fsboss_places fp
   SET fp.address_level = 7, fp.add_level_code_length = 5
 WHERE fp.parentid IN
       (SELECT t.id FROM fsboss_places t WHERE t.address_level = 6);

UPDATE fsboss_places fp
   SET fp.address_level = 8, fp.add_level_code_length = 5
 WHERE fp.parentid IN
       (SELECT t.id FROM fsboss_places t WHERE t.address_level = 7);
COMMIT;
--------------------------------------------------------------------------------
----------------������֤�ű�----------------------------------------------------
--------------------------------------------------------------------------------

SELECT * FROM fsboss_places t WHERE t.address_level IS NULL;
SELECT * FROM fsboss_places t WHERE t.parentid_in_starboss IS NULL;
SELECT * FROM fsboss_places t WHERE t.add_level_code_length IS NULL;
SELECT * FROM fsboss_places t WHERE t.parent_full_name_code IS NULL;
SELECT * FROM fsboss_places t WHERE t.parent_full_name IS NULL;

