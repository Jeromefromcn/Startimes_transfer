-- 提取有效的地址 
DROP TABLE import_raynode;
CREATE TABLE import_raynode AS
SELECT *
  FROM import_addressen a
 WHERE a.organ_code LIKE '@@LY%'
   AND a.addresslevelid_pk IN (4, 5);
-- 主键增加索引
CREATE INDEX index_ir_id ON import_raynode(address_id);
-- 增加光节点等级字段，预处理时更新
ALTER TABLE import_raynode add raynodelevelid_pk NUMBER(5);
-- 增加光节点等级长度，预处理时更新
ALTER TABLE import_raynode add raynode_level_code_length NUMBER(1);
-- 增加starboss中的上级光节点id，导入光节点时回写
ALTER TABLE import_raynode add raynodeid_fk NUMBER(19);
-- 增加上级光节点全称编码，导入光节点时回写
ALTER TABLE import_raynode add raynode_parent_full_name_code VARCHAR2(1024);


-- 填入光节点等级和光节点编码长度,第一级光节点的上级光节点设置为根节点
UPDATE import_raynode ir
   SET ir.raynodelevelid_pk         = 1,
       ir.raynode_level_code_length = 2,
       ir.raynodeid_fk              = 0
 WHERE ir.addresslevelid_pk = 4;
UPDATE import_raynode ir
   SET ir.raynodelevelid_pk = 2, ir.raynode_level_code_length = 3
 WHERE ir.addresslevelid_pk = 5;

COMMIT;

