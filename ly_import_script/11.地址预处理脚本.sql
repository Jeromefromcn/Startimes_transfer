-- 提取有效的地址 
DROP TABLE import_addressen;
CREATE TABLE import_addressen AS
SELECT *
  FROM lyboss.address_tree a
-- 在地址数中不需要拆分的地址
 WHERE NOT EXISTS (SELECT 'x'
          FROM lyboss.splitted_address t
         WHERE t.address_id = a.address_id)
UNION
SELECT t.parent_address_id || t.address_name_en address_id,
       t.parent_address_id,
       0 list_order,
       '' address_name_en,
       t.address_name_en address_name,
       '' leaf,
       '' organ_code,
       '' adr_code,
       '' num,
       '' buildings_num,
       '' danyuan_num,
       '' floor,
       '' door,
       '' allnums,
       '' son_front_port_id,
       '' exchange_machine_id,
       '' light_node_id,
       '' address_name_py
-- 拆分后所有上级地址
  FROM lyboss.splitted_address t
 GROUP BY t.parent_address_id, t.address_name_en
UNION
SELECT s.address_id,
       -- 上级地址为当 前上级地址||拆分后上级地址名称 
       s.parent_address_id || s.address_name_en parent_address_id,
       s.list_order,
       s.address_name_en,
       s.leaf address_name,
       s.leaf,
       s.organ_code,
       s.adr_code,
       s.num,
       s.buildings_num,
       s.danyuan_num,
       s.floor,
       s.door,
       s.allnums,
       s.son_front_port_id,
       s.exchange_machine_id,
       s.light_node_id,
       s.address_name_py
-- 拆分后的所有下级地址
  FROM lyboss.splitted_address s;
-- 主键增加索引
CREATE INDEX index_ia_id ON import_addressen(address_id);
-- 增加地址等级字段，预处理时更新
ALTER TABLE import_addressen add addresslevelid_pk NUMBER(5);
-- 增加地址等级长度，预处理时更新
ALTER TABLE import_addressen add add_level_code_length NUMBER(1);
-- 增加starboss中的上级地址id，导入地址时回写
ALTER TABLE import_addressen add addressid_fk NUMBER(19);
-- 增加上级地址全称编码，导入地址时回写
ALTER TABLE import_addressen add parent_full_name_code VARCHAR2(1024);
-- 增加上级地址全称，导入地址时回写
ALTER TABLE import_addressen add parent_full_name VARCHAR2(1024);
-- 增加对应starboss中地址的id，导入地址时回写
ALTER TABLE import_addressen add addressid_pk NUMBER(19);

-- 修改第二级地址 辽阳地区 的信息
UPDATE import_addressen ia
   SET ia.addresslevelid_pk     = 2,
       ia.addressid_fk          = 1, --初始化数据库创建 辽宁省 的id为 1
       ia.add_level_code_length = 1,
       ia.parent_full_name_code = '1',
       ia.parent_full_name      = '辽宁省'
 WHERE ia.address_id = '-1' -- "辽阳地区" 地址的id
;

-- 填入地址等级和地址编码长度
UPDATE import_addressen ia
   SET ia.addresslevelid_pk = 3, ia.add_level_code_length = 3
 WHERE ia.parent_address_id IN
       (SELECT t.address_id
          FROM import_addressen t
         WHERE t.addresslevelid_pk = 2);
UPDATE import_addressen ia
   SET ia.addresslevelid_pk = 4, ia.add_level_code_length = 4
 WHERE ia.parent_address_id IN
       (SELECT t.address_id
          FROM import_addressen t
         WHERE t.addresslevelid_pk = 3);
UPDATE import_addressen ia
   SET ia.addresslevelid_pk = 5, ia.add_level_code_length = 4
 WHERE ia.parent_address_id IN
       (SELECT t.address_id
          FROM import_addressen t
         WHERE t.addresslevelid_pk = 4);
UPDATE import_addressen ia
   SET ia.addresslevelid_pk = 6, ia.add_level_code_length = 5
 WHERE ia.parent_address_id IN
       (SELECT t.address_id
          FROM import_addressen t
         WHERE t.addresslevelid_pk = 5);
UPDATE import_addressen ia
   SET ia.addresslevelid_pk = 7, ia.add_level_code_length = 5
 WHERE ia.parent_address_id IN
       (SELECT t.address_id
          FROM import_addressen t
         WHERE t.addresslevelid_pk = 6);
UPDATE import_addressen ia
   SET ia.addresslevelid_pk = 8, ia.add_level_code_length = 5
 WHERE ia.parent_address_id IN
       (SELECT t.address_id
          FROM import_addressen t
         WHERE t.addresslevelid_pk = 7);

COMMIT;
--------------------------------------------------------------------------------
----------------数据验证脚本----------------------------------------------------
--------------------------------------------------------------------------------

SELECT * FROM import_addressen t WHERE t.addresslevelid_pk IS NULL;
SELECT * FROM import_addressen t WHERE t.addressid_fk IS NULL;
SELECT * FROM import_addressen t WHERE t.add_level_code_length IS NULL;
SELECT * FROM import_addressen t WHERE t.parent_full_name_code IS NULL;
SELECT * FROM import_addressen t WHERE t.parent_full_name IS NULL;
