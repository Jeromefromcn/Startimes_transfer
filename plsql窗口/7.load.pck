CREATE OR REPLACE PACKAGE transfer_dvb_load_pkg IS

  -- Author  : HUDAZHU
  -- Created : 2014/9/1 10:31:08 AM
  -- Purpose : 

  sql_code VARCHAR2(50);
  sql_errm VARCHAR2(1000);
  v_result NUMBER(1);

  PROCEDURE load_addrinfo_prc; -- 导入地址数据

  PROCEDURE load_raynode_prc; -- 导入光节点数据

  PROCEDURE load_grid_prc; -- 导入方格数据

  PROCEDURE load_customer_prc; --导入客户、账户、余额账本、支付方案、余额对象关系

  PROCEDURE load_grid_cust_mapping_prc; -- 导入方格与客户的关系

  PROCEDURE load_attached_grid_mapping_prc; -- 导入依托的方格，并建立方格与客户的关系

END transfer_dvb_load_pkg;
/
CREATE OR REPLACE PACKAGE BODY transfer_dvb_load_pkg IS

  -- 根据临时表创建BOSS系统的地址树信息

  PROCEDURE load_addrinfo_prc IS
    v_cnt                NUMBER;
    v_cnt_err            NUMBER;
    v_addr_count         NUMBER;
    v_addressid_pk       addressen.addressid_pk%TYPE;
    v_addresscodestr     addressen.addresscodestr%TYPE;
    v_detailaddressstr   addressen.detailaddressstr%TYPE;
    v_addressfullnamestr addressen.addressfullnamestr%TYPE;
    v_mem                addressen.mem%TYPE;
    v_result             NUMBER(1);
  
    -- 根据当前级别查询对应地址
    CURSOR cursor_current_level_address(level_num NUMBER) IS
      SELECT *
        FROM import_addressen ia
       WHERE ia.addresslevelid_pk = level_num;
  
  BEGIN
    v_cnt     := 0;
    v_cnt_err := 0;
    -- 循环第二级到第八级地址
    FOR level_num IN 2 .. 8 LOOP
      v_addr_count := 1;
      BEGIN
        -- 导入当前级别地址
        FOR c_current_level_addr IN cursor_current_level_address(level_num) LOOP
          BEGIN
            v_addr_count         := v_addr_count + 1;
            v_addresscodestr     := lpad(to_char(v_addr_count),
                                         c_current_level_addr.add_level_code_length,
                                         '0'); -- 地址码,根据地址编码长度左补0
            v_detailaddressstr   := c_current_level_addr.parent_full_name_code ||
                                    v_addresscodestr; -- 地址全称编码
            v_addressfullnamestr := c_current_level_addr.parent_full_name ||
                                    c_current_level_addr.address_name; -- 地址全称
            v_mem                := c_current_level_addr.address_id; -- 原系统id
          
            SELECT seq_addressen.nextval INTO v_addressid_pk FROM dual;
            v_result := transfer_dvb_insert_pkg.fun_insert_addressen(p_addressid_pk       => v_addressid_pk, -- 地址PK
                                                                     p_addressid_fk       => c_current_level_addr.addressid_fk,
                                                                     p_addresslevelid_pk  => c_current_level_addr.addresslevelid_pk,
                                                                     p_addressnamestr     => c_current_level_addr.address_name,
                                                                     p_addresscodestr     => v_addresscodestr,
                                                                     p_detailaddressstr   => v_detailaddressstr,
                                                                     p_addressabstr       => NULL,
                                                                     p_statusid           => 1, -- 地址状态默认有效
                                                                     p_mem                => v_mem,
                                                                     p_createid           => NULL,
                                                                     p_modifyid           => NULL,
                                                                     p_createcodestr      => NULL,
                                                                     p_modifycodestr      => NULL,
                                                                     p_terminalid         => NULL,
                                                                     p_salechannelid      => NULL,
                                                                     p_createdt           => SYSDATE,
                                                                     p_modifydt           => NULL,
                                                                     p_addressfullnamestr => v_addressfullnamestr);
            -- 插入地址扩展信息
            INSERT INTO addrexinfoen a
              (a.addrexinfoid_pk,
               a.addressid_pk,
               a.mem,
               a.createdt,
               a.statusid,
               a.structdt) -- 模拟信号关停日期
            VALUES
              (seq_addrexinfoen.nextval,
               v_addressid_pk,
               NULL,
               SYSDATE,
               1,
               NULL);
          
            -- 更新地址上starboss中的地址id
            UPDATE import_addressen ia
               SET ia.addressid_pk = v_addressid_pk
             WHERE ia.address_id = c_current_level_addr.address_id;
            -- 更新临时表中本级地址所有下级地址的上级地址id，上级地址全称编码，上级地址全称
            UPDATE import_addressen ia
               SET ia.addressid_fk          = v_addressid_pk,
                   ia.parent_full_name_code = v_detailaddressstr,
                   ia.parent_full_name      = v_addressfullnamestr
             WHERE ia.parent_address_id = c_current_level_addr.address_id;
          
            -- 将starboss中的对应地址id放入楼房与参数临时表的相应字段
            UPDATE import_grid_info t
               SET t.id_in_starboss =
                   (SELECT a.addressid_pk
                      FROM addressen a
                     WHERE a.mem = t.addr_id);
          
            -- 计数，每1000条提交
            v_cnt := v_cnt + 1;
            IF MOD(v_cnt, 1000) = 0 THEN
              COMMIT;
              transfer_dvb_log_pkg.transfer_log_prc(p_msg => v_cnt ||
                                                             ' addresses have been loaded in transfer_dvb_load_pkg.load_addrinfo_prc.');
            END IF;
          END;
        END LOOP;
      
      EXCEPTION
        WHEN OTHERS THEN
          sql_code  := SQLCODE;
          sql_errm  := SQLERRM;
          v_cnt_err := v_cnt_err + 1;
          transfer_dvb_log_pkg.transfer_err_prc(p_sql_code => sql_code,
                                                p_sql_errm => sql_errm,
                                                p_calledby => 'transfer_dvb_load_pkg.load_addrinfo_prc',
                                                p_comments => NULL,
                                                p_custid   => NULL);
      END;
    
    END LOOP;
    COMMIT;
    transfer_dvb_log_pkg.transfer_log_prc(p_msg => 'total ' || v_cnt_err ||
                                                   ' errors in transfer_dvb_load_pkg.load_addrinfo_prc.');
    transfer_dvb_log_pkg.transfer_log_prc(p_msg => 'total ' || v_cnt ||
                                                   ' addresses info loading finished.');
  END;
  PROCEDURE load_raynode_prc IS
    v_cnt              NUMBER;
    v_cnt_err          NUMBER;
    v_raynode_count    NUMBER;
    v_raynodeid_pk     raynodeen.raynodeeid_pk%TYPE;
    v_raynodeecodestr  raynodeen.raynodeecodestr%TYPE;
    v_detailraynodestr raynodeen.detailraynodestr%TYPE;
  
    -- 根据当前级别查询对应光节点
    CURSOR cursor_current_level_raynode(level_num NUMBER) IS
      SELECT *
        FROM import_raynode ir
       WHERE ir.raynodelevelid_pk = level_num;
  
  BEGIN
    v_cnt     := 0;
    v_cnt_err := 0;
    FOR level_num IN 1 .. 2 LOOP
      v_raynode_count := 0;
      BEGIN
        -- 导入当前级别光节点
        FOR c_raynode IN cursor_current_level_raynode(level_num) LOOP
          BEGIN
            v_raynode_count    := v_raynode_count + 1;
            v_raynodeecodestr  := lpad(to_char(v_raynode_count),
                                       c_raynode.raynode_level_code_length,
                                       '0'); -- 光节点编码,根据光节点编码长度左补0
            v_detailraynodestr := c_raynode.raynode_parent_full_name_code ||
                                  v_raynodeecodestr;
            SELECT seq_raynodeen.nextval INTO v_raynodeid_pk FROM dual;
          
            INSERT INTO raynodeen
              (raynodeenamestr,
               createdt,
               covermonth,
               raynodelevelid_pk,
               raynodeeid_pk,
               statusid,
               raynodeeid_fk,
               createid,
               detailraynodestr,
               raynodeecodestr,
               createcodestr,
               mem)
            VALUES
              (c_raynode.address_name,
               SYSDATE,
               SYSDATE,
               level_num,
               v_raynodeid_pk,
               1,
               c_raynode.raynodeid_fk,
               1,
               v_detailraynodestr,
               v_raynodeecodestr,
               '00000',
               c_raynode.address_id -- 原系统id
               );
          
            -- 更新地址上与光节点的关系,包括与光节点对应地址的所有下级地址
            UPDATE addressen a
               SET a.raynodeeid_fk = v_raynodeid_pk
             WHERE a.detailaddressstr LIKE
                   (SELECT t.detailaddressstr
                      FROM addressen t
                     WHERE t.mem = c_raynode.address_id) || '%';
          
            -- 更新临时表中本级光节点所有下级光节点的上级光节点id，上级光节点全称编码
            UPDATE import_raynode ir
               SET ir.raynodeid_fk                  = v_raynodeid_pk,
                   ir.raynode_parent_full_name_code = v_detailraynodestr
             WHERE ir.parent_address_id = c_raynode.address_id;
          
            -- 计数，每1000条提交
            v_cnt := v_cnt + 1;
            IF MOD(v_cnt, 1000) = 0 THEN
              COMMIT;
              transfer_dvb_log_pkg.transfer_log_prc(p_msg => v_cnt ||
                                                             ' raynode have been loaded in transfer_dvb_load_pkg.load_raynode_prc.');
            END IF;
          END;
        END LOOP;
      
      EXCEPTION
        WHEN OTHERS THEN
          sql_code  := SQLCODE;
          sql_errm  := SQLERRM;
          v_cnt_err := v_cnt_err + 1;
          transfer_dvb_log_pkg.transfer_err_prc(p_sql_code => sql_code,
                                                p_sql_errm => sql_errm,
                                                p_calledby => 'transfer_dvb_load_pkg.load_raynode_prc',
                                                p_comments => NULL,
                                                p_custid   => NULL);
      END;
    
    END LOOP;
    COMMIT;
    transfer_dvb_log_pkg.transfer_log_prc(p_msg => 'total ' || v_cnt_err ||
                                                   ' errors in transfer_dvb_load_pkg.load_raynode_prc.');
    transfer_dvb_log_pkg.transfer_log_prc(p_msg => 'total ' || v_cnt ||
                                                   ' raynode info loading finished.');
  
  END;

  PROCEDURE load_grid_prc IS
    v_cnt             NUMBER;
    v_cnt_err         NUMBER;
    v_zero_unitid_pk  uniten.unitid_pk%TYPE; -- 0单元id
    v_zero_floorid_pk flooren.floorid_pk%TYPE; -- 0楼层id
    v_unitid_pk       uniten.unitid_pk%TYPE; -- 单元的id
    v_floorid_pk      flooren.floorid_pk%TYPE; -- 楼层的id
    v_murotoid_pk     murotoen.murotoid_pk%TYPE; -- 户室的id
    v_grid_code       murotoen.murotocodestr%TYPE;
    v_muroto_num      NUMBER(5); -- 户室的个数
    v_isenable        NUMBER(1);
    CURSOR cur_building_infos IS
      SELECT *
        FROM import_grid_info t
       WHERE EXISTS (SELECT 'x' FROM addressen a WHERE a.mem = t.addr_id);
  BEGIN
    v_cnt     := 0;
    v_cnt_err := 0;
    FOR c_building IN cur_building_infos LOOP
      BEGIN
        -- 更新建筑物的参数
        UPDATE addrexinfoen ax
           SET ax.murotowayid   = transfer_dvb_utils_pkg.fun_get_basedata2(c_building.building_style,
                                                                           '进户方式'),
               ax.flotrendid    = transfer_dvb_utils_pkg.fun_get_basedata2(c_building.building_direction,
                                                                           '楼向'),
               ax.floshapeid    = transfer_dvb_utils_pkg.fun_get_basedata2(c_building.building_style,
                                                                           '楼型'),
               ax.flolevelnumid = c_building.floor_count,
               ax.unitnumid     = c_building.unit_num,
               ax.flocustnumid  = c_building.unit_room_count
         WHERE ax.addressid_pk = c_building.id_in_starboss;
        -- 插入0单元
        SELECT seq_uniten.nextval INTO v_zero_unitid_pk FROM dual;
        v_result := transfer_dvb_insert_pkg.fun_insert_uniten(p_unitid_pk      => v_zero_unitid_pk,
                                                              p_unitnamestr    => 'UnitInfo',
                                                              p_unitcodestr    => 'UnitInfo',
                                                              p_unitnum        => 0,
                                                              p_addressid      => c_building.id_in_starboss,
                                                              p_subnum         => 0, -- 依托方格数 导入依托方格是修改
                                                              p_statusid       => 1,
                                                              p_mem            => NULL,
                                                              p_createid       => 1,
                                                              p_modifyid       => NULL,
                                                              p_createcodestr  => '00000',
                                                              p_modifycodestr  => NULL,
                                                              p_terminalid     => NULL,
                                                              p_salechannelid  => NULL,
                                                              p_createdt       => SYSDATE,
                                                              p_modifydt       => NULL,
                                                              p_salechannelid1 => NULL,
                                                              p_operareaid     => NULL);
        -- 插入0楼层
        SELECT seq_flooren.nextval INTO v_zero_floorid_pk FROM dual;
        v_result := transfer_dvb_insert_pkg.fun_insert_flooren(p_floorid_pk     => v_zero_floorid_pk,
                                                               p_floornamestr   => 'RestInfo',
                                                               p_floorcodestr   => 'RestInfo',
                                                               p_floornum       => 0,
                                                               p_addressid      => c_building.id_in_starboss,
                                                               p_statusid       => 1,
                                                               p_mem            => NULL,
                                                               p_createid       => 1,
                                                               p_modifyid       => NULL,
                                                               p_createcodestr  => '00000',
                                                               p_modifycodestr  => NULL,
                                                               p_terminalid     => NULL,
                                                               p_salechannelid  => NULL,
                                                               p_createdt       => SYSDATE,
                                                               p_modifydt       => NULL,
                                                               p_salechannelid1 => NULL,
                                                               p_operareaid     => NULL);
      
        -- 生成楼层                                                     
        FOR floornum IN 1 .. c_building.floor_count LOOP
          SELECT seq_flooren.nextval INTO v_floorid_pk FROM dual;
          v_result := transfer_dvb_insert_pkg.fun_insert_flooren(p_floorid_pk     => v_floorid_pk,
                                                                 p_floornamestr   => 'FloorInfo',
                                                                 p_floorcodestr   => 'FloorInfo',
                                                                 p_floornum       => floornum,
                                                                 p_addressid      => c_building.id_in_starboss,
                                                                 p_statusid       => 1,
                                                                 p_mem            => NULL,
                                                                 p_createid       => 1,
                                                                 p_modifyid       => NULL,
                                                                 p_createcodestr  => '00000',
                                                                 p_modifycodestr  => NULL,
                                                                 p_terminalid     => NULL,
                                                                 p_salechannelid  => NULL,
                                                                 p_createdt       => SYSDATE,
                                                                 p_modifydt       => NULL,
                                                                 p_salechannelid1 => NULL,
                                                                 p_operareaid     => NULL);
        END LOOP;
      
        -- 生成单元
        FOR unitnum IN 1 .. c_building.unit_num LOOP
        
          -- 因为每个单元的户室数不固定，需要取方格单元信息表中的户室数
          SELECT t.unit_room_count
            INTO v_muroto_num
            FROM import_grid_unit_info t
           WHERE t.addr_id = c_building.addr_id
             AND t.unit_num = unitnum;
        
          SELECT seq_uniten.nextval INTO v_unitid_pk FROM dual;
          v_result := transfer_dvb_insert_pkg.fun_insert_uniten(p_unitid_pk      => v_unitid_pk,
                                                                p_unitnamestr    => 'UnitInfo',
                                                                p_unitcodestr    => 'UnitInfo',
                                                                p_unitnum        => unitnum,
                                                                p_addressid      => c_building.id_in_starboss,
                                                                p_subnum         => v_muroto_num,
                                                                p_statusid       => 1,
                                                                p_mem            => NULL,
                                                                p_createid       => 1,
                                                                p_modifyid       => NULL,
                                                                p_createcodestr  => '00000',
                                                                p_modifycodestr  => NULL,
                                                                p_terminalid     => NULL,
                                                                p_salechannelid  => NULL,
                                                                p_createdt       => SYSDATE,
                                                                p_modifydt       => NULL,
                                                                p_salechannelid1 => NULL,
                                                                p_operareaid     => NULL);
          --循环楼层                                                     
          FOR floornum IN 1 .. c_building.floor_count LOOP
            -- 生成方格
            FOR murotonum IN 1 .. v_muroto_num LOOP
              SELECT seq_murotoen.nextval INTO v_murotoid_pk FROM dual;
              v_grid_code := unitnum || '-' || floornum || '-' || murotonum;
            
              v_isenable := transfer_dvb_utils_pkg.fun_is_grid_enable(c_building.addr_id,
                                                                      floornum,
                                                                      unitnum,
                                                                      murotonum);
              v_result   := transfer_dvb_insert_pkg.fun_insert_murotoen(p_murotoid_pk    => v_murotoid_pk,
                                                                        p_murotonamestr  => v_grid_code,
                                                                        p_murotocodestr  => v_grid_code,
                                                                        p_murotonum      => murotonum,
                                                                        p_addressid      => c_building.id_in_starboss,
                                                                        p_floorid        => v_zero_floorid_pk +
                                                                                            floornum, -- 楼层为0层pk加当前楼层
                                                                        p_unitid         => v_unitid_pk, -- 单元
                                                                        p_isenable       => v_isenable,
                                                                        p_statusid       => 1,
                                                                        p_mem            => NULL,
                                                                        p_createid       => 1,
                                                                        p_modifyid       => NULL,
                                                                        p_createcodestr  => '00000',
                                                                        p_modifycodestr  => NULL,
                                                                        p_terminalid     => NULL,
                                                                        p_salechannelid  => NULL,
                                                                        p_createdt       => SYSDATE,
                                                                        p_modifydt       => NULL,
                                                                        p_salechannelid1 => NULL,
                                                                        p_operareaid     => NULL);
            END LOOP;
          END LOOP;
        
        END LOOP;
      
        -- 计数，分段提交
        v_cnt := v_cnt + 1;
        IF MOD(v_cnt, 1000) = 0 THEN
          COMMIT;
          transfer_dvb_log_pkg.transfer_log_prc(p_msg => v_cnt ||
                                                         ' addresses have been loaded in transfer_dvb_load_pkg.load_addrinfo_prc.');
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          sql_code  := SQLCODE;
          sql_errm  := SQLERRM;
          v_cnt_err := v_cnt_err + 1;
          transfer_dvb_log_pkg.transfer_err_prc(p_sql_code => sql_code,
                                                p_sql_errm => sql_errm,
                                                p_calledby => 'transfer_dvb_load_pkg.load_grid_prc',
                                                p_comments => NULL,
                                                p_custid   => NULL);
      END;
    END LOOP;
    COMMIT;
    transfer_dvb_log_pkg.transfer_log_prc(p_msg => 'total ' || v_cnt_err ||
                                                   ' errors in transfer_dvb_load_pkg.load_grid_prc.');
    transfer_dvb_log_pkg.transfer_log_prc(p_msg => 'total ' || v_cnt ||
                                                   ' grid infos loading finished.');
  
  END;

  PROCEDURE load_customer_prc IS
  
    v_cnt                NUMBER;
    v_cnt_err            NUMBER;
    v_customerid         customeren.customerid_pk%TYPE;
    v_accountid_pk       accounten.accountid_pk%TYPE;
    v_acctbookid_pk      acctbooken.acctbookid_pk%TYPE;
    v_payprojectid_pk    payprojecten.payprojectid_pk%TYPE;
    v_accbalanceobjid_pk acctbalanceobjen.accbalanceobjid_pk%TYPE;
  
    v_mr_salechannelid customeren.salechannelid1%TYPE;
  
    v_mr_createcodestr customeren.createcodestr%TYPE;
    v_mr_createid      customeren.createid%TYPE;
  
    v_customerlevelid   customeren.customerlevelid%TYPE;
    v_operareaid        operareaen.operareaid_pk%TYPE;
    v_salechannelid     customeren.salechannelid1%TYPE;
    v_certificatetypeid customeren.certificatetypeid%TYPE;
  
    v_societyid customeren.societyid%TYPE;
  
    v_cust_mark VARCHAR2(50);
    CURSOR c_customer IS
    
      SELECT NULL customerid_fk,
             
             decode(cust.cust_type, 1, 0, 2, 1, 0) customertypeid,
             
             -- 客户姓名，去掉空格
             REPLACE(cust.name, ' ', '') customernamestr,
             --客户编码；按照规则重新生成
             NULL customercodestr,
             
             -- 证件类型
             cust.social_id_type certificatetypeid,
             
             -- 证件号码
             REPLACE(cust.social_id, ' ', '') certcodestr,
             
             -- 联系电话
             REPLACE(cust.cust_contact_tel, ' ', '') linktelstr,
             
             -- 移动电话
             REPLACE(cust.mobile, ' ', '') mobilestr,
             
             -- 联系人
             nvl(REPLACE(cust.cust_contact_name, ' ', ''), cust.name) linkmanstr, -- 联系人，取得空格
             
             cust. postalcode zipcodestr,
             
             -- 客户联系地址，取 新宇龙系统内的客户关联的地址信息
             ca.addressnamestr_fk || ca.serv_address contactaddrstr,
             
             NULL detailaddrcodestr,
             
             -- 注册日期，原系统中没有注册日期
             nvl(cust.create_date,
                 to_date('20000101 10:10:10', 'yyyymmdd hh24:mi:ss')) enroldt,
             
             --性别
             decode(　cust.gender, 'M', 0, 'F', 1, NULL) sexstr,
             
             NULL vacationid,
             --生日
             cust.cust_birth birthdaydt,
             
             NULL certenddt,
             NULL certregionaddrstr,
             NULL companytypestr,
             --客户地址
             ca.address_pk custaddressid,
             
             -- 使用旧系统标识 记录SMS系统的客户编码
             TRIM(cust.cust_no) oldsysid,
             
             --社会类别
             　cust.cust_class_id societyid,
             --运营区域：抚顺
             cust.organ_code operareaid,
             --客户状态
             cust.state customerstatusid,
             --建档渠道
             NULL salechannelid,
             --详细地址(截取地址后的 西起1-1-1)
             substr(ca.serv_address, length(ca.addressnamestr)) customeraddrstr,
             cust.e_mail emailstr,
             NULL faxcodestr,
             NULL companyaddrstr,
             NULL companynetaddrstr,
             NULL vipstr,
             NULL logoffreasonid,
             NULL logoffdt,
             NULL restorereasonid,
             NULL restoredt,
             NULL vodflagid,
             cust.remark mem,
             
             NULL createid,
             NULL modifyid,
             NULL createcodestr,
             NULL modifycodestr,
             NULL terminalid,
             nvl(cust.create_date,
                 to_date('20000101 10:10:10', 'yyyymmdd hh24:mi:ss')) createdt,
             NULL modifydt,
             --原系统中当前客户ID
             cust.cust_id addinfostr2,
             --原系统中当前客户的上级客户ID
             　cust.parent_id addinfostr3,
             -- 客户级别
             cust.vip_type customerlevelid
      
        FROM lyboss.cust  cust, --客户表
             cust_address ca
       WHERE cust.cust_id = ca.cust_id
         AND cust.state <> '70H';
  
  BEGIN
  
    v_cnt     := 0;
    v_cnt_err := 0;
  
    v_cust_mark := '导库';
  
    v_mr_salechannelid := 1;
  
    v_mr_createcodestr := '00000';
    v_mr_createid      := '1';
  
    FOR v_customer IN c_customer LOOP
    
      BEGIN
      
        SELECT seq_customeren.nextval INTO v_customerid FROM dual;
      
        -- 营销渠道
        --v_salechannelid := transfer_dvb_utils_pkg.fun_get_salechannel(v_customer.userid);
        --if v_salechannelid = 0 then  -- 如果没有查到对应的营销渠道，则取默认 营销渠道
        v_salechannelid := v_mr_salechannelid;
        --end if;
      
        v_result := transfer_dvb_insert_pkg.fun_insert_customeren(p_customerid_pk   => v_customerid,
                                                                  p_addressid       => v_customer.custaddressid,
                                                                  p_customerid_fk   => v_customer.customerid_fk,
                                                                  p_customernamestr => v_customer.customernamestr,
                                                                  p_customercodestr => lpad(v_customerid,
                                                                                            12,
                                                                                            '0'), -- 客户编码, 
                                                                  p_custtypeid      => v_customer.customertypeid, -- 客户类型 
                                                                  
                                                                  p_certificatetypeid => v_certificatetypeid, -- 证件类型,
                                                                  p_certcodestr       => v_customer.certcodestr, -- 证件号码
                                                                  p_linktelstr        => v_customer.linktelstr, -- 联系电话
                                                                  p_mobilestr         => v_customer.mobilestr, -- 手机
                                                                  p_customeraddrstr   => v_customer.customeraddrstr, -- 详细地址
                                                                  p_customerstatusid  => 1,
                                                                  
                                                                  p_linkmanstr        => v_customer.linkmanstr, -- 联系人
                                                                  p_zipcodestr        => v_customer.zipcodestr,
                                                                  p_contactaddrstr    => v_customer.contactaddrstr, -- 联系地址
                                                                  p_detailaddrcodestr => v_customer.detailaddrcodestr,
                                                                  p_pwdstr            => transfer_dvb_utils_pkg.cust_pwd,
                                                                  p_enroldt           => v_customer.enroldt,
                                                                  p_salechannelid1    => v_customer.salechannelid, --建档渠道
                                                                  p_sexstr            => v_customer.sexstr,
                                                                  p_vacationid        => v_customer.vacationid,
                                                                  p_birthdaydt        => v_customer.birthdaydt,
                                                                  p_societyid         => v_societyid, -- 社会类别
                                                                  p_certenddt         => v_customer.certenddt,
                                                                  p_certregionaddrstr => v_customer.certregionaddrstr,
                                                                  p_companytypestr    => v_customer.companytypestr,
                                                                  p_oldsysid          => v_customer.oldsysid,
                                                                  p_emailstr          => v_customer.emailstr,
                                                                  p_faxcodestr        => v_customer.faxcodestr,
                                                                  p_companyaddrstr    => v_customer.companyaddrstr,
                                                                  p_companynetaddrstr => v_customer.companynetaddrstr,
                                                                  p_customerlevelid   => v_customerlevelid, -- 客户级别
                                                                  p_vipstr            => v_customer.vipstr,
                                                                  p_logoffreasonid    => v_customer.logoffreasonid,
                                                                  p_logoffdt          => v_customer.logoffdt,
                                                                  p_restorereasonid   => v_customer.restorereasonid,
                                                                  p_restoredt         => v_customer.restoredt,
                                                                  p_vodflagid         => v_customer.vodflagid,
                                                                  p_mem               => v_customer.mem,
                                                                  p_createid          => v_mr_createid,
                                                                  p_modifyid          => v_customer.modifyid,
                                                                  p_createcodestr     => v_mr_createcodestr,
                                                                  p_modifycodestr     => v_customer.modifycodestr,
                                                                  p_terminalid        => v_customer.terminalid,
                                                                  p_salechannelid     => v_customer.salechannelid,
                                                                  p_createdt          => v_customer.createdt,
                                                                  p_modifydt          => v_customer.modifydt,
                                                                  p_operareaid        => 1,
                                                                  -- 运营区域
                                                                  p_addinfostr1   => v_cust_mark,
                                                                  p_addinfostr2   => v_customer.addinfostr2,
                                                                  p_addinfostr3   => v_customer.addinfostr3,
                                                                  p_addinfostr4   => NULL,
                                                                  p_encryptpwdstr => '123456'
                                                                  
                                                                  );
        -- 为客户创建账户
        SELECT seq_accounten.nextval INTO v_accountid_pk FROM dual;
        v_result := transfer_dvb_insert_pkg.fun_insert_accounten(p_accountid_pk   => v_accountid_pk, -- 账户PK
                                                                 p_customerid_pk  => v_customerid, -- 客户PK
                                                                 p_accountcodestr => lpad(v_accountid_pk,
                                                                                          12,
                                                                                          '0'), -- 账户编码，账户PK 左补位 0，总长 12位
                                                                 -- 账户名称：客户名称 + 业务名称（需要根据系统参数的设定来确定是否为哪个业务创建账户）
                                                                 p_accountnamestr => v_customer.customernamestr ||
                                                                                     '-公共业务帐户',
                                                                 p_isdefaultid    => 1, -- 是否默认帐户（新增）
                                                                 p_postwayid      => 0, -- 账单邮寄方式：普通邮寄
                                                                 p_postaddrstr    => v_customer.contactaddrstr, -- 邮寄地址：客户联系地址
                                                                 p_zipcodestr     => NULL,
                                                                 p_logoffreasonid => NULL,
                                                                 p_businessid     => 0, --付费业务：公共业务，可以创建多余额账本，用于支持多业务
                                                                 p_statusid       => 1, -- 状态：有效
                                                                 p_mem            => NULL,
                                                                 p_createid       => v_customer.createid,
                                                                 p_modifyid       => v_customer.modifyid,
                                                                 p_createcodestr  => NULL,
                                                                 p_modifycodestr  => NULL,
                                                                 p_terminalid     => NULL,
                                                                 p_salechannelid  => NULL,
                                                                 p_createdt       => v_customer.createdt,
                                                                 p_modifydt       => v_customer.modifydt,
                                                                 p_salechannelid1 => NULL,
                                                                 p_operareaid     => v_operareaid
                                                                 -- 运营区域
                                                                 );
      
        -- 创建余额账本
        SELECT seq_acctbooken.nextval INTO v_acctbookid_pk FROM dual;
        v_result := transfer_dvb_insert_pkg.fun_insert_acctbooken(p_acctbookid_pk    => v_acctbookid_pk,
                                                                  p_balancetypeid_pk => 0,
                                                                  p_acctbooknamestr  => v_customer.customernamestr ||
                                                                                        '-公共业务帐户普通预存款余额',
                                                                  p_acctbookcodestr  => lpad(v_acctbookid_pk,
                                                                                             12,
                                                                                             '0') || '0',
                                                                  p_startdt          => v_customer.createdt,
                                                                  p_enddt            => NULL,
                                                                  p_balanceid        => 0, -- 余额
                                                                  p_cycle_upperid    => 0, -- 扣费最高额
                                                                  p_cycle_lowerid    => 0, -- 扣费最低额
                                                                  p_statusid         => 1, -- 状态 有效
                                                                  p_mem              => NULL,
                                                                  p_createid         => v_customer.createid,
                                                                  p_modifyid         => v_customer.modifyid,
                                                                  p_createcodestr    => NULL,
                                                                  p_modifycodestr    => NULL,
                                                                  p_terminalid       => NULL,
                                                                  p_salechannelid    => NULL,
                                                                  p_createdt         => v_customer.createdt,
                                                                  p_salechannelid1   => NULL,
                                                                  p_operareaid       => NULL, -- 运营区域
                                                                  p_modifydt         => v_customer.modifydt,
                                                                  p_deductpriid      => 0, -- 扣款优先级 0 为最高
                                                                  p_customerid       => v_customerid, -- 客户标识
                                                                  p_objtypeid        => 1, -- 余额对象类型  1：账户
                                                                  p_objid            => v_accountid_pk); -- 帐户PK：余额对象
      
        -- 创建支付方案
        SELECT seq_payprojecten.nextval INTO v_payprojectid_pk FROM dual;
      
        v_result := transfer_dvb_insert_pkg.fun_insert_payprojecten(p_payprojectid_pk    => v_payprojectid_pk,
                                                                    p_paymethodid_pk     => 111, -- 付款类型  现金
                                                                    p_acctbookid_pk      => v_acctbookid_pk, -- 余额账本PK
                                                                    p_accountid_pk       => v_accountid_pk, -- 账户PK
                                                                    p_paytypeid          => 1, -- 付费方式
                                                                    p_priid              => 0, -- 优先级
                                                                    p_bankid             => NULL,
                                                                    p_bankaccountcodestr => NULL,
                                                                    p_bankaccountnamestr => NULL,
                                                                    p_bankaccounttypestr => NULL,
                                                                    p_creditvalidatedt   => NULL,
                                                                    p_mem                => NULL,
                                                                    p_createid           => v_customer.createid,
                                                                    p_modifyid           => v_customer.modifyid,
                                                                    p_createcodestr      => NULL,
                                                                    p_modifycodestr      => NULL,
                                                                    p_terminalid         => NULL,
                                                                    p_salechannelid      => NULL,
                                                                    p_createdt           => v_customer.createdt,
                                                                    p_modifydt           => v_customer.modifydt,
                                                                    p_salechannelid1     => NULL,
                                                                    p_operareaid         => v_operareaid, -- 运营区域
                                                                    p_statusid           => 1);
        -- 创建余额对象关系
        SELECT seq_acctbalanceobjen.nextval
          INTO v_accbalanceobjid_pk
          FROM dual;
      
        v_result := transfer_dvb_insert_pkg.fun_insert_acctbalanceobjen(p_accbalanceobjid_pk => v_accbalanceobjid_pk,
                                                                        p_acctbookid_pk      => v_acctbookid_pk, -- 余额账本PK
                                                                        p_objtypeid          => 1, -- 余额账本隶属于帐户：1
                                                                        p_objid              => v_accountid_pk, -- 账户PK
                                                                        p_mem                => NULL,
                                                                        p_createid           => v_customer.createid,
                                                                        p_modifyid           => v_customer.modifyid,
                                                                        p_createcodestr      => NULL,
                                                                        p_modifycodestr      => NULL,
                                                                        p_terminalid         => NULL,
                                                                        p_salechannelid      => NULL,
                                                                        p_createdt           => v_customer.createdt,
                                                                        p_salechannelid1     => NULL,
                                                                        p_operareaid         => v_operareaid, -- 运营区域
                                                                        p_modifydt           => v_customer.modifyid,
                                                                        p_statusid           => 1);
        -- 更新预处理数据，存放starboss的客户id
        UPDATE import_grid_cust_mapping t
           SET t.custid_in_starboss = v_customerid
         WHERE t.cust_id = v_customer.addinfostr2;
      
        v_cnt := v_cnt + 1;
        IF MOD(v_cnt, 10000) = 0 THEN
          COMMIT;
          transfer_dvb_log_pkg.transfer_log_prc(p_msg => v_cnt ||
                                                         ' customers have been loaded in transfer_dvb_load_pkg.load_customer_prc.');
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          sql_code  := SQLCODE;
          sql_errm  := SQLERRM;
          v_cnt_err := v_cnt_err + 1;
          transfer_dvb_log_pkg.transfer_err_prc(p_sql_code => sql_code,
                                                p_sql_errm => sql_errm,
                                                p_calledby => 'transfer_dvb_load_pkg.load_customer_prc',
                                                p_comments => TRIM(v_customer.oldsysid),
                                                p_custid   => NULL);
      END;
    END LOOP;
    COMMIT;
    transfer_dvb_log_pkg.transfer_log_prc(p_msg => 'total ' || v_cnt_err ||
                                                   ' errors in transfer_dvb_load_pkg.load_customer_prc.');
    transfer_dvb_log_pkg.transfer_log_prc(p_msg => 'total ' || v_cnt ||
                                                   ' customer_indiv info loading finished.');
  
  END;
  PROCEDURE load_grid_cust_mapping_prc IS
    v_cnt                 NUMBER;
    v_cnt_err             NUMBER;
    v_customerid          customeren.customerid_pk%TYPE;
    v_murotoid            murotoen.murotoid_pk%TYPE;
    v_count_for_existence NUMBER;
    CURSOR cur_mapping IS
      SELECT *
        FROM import_grid_cust_mapping t /*WHERE t.cust_id = 970243*/
      ;
  BEGIN
    v_cnt     := 0;
    v_cnt_err := 0;
    FOR c_mapping IN cur_mapping LOOP
      BEGIN
      
        SELECT COUNT(*)
          INTO v_count_for_existence
          FROM murotoen m
         WHERE m.addressid = c_mapping.address_pk
           AND m.murotocodestr = c_mapping.muroto_map;
      
        IF v_count_for_existence > 0 THEN
          SELECT m.murotoid_pk
            INTO v_murotoid
            FROM murotoen m
           WHERE m.addressid = c_mapping.address_pk
             AND m.murotocodestr = c_mapping.muroto_map;
        
          INSERT INTO muroto_custen
          VALUES
            (v_murotoid, c_mapping.custid_in_starboss);
          -- 如果能够关联到方格，则更改 is_in_grid 字段为true
          UPDATE import_grid_cust_mapping i
             SET i.is_in_grid = 'true'
           WHERE i.cust_id = c_mapping.cust_id;
        
          v_cnt := v_cnt + 1;
          IF MOD(v_cnt, 10000) = 0 THEN
            COMMIT;
            transfer_dvb_log_pkg.transfer_log_prc(p_msg => v_cnt ||
                                                           ' mapping have been created in transfer_dvb_load_pkg.load_grid_cust_mapping_prc.');
          END IF;
        
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          sql_code  := SQLCODE;
          sql_errm  := SQLERRM;
          v_cnt_err := v_cnt_err + 1;
          transfer_dvb_log_pkg.transfer_err_prc(p_sql_code => sql_code,
                                                p_sql_errm => sql_errm,
                                                p_calledby => 'transfer_dvb_load_pkg.load_grid_cust_mapping_prc',
                                                p_comments => c_mapping.cust_id,
                                                p_custid   => v_customerid);
      END;
    END LOOP;
    COMMIT;
    transfer_dvb_log_pkg.transfer_log_prc(p_msg => 'total ' || v_cnt_err ||
                                                   ' errors in transfer_dvb_load_pkg.load_grid_cust_mapping_prc.');
    transfer_dvb_log_pkg.transfer_log_prc(p_msg => 'total ' || v_cnt ||
                                                   ' mapping info creating finished.');
  
  END;

  PROCEDURE load_attached_grid_mapping_prc IS
    v_cnt               NUMBER;
    v_cnt_err           NUMBER;
    v_murotoid_pk       murotoen.murotoid_pk%TYPE;
    v_zero_unitid_pk    uniten.unitid_pk%TYPE;
    v_zero_floorid_pk   flooren.floorid_pk%TYPE;
    v_count_attachement NUMBER(5);
    CURSOR cur_attached_grids IS
      SELECT *
        FROM import_grid_cust_mapping t
       WHERE t.is_in_grid = 'false';
  
  BEGIN
    v_cnt     := 0;
    v_cnt_err := 0;
    FOR c_attachment IN cur_attached_grids LOOP
      BEGIN
        SELECT t.unitid_pk
          INTO v_zero_unitid_pk
          FROM uniten t
         WHERE t.unitnum = 0
           AND t.addressid = c_attachment.address_pk;
        SELECT t.floorid_pk
          INTO v_zero_floorid_pk
          FROM flooren t
         WHERE t.floornum = 0
           AND t.addressid = c_attachment.address_pk;
        -- 更新0单元依托数，增加一个依托方格该数字增加1
        UPDATE uniten t
           SET t.subnum = t.subnum + 1
         WHERE t.unitid_pk = v_zero_unitid_pk;
        -- 创建依托方格
        -- 查询目前依托方格数作为依托方格的编码
        SELECT t.subnum
          INTO v_count_attachement
          FROM uniten t
         WHERE t.unitid_pk = v_zero_unitid_pk;
        SELECT seq_murotoen.nextval INTO v_murotoid_pk FROM dual;
        v_result := transfer_dvb_insert_pkg.fun_insert_murotoen(p_murotoid_pk    => v_murotoid_pk,
                                                                p_murotonamestr  => 'Y' || '-' ||
                                                                                    v_count_attachement,
                                                                p_murotocodestr  => 'Y' || '-' ||
                                                                                    v_count_attachement,
                                                                p_murotonum      => v_count_attachement,
                                                                p_addressid      => c_attachment.address_pk,
                                                                p_floorid        => v_zero_floorid_pk,
                                                                p_unitid         => v_zero_unitid_pk, -- 单元
                                                                p_isenable       => 1,
                                                                p_statusid       => 1,
                                                                p_mem            => c_attachment.serv_address,
                                                                p_createid       => 1,
                                                                p_modifyid       => NULL,
                                                                p_createcodestr  => '00000',
                                                                p_modifycodestr  => NULL,
                                                                p_terminalid     => NULL,
                                                                p_salechannelid  => NULL,
                                                                p_createdt       => SYSDATE,
                                                                p_modifydt       => NULL,
                                                                p_salechannelid1 => NULL,
                                                                p_operareaid     => NULL);
        -- 绑定依托方格跟客户
      
        INSERT INTO muroto_custen
        VALUES
          (v_murotoid_pk, c_attachment.custid_in_starboss);
      
        v_cnt := v_cnt + 1;
        IF MOD(v_cnt, 10000) = 0 THEN
          COMMIT;
          transfer_dvb_log_pkg.transfer_log_prc(p_msg => v_cnt ||
                                                         ' mapping have been created in transfer_dvb_load_pkg.load_attached_grid_mapping_prc.');
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          sql_code  := SQLCODE;
          sql_errm  := SQLERRM;
          v_cnt_err := v_cnt_err + 1;
          transfer_dvb_log_pkg.transfer_err_prc(p_sql_code => sql_code,
                                                p_sql_errm => sql_errm,
                                                p_calledby => 'transfer_dvb_load_pkg.load_attached_grid_mapping_prc',
                                                p_comments => NULL,
                                                p_custid   => NULL);
      END;
    END LOOP;
    COMMIT;
    transfer_dvb_log_pkg.transfer_log_prc(p_msg => 'total ' || v_cnt_err ||
                                                   ' errors in transfer_dvb_load_pkg.load_attached_grid_mapping_prc.');
    transfer_dvb_log_pkg.transfer_log_prc(p_msg => 'total ' || v_cnt ||
                                                   ' attached grids info creating finished.');
  END;

END transfer_dvb_load_pkg;
/
