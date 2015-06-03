-- Create table
create table TRANSFER_LOGS
(
  seq_no          NUMBER,
  oldcontentid    VARCHAR2(1024),
  typeid          NUMBER,
  comments        VARCHAR2(2048),
  newcontentid    VARCHAR2(1024),
  subscriberid_pk NUMBER,
  customerid_pk   NUMBER,
  instanceid_pk   NUMBER,
  usr_no          VARCHAR2(10),
  cus_no          VARCHAR2(10)
)
tablespace USERS
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
-- Add comments to the columns 
comment on column TRANSFER_LOGS.typeid
  is '--1:表示调整客户地址;--2:表示删除空房用户；--3:表示最后把南昌根下没有找到具体楼号的客户分散到各个片区地址中--4:表示计费截止日期为空的用户--5:表示调整用户的明细安装地址';
-- Create/Recreate indexes 
create index IDX$TL_3COL on TRANSFER_LOGS (SEQ_NO)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
create index IDX$TL_SUBSCRIBERID_PK on TRANSFER_LOGS (SUBSCRIBERID_PK)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
