      SELECT *
        FROM import_addressen ia
       WHERE ia.addresslevelid_pk = 5
         AND ia.organ_code like '@@LY%';


SELECT COUNT(*)  from import_grid_cust_mapping t WHERE t.is_in_grid = 'false';

SELECT * FROM import_grid_cust_mapping t WHERE t.cust_id = 969164;
SELECT t.addinfostr2,t.* from customeren t WHERE t.customerid_pk = 434102;
SELECT * from import_grid_cust_mapping t WHERE t.cust_id = 968968;

SELECT * from addressen a WHERE a.mem = 'A000000066';
SELECT * from uniten t WHERE t.addressid =119797;

SELECT * from import_grid_cust_mapping t ORDER BY t.cust_id
SELECT COUNT(*) FROM cust_address t;
SELECT * from customeren c WHERE c.addinfostr2 = '966351';
        SELECT m.murotoid_pk
          FROM murotoen m
         WHERE m.addressid = 119799
           AND m.murotocodestr = '6-4-2';
-- 关联的地址不存在方格图
SELECT COUNT(*)
  FROM cust_address t
 WHERE NOT EXISTS
 (SELECT 'x' FROM import_grid_info i WHERE i.addr_id = t.addr_code);

-- 不符合“x-x-x”格式结尾的，并且关联的地址存在方格图
SELECT COUNT(*)
  FROM cust_address ca
 WHERE ca.cust_id NOT IN
       (SELECT t.cust_id
          FROM cust_address t
         WHERE regexp_like(t.serv_address,
                           '([1-9]|[1-9]\d)-([1-9]|[1-9]\d)-([1-9]|[1-9]\d)$'))
   AND EXISTS
 (SELECT 'x' FROM import_grid_info i WHERE i.addr_id = ca.addr_code);

-- 符合 “x-x-x”格式结尾的，但不能对应到方格          
SELECT COUNT(*)
  FROM cust_address t, import_grid_info i
 WHERE regexp_like(t.serv_address,
                   '([1-9]|[1-9]\d)-([1-9]|[1-9]\d)-([1-9]|[1-9]\d)$')
   AND i.addr_id = t.addr_code
   AND NOT EXISTS (SELECT *
          FROM murotoen m
         WHERE m.murotocodestr =
               regexp_substr(t.serv_address,
                             '([1-9]|[1-9]\d)-([1-9]|[1-9]\d)-([1-9]|[1-9]\d)$')
           AND m.addressid = t.address_pk);

-- 符合 “x-x-x”格式结尾的，并且能对应到方格
SELECT COUNT(*)
  FROM cust_address t, import_grid_info i
 WHERE regexp_like(t.serv_address,
                   '([1-9]|[1-9]\d)-([1-9]|[1-9]\d)-([1-9]|[1-9]\d)$')
   AND i.addr_id = t.addr_code
   AND EXISTS (SELECT *
          FROM murotoen m
         WHERE m.murotocodestr =
               regexp_substr(t.serv_address,
                             '([1-9]|[1-9]\d)-([1-9]|[1-9]\d)-([1-9]|[1-9]\d)$')
           AND m.addressid = t.address_pk);
