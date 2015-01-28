-- 验证地址总量
SELECT COUNT(*) FROM fsboss_places t;
SELECT COUNT(*) FROM addressen t;

-- 方格图总量
SELECT COUNT(*) FROM fsboss_manageaddresses_fs;
SELECT COUNT(*) FROM murotoen m WHERE m.isenable = 1;

-- 验证资源总量
SELECT COUNT(*) FROM fsboss_phyresource t;
SELECT COUNT(*) FROM phyresourceen t;

-- 验证客户总量
SELECT COUNT(*) FROM fsboss_customer t;
SELECT COUNT(*) FROM customeren t;

-- 验证用户总量
SELECT COUNT(*) FROM fsboss_subscriber t;
SELECT COUNT(*) FROM subscriberen t;

-- 验证物理产品实例总量
SELECT COUNT(*) FROM fsboss_phy_instance;
SELECT COUNT(*) FROM instanceen i WHERE i.productchildtypeid = 1;

-- 验证服务产品实例总量
SELECT COUNT(*) FROM fsboss_ser_instance;
SELECT COUNT(*) FROM instanceen i WHERE i.productchildtypeid = 2;

SELECT COUNT(*)
  FROM subscriberen        s, -- 用户表
       customeren          c, --客户表
       fsboss_ser_instance fsi -- 服务产品实例临时表
 WHERE s.businessid = 2
   AND c.customerid_pk = s.customerid_pk
   AND fsi.terminalid = s.addinfostr3;

SELECT c.code, pi.*
  FROM fsboss_phy_instance pi, fsboss_customer c
 WHERE NOT EXISTS
 (SELECT '*' FROM subscriberen s WHERE s.addinfostr4 = pi.terminalid)
   AND c.id = pi.customerid;
