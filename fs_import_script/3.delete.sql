-- ɾ������Ա
DELETE FROM operationlogen;
DELETE FROM operator_roleen o WHERE o.operatorid_pk NOT IN (1, 2);
DELETE FROM operator_stocken os WHERE os.operatorid_pk NOT IN (1, 2);
DELETE FROM operator_salechannelen os WHERE os.operatorid_pk NOT IN (1, 2);
DELETE FROM operator_operareaen oo WHERE oo.operatorid_pk NOT IN (1, 2);
DELETE FROM favoriteen f WHERE f.operatorid NOT IN (1, 2);
DELETE FROM servicesegment_operatoren so
 WHERE so.operator_pk NOT IN (1, 2);
DELETE FROM operatoren o WHERE o.operatorid_pk NOT IN (1, 2);

-- ������Ҫɾ���ı�

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

-- ɾ��Ƿ���û����˵�
DELETE FROM billen;
DELETE FROM oweobjecten;

-- �����Ʒʵ��
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

-- �����Ʒʵ��
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
-- �û�
DELETE FROM subscriberstatusalterlogen;
DELETE FROM acceptsheet_subscriberen;
delete from subscriberen;
-- Ѻ��
DELETE FROM depositrecorden;
DELETE FROM paymenten;
-- �ͻ�
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
-- �߼���Դ
DELETE FROM logicresourceen;
-- ������Դ
DELETE FROM formdetailen;
delete from phyresourceen;
-- ����ͼ
truncate table muroto_custen;
delete from murotoen;
delete from flooren;
delete from uniten;
-- �����ϵ
DELETE FROM servicesegment_addressen;
DELETE FROM servicesegment_operatoren;
UPDATE addressen a SET a.segmentid_pk = NULL;
-- ��ַ
DELETE FROM addrexinfoen t
 WHERE t.addressid_pk IN
       (SELECT a.addressid_pk FROM addressen a WHERE a.addresslevelid_pk > 1);
DELETE FROM addressen t WHERE t.addresslevelid_pk > 1;
COMMIT;
