--提取物理资源与产品见关系
DROP TABLE fsboss_phy_ins_relation;
CREATE TABLE fsboss_phy_ins_relation 
AS SELECT * from huiju.productphysicalresources_fs;

-- 提取物理产品实例信息
DROP TABLE fsboss_phy_instance;
CREATE TABLE fsboss_phy_instance AS
SELECT card.code rescode, -- 智能卡编码，取服务号码
       '倒库:' || mk.name mem,
       1 equ_type, -- 资源类型:智能卡
       card.resourcespecificationid resourcespecificationid,
       pd.*
  FROM huiju.products_fs                 pd,
       huiju.productphysicalresources_fs phy,
       huiju.smartcards_fs               card,
       huiju.marketingplans              mk
 WHERE pd.id = phy.productid
   AND phy.physicalresourceid = card.id
   AND pd.marketingplanid = mk.id(+)

UNION

-- 第二部分：机顶盒
SELECT box.code rescode, -- 机顶盒编码
       '倒库:' || mk.name mem,
       2 equ_type, -- 资源类型:机顶盒
       box.resourcespecificationid resourcespecificationid,
       pd.*
  FROM huiju.productphysicalresources_fs phy,
       huiju.products_fs                 pd,
       huiju.settopboxs_fs               box,
       huiju.marketingplans              mk
 WHERE pd.id = phy.productid
   AND phy.physicalresourceid = box.id
   AND pd.marketingplanid = mk.id(+)

UNION

-- 第三部分：EOC
SELECT eoc.code rescode, -- EOC编码
       '倒库:' || mk.name mem,
       9 equ_type, -- 资源类型：eoc
       eoc.resourcespecificationid resourcespecificationid,
       pd.*
  FROM huiju.products_fs                 pd,
       huiju.productphysicalresources_fs phy, --Eoc资源占用表
       huiju.eocs_fs                     eoc,
       huiju.marketingplans              mk
 WHERE pd.id = phy.productid
   AND pd.marketingplanid = mk.id(+)
   AND phy.physicalresourceid = eoc.id;
   
   
 

-- 增加索引   
/* 90003--》6838 ok
 90005--》6840 ok
 90161--》6845 ok
 90002--》6232 ok
 90006--》6841 ok
 90004--》6839*/
CREATE INDEX index_phy_instance_1 ON fsboss_phy_instance(id);

UPDATE fsboss_phy_instance pi SET pi.productofferingid = 90006
 WHERE pi.id IN (SELECT p.id
                   FROM fsboss_phy_instance     p,
                        fsboss_phyresource      pf,
                        fsboss_phy_ins_relation prf
                  WHERE p.productofferingid = 90169 --未购买机顶盒
                    AND prf.physicalresourceid = pf.id
                    AND pf.equiptype = 2
                    AND prf.productid = p.id
                    AND pf.resourcespecificationid = 6841 --九联
                 );
UPDATE fsboss_phy_instance pi
   SET pi.productofferingid = 90005
 WHERE pi.id IN (SELECT p.id
                   FROM fsboss_phy_instance     p,
                        fsboss_phyresource      pf,
                        fsboss_phy_ins_relation prf
                  WHERE p.productofferingid = 90169 --未购买机顶盒
                    AND prf.physicalresourceid = pf.id
                    AND pf.equiptype = 2
                    AND prf.productid = p.id
                    AND pf.resourcespecificationid = 6840 --海信标清
                 );
UPDATE fsboss_phy_instance pi
   SET pi.productofferingid = 90003
 WHERE pi.id IN (SELECT p.id
                   FROM fsboss_phy_instance     p,
                        fsboss_phyresource      pf,
                        fsboss_phy_ins_relation prf
                  WHERE p.productofferingid = 90169 --未购买机顶盒
                    AND prf.physicalresourceid = pf.id
                    AND pf.equiptype = 2
                    AND prf.productid = p.id
                    AND pf.resourcespecificationid = 6838 --创维
                 );


UPDATE fsboss_phy_instance pi
   SET pi.productofferingid = 90161
 WHERE pi.id IN (SELECT p.id
                   FROM fsboss_phy_instance     p,
                        fsboss_phyresource      pf,
                        fsboss_phy_ins_relation prf
                  WHERE p.productofferingid = 90169 --未购买机顶盒
                    AND prf.physicalresourceid = pf.id
                    AND pf.equiptype = 2
                    AND prf.productid = p.id
                    AND pf.resourcespecificationid = 6845 --海信高清
                 );

UPDATE fsboss_phy_instance pi
   SET pi.productofferingid = 90002
 WHERE pi.id IN (SELECT p.id
                   FROM fsboss_phy_instance     p,
                        fsboss_phyresource      pf,
                        fsboss_phy_ins_relation prf
                  WHERE p.productofferingid = 90169 --未购买机顶盒
                    AND prf.physicalresourceid = pf.id
                    AND pf.equiptype = 2
                    AND prf.productid = p.id
                    AND pf.resourcespecificationid = 6232 --机顶盒规格
                 );

UPDATE fsboss_phy_instance pi
   SET pi.productofferingid = 90004
 WHERE pi.id IN (SELECT p.id
                   FROM fsboss_phy_instance     p,
                        fsboss_phyresource      pf,
                        fsboss_phy_ins_relation prf
                  WHERE p.productofferingid = 90169 --未购买机顶盒
                    AND prf.physicalresourceid = pf.id
                    AND pf.equiptype = 2
                    AND prf.productid = p.id
                    AND pf.resourcespecificationid = 6839 --机顶盒规格
                 );


COMMIT;
