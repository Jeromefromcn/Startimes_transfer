-- 提取网格与地址的关系
DROP TABLE fsboss_areamanagesections;
CREATE TABLE fsboss_areamanagesections AS
SELECT am.*
  FROM huiju.places p, huiju.areas a, huiju.areamanagesections am
 WHERE p.endlifecycle =
       to_date('9999/12/31 23:59:59', 'yyyy/MM/dd hh24:mi:ss') -- 关联的地址有效
   AND a.endlifecycle =
       to_date('9999/12/31 23:59:59', 'yyyy/MM/dd hh24:mi:ss') -- 关联的网格有效
   AND p.id = am.managesectionid
   AND a.id = am.areaid;

-- 提取网格与操作员的关系
DROP TABLE fsboss_areas;
CREATE TABLE fsboss_areas AS

SELECT a.id, a.employeeid
  FROM huiju.areas a
 WHERE a.endlifecycle =
       to_date('9999/12/31 23:59:59', 'yyyy/MM/dd hh24:mi:ss');
