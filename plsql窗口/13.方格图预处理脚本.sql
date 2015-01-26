-- 提取方格图信息
DROP TABLE import_grid_info;
CREATE TABLE import_grid_info AS
SELECT gbi.addr_id,
       gbi.building_direction,
       gbi.building_style,
       gbi.floor_count,
       m.max_unit_num         unit_num, -- 取单元信息表中最大单元数为实际单元数
       m.max_unit_room_count  unit_room_count -- 取单元信息表中最大户数为实际户数
  FROM lyboss.grid_building_info gbi,
       (SELECT t.addr_id addr_id,
               MAX(to_number(t.unit_num)) max_unit_num,
               MAX(t.unit_room_count) max_unit_room_count
          FROM lyboss.grid_building_unit_info t
         GROUP BY t.addr_id
        -- 最大单元数必须等于单元信息的条数
        HAVING MAX(to_number(t.unit_num)) = COUNT(*)) m -- 楼宇与单元个数临时表
 WHERE EXISTS (SELECT 'x'
          FROM lyboss.address_tree a
         WHERE a.address_id = gbi.addr_id) -- 存在与方格绑定的地址
   AND gbi.unit_count > 0 -- 单元数必须大于零
   AND gbi.floor_count > 0 -- 楼层数必须大于零
   AND gbi.addr_id = m.addr_id;

-- 主键增加索引
CREATE INDEX index_igi_id ON import_grid_info(addr_id);
-- 增加字段存放starboss中地址的id
ALTER TABLE import_grid_info add id_in_starboss NUMBER(10);

-- 提取单元信息
DROP TABLE import_grid_unit_info;
CREATE TABLE import_grid_unit_info AS
SELECT * from lyboss.grid_building_unit_info gbui;

-- 主键增加索引
CREATE INDEX index_igui_id ON import_grid_unit_info(addr_id);

-- 提取无效方格信息
DROP TABLE import_grid_other_info;
CREATE TABLE import_grid_other_info AS
SELECT * from lyboss.grid_building_other_info gboi;
-- 主键增加索引
CREATE INDEX index_igoi_id ON import_grid_other_info(addr_id);

COMMIT;
