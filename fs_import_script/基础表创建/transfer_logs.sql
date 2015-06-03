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
  is '--1:��ʾ�����ͻ���ַ;--2:��ʾɾ���շ��û���--3:��ʾ�����ϲ�����û���ҵ�����¥�ŵĿͻ���ɢ������Ƭ����ַ��--4:��ʾ�Ʒѽ�ֹ����Ϊ�յ��û�--5:��ʾ�����û�����ϸ��װ��ַ';
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
