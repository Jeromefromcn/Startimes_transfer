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
  /* 从基础数据表中获取数据,如果没有相应基础数据返回null */
  FUNCTION fun_get_basedata2(p_old_baseid VARCHAR2, p_data_type VARCHAR2)
    RETURN VARCHAR2;
  /* 根据条件判断该方格是否存在*/
  FUNCTION fun_is_grid_enable(addrid VARCHAR2,
                              floor  NUMBER,
                              unit   NUMBER,
                              room   NUMBER) RETURN NUMBER;

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
  END;

  --- ****** 从基础数据表中获取基础数据 ******--------
  FUNCTION fun_get_basedata2(p_old_baseid VARCHAR2, p_data_type VARCHAR2)
    RETURN VARCHAR2 IS
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
            v_new_baseid := NULL;
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
        RETURN(NULL);
    END;
  END;

  FUNCTION fun_is_grid_enable(addrid VARCHAR2,
                              floor  NUMBER,
                              unit   NUMBER,
                              room   NUMBER) RETURN NUMBER IS
    v_count NUMBER(3);
  BEGIN
    -- 赋初值为有效
    SELECT COUNT(*)
      INTO v_count
      FROM import_grid_other_info t
     WHERE t.addr_id = addrid
       AND t.unexist_floor = floor
       AND t.unexist_unit = unit
       AND t.unexist_room = room;
  
    IF v_count > 0 THEN
      RETURN(0);
    END IF;
    -- 如果通过楼层、单元、户室没有查到信息，有可能该单元整个楼层无效，还需要通过楼层和单元进行查找
    SELECT COUNT(*)
      INTO v_count
      FROM import_grid_other_info t
     WHERE t.addr_id = addrid
       AND t.unexist_floor = floor
       AND t.unexist_unit = unit;
    IF v_count > 0 THEN
      RETURN(0);
    END IF;
    RETURN(1);
  END;

END transfer_dvb_utils_pkg;
/
