-- 提取有效的地址 
 DROP TABLE fsboss_places;
 CREATE TABLE fsboss_places AS
SELECT *
  FROM huiju.places p
 WHERE p.endlifecycle =
       to_date('9999/12/31 23:59:59', 'yyyy/MM/dd hh24:mi:ss');
-- 主键增加索引
CREATE INDEX index_places_id ON fsboss_places(id);
CREATE INDEX index_places_operationroleid ON fsboss_places(operationroleid);
-- 增加地址等级字段
ALTER TABLE fsboss_places add address_level NUMBER(1);
-- 增加starboss中的上级地址id
ALTER TABLE fsboss_places add parentid_in_starboss NUMBER(19);
-- 增加地址等级长度
ALTER TABLE fsboss_places add add_level_code_length NUMBER(1);
-- 增加上级地址全称编码
ALTER TABLE fsboss_places add parent_full_name_code VARCHAR2(1024);
-- 增加上级地址全称
ALTER TABLE fsboss_places add parent_full_name VARCHAR2(1024);
-- 增加对应starboss中地址的id
ALTER TABLE fsboss_places add id_in_starboss NUMBER(19);

-- 抚顺有线 为第二级地址,改名为 抚顺市
UPDATE fsboss_places fp
   SET fp.name                  = '抚顺市',
       fp.address_level         = 2,
       fp.parentid_in_starboss  = 1, --初始化数据库创建 辽宁省 的id为 1
       fp.add_level_code_length = 2,
       fp.parent_full_name_code = '01',
       fp.parent_full_name      = '辽宁省'
 WHERE fp.id = 9223372030202793149 -- "抚顺有线" 地址的id
;

-- 各区县和 “公司本部” 为第三级地址
-- 原系统中各个区没有上级地址id，补充
UPDATE fsboss_places fp
   SET fp.address_level         = 3,
       fp.add_level_code_length = 2,
       fp.parentid              = 9223372030202793149 -- "抚顺有线" 地址的id
 WHERE fp.id IN (9223372030202793040,
                 9223372030202792765,
                 9223372030202792985,
                 9223372030202793095,
                 9223372030202792710,
                 9223372030202792820,
                 9223372030202792930,
                 9223372030202792875,
                 9223372030102414318) -- 所有三级地址的id
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
----------------数据验证脚本----------------------------------------------------
--------------------------------------------------------------------------------

SELECT * FROM fsboss_places t WHERE t.address_level IS NULL;
SELECT * FROM fsboss_places t WHERE t.parentid_in_starboss IS NULL;
SELECT * FROM fsboss_places t WHERE t.add_level_code_length IS NULL;
SELECT * FROM fsboss_places t WHERE t.parent_full_name_code IS NULL;
SELECT * FROM fsboss_places t WHERE t.parent_full_name IS NULL;

