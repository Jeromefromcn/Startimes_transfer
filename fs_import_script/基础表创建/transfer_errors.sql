-- Create table
create table TRANSFER_ERRORS
(
  errorno   NUMBER,
  errorcode VARCHAR2(200),
  calledby  VARCHAR2(200),
  custid    VARCHAR2(200),
  comments  VARCHAR2(2000),
  gentime   DATE,
  errormsg  VARCHAR2(2000)
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
-- Create/Recreate indexes 
create index FDSF on TRANSFER_ERRORS (COMMENTS)
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
