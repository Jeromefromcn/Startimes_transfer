-- 提取智能卡、机顶盒、eoc设备信息
 DROP TABLE fsboss_phyresource;
 CREATE TABLE fsboss_phyresource AS
(SELECT t.id,
       t.version,
       t.code,
       t.name,
       t.serialnumber,
       t.description,
       t.startlifecycle,
       t.endlifecycle,
       t.resourcespecificationid,
       NULL                      macaddressid,
       t.statusid,
       NULL                      smartcardid,
       t.usingmodeid,
       t.statustime,
       t.preauthtimes,
       NULL                      usercode,
       t.purchasecontractid,
       t.neworoldattributeid,
       t.obtainwayid,
       NULL                      refurbishedattributeid,
       t.warranty,
       1                         equiptype, -- 智能卡
       tt.providerid             providerid,
       pe.keeperid               keeperid
  FROM fsboss.smartcards_fs                 t,
       fsboss.smartcardspecifications       tt,
       fsboss.physicalresourceentryitems_fs pi,
       fsboss.physicalresourceentries_fs    pe
 WHERE t.resourcespecificationid = tt.id
   AND t.id = pi.physicalresourceid
   AND pi.physicalresourceentryid = pe.id
UNION
SELECT t.id,
       t.version,
       t.code,
       t.name,
       t.serialnumber,
       t.description,
       t.startlifecycle,
       t.endlifecycle,
       t.resourcespecificationid,
       t.macaddressid,
       t.statusid,
       t.smartcardid,
       t.usingmodeid,
       t.statustime,
       t.preauthtimes,
       t.usercode,
       t.purchasecontractid,
       t.neworoldattributeid,
       t.obtainwayid,
       t.refurbishedattributeid,
       t.warranty,
       2                         equiptype, -- 机顶盒
       tt.providerid             providerid,
       pe.keeperid               keeperid
  FROM fsboss.settopboxs_fs                 t,
       fsboss.settopboxspecifications       tt,
       fsboss.physicalresourceentryitems_fs pi,
       fsboss.physicalresourceentries_fs    pe
 WHERE t.resourcespecificationid = tt.id
   AND t.id = pi.physicalresourceid
   AND pi.physicalresourceentryid = pe.id
UNION
SELECT t.id,
       t.version,
       t.code,
       t.name,
       t.serialnumber,
       t.description,
       t.startlifecycle,
       t.endlifecycle,
       t.resourcespecificationid,
       t.macaddressid,
       t.statusid,
       NULL                      smartcardid,
       t.usingmodeid,
       t.statustime,
       t.preauthtimes,
       NULL                      usercode,
       t.purchasecontractid,
       t.neworoldattributeid,
       t.obtainwayid,
       NULL                      refurbishedattributeid,
       NULL                      warranty,
       9                         equiptype, -- EOC
       tt.providerid             providerid,
       pe.keeperid               keeperid
  FROM fsboss.eocs_fs                       t,
       fsboss.eocspecifications             tt,
       fsboss.physicalresourceentryitems_fs pi,
       fsboss.physicalresourceentries_fs    pe
 WHERE t.resourcespecificationid = tt.id
   AND t.id = pi.physicalresourceid
   AND pi.physicalresourceentryid = pe.id);
COMMIT;
