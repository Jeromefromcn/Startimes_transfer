CREATE OR REPLACE PACKAGE transfer_dvb_log_pkg IS

  -- Author  : JEROME
  -- Created : 2014/7/4 10:43:11 AM
  -- Purpose : 

  sql_code VARCHAR2(50);
  sql_errm VARCHAR2(1000);

  PROCEDURE transfer_log_prc(p_msg VARCHAR2);

  PROCEDURE transfer_err_prc(p_sql_code transfer_errors.errorno%TYPE,
                             p_sql_errm transfer_errors.errorcode%TYPE,
                             p_calledby transfer_errors.calledby%TYPE,
                             p_comments transfer_errors.comments%TYPE,
                             p_custid   transfer_errors.custid%TYPE);

  PROCEDURE transfer_manage_prc(p_oldcontentid    transfer_logs.oldcontentid%TYPE,
                                p_typeid          transfer_logs.typeid%TYPE,
                                p_comments        transfer_logs.comments%TYPE,
                                p_newcontentid    transfer_logs.newcontentid%TYPE,
                                p_subscriberid_pk transfer_logs.subscriberid_pk%TYPE,
                                p_customerid_pk   transfer_logs.customerid_pk %TYPE,
                                p_instanceid_pk   transfer_logs.instanceid_pk %TYPE,
                                p_usr_no          transfer_logs.usr_no %TYPE,
                                p_cus_no          transfer_logs.cus_no %TYPE);

END transfer_dvb_log_pkg;
/
CREATE OR REPLACE PACKAGE BODY transfer_dvb_log_pkg IS

  PROCEDURE transfer_log_prc(p_msg VARCHAR2) IS
    file_handle utl_file.file_type;
  BEGIN
  
    file_handle := utl_file.fopen('DUMP_STARBOSS_DIR', 'import_log', 'a');
    utl_file.put_line(file_handle,
                      to_char(SYSDATE, 'yyyy-mm-dd,hh24:mi:ss') || ':' ||
                      p_msg);
    utl_file.fclose(file_handle);
  
  EXCEPTION
    WHEN OTHERS THEN
      sql_code := SQLCODE;
      sql_errm := SQLERRM;
      transfer_err_prc(p_sql_code => sql_code,
                       p_sql_errm => sql_errm,
                       p_calledby => '',
                       p_comments => '',
                       p_custid   => '');
    
  END;

  PROCEDURE transfer_err_prc(p_sql_code transfer_errors.errorno%TYPE,
                             p_sql_errm transfer_errors.errorcode%TYPE,
                             p_calledby transfer_errors.calledby%TYPE,
                             p_comments transfer_errors.comments%TYPE,
                             p_custid   transfer_errors.custid%TYPE) IS
  
  BEGIN
  
    INSERT INTO transfer_errors
      (errorno, calledby, errorcode, errormsg, gentime, comments, custid)
    VALUES
      (seq_transfer_errors.nextval,
       p_calledby,
       p_sql_code,
       p_sql_code || '  ' || p_sql_errm,
       SYSDATE,
       p_comments,
       p_custid);
    COMMIT;
  
  END;

  PROCEDURE transfer_manage_prc(p_oldcontentid    transfer_logs.oldcontentid%TYPE,
                                p_typeid          transfer_logs.typeid%TYPE,
                                p_comments        transfer_logs.comments%TYPE,
                                p_newcontentid    transfer_logs.newcontentid%TYPE,
                                p_subscriberid_pk transfer_logs.subscriberid_pk%TYPE,
                                p_customerid_pk   transfer_logs.customerid_pk %TYPE,
                                p_instanceid_pk   transfer_logs.instanceid_pk %TYPE,
                                p_usr_no          transfer_logs.usr_no %TYPE,
                                p_cus_no          transfer_logs.cus_no %TYPE) IS
  
    --1:从‘有效’变为‘无效’的产品实例;
    --2:三个基本包合成一个后失效的产品实例标识;
    --3:地址编码按模糊查询变换的地址编码;
    --4:调整基本包计费起始日期;
    --5:罚停用户跟踪
  
  BEGIN
    INSERT INTO transfer_logs
      (seq_no,
       oldcontentid,
       typeid,
       comments,
       newcontentid,
       subscriberid_pk,
       customerid_pk,
       instanceid_pk,
       usr_no,
       cus_no)
    VALUES
      (seq_transfer_logs.nextval,
       p_oldcontentid,
       p_typeid,
       p_comments,
       p_newcontentid,
       p_subscriberid_pk,
       p_customerid_pk,
       p_instanceid_pk,
       p_usr_no,
       p_cus_no);
  
    --commit;
  
  END;
END transfer_dvb_log_pkg;
/
