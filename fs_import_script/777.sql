SELECT t.rescode FROM fsboss_ser_instance t
minus
SELECT s.resourcecodestr FROM instanceen i,subscriberaddonen s WHERE i.productchildtypeid = 1 
 and s.instanceid_pk = i.instanceid_pk;

select * from phyresourceen p where p.resourcecodestr = '000F1E0B8765';
