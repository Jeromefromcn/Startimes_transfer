-- 提取物理产品实例信息
DROP TABLE fsboss_phy_instance;
CREATE TABLE fsboss_phy_instance AS
SELECT card.code rescode, -- 智能卡编码，取服务号码
       '倒库:' || mk.name mem,
       1 equ_type, -- 资源类型:智能卡
       pd.*
  FROM fsboss.products_fs                 pd,
       fsboss.productphysicalresources_fs phy,
       fsboss.smartcards_fs               card,
       fsboss.marketingplans              mk
 WHERE pd.id = phy.productid
   AND phy.physicalresourceid = card.id
   AND pd.marketingplanid = mk.id(+)

UNION

-- 第二部分：机顶盒
SELECT box.code rescode, -- 机顶盒编码
       '倒库:' || mk.name mem,
       2 equ_type, -- 资源类型:机顶盒
       pd.*
  FROM fsboss.productphysicalresources_fs phy,
       fsboss.products_fs                 pd,
       fsboss.settopboxs_fs               box,
       fsboss.marketingplans              mk
 WHERE pd.id = phy.productid
   AND phy.physicalresourceid = box.id
   AND pd.marketingplanid = mk.id(+)

UNION

-- 第三部分：EOC
SELECT eoc.code rescode, -- EOC编码
       '倒库:' || mk.name mem,
       9 equ_type, -- 资源类型：eoc
       pd.*
  FROM fsboss.products_fs                 pd,
       fsboss.productphysicalresources_fs phy, --Eoc资源占用表
       fsboss.eocs_fs                     eoc,
       fsboss.marketingplans              mk
 WHERE pd.id = phy.productid
   AND pd.marketingplanid = mk.id(+)
   AND phy.physicalresourceid = eoc.id;

-- 增加索引
CREATE INDEX index_phy_instance_1 ON fsboss_phy_instance(id);
COMMIT;
