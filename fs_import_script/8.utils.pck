CREATE OR REPLACE PACKAGE "TRANSFER_DVB_UTILS_PKG" IS

  -- Author  : JEROME
  -- Created : 2014/7/4 10:37:34 AM
  -- Purpose : 

  sql_code VARCHAR2(50);

  sql_errm VARCHAR2(1000);

  v_result NUMBER;

  --初始化客户密码，md5加密
  cust_pwd VARCHAR2(32) := 'e10adc3949ba59abbe56e057f20f883e'; --123456

  /* 从基础数据表中获取数据 */
  FUNCTION fun_get_basedata(p_old_baseid VARCHAR2, p_data_type VARCHAR2)
    RETURN VARCHAR2;

  /* 根据机顶盒编码确定机顶盒类型 */
  FUNCTION fun_get_stb_type(products_fsid NUMBER) RETURN NUMBER;

  FUNCTION fun_get_resourceid_by_rescode(p_rescode VARCHAR2,
                                         p_restype NUMBER) RETURN NUMBER;
  /*根据门址获得单元数*/
  FUNCTION fun_get_unitnum(p_addressname VARCHAR2) RETURN NUMBER;
  /*根据门址获得楼层数*/
  FUNCTION fun_get_floornum(p_addressname VARCHAR2) RETURN NUMBER;
  /*根据门址获得户数*/
  FUNCTION fun_get_murotonum(p_addressname VARCHAR2) RETURN NUMBER;

  /*进行MD5加密*/
  FUNCTION fun_md5(input_string VARCHAR2) RETURN VARCHAR2;

END transfer_dvb_utils_pkg;
/
CREATE OR REPLACE PACKAGE BODY "TRANSFER_DVB_UTILS_PKG" IS

  --- ****** 从基础数据表中获取基础数据 ******--------
  FUNCTION fun_get_basedata(p_old_baseid VARCHAR2, p_data_type VARCHAR2)
    RETURN VARCHAR2 IS
    /**************************************************************************
    creator: ouyanglie
    date: 2013-11-27
    reson:代码复用，在基础信息表里的信息可以通过类型和旧系统ID，采用此函数转换成新的ID
    ***************************************************************************/
    v_new_baseid VARCHAR2(100);
  
    CURSOR cur_get_baseid IS
      SELECT bt.newid newid
        FROM basedata_transfer bt
       WHERE bt.oldid = p_old_baseid
         AND bt.data_type = p_data_type;
  BEGIN
    v_new_baseid := '0';
    BEGIN
      FOR v_cur_get_baseid IN cur_get_baseid LOOP
        BEGIN
          IF v_cur_get_baseid.newid IS NULL THEN
            v_new_baseid := '0';
          ELSE
            v_new_baseid := v_cur_get_baseid.newid;
          END IF;
        END;
      END LOOP;
      RETURN(v_new_baseid);
    EXCEPTION
      WHEN OTHERS THEN
        sql_code := SQLCODE;
        sql_errm := SQLERRM;
        transfer_dvb_log_pkg.transfer_err_prc(p_sql_code => sql_code,
                                              p_sql_errm => sql_errm,
                                              p_calledby => 'transfer_dvb_utils_pkg.prc_get_basedata',
                                              p_comments => p_data_type,
                                              p_custid   => p_old_baseid);
        RETURN(0);
    END;
    --RETURN(v_result);
  END;

  FUNCTION fun_get_stb_type(products_fsid NUMBER) RETURN NUMBER
  --==============================================================================
    --function: 根据机顶盒编码判断机顶盒高标清类型，需要根据此类型确定导入用户的类型
    --createby: laiyaoyu
    --date    : 2014-11-01
    --history :
    --==============================================================================
   IS
    stb_type VARCHAR2(10);
  
    CURSOR stb_types IS
      SELECT pd.id
        FROM huiju.products_fs pd
       WHERE pd.id = products_fsid
         AND EXISTS
       (SELECT 'x'
                FROM huiju.products_fs                 pf,
                     huiju.productphysicalresources_fs phy,
                     huiju.settopboxs_fs               st,
                     huiju.settopboxspecifications     sts
               WHERE pf.terminalid = pd.terminalid
                 AND pf.id = phy.productid
                 AND st.id = phy.physicalresourceid
                 AND st.resourcespecificationid = sts.id
                 AND sts.code IN
                     ('HisenseHDSetTopBoxSpec', 'DoubleHDSetTopBoxSpec')
              
              )
         AND pd.id = products_fsid;
  
  BEGIN
    OPEN stb_types;
    IF stb_types%NOTFOUND THEN
      stb_type := 2046;
    ELSE
      stb_type := 2045;
    END IF;
    CLOSE stb_types;
    RETURN(stb_type);
  
  END;

  FUNCTION fun_get_resourceid_by_rescode(p_rescode VARCHAR2,
                                         p_restype NUMBER) RETURN NUMBER
  --==============================================================================
    --name    :fun_get_resourceid_by_rescode
    --参数：p_restype 1-智能卡；2-机顶盒
    --createby:frontsoft liuyuehua
    --date    :sep 15,2008
    --history :hudazhu  2013-12-07  去掉了对仓库的限制
    --==============================================================================
   IS
    v_resourceid_pk NUMBER;
  BEGIN
    SELECT MAX(pr.resourceid_pk)
      INTO v_resourceid_pk
      FROM phyresourceen pr
     WHERE pr.resourcecodestr = TRIM(p_rescode)
       AND pr.resourcetypeid = p_restype;
    RETURN(v_resourceid_pk);
  EXCEPTION
    WHEN OTHERS THEN
      sql_code := SQLCODE;
      sql_errm := SQLERRM;
      transfer_dvb_log_pkg.transfer_err_prc(p_sql_code => sql_code,
                                            p_sql_errm => sql_errm,
                                            p_calledby => 'transfer_dvb_utils_pkg.fun_get_resourceid_by_rescode',
                                            p_comments => p_rescode,
                                            p_custid   => NULL);
      RETURN('-1');
  END;

  FUNCTION fun_get_unitnum(p_addressname VARCHAR2) RETURN NUMBER IS
    v_unitnum NUMBER;
  BEGIN
    v_unitnum := to_number(substr(p_addressname,
                                  1,
                                  instr(p_addressname, '-') - 1));
    RETURN(v_unitnum);
  END;

  FUNCTION fun_get_floornum(p_addressname VARCHAR2) RETURN NUMBER IS
    v_floornum NUMBER;
  BEGIN
    v_floornum := to_number(substr(p_addressname,
                                   instr(p_addressname, '-') + 1,
                                   length(p_addressname) -
                                   instr(p_addressname, '-') - 2));
    RETURN(v_floornum);
  END;

  FUNCTION fun_get_murotonum(p_addressname VARCHAR2) RETURN NUMBER IS
    v_murotonum NUMBER;
  BEGIN
    v_murotonum := to_number(substr(p_addressname,
                                    length(p_addressname) - 1));
    RETURN(v_murotonum);
  END;

  FUNCTION fun_md5(input_string VARCHAR2) RETURN VARCHAR2 IS
    raw_input     RAW(128) := utl_raw.cast_to_raw(input_string);
    decrypted_raw RAW(2048);
    error_in_input_buffer_length EXCEPTION;
  BEGIN
    sys.dbms_obfuscation_toolkit.md5(input    => raw_input,
                                     checksum => decrypted_raw);
    RETURN lower(rawtohex(decrypted_raw));
  END;

END transfer_dvb_utils_pkg;
/
