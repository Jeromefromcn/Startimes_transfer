-- 导入所有的门址
-- 将原门址名称放入originalname字段,将是否符合方格格式放入isformated字段,默认为0 ,1为符合
DROP TABLE fsboss_manageaddresses_fs;
CREATE TABLE fsboss_manageaddresses_fs AS
SELECT t.*, t.name originalname, 0 isformated
  FROM fsboss.manageaddresses_fs t, fsboss_places p
 WHERE t.managesectionid = p.id;
 
 -- 增加单元参数
ALTER TABLE fsboss_manageaddresses_fs add unitnum NUMBER(3);
-- 增加楼层参数
ALTER TABLE fsboss_manageaddresses_fs add floornum NUMBER(3);
-- 增加户数参数
ALTER TABLE fsboss_manageaddresses_fs add murotonum NUMBER(3);

-- 增加与方格对应字段
ALTER TABLE fsboss_manageaddresses_fs add connectioncode VARCHAR2(16);

-- 增加主键索引
CREATE INDEX index_fsboss_ma_fs_id ON fsboss_manageaddresses_fs(id);
-- 增加地址外键索引
CREATE INDEX index_fsboss_ma_fs_maid ON fsboss_manageaddresses_fs(managesectionid);

-- 增加索引
CREATE INDEX index_fsboss_conncode ON fsboss_manageaddresses_fs(connectioncode);



-- 创建可以导入的门址临时表 temp_manageaddresses_fs,并且修改门址为正确门址
DROP TABLE temp_manageaddresses_fs;
CREATE TABLE temp_manageaddresses_fs AS
SELECT t.id, t.name
  FROM fsboss.manageaddresses_fs t
 WHERE regexp_like(t.name, '^[0-9]-[0-9]{3}$')

UNION

SELECT t.id, t.name
  FROM fsboss.manageaddresses_fs t
 WHERE regexp_like(t.name, '^[0-9]-[0-9]{4}$')

UNION

SELECT t.id, t.name
  FROM fsboss.manageaddresses_fs t
 WHERE regexp_like(t.name, '^[0-9]{2}-[0-9]{3}$')

UNION

SELECT t.id, t.name
  FROM fsboss.manageaddresses_fs t
 WHERE regexp_like(t.name, '^[0-9]{2}-[0-9]{4}$')

UNION

SELECT t.id, regexp_substr(t.name, '[0-9]-[0-9]{3}')
  FROM fsboss.manageaddresses_fs t
 WHERE regexp_like(t.name, '.*\D[0-9]-[0-9]{3}$')
   AND regexp_count(t.name, '[0-9]-[0-9]{3}') = 1
   AND regexp_count(t.name, '[0-9]-[0-9]{4}') = 0
   AND regexp_count(t.name, '[0-9]{2}-[0-9]{3}') = 0
   AND regexp_count(t.name, '[0-9]{2}-[0-9]{4}') = 0

UNION

SELECT t.id, regexp_substr(t.name, '[0-9]-[0-9]{3}')
  FROM fsboss.manageaddresses_fs t
 WHERE regexp_like(t.name, '^[0-9]-[0-9]{3}\D.*')
   AND regexp_count(t.name, '[0-9]-[0-9]{3}') = 1
   AND regexp_count(t.name, '[0-9]-[0-9]{4}') = 0
   AND regexp_count(t.name, '[0-9]{2}-[0-9]{3}') = 0
   AND regexp_count(t.name, '[0-9]{2}-[0-9]{4}') = 0;

-- 增加主键索引
CREATE INDEX index_temp_ma_fs_id ON temp_manageaddresses_fs(id);

--将表fsboss_manageaddresses_fs中不正确的门址修正
UPDATE fsboss_manageaddresses_fs t
   SET t.name =
       (SELECT tma.name FROM temp_manageaddresses_fs tma WHERE tma.id = t.id)
 WHERE EXISTS
 (SELECT 'x' FROM temp_manageaddresses_fs ma WHERE t.id = ma.id);

-- 匹配修正后的门址名称,符合标准的设置isformated为 1 可以导入,排除0楼层0单元
UPDATE fsboss_manageaddresses_fs t
   SET t.isformated = 1
 WHERE regexp_like(t.name,
                   '^([1-9]|[1-9]\d)-([1-9]|[1-9]\d)(\d[1-9]|[1-9]\d)$');

-- 拆分 单元 楼层 户数 三个参数
UPDATE fsboss_manageaddresses_fs t
   SET t.unitnum   = transfer_dvb_utils_pkg.fun_get_unitnum(t.name),
       t.floornum  = transfer_dvb_utils_pkg.fun_get_floornum(t.name),
       t.murotonum = transfer_dvb_utils_pkg.fun_get_murotonum(t.name)
 WHERE t.isformated = 1;

-- 合成与方格对应的字段

UPDATE fsboss_manageaddresses_fs t
   SET t.connectioncode = t.unitnum || '-' || t.floornum || '-' ||
                          t.murotonum
 WHERE t.isformated = 1;
 
-- 为了能给只有依托方格的地址创建方格图，更新isformated字段为0的门址的单元、楼层、户数字段为1
-- 将来生成方格图时，除了依托的方格，还会生成一个正常的方格，但是由于对应不到门址，会被置为无效状态
UPDATE fsboss_manageaddresses_fs t
   SET t.unitnum = 1, t.floornum = 1, t.murotonum = 1
 WHERE t.isformated = 0;

-- 创建楼址与楼房参数的临时表 temp_building_parameters,统计每个楼依托方格的数量  
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
-- 主键增加索引
CREATE INDEX index_temp_b_p_id ON temp_building_parameters(managesectionid);

-- 增加字段存放starboss中地址的id
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
-- 查询门址总数
/*SELECT 0 序号, '门址总数' 类型, '' 例子, COUNT(*) 数量
  FROM fsboss.manageaddresses_fs t

UNION

SELECT 1 序号, '^[0-9]-[0-9]{3}$' 类型, '1-101' 例子, COUNT(*) 数量
  FROM fsboss.manageaddresses_fs t
 WHERE regexp_like(t.name, '^[0-9]-[0-9]{3}$')

UNION

SELECT 2 序号, '^[0-9]-[0-9]{4}$' 类型, '1-1101' 例子, COUNT(*) 数量
  FROM fsboss.manageaddresses_fs t
 WHERE regexp_like(t.name, '^[0-9]-[0-9]{4}$')

UNION

SELECT 3 序号, '^[0-9]{2}-[0-9]{3}$' 类型, '11-101' 例子, COUNT(*) 数量
  FROM fsboss.manageaddresses_fs t
 WHERE regexp_like(t.name, '^[0-9]{2}-[0-9]{3}$')

UNION

SELECT 4 序号, '^[0-9]{2}-[0-9]{4}$' 类型, '11-1101' 例子, COUNT(*) 数量
  FROM fsboss.manageaddresses_fs t
 WHERE regexp_like(t.name, '^[0-9]{2}-[0-9]{4}$')

UNION

SELECT 5 序号, '.*\D[0-9]-[0-9]{3}$' 类型, '南楼3-302' 例子, COUNT(*) 数量
  FROM fsboss.manageaddresses_fs t
 WHERE regexp_like(t.name, '.*\D[0-9]-[0-9]{3}$')
   AND regexp_count(t.name, '[0-9]-[0-9]{3}') = 1
   AND regexp_count(t.name, '[0-9]-[0-9]{4}') = 0
   AND regexp_count(t.name, '[0-9]{2}-[0-9]{3}') = 0
   AND regexp_count(t.name, '[0-9]{2}-[0-9]{4}') = 0

UNION

SELECT 6 序号, '^[0-9]-[0-9]{3}\D.*' 类型, '9-802(1)' 例子, COUNT(*) 数量
  FROM fsboss.manageaddresses_fs t
 WHERE regexp_like(t.name, '^[0-9]-[0-9]{3}\D.*')
   AND regexp_count(t.name, '[0-9]-[0-9]{3}') = 1
   AND regexp_count(t.name, '[0-9]-[0-9]{4}') = 0
   AND regexp_count(t.name, '[0-9]{2}-[0-9]{3}') = 0
   AND regexp_count(t.name, '[0-9]{2}-[0-9]{4}') = 0

UNION

SELECT 7 序号,
       '.*\D[0-9]-[0-9]{3}\D.*' 类型,
       '着火楼-4-4-202-2' 例子,
       COUNT(*) 数量
  FROM fsboss.manageaddresses_fs t
 WHERE regexp_like(t.name, '.*\D[0-9]-[0-9]{3}\D.*')
   AND regexp_count(t.name, '[0-9]-[0-9]{3}') = 1
   AND regexp_count(t.name, '[0-9]-[0-9]{4}') = 0
   AND regexp_count(t.name, '[0-9]{2}-[0-9]{3}') = 0
   AND regexp_count(t.name, '[0-9]{2}-[0-9]{4}') = 0

UNION

SELECT 8 序号,
       '.*\D[0-9]-[0-9]{4}$' 类型,
       '永宁街北段6#(北台SOHO)2-1907' 例子,
       COUNT(*) 数量
  FROM fsboss.manageaddresses_fs t
 WHERE regexp_like(t.name, '.*\D[0-9]-[0-9]{4}$')
   AND regexp_count(t.name, '[0-9]-[0-9]{3}') = 1
   AND regexp_count(t.name, '[0-9]-[0-9]{4}') = 1
   AND regexp_count(t.name, '[0-9]{2}-[0-9]{3}') = 0
   AND regexp_count(t.name, '[0-9]{2}-[0-9]{4}') = 0

UNION

SELECT 9 序号, '^[0-9]-[0-9]{4}\D.*' 类型, '6-1502-1' 例子, COUNT(*) 数量
  FROM fsboss.manageaddresses_fs t
 WHERE regexp_like(t.name, '^[0-9]-[0-9]{4}\D.*')
   AND regexp_count(t.name, '[0-9]-[0-9]{3}') = 1
   AND regexp_count(t.name, '[0-9]-[0-9]{4}') = 1
   AND regexp_count(t.name, '[0-9]{2}-[0-9]{3}') = 0
   AND regexp_count(t.name, '[0-9]{2}-[0-9]{4}') = 0

UNION

SELECT 10 序号,
       '.*\D[0-9]-[0-9]{4}\D.*' 类型,
       '永宁街北段6甲(北台SOHOA座B区2-1403)' 例子,
       COUNT(*) 数量
  FROM fsboss.manageaddresses_fs t
 WHERE regexp_like(t.name, '.*\D[0-9]-[0-9]{4}\D.*')
   AND regexp_count(t.name, '[0-9]-[0-9]{3}') = 1
   AND regexp_count(t.name, '[0-9]-[0-9]{4}') = 1
   AND regexp_count(t.name, '[0-9]{2}-[0-9]{3}') = 0
   AND regexp_count(t.name, '[0-9]{2}-[0-9]{4}') = 0

UNION

SELECT 11 序号,
       '.*\D[0-9]{2}-[0-9]{3}$' 类型,
       '迎宾路90方块10-201' 例子,
       COUNT(*) 数量
  FROM fsboss.manageaddresses_fs t
 WHERE regexp_like(t.name, '.*\D[0-9]{2}-[0-9]{3}$')
   AND regexp_count(t.name, '[0-9]-[0-9]{3}') = 1
   AND regexp_count(t.name, '[0-9]-[0-9]{4}') = 0
   AND regexp_count(t.name, '[0-9]{2}-[0-9]{3}') = 1
   AND regexp_count(t.name, '[0-9]{2}-[0-9]{4}') = 0

UNION

SELECT 12 序号,
       '^[0-9]{2}-[0-9]{3}\D.*' 类型,
       '10-101(1)' 例子,
       COUNT(*) 数量
  FROM fsboss.manageaddresses_fs t
 WHERE regexp_like(t.name, '^[0-9]{2}-[0-9]{3}\D.*')
   AND regexp_count(t.name, '[0-9]-[0-9]{3}') = 1
   AND regexp_count(t.name, '[0-9]-[0-9]{4}') = 0
   AND regexp_count(t.name, '[0-9]{2}-[0-9]{3}') = 1
   AND regexp_count(t.name, '[0-9]{2}-[0-9]{4}') = 0

UNION

SELECT 13 序号, '.*\D[0-9]{2}-[0-9]{3}\D.*' 类型, '' 例子, COUNT(*) 数量
  FROM fsboss.manageaddresses_fs t
 WHERE regexp_like(t.name, '.*\D[0-9]{2}-[0-9]{3}\D.*')
   AND regexp_count(t.name, '[0-9]-[0-9]{3}') = 1
   AND regexp_count(t.name, '[0-9]-[0-9]{4}') = 0
   AND regexp_count(t.name, '[0-9]{2}-[0-9]{3}') = 1
   AND regexp_count(t.name, '[0-9]{2}-[0-9]{4}') = 0

UNION

SELECT 14 序号, '.*\D[0-9]{2}-[0-9]{4}$' 类型, '' 例子, COUNT(*) 数量
  FROM fsboss.manageaddresses_fs t
 WHERE regexp_like(t.name, '.*\D[0-9]{2}-[0-9]{4}$')
   AND regexp_count(t.name, '[0-9]-[0-9]{3}') = 1
   AND regexp_count(t.name, '[0-9]-[0-9]{4}') = 1
   AND regexp_count(t.name, '[0-9]{2}-[0-9]{3}') = 1
   AND regexp_count(t.name, '[0-9]{2}-[0-9]{4}') = 1

UNION

SELECT 15 序号, '^[0-9]{2}-[0-9]{4}\D.*' 类型, '' 例子, COUNT(*) 数量
  FROM fsboss.manageaddresses_fs t
 WHERE regexp_like(t.name, '^[0-9]{2}-[0-9]{4}\D.*')
   AND regexp_count(t.name, '[0-9]-[0-9]{3}') = 1
   AND regexp_count(t.name, '[0-9]-[0-9]{4}') = 1
   AND regexp_count(t.name, '[0-9]{2}-[0-9]{3}') = 1
   AND regexp_count(t.name, '[0-9]{2}-[0-9]{4}') = 1

UNION

SELECT 16 序号, '.*\D[0-9]{2}-[0-9]{4}\D.*' 类型, '' 例子, COUNT(*) 数量
  FROM fsboss.manageaddresses_fs t
 WHERE regexp_like(t.name, '.*\D[0-9]{2}-[0-9]{4}\D.*')
   AND regexp_count(t.name, '[0-9]-[0-9]{3}') = 1
   AND regexp_count(t.name, '[0-9]-[0-9]{4}') = 1
   AND regexp_count(t.name, '[0-9]{2}-[0-9]{3}') = 1
   AND regexp_count(t.name, '[0-9]{2}-[0-9]{4}') = 1;
*/
