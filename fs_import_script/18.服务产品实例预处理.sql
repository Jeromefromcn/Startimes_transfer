-- 提取服务产品实例信息




-- 第一部分：数字电视基本包
DROP TABLE fsboss_ser_instance;
CREATE TABLE fsboss_ser_instance AS
SELECT pd.terminalid,
       pd.id,
       pd.productofferingid serviceproduct_id, -- 产品PK
       2 productchildtypeid, -- 产品子类 2：服务产品
       1 salewayid, -- 销售方式
       pd.startvalidfor subscriberstartdt, -- 计费开始日期
       0 billingflag, -- 产品是否计费， 0：计费 
       pd.startvalidfor rundt, -- 开通日期  
       pd.endvalidfor enddt, -- 计费截止日期 
       mk.name || '原产品:' || po.name || ';原优惠:' || pre.name mem, -- 取得套餐名称作为备注 
       to_date((to_char(pd.startvalidfor, 'yyyyMMdd') || '000000'),
               'yyyyMMddhh24miss') createdt,
       pd.startlifecycle finishdt, -- 竣工日期，取产品的计费开始日期
       po.name oldproname, -- 原系统产品名称
       1 export_pro_type -- 导库用产品类型 1：数字基本包
  FROM huiju.products_fs               pd, --汇巨系统用户订购表
       huiju.marketingplans            mk, --营销计划表
       huiju.productofferings          po,
       huiju.productofferingattributes poatt,
       huiju.simpletypes               poatts,
       huiju.preferentialpolicies      pre
 WHERE pd.productofferingid = po.id
   AND po.id = poatt.productofferingid
   AND poatt.domainobjectattributeid = poatts.id
   AND poatts.code = 'Po_DigitalBase'
   AND pd.statusid IN (3602, 3604, 3609, 3612)
   AND pd.marketingplanid = mk.id(+)
   AND pd.preferentialpolicyid = pre.id(+)

UNION

-- 第二部分：时段产品
SELECT pd.terminalid,
       pd.id,
       pd.productofferingid serviceproduct_id, -- 产品PK
       2 productchildtypeid, -- 产品子类 2：服务产品
       1 salewayid, -- 销售方式
       pd.startvalidfor subscriberstartdt, -- 计费开始日期
       0 billingflag, -- 产品是否计费， 0：计费 
       pd.startvalidfor rundt, -- 开通日期            
       pd.endvalidfor enddt, -- 计费截止日期 
       mk.name || '原产品:' || pf.name || ';原优惠-' || pre.name mem,
       pd.startvalidfor createdt,
       pd.startvalidfor finishdt, -- 竣工日期，取产品的计费开始日期
       pf.name oldproname, -- 原系统产品名称
       2 export_pro_type -- 导库用产品类型 2：简单产品
  FROM fsboss_products             pf, --需要导入的产品信息表
       huiju.products_fs          pd,
       huiju.marketingplans       mk, --汇巨系统的营销计划
       huiju.preferentialpolicies pre
 WHERE pd.productofferingid = pf.id
   AND pd.marketingplanid = mk.id(+)
   AND pd.preferentialpolicyid = pre.id(+)
   AND pd.statusid IN (3601, 3602, 3604, 3605, 3612)
   AND pf.isdvb = 1
   AND pd.endvalidfor >TRUNC(SYSDATE) ------数字时段产品计费截止日期大于当前日期的认为已到期 不导入
UNION

SELECT pd.terminalid,
       pd.id,
       pd.productofferingid serviceproduct_id, -- 产品PK
       2 productchildtypeid, -- 产品子类 2：服务产品
       1 salewayid, -- 销售方式
       pd.startvalidfor subscriberstartdt, -- 计费开始日期
       0 billingflag, -- 产品是否计费， 0：计费 
       pd.startvalidfor rundt, -- 开通日期            
       pd.endvalidfor enddt, -- 计费截止日期 
       mk.name || '原产品:' || pf.name || ';原优惠-' || pre.name mem,
       pd.startvalidfor createdt,
       pd.startvalidfor finishdt, -- 竣工日期，取产品的计费开始日期
       pf.name oldproname, -- 原系统产品名称
       2 export_pro_type -- 导库用产品类型 2：简单产品
  FROM fsboss_products             pf, --需要导入的产品信息表
       huiju.products_fs          pd,
       huiju.marketingplans       mk, --汇巨系统的营销计划
       huiju.preferentialpolicies pre
 WHERE pd.productofferingid = pf.id
   AND pd.marketingplanid = mk.id(+)
   AND pd.preferentialpolicyid = pre.id(+)
   AND pd.statusid IN (3601, 3602, 3604, 3605, 3612)
   AND pf.isdvb = 0

UNION

-- 第三部分：模拟基本包
SELECT pd.terminalid,
       pd.id,
       pd.productofferingid serviceproduct_id, -- 产品PK
       2 productchildtypeid, -- 产品子类 2：服务产品
       1 salewayid, -- 销售方式
       pd.startvalidfor subscriberstartdt, -- 计费开始日期
       0 billingflag, -- 产品是否计费， 0：计费 
       pd.startvalidfor rundt, -- 开通日期            
       pd.endvalidfor enddt, -- 计费截止日期 
       '原产品:' || pd.name || ';原优惠-' || pre.name mem,
       pd.startvalidfor createdt,
       pd.startvalidfor finishdt, -- 竣工日期，取产品的计费开始日期
       pd.name oldproname, -- 原系统产品名称
       3 export_pro_type -- 导库用产品类型 3,模拟基本包
  FROM huiju.productofferingattributes poatt,
       huiju.simpletypes               poatts,
       huiju.products_fs               pd,
       huiju.preferentialpolicies      pre -- 汇巨系统优惠
 WHERE pd.productofferingid = poatt.productofferingid
   AND poatt.domainobjectattributeid = poatts.id
   AND poatts.code = 'Po_Analog'
   AND pd.preferentialpolicyid = pre.id(+)
   AND pd.statusid IN (3601, 3602, 3604, 3605, 3612);
-- 增加索引
CREATE INDEX index_ser_instance_1 ON fsboss_ser_instance(serviceproduct_id);
CREATE INDEX index_ser_instance_2 ON fsboss_ser_instance(terminalid);
COMMIT;
