-- ��ȡ�����Ʒʵ����Ϣ




-- ��һ���֣����ֵ��ӻ�����
DROP TABLE fsboss_ser_instance;
CREATE TABLE fsboss_ser_instance AS
SELECT pd.terminalid,
       pd.id,
       pd.productofferingid serviceproduct_id, -- ��ƷPK
       2 productchildtypeid, -- ��Ʒ���� 2�������Ʒ
       1 salewayid, -- ���۷�ʽ
       pd.startvalidfor subscriberstartdt, -- �Ʒѿ�ʼ����
       0 billingflag, -- ��Ʒ�Ƿ�Ʒѣ� 0���Ʒ� 
       pd.startvalidfor rundt, -- ��ͨ����  
       pd.endvalidfor enddt, -- �Ʒѽ�ֹ���� 
       mk.name || 'ԭ��Ʒ:' || po.name || ';ԭ�Ż�:' || pre.name mem, -- ȡ���ײ�������Ϊ��ע 
       to_date((to_char(pd.startvalidfor, 'yyyyMMdd') || '000000'),
               'yyyyMMddhh24miss') createdt,
       pd.startlifecycle finishdt, -- �������ڣ�ȡ��Ʒ�ļƷѿ�ʼ����
       po.name oldproname, -- ԭϵͳ��Ʒ����
       1 export_pro_type -- �����ò�Ʒ���� 1�����ֻ�����
  FROM huiju.products_fs               pd, --���ϵͳ�û�������
       huiju.marketingplans            mk, --Ӫ���ƻ���
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

-- �ڶ����֣�ʱ�β�Ʒ
SELECT pd.terminalid,
       pd.id,
       pd.productofferingid serviceproduct_id, -- ��ƷPK
       2 productchildtypeid, -- ��Ʒ���� 2�������Ʒ
       1 salewayid, -- ���۷�ʽ
       pd.startvalidfor subscriberstartdt, -- �Ʒѿ�ʼ����
       0 billingflag, -- ��Ʒ�Ƿ�Ʒѣ� 0���Ʒ� 
       pd.startvalidfor rundt, -- ��ͨ����            
       pd.endvalidfor enddt, -- �Ʒѽ�ֹ���� 
       mk.name || 'ԭ��Ʒ:' || pf.name || ';ԭ�Ż�-' || pre.name mem,
       pd.startvalidfor createdt,
       pd.startvalidfor finishdt, -- �������ڣ�ȡ��Ʒ�ļƷѿ�ʼ����
       pf.name oldproname, -- ԭϵͳ��Ʒ����
       2 export_pro_type -- �����ò�Ʒ���� 2���򵥲�Ʒ
  FROM fsboss_products             pf, --��Ҫ����Ĳ�Ʒ��Ϣ��
       huiju.products_fs          pd,
       huiju.marketingplans       mk, --���ϵͳ��Ӫ���ƻ�
       huiju.preferentialpolicies pre
 WHERE pd.productofferingid = pf.id
   AND pd.marketingplanid = mk.id(+)
   AND pd.preferentialpolicyid = pre.id(+)
   AND pd.statusid IN (3601, 3602, 3604, 3605, 3612)
   AND pf.isdvb = 1
   AND pd.endvalidfor >TRUNC(SYSDATE) ------����ʱ�β�Ʒ�Ʒѽ�ֹ���ڴ��ڵ�ǰ���ڵ���Ϊ�ѵ��� ������
UNION

SELECT pd.terminalid,
       pd.id,
       pd.productofferingid serviceproduct_id, -- ��ƷPK
       2 productchildtypeid, -- ��Ʒ���� 2�������Ʒ
       1 salewayid, -- ���۷�ʽ
       pd.startvalidfor subscriberstartdt, -- �Ʒѿ�ʼ����
       0 billingflag, -- ��Ʒ�Ƿ�Ʒѣ� 0���Ʒ� 
       pd.startvalidfor rundt, -- ��ͨ����            
       pd.endvalidfor enddt, -- �Ʒѽ�ֹ���� 
       mk.name || 'ԭ��Ʒ:' || pf.name || ';ԭ�Ż�-' || pre.name mem,
       pd.startvalidfor createdt,
       pd.startvalidfor finishdt, -- �������ڣ�ȡ��Ʒ�ļƷѿ�ʼ����
       pf.name oldproname, -- ԭϵͳ��Ʒ����
       2 export_pro_type -- �����ò�Ʒ���� 2���򵥲�Ʒ
  FROM fsboss_products             pf, --��Ҫ����Ĳ�Ʒ��Ϣ��
       huiju.products_fs          pd,
       huiju.marketingplans       mk, --���ϵͳ��Ӫ���ƻ�
       huiju.preferentialpolicies pre
 WHERE pd.productofferingid = pf.id
   AND pd.marketingplanid = mk.id(+)
   AND pd.preferentialpolicyid = pre.id(+)
   AND pd.statusid IN (3601, 3602, 3604, 3605, 3612)
   AND pf.isdvb = 0

UNION

-- �������֣�ģ�������
SELECT pd.terminalid,
       pd.id,
       pd.productofferingid serviceproduct_id, -- ��ƷPK
       2 productchildtypeid, -- ��Ʒ���� 2�������Ʒ
       1 salewayid, -- ���۷�ʽ
       pd.startvalidfor subscriberstartdt, -- �Ʒѿ�ʼ����
       0 billingflag, -- ��Ʒ�Ƿ�Ʒѣ� 0���Ʒ� 
       pd.startvalidfor rundt, -- ��ͨ����            
       pd.endvalidfor enddt, -- �Ʒѽ�ֹ���� 
       'ԭ��Ʒ:' || pd.name || ';ԭ�Ż�-' || pre.name mem,
       pd.startvalidfor createdt,
       pd.startvalidfor finishdt, -- �������ڣ�ȡ��Ʒ�ļƷѿ�ʼ����
       pd.name oldproname, -- ԭϵͳ��Ʒ����
       3 export_pro_type -- �����ò�Ʒ���� 3,ģ�������
  FROM huiju.productofferingattributes poatt,
       huiju.simpletypes               poatts,
       huiju.products_fs               pd,
       huiju.preferentialpolicies      pre -- ���ϵͳ�Ż�
 WHERE pd.productofferingid = poatt.productofferingid
   AND poatt.domainobjectattributeid = poatts.id
   AND poatts.code = 'Po_Analog'
   AND pd.preferentialpolicyid = pre.id(+)
   AND pd.statusid IN (3601, 3602, 3604, 3605, 3612);
-- ��������
CREATE INDEX index_ser_instance_1 ON fsboss_ser_instance(serviceproduct_id);
CREATE INDEX index_ser_instance_2 ON fsboss_ser_instance(terminalid);
COMMIT;
