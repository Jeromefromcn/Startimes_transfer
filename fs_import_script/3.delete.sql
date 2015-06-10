-- 删除操作员
DELETE FROM operationlogen;
DELETE FROM operator_roleen o WHERE o.operatorid_pk NOT IN (1, 2);
DELETE FROM operator_stocken os WHERE os.operatorid_pk NOT IN (1, 2);
DELETE FROM operator_salechannelen os WHERE os.operatorid_pk NOT IN (1, 2);
DELETE FROM operator_operareaen oo WHERE oo.operatorid_pk NOT IN (1, 2);
DELETE FROM favoriteen f WHERE f.operatorid NOT IN (1, 2);
DELETE FROM servicesegment_operatoren so
 WHERE so.operator_pk NOT IN (1, 2);
DELETE FROM operatoren o WHERE o.operatorid_pk NOT IN (1, 2);

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
delete from priceinstanceen t WHERE EXISTS(
  SELECT 'x'
    FROM instanceen i
   WHERE i.productchildtypeid = 2
     AND t.instanceid_pk = i.instanceid_pk);
delete from priceinstanceen t WHERE EXISTS(
  SELECT 'x'
    FROM instanceen i
   WHERE i.productchildtypeid = 2
     AND t.instanceid_pk = i.instanceid_pk);
DELETE FROM prodinschangelogen t
 WHERE EXISTS (SELECT 'x'
          FROM instanceen i
         WHERE i.productchildtypeid = 2
           AND t.instanceid_pk = i.instanceid_pk);
delete from instanceserviceen;
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
delete from instanceen t WHERE t.productchildtypeid = 1;
-- 用户
DELETE FROM subscriberstatusalterlogen;
DELETE FROM acceptsheet_subscriberen;
delete from subscriberen;
-- 押金
DELETE FROM depositrecorden;
DELETE FROM paymenten;
-- 客户
delete from muroto_custen;
delete from acctbalanceobjen;
delete from payprojecten;
delete from balancelogen;
delete from acctbooken;
delete from writeoffen;
delete from ncpayrelation;
delete from note_paymenten;
delete from checkpayrelation;
delete from paymenten;
delete from accounten;
delete from norecurringen;
delete from ordercontenten;
delete from orderen;
delete from acceptsheeten;
delete from printinstanceen;
delete from customeren;
-- 逻辑资源
DELETE FROM logicresourceen;
-- 物理资源
DELETE FROM formdetailen;
delete from phyresourceen;
-- 方格图
truncate table muroto_custen;
delete from murotoen;
delete from flooren;
delete from uniten;
-- 网格关系
DELETE FROM servicesegment_addressen;
DELETE FROM servicesegment_operatoren;
UPDATE addressen a SET a.segmentid_pk = NULL;
-- 地址
DELETE FROM addrexinfoen t
 WHERE t.addressid_pk IN
       (SELECT a.addressid_pk FROM addressen a WHERE a.addresslevelid_pk > 1);
DELETE FROM addressen t WHERE t.addresslevelid_pk > 1;
COMMIT;
