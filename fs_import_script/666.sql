select * FROM subscriberen s, fsboss_phy_instance pi
       WHERE s.addinfostr4 = pi.terminalid and pi.rescode = '000F1E0B8765';
       
select to_char(pp.terminalid) from fsboss_phy_instance pp where rescode = '000F1E0B8765';

select * from subscriberen s where s.addinfostr4 = '9223372029184323804';

select * from fsboss_subscriber fs where to_char(fs.terminalid) = '9223372029184323804';

select * from fsboss_ser_instance f where not exists (select 'x' from basedata_transfer b where b.data_type = '服务产品PK' and
b.oldid = f.serviceproduct_id)

select * from producten p where not exists(
   select 'x' from basedata_transfer b where to_char(p.productid_pk) = b.newid
) and p.productchildtypeid = 2;
