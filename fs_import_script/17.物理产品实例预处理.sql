--��ȡ������Դ���Ʒ����ϵ
DROP TABLE fsboss_phy_ins_relation;
CREATE TABLE fsboss_phy_ins_relation 
AS SELECT * from huiju.productphysicalresources_fs;

-- ��ȡ�����Ʒʵ����Ϣ
DROP TABLE fsboss_phy_instance;
CREATE TABLE fsboss_phy_instance AS
SELECT card.code rescode, -- ���ܿ����룬ȡ�������
       '����:' || mk.name mem,
       1 equ_type, -- ��Դ����:���ܿ�
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

-- �ڶ����֣�������
SELECT box.code rescode, -- �����б���
       '����:' || mk.name mem,
       2 equ_type, -- ��Դ����:������
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

-- �������֣�EOC
SELECT eoc.code rescode, -- EOC����
       '����:' || mk.name mem,
       9 equ_type, -- ��Դ���ͣ�eoc
       eoc.resourcespecificationid resourcespecificationid,
       pd.*
  FROM huiju.products_fs                 pd,
       huiju.productphysicalresources_fs phy, --Eoc��Դռ�ñ�
       huiju.eocs_fs                     eoc,
       huiju.marketingplans              mk
 WHERE pd.id = phy.productid
   AND pd.marketingplanid = mk.id(+)
   AND phy.physicalresourceid = eoc.id;
   
   
 

-- ��������   
/* 90003--��6838 ok
 90005--��6840 ok
 90161--��6845 ok
 90002--��6232 ok
 90006--��6841 ok
 90004--��6839*/
CREATE INDEX index_phy_instance_1 ON fsboss_phy_instance(id);

UPDATE fsboss_phy_instance pi SET pi.productofferingid = 90006
 WHERE pi.id IN (SELECT p.id
                   FROM fsboss_phy_instance     p,
                        fsboss_phyresource      pf,
                        fsboss_phy_ins_relation prf
                  WHERE p.productofferingid = 90169 --δ���������
                    AND prf.physicalresourceid = pf.id
                    AND pf.equiptype = 2
                    AND prf.productid = p.id
                    AND pf.resourcespecificationid = 6841 --����
                 );
UPDATE fsboss_phy_instance pi
   SET pi.productofferingid = 90005
 WHERE pi.id IN (SELECT p.id
                   FROM fsboss_phy_instance     p,
                        fsboss_phyresource      pf,
                        fsboss_phy_ins_relation prf
                  WHERE p.productofferingid = 90169 --δ���������
                    AND prf.physicalresourceid = pf.id
                    AND pf.equiptype = 2
                    AND prf.productid = p.id
                    AND pf.resourcespecificationid = 6840 --���ű���
                 );
UPDATE fsboss_phy_instance pi
   SET pi.productofferingid = 90003
 WHERE pi.id IN (SELECT p.id
                   FROM fsboss_phy_instance     p,
                        fsboss_phyresource      pf,
                        fsboss_phy_ins_relation prf
                  WHERE p.productofferingid = 90169 --δ���������
                    AND prf.physicalresourceid = pf.id
                    AND pf.equiptype = 2
                    AND prf.productid = p.id
                    AND pf.resourcespecificationid = 6838 --��ά
                 );


UPDATE fsboss_phy_instance pi
   SET pi.productofferingid = 90161
 WHERE pi.id IN (SELECT p.id
                   FROM fsboss_phy_instance     p,
                        fsboss_phyresource      pf,
                        fsboss_phy_ins_relation prf
                  WHERE p.productofferingid = 90169 --δ���������
                    AND prf.physicalresourceid = pf.id
                    AND pf.equiptype = 2
                    AND prf.productid = p.id
                    AND pf.resourcespecificationid = 6845 --���Ÿ���
                 );

UPDATE fsboss_phy_instance pi
   SET pi.productofferingid = 90002
 WHERE pi.id IN (SELECT p.id
                   FROM fsboss_phy_instance     p,
                        fsboss_phyresource      pf,
                        fsboss_phy_ins_relation prf
                  WHERE p.productofferingid = 90169 --δ���������
                    AND prf.physicalresourceid = pf.id
                    AND pf.equiptype = 2
                    AND prf.productid = p.id
                    AND pf.resourcespecificationid = 6232 --�����й��
                 );

UPDATE fsboss_phy_instance pi
   SET pi.productofferingid = 90004
 WHERE pi.id IN (SELECT p.id
                   FROM fsboss_phy_instance     p,
                        fsboss_phyresource      pf,
                        fsboss_phy_ins_relation prf
                  WHERE p.productofferingid = 90169 --δ���������
                    AND prf.physicalresourceid = pf.id
                    AND pf.equiptype = 2
                    AND prf.productid = p.id
                    AND pf.resourcespecificationid = 6839 --�����й��
                 );


COMMIT;
