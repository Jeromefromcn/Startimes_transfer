-- 创建p1表 
DROP TABLE temp_places1;
CREATE TABLE temp_places1 AS
SELECT get_strarraystrofindex@fsboss(sys_connect_by_path(p.id, '>'), '>', 1) cid,
       p.id,
       p.operationroleid,
       p.endlifecycle
  FROM places@fsboss p
 START WITH p.parentid IS NOT NULL
CONNECT BY PRIOR p.parentid = p.id;
-- 增加索引
CREATE INDEX index_places1_1 ON temp_places1(ID);
CREATE INDEX index_places1_2 ON temp_places1(operationroleid);
CREATE INDEX index_places1_3 ON temp_places1(cid);
-- 创建p2表
DROP TABLE temp_places2;
CREATE TABLE temp_places2 AS
SELECT pa1.operationroleid, pa2.id, pa2.code, pa2.endlifecycle, pa2.name
  FROM places@fsboss pa1, places@fsboss pa2
 WHERE pa1.parentid IS NULL
   AND pa2.parentid = pa1.id;
-- 增加索引
CREATE INDEX index_places2_1 ON temp_places2(ID);
CREATE INDEX index_places2_2 ON temp_places2(operationroleid);
-- 提取数字用户信息
DROP TABLE fsboss_subscriber;
CREATE TABLE fsboss_subscriber AS
-- 服务号码、业务类型、用户类型、上次停断时间、终端号、主终端标识、用户状态
-- 绑定智能卡号 299932 相差53个，有基本包无智能卡
SELECT pd.*,
       sc.code servicestr, -- 用户服务号码
       2 type_of_service, -- 业务类型
       t.masterid masterid, -- 主终端标识
       t.terminalspecificationid terminalspecificationid, -- 终端类型标识，是否主终端
       decode(t.terminalspecificationid,
              9223372032954843176,
              1,
              t.serialnumber + 2) seqstr, -- 终端号
       1 accesspointid, -- 接入点id
       eu.organizationunit_id organizationunit_id, -- 受理渠道id
       '抚顺导库-数字用户' mem,
       transfer_dvb_utils_pkg.fun_get_stb_type(pd.id) subscriber_tpye, -- 数字用户类型
       2 authenticationtypeid, -- CA认证方式
       202 equiptypeid -- 设备类型
  FROM temp_places1                       p1,
       temp_places2                       p2,
       manageaddresses_fs@fsboss          m,
       customers_fs@fsboss                c,
       products_fs@fsboss                 pd,
       productofferingattributes@fsboss   poa,
       simpletypes@fsboss                 pos,
       terminals_fs@fsboss                t,
       terminalspecifications@fsboss      ts,
       smartcards_fs@fsboss               sc,
       productphysicalresources_fs@fsboss ppr,
       products_fs@fsboss                 scpd,
       employee_organizationunit@fsboss   eu
 WHERE p1.operationroleid = p2.operationroleid
   AND p1.id = p2.id
   AND m.managesectionid = p1.cid
   AND c.defaultinstalladdressid = m.id
   AND pd.customerid = c.id
   AND poa.productofferingid = pd.productofferingid
   AND pos.id = poa.domainobjectattributeid
   AND pos.code = 'Po_DigitalBase'
   AND t.id = pd.terminalid
   AND ts.id = t.terminalspecificationid
   AND pd.statusid IN (3602, 3604, 3609, 3612) -- 状态为正常、客户暂停、关联暂停、到期暂停
   AND scpd.id = ppr.productid
   AND ppr.physicalresourceid = sc.id
   AND scpd.terminalid = t.id
   AND eu.employee_id = pd.salesmanid
UNION

-- 提取模拟用户信息

SELECT pd.*,
       nvl(c.optionalcode, c.code) servicestr, -- 服务号码：优先取SMS客户编码，没有的取客户编码
       1 type_of_service, -- 业务类型
       t.masterid masterid, -- 主终端标识
       t.terminalspecificationid terminalspecificationid, -- 终端类型标识，是否主终端
       decode(t.terminalspecificationid,
              9223372032954843176,
              1,
              t.serialnumber + 2) seqstr, -- 终端号
       NULL accesspointid, -- 接入点id
       eu.organizationunit_id organizationunit_id, -- 受理渠道id
       '抚顺导库-模拟用户' mem,
       1045 subscriber_tpye, -- 模拟普通用户类型
       1 authenticationtypeid, -- 模拟认证方式
       NULL equiptypeid -- 设备类型
  FROM products_fs@fsboss               pd, -- 汇巨系统产品订购表
       productofferings@fsboss          po,
       productofferingattributes@fsboss poatt,
       simpletypes@fsboss               poatts,
       customers_fs@fsboss              c, --汇巨系统客户表
       terminals_fs@fsboss             t,
       employee_organizationunit@fsboss eu -- 受理人记录
 WHERE pd.customerid = c.id
   AND c.defaultinstalladdressid IS NOT NULL --没有门址的客户不导入
   AND pd.productofferingid = po.id
   AND po.id = poatt.productofferingid
   AND poatt.domainobjectattributeid = poatts.id
   AND pd.terminalid = t.id
   AND poatts.code = 'Po_Analog'
   AND eu.employee_id = pd.salesmanid
   AND pd.statusid IN (3601, 3602, 3604, 3605, 3612)

UNION

-- 提取宽带用户信息 

SELECT pd.*,
       TRIM(users.code) servicestr, -- 服务号码（重点）
       3 type_of_service, -- 业务类型
       t.masterid masterid, -- 主终端标识
       t.terminalspecificationid terminalspecificationid, -- 终端类型标识，是否主终端
       decode(t.terminalspecificationid,
              9223372032954843176,
              1,
              t.serialnumber + 2) seqstr, -- 终端号
       NULL accesspointid, -- 接入点id
       eu.organizationunit_id organizationunit_id, -- 受理渠道id
       '抚顺导库-宽带用户' mem,
       3045 subscriber_tpye, -- 宽带普通用户类型
       3 authenticationtypeid, -- 宽带认证方式
       NULL equiptypeid -- 设备类型
  FROM customers_fs@fsboss              c, --汇巨系统客户表
       products_fs@fsboss               pd, --汇巨系统产品订购表
       productofferings@fsboss          po, --汇巨系统产品表
       productofferingattributes@fsboss poatt, --汇巨系统产品类型表
       simpletypes@fsboss               poatts, --汇巨系统产品类型表2
       productservices_fs@fsboss        pf, --汇巨系统产品服务表
       userservices_fs@fsboss           uf, --汇巨系统用户订购服务表
       users_fs@fsboss                  users, --汇巨系统用户表，记录用户宽带账号
       employee_organizationunit@fsboss eu, -- 受理人记录
       terminals_fs@fsboss              t
 WHERE pd.statusid IN (3601, 3602, 3604, 3605, 3612)
   AND pd.productofferingid = po.id
   AND po.id = poatt.productofferingid
   AND poatt.domainobjectattributeid = poatts.id
   AND poatts.code = 'Po_Broadband'
   AND pf.productid = pd.id
   AND pd.salesmanid = eu.employee_id(+)
   AND pf.serviceid = uf.serviceid
   AND t.id = pd.terminalid
   AND uf.userid = users.id
   AND c.id = pd.customerid
   AND c.defaultinstalladdressid IS NOT NULL
UNION

-- 提取宽带专网用户信息 
SELECT pd.*,
       to_char(pd.id) servicestr, -- 服务号码（重点）
       3 type_of_service, -- 业务类型
       t.masterid masterid, -- 主终端标识
       t.terminalspecificationid terminalspecificationid, -- 终端类型标识，是否主终端
       decode(t.terminalspecificationid,
              9223372032954843176,
              1,
              t.serialnumber + 2) seqstr, -- 终端号
       NULL accesspointid, -- 接入点id
       eu.organizationunit_id organizationunit_id, -- 受理渠道id  
       '抚顺导库-宽带专网' mem,
       3045 subscriber_tpye, -- 宽带普通用户类型
       3 authenticationtypeid, -- 宽带认证方式
       NULL equiptypeid -- 设备类型
  FROM customers_fs@fsboss              c, --汇巨系统客户表
       products_fs@fsboss               pd, --汇巨系统产品订购表
       productofferings@fsboss          po, --汇巨系统产品表
       productofferingattributes@fsboss poatt, --汇巨系统产品类型表
       simpletypes@fsboss               poatts,
       employee_organizationunit@fsboss eu, --受理人
       terminals_fs@fsboss              t
 WHERE pd.statusid IN (3601, 3602, 3604, 3605, 3612)
   AND pd.productofferingid = po.id
   AND po.id = poatt.productofferingid
   AND poatt.domainobjectattributeid = poatts.id
   AND poatts.code = 'Po_Broadband'
   AND pd.salesmanid = eu.employee_id(+)
   AND c.id = pd.customerid
   AND pd.terminalid = t.id
   AND c.defaultinstalladdressid IS NOT NULL
   AND NOT EXISTS (SELECT 'x'
          FROM productservices_fs@fsboss pf
         WHERE pf.productid = pd.id);
         
-- 增加索引
CREATE INDEX index_subscriber_1 ON fsboss_subscriber(ID);
CREATE INDEX index_subscriber_2 ON fsboss_subscriber(customerid);

--删除重复terminalid中，status为3612的用户
DELETE fsboss_subscriber dfs
 WHERE dfs.terminalid IN
       (SELECT fs.terminalid
          FROM fsboss_subscriber fs
         WHERE EXISTS (SELECT *
                  FROM fsboss_subscriber fd
                 WHERE fd.terminalid = fs.terminalid
                   AND fd.servicestr <> fs.servicestr))
   AND dfs.statusid = 3612;
COMMIT;
