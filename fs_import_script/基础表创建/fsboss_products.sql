/*--创建临时表，保存需要导入的服务产品
并将需要基础数据中，本次需要导入的服务产品复制到改表中*/
create table FSBOSS_PRODUCTS
(
  id   NUMBER(19) not null,
  name VARCHAR2(255) not NULL,
  isdvb NUMBER(2) NOT NULL
)
tablespace USERS
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
