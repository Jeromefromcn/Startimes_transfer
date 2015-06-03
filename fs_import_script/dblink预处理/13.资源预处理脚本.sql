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
  FROM smartcards_fs@fsboss                 t,
       smartcardspecifications@fsboss       tt,
       physicalresourceentryitems_fs@fsboss pi,
       physicalresourceentries_fs@fsboss    pe
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
  FROM settopboxs_fs@fsboss                 t,
       settopboxspecifications@fsboss       tt,
       physicalresourceentryitems_fs@fsboss pi,
       physicalresourceentries_fs@fsboss    pe
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
  FROM eocs_fs@fsboss                      t,
       eocspecifications@fsboss             tt,
       physicalresourceentryitems_fs@fsboss pi,
       physicalresourceentries_fs@fsboss    pe
 WHERE t.resourcespecificationid = tt.id
   AND t.id = pi.physicalresourceid
   AND pi.physicalresourceentryid = pe.id);
COMMIT;
