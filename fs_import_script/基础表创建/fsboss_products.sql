/*--������ʱ��������Ҫ����ķ����Ʒ
������Ҫ���������У�������Ҫ����ķ����Ʒ���Ƶ��ı���*/
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
