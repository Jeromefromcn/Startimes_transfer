-- 提取客户信息 
-- 账户的名字、余额账本的名字、客户的名字字段长度都改为256
ALTER TABLE customeren modify(customernamestr VARCHAR2(256));
ALTER TABLE accounten Modify(accountnamestr Varchar2(255));
ALTER TABLE acctbooken MODIFY (acctbooknamestr VARCHAR2(256));
ALTER TABLE subscriberen ADD(addinfostr4 VARCHAR2(50));
ALTER TABLE customeren MODIFY (LINKMANSTR Varchar2(256));

DROP TABLE fsboss_customer; 
CREATE TABLE fsboss_customer AS
SELECT t.*,
       ma.managesectionid  managesectionid, -- 用来关联地址
       cla.customerlevelid customerlevelid -- 用来关联社会类别
  FROM fsboss.customers_fs               t,
       fsboss.manageaddresses_fs         ma,
       fsboss.customerlevelagreements_fs cla,
       fsboss_places                     p
 WHERE t.defaultinstalladdressid IS NOT NULL
   AND t.defaultinstalladdressid = ma.id
   AND t.id = cla.customerid
   AND ma.managesectionid = p.id;
-- 主键增加索引
CREATE INDEX index_customer_id ON fsboss_customer(id);
-- 与地址关联的字段增加索引
CREATE INDEX index_customer_msid ON fsboss_customer(managesectionid);
-- 增加索引
CREATE INDEX index_fsboss_def_install_add ON fsboss_customer(defaultinstalladdressid);
-- 增加方格id，生成方格时填入
ALTER TABLE fsboss_customer add murotoid NUMBER(19);
-- 增加索引
CREATE INDEX index_cust_murotoid ON fsboss_customer(murotoid);

COMMIT;
