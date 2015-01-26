-- 删除操作员
/*DELETE FROM operationlogen;
DELETE FROM operator_roleen o WHERE o.operatorid_pk NOT IN (1, 2);
DELETE FROM operator_stocken os WHERE os.operatorid_pk NOT IN (1, 2);
DELETE FROM operator_salechannelen os WHERE os.operatorid_pk NOT IN (1, 2);
DELETE FROM operator_operareaen oo WHERE oo.operatorid_pk NOT IN (1, 2);
DELETE FROM favoriteen f WHERE f.operatorid NOT IN (1, 2);
DELETE FROM servicesegment_operatoren so
 WHERE so.operator_pk NOT IN (1, 2);
DELETE FROM operatoren o WHERE o.operatorid_pk NOT IN (1, 2);*/

-- 其他需要删除的表

DELETE FROM operationlogen;
DELETE FROM infochangedetailen;
DELETE FROM infochangeen;
DELETE FROM resourceacclogen;
DELETE FROM dvbbusiinsten;
DELETE FROM writeoffitemen;
DELETE FROM integralen;
DELETE FROM crediten;
DELETE FROM noteen;
DELETE FROM formaddonen;
DELETE FROM formen;
DELETE FROM checkedpaymenten;
DELETE FROM checknoterelation;
DELETE FROM his_dvbbusiinsten;
DELETE FROM discountuselogen;
DELETE FROM noteallocateen;
DELETE FROM vodinsten;

-- 删除欠费用户和账单
DELETE FROM billen;
DELETE FROM oweobjecten;

-- 服务产品实例
DELETE FROM priceinstanceen t
 WHERE EXISTS (SELECT 'x'
          FROM instanceen i
         WHERE i.productchildtypeid = 2
           AND t.instanceid_pk = i.instanceid_pk);
DELETE FROM prodinschangelogen t
 WHERE EXISTS (SELECT 'x'
          FROM instanceen i
         WHERE i.productchildtypeid = 2
           AND t.instanceid_pk = i.instanceid_pk);
DELETE FROM instanceserviceen;
DELETE FROM instanceen t WHERE t.productchildtypeid = 2;

-- 物理产品实例
DELETE FROM priceinstanceen t
 WHERE EXISTS (SELECT 'x'
          FROM instanceen i
         WHERE i.productchildtypeid = 1
           AND t.instanceid_pk = i.instanceid_pk);
DELETE FROM subscriberaddonen;
DELETE FROM prodinschangelogen t
 WHERE EXISTS (SELECT 'x'
          FROM instanceen i
         WHERE i.productchildtypeid = 1
           AND t.instanceid_pk = i.instanceid_pk);
DELETE FROM instanceen t WHERE t.productchildtypeid = 1;
-- 用户
DELETE FROM subscriberstatusalterlogen;
DELETE FROM acceptsheet_subscriberen;
DELETE FROM subscriberen;
-- 押金
DELETE FROM depositrecorden;
DELETE FROM paymenten;
-- 客户
DELETE FROM muroto_custen;
DELETE FROM acctbalanceobjen;
DELETE FROM payprojecten;
DELETE FROM balancelogen;
DELETE FROM acctbooken;
DELETE FROM writeoffen;
DELETE FROM ncpayrelation;
DELETE FROM note_paymenten;
DELETE FROM checkpayrelation;
DELETE FROM paymenten;
DELETE FROM accounten;
DELETE FROM norecurringen;
DELETE FROM ordercontenten;
DELETE FROM orderen;
DELETE FROM acceptsheeten;
DELETE FROM printinstanceen;
DELETE FROM customeren;
-- 逻辑资源
DELETE FROM logicresourceen;
-- 物理资源
DELETE FROM formdetailen;
DELETE FROM phyresourceen;

-- 依托方格
DELETE FROM muroto_custen t
 WHERE EXISTS (SELECT 'x'
          FROM uniten u, murotoen m
         WHERE u.unitnum = 0
           AND m.murotoid_pk = t.murotoid
           AND m.unitid = u.unitid_pk);
DELETE FROM murotoen t
 WHERE EXISTS (SELECT 'x'
          FROM uniten u
         WHERE u.unitnum = 0
           AND u.unitid_pk = t.unitid);

UPDATE uniten t SET t.subnum = 0 WHERE t.unitnum = 0;

-- 方格与客户关系
DELETE FROM muroto_custen;
-- 方格图
DELETE FROM murotoen;
DELETE FROM flooren;
DELETE FROM uniten;
-- 网格关系
DELETE FROM servicesegment_addressen;
DELETE FROM servicesegment_operatoren;
UPDATE addressen a SET a.segmentid_pk = NULL;
-- 光节点
UPDATE addressen a SET a.raynodeeid_fk = NULL;
DELETE FROM raynodeen t WHERE t.raynodeeid_pk > 0;
-- 地址
DELETE FROM addrexinfoen t
 WHERE t.addressid_pk IN
       (SELECT a.addressid_pk FROM addressen a WHERE a.addresslevelid_pk > 1);
DELETE FROM addressen t WHERE t.addresslevelid_pk > 1;
COMMIT;
