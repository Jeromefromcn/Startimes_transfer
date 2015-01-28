/*1.给subscriberen表增加字段 addinfostr4*/

/*ALTER TABLE subscriberen ADD (addinfostr4 VARCHAR2(50));*/

/*2.导入客户时，客户地址取自用户，需要提供中间表得到客户与地址的关系*/
DROP TABLE cust_address;
CREATE TABLE cust_address AS 
SELECT ss.cust_id, ss.addr_code, ss.serv_address
  FROM lyboss.serv ss
 WHERE ss.serv_id IN
       (SELECT MAX(s.serv_id) FROM lyboss.serv s GROUP BY s.cust_id);

ALTER TABLE cust_address add(address_pk NUMBER(8),
                             addressnamestr VARCHAR2(50),
                             address_fk NUMBER(8),
                             addressnamestr_fk VARCHAR2(500));



/*4.将中间表中，根据原系统地址编码对其到四达Boss系统的地址pk
并且获取四达Boss系统中的 当前地址名称，上级地址pk,上级地址全称*/

UPDATE cust_address ca
   SET ca.address_pk =
       (SELECT a.addressid_pk FROM addressen a WHERE a.mem = ca.addr_code);

UPDATE cust_address ca
   SET ca.addressnamestr   =
       (SELECT a.addressnamestr
          FROM addressen a
         WHERE a.addressid_pk = ca.address_pk),
       ca.address_fk       =
       (SELECT ad.addressid_fk
          FROM addressen ad
         WHERE ad.addressid_pk = ca.address_pk),
       ca.addressnamestr_fk =
       (SELECT adr.addressfullnamestr
          FROM addressen adr
         WHERE adr.addressid_pk = ca.address_fk);
COMMIT;
