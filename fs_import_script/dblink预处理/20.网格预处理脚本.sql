-- ��ȡ�������ַ�Ĺ�ϵ
DROP TABLE fsboss_areamanagesections;
CREATE TABLE fsboss_areamanagesections AS
SELECT am.*
  FROM places@fsboss p, 
       areas@fsboss a, 
	   areamanagesections@fsboss am
 WHERE p.endlifecycle =
       to_date('9999/12/31 23:59:59', 'yyyy/MM/dd hh24:mi:ss') -- �����ĵ�ַ��Ч
   AND a.endlifecycle =
       to_date('9999/12/31 23:59:59', 'yyyy/MM/dd hh24:mi:ss') -- ������������Ч
   AND p.id = am.managesectionid
   AND a.id = am.areaid;

-- ��ȡ���������Ա�Ĺ�ϵ
DROP TABLE fsboss_areas;
CREATE TABLE fsboss_areas AS

SELECT a.id, a.employeeid
  FROM areas@fsboss a
 WHERE a.endlifecycle =
       to_date('9999/12/31 23:59:59', 'yyyy/MM/dd hh24:mi:ss');
