-- Create table
create table BASEDATA_TRANSFER
(
  newid     VARCHAR2(50),
  newdesc   VARCHAR2(50),
  oldid     VARCHAR2(50),
  olddesc   VARCHAR2(50),
  data_type VARCHAR2(50)
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
