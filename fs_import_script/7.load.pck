CREATE OR REPLACE PACKAGE transfer_dvb_load_pkg IS

  -- Author  : HUDAZHU
  -- Created : 2014/9/1 10:31:08 AM
  -- Purpose :

  sql_code VARCHAR2(50);
  sql_errm VARCHAR2(1000);
  v_result NUMBER(1);

  PROCEDURE load_addrinfo_prc; -- 导入地址数据

  PROCEDURE load_operator; -- 导入操作员，只有营业员导入关联营销渠道和仓库

  PROCEDURE load_servicesegment; -- 导入网格与地址的关系，网格与操作员的关系

  PROCEDURE load_grid_prc; -- 导入方格数据

  PROCEDURE load_phyresource_prc; --导入物理资源，本次只导入智能卡数据

  PROCEDURE load_customer_prc; --导入客户、账户、余额账本、支付方案、余额对象关系

  PROCEDURE load_deposit_prc; -- 导入押金

  PROCEDURE load_subscriber_prc; --导入用户，并设定副终端用户的终端号

  PROCEDURE load_logicalresource_prc; -- 导入逻辑资源

  PROCEDURE load_phyprod_instance_prc; -- 导入物理产品实例

  PROCEDURE load_serprod_instance_prc; -- 导入服务产品实例

  PROCEDURE load_generate_bills; -- 生成导库日到月底的欠费帐单

  PROCEDURE prc_del_bad_segment_addr; -- 处理地址与网格的关系

END transfer_dvb_load_pkg;
/
CREATE OR REPLACE PACKAGE BODY transfer_dvb_load_pkg IS

  -- 根据临时表创建BOSS系统的地址树信息

  PROCEDURE load_addrinfo_prc IS
    v_level_count        NUMBER;
    v_addressid_pk       addressen.addressid_pk%TYPE;
    v_addresscodestr     addressen.addresscodestr%TYPE;
    v_detailaddressstr   addressen.detailaddressstr%TYPE;
    v_addressfullnamestr addressen.addressfullnamestr%TYPE;
    v_mem                addressen.mem%TYPE;
    v_result             NUMBER(1);
  
    -- 根据当前级别查询对应地址
    CURSOR cursor_current_level_address(level_id NUMBER) IS
      SELECT * FROM fsboss_places t WHERE t.address_level = level_id;
  
  BEGIN
  
    -- 循环第二级到第八级地址
    FOR level_id IN 2 .. 8 LOOP
      v_level_count := 1;
      BEGIN
        -- 导入当前级别地址
        FOR c_current_level_addr IN cursor_current_level_address(level_id) LOOP
          BEGIN
            v_level_count        := v_level_count + 1;
            v_addresscodestr     := lpad(to_char(v_level_count),
                                         c_current_level_addr.add_level_code_length,
                                         '0'); -- 地址码,根据地址编码长度左补0
            v_detailaddressstr   := c_current_level_addr.parent_full_name_code ||
                                    v_addresscodestr; -- 地址全称编码
            v_addressfullnamestr := c_current_level_addr.parent_full_name ||
                                    c_current_level_addr.name; -- 地址全称
            v_mem                := c_current_level_addr.id; -- 原系统id
          
            SELECT seq_addressen.nextval INTO v_addressid_pk FROM dual;
            v_result := transfer_dvb_insert_pkg.fun_insert_addressen(p_addressid_pk       => v_addressid_pk, -- 地址PK
                                                                     p_addressid_fk       => c_current_level_addr.parentid_in_starboss,
                                                                     p_addresslevelid_pk  => c_current_level_addr.address_level,
                                                                     p_addressnamestr     => c_current_level_addr.name,
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
                                                                     p_createdt           => c_current_level_addr.startlifecycle, -- 创建时间取原系统时间
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
               c_current_level_addr.analogsignalstopdate);
          
            -- 更新地址上starboss中的地址id
            UPDATE fsboss_places fp
               SET fp.id_in_starboss = v_addressid_pk
             WHERE fp.id = c_current_level_addr.id;
            -- 更新临时表中本级地址所有下级地址的上级地址id，上级地址全称编码，上级地址全称
            UPDATE fsboss_places fp
               SET fp.parentid_in_starboss  = v_addressid_pk,
                   fp.parent_full_name_code = v_detailaddressstr,
                   fp.parent_full_name      = v_addressfullnamestr
             WHERE fp.parentid = c_current_level_addr.id;
            COMMIT;
          END;
        END LOOP;
        -- 将starboss中的对应地址id放入楼房与参数临时表的相应字段
        UPDATE temp_building_parameters t
           SET t.id_in_starboss =
               (SELECT a.addressid_pk
                  FROM addressen a
                 WHERE a.mem = t.managesectionid);
      END;
    END LOOP;
    COMMIT;
  END;
  PROCEDURE load_operator IS
    v_operator_id NUMBER(8);
    CURSOR old_operators IS
      SELECT op.* FROM fsboss_operators op;
    CURSOR operareas IS
      SELECT * FROM operareaen oa;
    CURSOR operator_stock(salechannelid salechannelen.salechannelid_pk%TYPE) IS
      SELECT os.stockid_pk
        FROM salechannel_stocken os
       WHERE os.salechannelid_pk = salechannelid;
  
  BEGIN
  
    FOR v_old_operator IN old_operators LOOP
      SELECT seq_operatoren.nextval INTO v_operator_id FROM dual;
      --操作员
      INSERT INTO operatoren o
        (operatorid_pk,
         deptid_pk,
         operlevelid_pk, --操作等级
         addressid_pk, -- 可操作地址
         raynodeeid_pk, -- 光节点
         operatorcodestr,
         operatorpwdstr,
         operatornamestr,
         operatortypeid, --操作员类型
         operatorstatusid,
         startdt,
         enddt,
         mem)
      VALUES
        (v_operator_id,
         v_old_operator.starboss_operid_pk,
         1002, --普通操作员
         1,
         NULL,
         v_old_operator.employee_code,
         v_old_operator.new_password,
         v_old_operator.employee_name,
         2,
         1,
         to_date('20050101', 'yyyyMMdd'),
         to_date('20500101', 'yyyyMMdd'),
         v_old_operator.employee_id);
      --操作员与营销渠道
      INSERT INTO operator_salechannelen os
      VALUES
        (v_old_operator.starboss_salechannel_id, v_operator_id, 1);
    
      --操作员与运营区域
      FOR v_operarea IN operareas LOOP
        INSERT INTO operator_operareaen oo
        VALUES
          (v_operarea.operareaid_pk, v_operator_id);
      END LOOP;
      --操作员与角色,非营业员不导入角色和仓库
      IF v_old_operator.starboss_salechannel_id <> 1 THEN
        INSERT INTO operator_roleen
          (roleid_pk, operatorid_pk, ifgrantid)
        VALUES
          (1003, v_operator_id, 1);
        --操作员与仓库
        FOR v_operator_stock IN operator_stock(v_old_operator.starboss_salechannel_id) LOOP
          INSERT INTO operator_stocken os
          VALUES
            (v_operator_id, v_operator_stock.stockid_pk);
        END LOOP;
      END IF;
    
    END LOOP;
    COMMIT;
  END;

  PROCEDURE load_servicesegment IS
    CURSOR cur_servicesegment_address IS -- 根据网格id查询网格关联的
      SELECT a.addressid_pk, s.segmentid_pk
        FROM fsboss_areamanagesections sa, addressen a, servicesegmenten s
       WHERE a.mem = sa.managesectionid
         AND s.mem = sa.areaid;
    CURSOR cur_servicesegment_operator IS -- 查询关联的操作员
      SELECT s.segmentid_pk, o.operatorid_pk
        FROM servicesegmenten s, fsboss_areas a, operatoren o
       WHERE s.segmenttype = 1 -- 查询 单元网格 类型的网格
         AND a.id = s.mem
         AND o.mem = a.employeeid;
  BEGIN
    FOR c_sa IN cur_servicesegment_address LOOP
      INSERT INTO servicesegment_addressen
      VALUES
        (c_sa.segmentid_pk, c_sa.addressid_pk);
      UPDATE addressen a
         SET a.segmentid_pk = c_sa.segmentid_pk
       WHERE a.addressid_pk = c_sa.addressid_pk;
    END LOOP;
    FOR c_so IN cur_servicesegment_operator LOOP
      INSERT INTO servicesegment_operatoren
      VALUES
        (c_so.segmentid_pk, c_so.operatorid_pk);
    END LOOP;
    COMMIT;
  END;

  PROCEDURE load_grid_prc IS
    v_cnt               NUMBER;
    v_cnt_err           NUMBER;
    v_count_attachement NUMBER;
    v_unitid_pk         uniten.unitid_pk%TYPE;
    v_zero_unitid_pk    uniten.unitid_pk%TYPE;
    v_floorid_pk        flooren.floorid_pk%TYPE;
    v_zero_floorid_pk   flooren.floorid_pk%TYPE;
    v_murotoid_pk       murotoen.murotoid_pk%TYPE;
    v_grid_code         murotoen.murotocodestr%TYPE;
    v_isenable          NUMBER(1);
    v_first_level_pk    NUMBER(20);
    v_count_muroto      NUMBER(10);
    CURSOR cur_buildings IS
      SELECT *
        FROM temp_building_parameters t
      /*       WHERE t.managesectionid = 9223372029467091423*/
      ;
    CURSOR cur_attachments(p_maid NUMBER) IS
      SELECT *
        FROM fsboss_manageaddresses_fs ma
       WHERE ma.isformated = 0
         AND ma.managesectionid = p_maid;
  BEGIN
    v_cnt     := 0;
    v_cnt_err := 0;
    FOR c_building IN cur_buildings LOOP
    
      BEGIN
        -- 插入0单元
        SELECT seq_uniten.nextval INTO v_zero_unitid_pk FROM dual;
        v_result := transfer_dvb_insert_pkg.fun_insert_uniten(p_unitid_pk      => v_zero_unitid_pk,
                                                              p_unitnamestr    => 'UnitInfo',
                                                              p_unitcodestr    => 'UnitInfo',
                                                              p_unitnum        => 0,
                                                              p_addressid      => c_building.id_in_starboss,
                                                              p_subnum         => c_building.attachementnum, -- 依托方格数
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
      
        FOR unitnum IN 1 .. c_building.unitnum LOOP
          -- 生成单元
          SELECT seq_uniten.nextval INTO v_unitid_pk FROM dual;
          v_result := transfer_dvb_insert_pkg.fun_insert_uniten(p_unitid_pk      => v_unitid_pk,
                                                                p_unitnamestr    => 'UnitInfo',
                                                                p_unitcodestr    => 'UnitInfo',
                                                                p_unitnum        => unitnum,
                                                                p_addressid      => c_building.id_in_starboss,
                                                                p_subnum         => c_building.murotonum,
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
          FOR floornum IN 1 .. c_building.floornum LOOP
            -- 生成楼层
            -- 楼层只需生成一遍,只有在单元数为1 的时候才生成楼层,如果否则取当前楼层id为楼层id
            IF unitnum = 1 THEN
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
              -- 存储首层楼的pk,增加方格时可以根据首层pk拼出当前楼层pk
              IF floornum = 1 THEN
                v_first_level_pk := v_floorid_pk;
              END IF;
            END IF;
          
            FOR murotonum IN 1 .. c_building.murotonum LOOP
              -- 生成方格
              SELECT seq_murotoen.nextval INTO v_murotoid_pk FROM dual;
              v_grid_code := unitnum || '-' || floornum || '-' || murotonum;
              -- 查找对应的门址,如果找到则方格可用,否则不可用
              SELECT COUNT(*)
                INTO v_count_muroto
                FROM fsboss_manageaddresses_fs fma
               WHERE fma.connectioncode = v_grid_code
                 AND fma.managesectionid = c_building.managesectionid;
            
              IF v_count_muroto > 0 THEN
                -- 如果存在门址,方格有效，并建立方格与客户的关系
                v_isenable := 1;
                UPDATE fsboss_customer c
                   SET c.murotoid = v_murotoid_pk
                 WHERE EXISTS
                 (SELECT 'x'
                          FROM fsboss_manageaddresses_fs fma
                         WHERE fma.connectioncode = v_grid_code
                           AND fma.managesectionid =
                               c_building.managesectionid
                           AND c.defaultinstalladdressid = fma.id);
                /*
                c.defaultinstalladdressid IN
                      (SELECT fma.id
                         FROM fsboss_manageaddresses_fs fma
                        WHERE fma.connectioncode = v_grid_code
                          AND fma.managesectionid =
                              c_building.managesectionid);*/
              ELSE
                -- 如何不存在门址，方格为无效
                v_isenable := 0;
              END IF;
            
              v_result := transfer_dvb_insert_pkg.fun_insert_murotoen(p_murotoid_pk    => v_murotoid_pk,
                                                                      p_murotonamestr  => v_grid_code,
                                                                      p_murotocodestr  => v_grid_code,
                                                                      p_murotonum      => murotonum,
                                                                      p_addressid      => c_building.id_in_starboss,
                                                                      p_floorid        => v_first_level_pk +
                                                                                          floornum - 1, -- 楼层为首层pk加当前楼层-1
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
      
        v_count_attachement := 1;
        FOR c_attachment IN cur_attachments(c_building.managesectionid) LOOP
          -- 导入依托的方格
          SELECT seq_murotoen.nextval INTO v_murotoid_pk FROM dual;
          v_result            := transfer_dvb_insert_pkg.fun_insert_murotoen(p_murotoid_pk    => v_murotoid_pk,
                                                                             p_murotonamestr  => 'Y' || '-' ||
                                                                                                 v_count_attachement,
                                                                             p_murotocodestr  => 'Y' || '-' ||
                                                                                                 v_count_attachement,
                                                                             p_murotonum      => v_count_attachement,
                                                                             p_addressid      => c_building.id_in_starboss,
                                                                             p_floorid        => v_zero_floorid_pk, -- 楼层
                                                                             p_unitid         => v_zero_unitid_pk, -- 单元
                                                                             p_isenable       => 1,
                                                                             p_statusid       => 1,
                                                                             p_mem            => c_attachment.originalname, -- 原地址信息
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
          v_count_attachement := v_count_attachement + 1;
          -- 建立依托方格与客户的关系
          UPDATE fsboss_customer c
             SET c.murotoid = v_murotoid_pk
           WHERE c.defaultinstalladdressid = c_attachment.id;
        END LOOP;
      
        v_cnt := v_cnt + 1;
        IF MOD(v_cnt, 500) = 0 THEN
          COMMIT;
          transfer_dvb_log_pkg.transfer_log_prc(p_msg => v_cnt ||
                                                         ' grid have been loaded in transfer_dvb_load_pkg.load_grid_prc.');
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
                                                   ' grid info loading finished.');
  END;

  PROCEDURE load_phyresource_prc IS
  
    v_resourceid_pk phyresourceen.resourceid_pk%TYPE;
  
    v_resource_code VARCHAR2(50); -- 资源编码
  
    v_cnt     NUMBER;
    v_cnt_err NUMBER;
  
    CURSOR cur_phyresource IS
    
      SELECT ph.statusid pr_status, -- 资源状态
             NULL cardcataid_pk, -- 卡目录标识,只有资源是充值卡才起作用
             NULL servicestr, -- 服务号码（未用）
             TRIM(ph.code) resourcecodestr, -- 资源编码
             TRIM(ph.macaddressid) phyresourceincodestr, -- 内部编码
             nvl(ph.startlifecycle,
                 to_date('20000101 10:10:10', 'yyyymmdd hh24:mi:ss')) outdt, -- 出厂时间
             NULL outpriceid, -- 出厂价格
             NULL stockstr, -- 货号(批次)
             nvl(ph.startlifecycle,
                 to_date('20000101 10:10:10', 'yyyymmdd hh24:mi:ss')) comedt, -- 入库时间
             NULL pwdstr,
             nvl(ph.startlifecycle,
                 to_date('20000101 10:10:10', 'yyyymmdd hh24:mi:ss')) startdt, -- 有效起始时间
             nvl(ph.endlifecycle,
                 to_date('99991231 10:10:10', 'yyyymmdd hh24:mi:ss')) enddt, -- 无效终止时间
             1 stockitemtypeid, -- 库存项目类型 未使用
             NULL countunitid, -- 物理资源计数单位，当前未使用
             1 countid, -- 资源个数，对于序列化资源来说为1
             NULL containtypeid, -- 容器，当前未使用
             NULL validatecodestr, -- 资源验证码
             ph.providerid providerid, -- 厂商代码
             ph.version hardwareversionstr, -- 硬件版本
             NULL historyversionstr, -- 原始软件版本
             1 statusid, -- 资源状态 ，1为有效
             '抚顺导库' mem, -- 备注
             NULL createid,
             NULL modifyid,
             NULL createcodestr,
             NULL modifycodestr,
             NULL terminalid,
             NULL salechannelid, -- 营销渠道，实际数据库中为 null  ER文档中不存在该字段
             nvl(ph.startlifecycle,
                 to_date('20000101 10:10:10', 'yyyymmdd hh24:mi:ss')) createdt, -- 记录创建日期
             NULL modifydt,
             NULL proposetypeid, -- 枚举类型，表明资源的用途，是用于销售还是用于租赁
             NULL curversionstr, -- 物理资源的当前软件版本
             NULL clientnostr, -- 机顶盒ClientNo,只适用于机顶盒类资源
             NULL isbindid, -- 是否机卡配对，默认不配对
             NULL targetsalechannelid, -- 操作目的渠道：用户记录出库、调拨等操作的目的渠道
             NULL packagecodestr, -- 资源所在的箱号
             NULL specificationid_pk, -- 资源所属规格型号ID（与资源规格型号表对应）
             ph.keeperid keeperid, -- 仓库
             ph.equiptype equiptype, --资源类型
             ph.resourcespecificationid resourcecata
        FROM fsboss_phyresource ph
      /*       WHERE ph.id IN
      (9223372029411060158, 9223372029385538314, 9223372029405729160)*/
      ;
  
  BEGIN
    v_cnt     := 0;
    v_cnt_err := 0;
    /* v_date    := to_char(SYSDATE, 'yyyy-mm-dd');*/
    FOR c_phyresource IN cur_phyresource LOOP
      BEGIN
        SELECT seq_phyresourceen.nextval INTO v_resourceid_pk FROM dual;
      
        v_result := transfer_dvb_insert_pkg.fun_insert_phyresourceen(p_resourceid_pk        => v_resourceid_pk,
                                                                     p_stockid_pk           => transfer_dvb_utils_pkg.fun_get_basedata(c_phyresource.keeperid,
                                                                                                                                       '仓库'), -- 仓库
                                                                     p_cardcataid_pk        => c_phyresource.cardcataid_pk,
                                                                     p_containerid_pk       => transfer_dvb_utils_pkg.fun_get_basedata(c_phyresource.keeperid,
                                                                                                                                       '库位'), -- 库位
                                                                     p_resourcetypeid       => c_phyresource.equiptype, -- 资源类型
                                                                     p_resourcecataid_pk    => transfer_dvb_utils_pkg.fun_get_basedata(c_phyresource.resourcecata,
                                                                                                                                       '资源目录'), -- 资源目录
                                                                     p_servicestr           => c_phyresource.servicestr,
                                                                     p_resourcecodestr      => c_phyresource.resourcecodestr,
                                                                     p_phyresourceincodestr => c_phyresource.phyresourceincodestr,
                                                                     p_outdt                => c_phyresource.outdt,
                                                                     p_outpriceid           => c_phyresource.outpriceid,
                                                                     p_stockstr             => c_phyresource.stockstr,
                                                                     p_comedt               => c_phyresource.comedt,
                                                                     p_pwdstr               => c_phyresource.pwdstr,
                                                                     p_startdt              => c_phyresource.startdt,
                                                                     p_enddt                => c_phyresource.enddt,
                                                                     p_stockstatusid        => transfer_dvb_utils_pkg.fun_get_basedata(c_phyresource.pr_status,
                                                                                                                                       '库存状态'), -- 库存状态,
                                                                     p_phyresourcestatusid  => transfer_dvb_utils_pkg.fun_get_basedata(c_phyresource.pr_status,
                                                                                                                                       '资源状态'), -- 物理资源状态
                                                                     p_stockitemtypeid      => c_phyresource.stockitemtypeid,
                                                                     p_countunitid          => c_phyresource.countunitid,
                                                                     p_countid              => c_phyresource.countid,
                                                                     p_containtypeid        => c_phyresource.containtypeid,
                                                                     p_thirdid              => transfer_dvb_utils_pkg.fun_get_basedata(c_phyresource.providerid,
                                                                                                                                       '供应商'), -- 合作伙伴
                                                                     p_validatecodestr      => c_phyresource.validatecodestr,
                                                                     p_factorycodestr       => c_phyresource.providerid,
                                                                     p_hardwareversionstr   => c_phyresource.hardwareversionstr,
                                                                     p_historyversionstr    => c_phyresource.historyversionstr,
                                                                     p_statusid             => c_phyresource.statusid,
                                                                     p_mem                  => c_phyresource.mem, -- 通过日期进行备注
                                                                     p_createid             => c_phyresource.createid,
                                                                     p_modifyid             => c_phyresource.modifyid,
                                                                     p_createcodestr        => c_phyresource.createcodestr,
                                                                     p_modifycodestr        => c_phyresource.modifycodestr,
                                                                     p_terminalid           => c_phyresource.terminalid,
                                                                     p_salechannelid        => c_phyresource.salechannelid,
                                                                     p_createdt             => c_phyresource.createdt,
                                                                     p_modifydt             => c_phyresource.modifydt,
                                                                     p_proposetypeid        => c_phyresource.proposetypeid,
                                                                     p_curversionstr        => c_phyresource.curversionstr,
                                                                     p_clientnostr          => c_phyresource.clientnostr,
                                                                     p_isbindid             => c_phyresource.isbindid,
                                                                     p_targetsalechannelid  => c_phyresource.targetsalechannelid,
                                                                     p_packagecodestr       => c_phyresource.packagecodestr,
                                                                     p_specificationid_pk   => c_phyresource.specificationid_pk
                                                                     
                                                                     );
      
        v_cnt := v_cnt + 1;
        IF MOD(v_cnt, 10000) = 0 THEN
          COMMIT;
          transfer_dvb_log_pkg.transfer_log_prc(p_msg => v_cnt ||
                                                         ' phyresource have been loaded in transfer_dvb_load_pkg.load_phyresource_prc.');
        END IF;
      
      EXCEPTION
        WHEN OTHERS THEN
          sql_code  := SQLCODE;
          sql_errm  := SQLERRM;
          v_cnt_err := v_cnt_err + 1;
          transfer_dvb_log_pkg.transfer_err_prc(p_sql_code => sql_code,
                                                p_sql_errm => sql_errm,
                                                p_calledby => 'transfer_dvb_load_pkg.load_phyresource_prc',
                                                p_comments => 'v_resourceid_code:=' ||
                                                              v_resource_code,
                                                p_custid   => NULL);
      END;
    END LOOP;
    COMMIT;
    transfer_dvb_log_pkg.transfer_log_prc(p_msg => 'total ' || v_cnt_err ||
                                                   ' errors in transfer_dvb_load_pkg.load_phyresource_prc.');
    transfer_dvb_log_pkg.transfer_log_prc(p_msg => 'total ' || v_cnt ||
                                                   ' phyresource info loading finished.');
  END;

  PROCEDURE load_customer_prc IS
  
    v_cnt                NUMBER;
    v_cnt_err            NUMBER;
    v_customerid         customeren.customerid_pk%TYPE;
    v_accountid_pk       accounten.accountid_pk%TYPE;
    v_acctbookid_pk      acctbooken.acctbookid_pk%TYPE;
    v_payprojectid_pk    payprojecten.payprojectid_pk%TYPE;
    v_accbalanceobjid_pk acctbalanceobjen.accbalanceobjid_pk%TYPE;
    v_operareaid         accounten.operareaid%TYPE;
  
    CURSOR c_customer IS
    
      SELECT NULL customerid_fk,
             
             decode(custinfo.customertypeid, 1, 0, 2, 1, 0) customertypeid,
             
             -- 客户姓名，去掉空格
             REPLACE(custinfo.name, ' ', '') customernamestr,
             
             custinfo.code customercodestr,
             
             -- 证件类型
             custinfo.partyidentificationtypeid certificatetypeid,
             
             -- 证件号码
             REPLACE(custinfo.partyidentificationno, ' ', '') certcodestr,
             
             -- 联系电话
             REPLACE(custinfo.telephoneno, ' ', '') linktelstr,
             
             -- 移动电话
             REPLACE(custinfo.mobileno, ' ', '') mobilestr,
             
             -- 联系人
             REPLACE(nvl(custinfo.contanctmanname, custinfo.name), ' ', '') linkmanstr, -- 联系人，取得空格
             
             NULL zipcodestr,
             
             -- 客户联系地址，取 汇巨 系统内的客户关联的地址信息
             '辽宁省抚顺市' || p.fullname || m.murotonamestr contactaddrstr,
             
             NULL detailaddrcodestr,
             
             -- 注册日期，原系统中没有注册日期
             nvl(custinfo.startlifecycle,
                 to_date('20000101 10:10:10', 'yyyymmdd hh24:mi:ss')) enroldt,
             
             decode(custinfo.genderid, 202, 0, 201, 1, NULL) sexstr,
             
             NULL vacationid,
             
             NULL birthdaydt,
             
             NULL certenddt,
             NULL certregionaddrstr,
             NULL companytypestr,
             
             -- 使用旧系统标识 记录SMS系统的客户编码
             TRIM(custinfo.optionalcode) oldsysid,
             
             --社会类别
             custinfo.customerlevelid societyid,
             --运营区域：抚顺
             custinfo.operationroleid operareaid,
             --客户状态
             0 customerstatusid, -- 全部置为覆盖，后续按照是否有用户来修改
             --建档渠道
             1 salechannelid, -- 全部对应为默认营业厅
             --详细地址,方格的名称
             m.murotonamestr      customeraddrstr,
             NULL                 emailstr,
             NULL                 faxcodestr,
             NULL                 companyaddrstr,
             NULL                 companynetaddrstr,
             NULL                 vipstr,
             NULL                 logoffreasonid,
             NULL                 logoffdt,
             NULL                 restorereasonid,
             NULL                 restoredt,
             NULL                 vodflagid,
             custinfo.description mem,
             NULL                 createid,
             NULL                 modifyid,
             NULL                 createcodestr,
             NULL                 modifycodestr,
             NULL                 terminalid,
             
             nvl(custinfo.startlifecycle,
                 to_date('20000101 10:10:10', 'yyyymmdd hh24:mi:ss')) createdt,
             NULL modifydt,
             custinfo.id userid, -- 汇巨客户id
             p.id_in_starboss custaddressid, -- 地址
             custinfo.murotoid murotoid -- 客户对应方格的id
        FROM fsboss_customer custinfo, fsboss_places p, murotoen m
       WHERE custinfo.managesectionid = p.id
         AND custinfo.murotoid = m.murotoid_pk /*
                                                         AND custinfo.code='300055284'*/
      ;
  
  BEGIN
  
    v_cnt     := 0;
    v_cnt_err := 0;
  
    FOR v_customer IN c_customer LOOP
      BEGIN
        v_operareaid := transfer_dvb_utils_pkg.fun_get_basedata(v_customer.operareaid,
                                                                '运营区域');
        SELECT seq_customeren.nextval INTO v_customerid FROM dual;
        v_result := transfer_dvb_insert_pkg.fun_insert_customeren(p_customerid_pk   => v_customerid,
                                                                  p_addressid       => v_customer.custaddressid,
                                                                  p_customerid_fk   => v_customer.customerid_fk,
                                                                  p_customernamestr => v_customer.customernamestr,
                                                                  p_customercodestr => v_customer.customercodestr, -- 客户编码
                                                                  p_custtypeid      => v_customer.customertypeid, -- 客户类型
                                                                  
                                                                  p_certificatetypeid => transfer_dvb_utils_pkg.fun_get_basedata(v_customer.certificatetypeid,
                                                                                                                                 '证件类型'), -- 证件类型,
                                                                  p_certcodestr       => v_customer.certcodestr, -- 证件号码
                                                                  p_linktelstr        => v_customer.mobilestr,-- 将手机作为联系电话 v_customer.linktelstr, -- 联系电话
                                                                  p_mobilestr         => v_customer.mobilestr, -- 手机
                                                                  p_customeraddrstr   => v_customer.customeraddrstr, -- 详细地址
                                                                  p_customerstatusid  => v_customer.customerstatusid, -- 客户状态
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
                                                                  p_societyid         => transfer_dvb_utils_pkg.fun_get_basedata(v_customer.societyid,
                                                                                                                                 '社会类别'), -- 社会类别
                                                                  p_certenddt         => v_customer.certenddt,
                                                                  p_certregionaddrstr => v_customer.certregionaddrstr,
                                                                  p_companytypestr    => v_customer.companytypestr,
                                                                  p_oldsysid          => v_customer.oldsysid,
                                                                  p_emailstr          => v_customer.emailstr,
                                                                  p_faxcodestr        => v_customer.faxcodestr,
                                                                  p_companyaddrstr    => v_customer.companyaddrstr,
                                                                  p_companynetaddrstr => v_customer.companynetaddrstr,
                                                                  p_customerlevelid   => 1023, -- 客户级别 默认普通客户
                                                                  p_vipstr            => v_customer.vipstr,
                                                                  p_logoffreasonid    => v_customer.logoffreasonid,
                                                                  p_logoffdt          => v_customer.logoffdt,
                                                                  p_restorereasonid   => v_customer.restorereasonid,
                                                                  p_restoredt         => v_customer.restoredt,
                                                                  p_vodflagid         => v_customer.vodflagid,
                                                                  p_mem               => v_customer.mem,
                                                                  p_createid          => 2, -- 创建操作员，方便日后统计
                                                                  p_modifyid          => v_customer.modifyid,
                                                                  p_createcodestr     => 'Import',
                                                                  p_modifycodestr     => v_customer.modifycodestr,
                                                                  p_terminalid        => v_customer.terminalid,
                                                                  p_salechannelid     => v_customer.salechannelid,
                                                                  p_createdt          => v_customer.createdt,
                                                                  p_modifydt          => v_customer.modifydt,
                                                                  p_operareaid        => v_operareaid, -- 运营区域
                                                                  p_addinfostr2       => '抚顺倒库',
                                                                  p_addinfostr1       => NULL,
                                                                  p_addinfostr3       => v_customer.userid, -- 汇巨系统客户PK
                                                                  p_addinfostr4       => v_customer.mem,
                                                                  p_encryptpwdstr     => transfer_dvb_utils_pkg.cust_pwd);
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
                                                                 p_operareaid     => v_operareaid); -- 运营区域
      
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
                                                                    p_operareaid         => NULL, -- 运营区域
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
                                                                        p_operareaid         => NULL, -- 运营区域
                                                                        p_modifydt           => v_customer.modifyid,
                                                                        p_statusid           => 1);
        -- 创建客户与方格的关系
        INSERT INTO muroto_custen
        VALUES
          (v_customer.murotoid, v_customerid);
      
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
  PROCEDURE load_deposit_prc IS
  
    v_paymenten_pk paymenten.paymentid_pk%TYPE;
    v_deposit_pk   depositrecorden.depositrecordid_pk%TYPE;
  
    v_cnt     NUMBER;
    v_cnt_err NUMBER;
    sql_code  VARCHAR2(50);
    sql_errm  VARCHAR2(1000);
  
    CURSOR cur_payments IS
    
      SELECT ac.accountid_pk,
             111 paymethodid_pk, --前台现金
             c.customerid_pk customerid_pk,
             0 tradetypeid, --0 付款，1 ，退款
             0 paymentstatusid, --0 已生成，1已返销
             dp.amount amountid,
             dp.startlifecycle paymentdt,
             0 ifcheckid, --1已对账，0未对账
             1 ifproofid, --轧帐标志，默认为0
             0 ifchargeid,
             '导入-收款人:' || dp.employee_name mem,
             dp.startlifecycle createdt,
             dp.organizationunit_id salechannelid1,
             1 operareaid,
             dp.pricetypeid rateclasstype --账目类型
        FROM fsboss_cash_deposit_detail dp, customeren c, accounten ac
       WHERE c.addinfostr3 = dp.customerid
         AND ac.customerid_pk = c.customerid_pk;
  
  BEGIN
  
    v_cnt     := 0;
    v_cnt_err := 0;
  
    FOR v_payments IN cur_payments LOOP
      BEGIN
      
        SELECT seq_paymenten.nextval INTO v_paymenten_pk FROM dual;
        v_result := transfer_dvb_insert_pkg.fun_insert_paymenten(p_paymentid_pk        => v_paymenten_pk,
                                                                 p_accountid_pk        => v_payments.accountid_pk,
                                                                 p_paymethodid_pk      => v_payments.paymethodid_pk,
                                                                 p_customerid_pk       => v_payments.customerid_pk,
                                                                 p_tradetypeid         => v_payments.tradetypeid,
                                                                 p_paymentstatusid     => v_payments.paymentstatusid,
                                                                 p_amountid            => v_payments.amountid,
                                                                 p_paymentdt           => v_payments.paymentdt,
                                                                 p_checkcodestr        => NULL,
                                                                 p_checksrcstr         => NULL,
                                                                 p_checkvaliddt        => NULL,
                                                                 p_bankterminalstr     => NULL,
                                                                 p_bankcodestr         => NULL,
                                                                 p_bankaccountcodestr  => NULL,
                                                                 p_bankdealstr         => NULL,
                                                                 p_bankacceptstr       => NULL,
                                                                 p_bankoperatorstr     => NULL,
                                                                 p_ifcheckid           => v_payments.ifcheckid,
                                                                 p_ifproofid           => v_payments.ifproofid,
                                                                 p_ifchargeid          => v_payments.ifchargeid,
                                                                 p_operatedserialnbrid => NULL,
                                                                 p_chancollid_pk       => NULL,
                                                                 p_mem                 => v_payments.mem,
                                                                 p_createid            => NULL,
                                                                 p_modifyid            => NULL,
                                                                 p_createcodestr       => NULL,
                                                                 p_modifycodestr       => NULL,
                                                                 p_terminalid          => NULL,
                                                                 p_salechannelid       => NULL,
                                                                 p_createdt            => v_payments.createdt,
                                                                 p_modifydt            => NULL,
                                                                 p_salechannelid1      => transfer_dvb_utils_pkg.fun_get_basedata(v_payments.salechannelid1,
                                                                                                                                  '营销渠道'),
                                                                 p_operareaid          => v_payments.operareaid,
                                                                 p_resourceid_pk       => NULL,
                                                                 p_developid           => NULL);
      
        SELECT seq_depositrecorden.nextval INTO v_deposit_pk FROM dual;
      
        v_result := transfer_dvb_insert_pkg.fun_insert_depositrecorden(p_depositrecordid_pk => v_deposit_pk,
                                                                       p_noteid_pk          => NULL,
                                                                       p_customerid_pk      => v_payments.customerid_pk,
                                                                       p_rateclasstypeid    => transfer_dvb_utils_pkg.fun_get_basedata(v_payments.rateclasstype,
                                                                                                                                       '押金账目'),
                                                                       p_depositamountid    => v_payments.amountid,
                                                                       p_paymentid          => v_paymenten_pk,
                                                                       p_statusid           => 0, -- 0 有效，1 已退
                                                                       p_operatetypeid      => 0, -- 0收费，1退费
                                                                       p_enddt              => NULL,
                                                                       p_tenancydonewayid   => NULL,
                                                                       p_mem                => v_payments.mem,
                                                                       p_createid           => NULL,
                                                                       p_modifyid           => NULL,
                                                                       p_createcodestr      => NULL,
                                                                       p_modifycodestr      => NULL,
                                                                       p_terminalid         => NULL,
                                                                       p_salechannelid      => NULL,
                                                                       p_createdt           => NULL,
                                                                       p_modifydt           => NULL,
                                                                       p_salechannelid1     => transfer_dvb_utils_pkg.fun_get_basedata(v_payments.salechannelid1,
                                                                                                                                       '营销渠道'),
                                                                       
                                                                       p_operareaid          => 1,
                                                                       p_depositsettlementid => NULL,
                                                                       p_productinstanceid   => NULL,
                                                                       p_priceinstanceid     => NULL,
                                                                       p_subscriberid        => NULL,
                                                                       p_priceplanid         => NULL,
                                                                       p_productid           => NULL
                                                                       
                                                                       );
        v_cnt    := v_cnt + 1;
        IF MOD(v_cnt, 1000) = 0 THEN
          COMMIT;
          transfer_dvb_log_pkg.transfer_log_prc(p_msg => v_cnt ||
                                                         ' phyresources instance have been loaded in transfer_dvb_load_pkg.load_deposit_prc.');
        END IF;
      
      EXCEPTION
        WHEN OTHERS THEN
          sql_code := SQLCODE;
        
          sql_errm  := SQLERRM;
          v_cnt_err := v_cnt_err + 1;
        
          transfer_dvb_log_pkg.transfer_err_prc(p_sql_code => sql_code,
                                                p_sql_errm => sql_errm,
                                                p_calledby => 'transfer_dvb_load_pkg.load_deposit_prc',
                                                p_comments => NULL,
                                                p_custid   => NULL);
      END;
    END LOOP;
    COMMIT;
    transfer_dvb_log_pkg.transfer_log_prc(p_msg => 'total ' || v_cnt_err ||
                                                   ' errors in transfer_dvb_load_pkg.load_deposit_prc.');
    transfer_dvb_log_pkg.transfer_log_prc(p_msg => 'total ' || v_cnt ||
                                                   ' load_deposit_prc info loading finished.');
  
  END;
  PROCEDURE load_subscriber_prc IS
    v_cnt              NUMBER;
    v_cnt_err          NUMBER;
    v_subscriberid_pk  subscriberen.subscriberid_pk%TYPE;
    v_sub_status       NUMBER; -- 用户状态
    v_laststopdt       DATE; -- 上次暂停时间
    v_laststopstatusid NUMBER;
    v_salechannelid    NUMBER;
    v_mr_salechannelid NUMBER; -- 营业厅
    v_mr_createcodestr VARCHAR2(10);
    v_mr_createid      NUMBER;
    v_subscribertypeid NUMBER; -- 用户类型
    v_result           NUMBER(1);
    sql_code           VARCHAR2(50);
    sql_errm           VARCHAR2(1000);
    CURSOR c_subscriber IS
    
      SELECT s.startlifecycle createdt, -- 创建日期
             s.statuschangedate modifydt,
             cus.operareaid operareaid, -- 运营区域
             1 urgencypaysignid, -- 是否催缴   0 表示 取消催缴 1 表示催缴
             1 stopsignid, -- 是否停断   0 表示 取消停断 1 表示停断
             NULL parentid_fk, -- 上级用户标识
             NULL subscriberid_pk, -- 用户标识
             1 invoicecyctypeid_pk, -- 帐务周期类型标识  1（月）  取自：Invoicecyctypeen
             cus.customerid_pk customerid_pk, -- 客户PK
             s.type_of_service businessid, -- 业务PK  模拟业务
             s.servicestr servicestr, -- 服务号码（重点）
             cus.customerid_pk usedcustomerid, -- 使用客户标识
             (SELECT ac.accountid_pk
                FROM accounten ac
               WHERE ac.customerid_pk = cus.customerid_pk) defaultaccountid, -- 默认帐户PK
             cus.customeraddrstr setupaddrstr, -- 安装地址，取 客户的联系地址
             cus.addressid setupaddrcodeid, -- 安装地址编码，取客户的地址PK
             NULL detailaddrcodestr, -- 详细地址编码
             s.startlifecycle endworkdt, -- 竣工时间
             NULL pwdstr,
             s.startlifecycle startdt, -- 有效起始时间
             NULL enddt,
             NULL contractid,
             NULL ifcontractid,
             NULL operatorid,
             NULL orderlevelid,
             0 iscdmuserflag,
             NULL preoperitemid,
             NULL prestatusid,
             s.statusid subscriber_status, -- 用户状态状态
             NULL laststartdt,
             1 operwayid,
             s.mem mem, -- 备注
             NULL createid,
             NULL modifyid,
             NULL createcodestr,
             NULL modifycodestr,
             NULL terminalid,
             s.masterid addinfostr1, --记录terminals_fs的上级用户标志
             cus.societyid addinfostr2, -- 保存社会类别，用于查询 价格计划
             s.organizationunit_id addinfostr3, --通过汇巨操作员所在部门获取用户的营销渠道
             s.startvalidfor activedt, -- 激活日期
             NULL equ_type, -- 资源类型
             s.statuschangedate lastchangedate, -- 上次停断时间
             s.endvalidfor laststopdate, --汇巨系统中存在到期暂停后又做了客户暂停，上次暂停时间保留为产品的计费截止日期
             s.seqstr seqstr, -- 终端编号
             NULL servid, -- 服务PK
             s.authenticationtypeid authenticationtypeid, -- 认证类型
             s.equiptypeid equiptypeid,
             cus.oldsysid oldsysid, -- 旧系统标识
             s.terminalid addinfo4, -- 汇巨系统中终端id
             s.accesspointid accesspointid, --数字电视用户接入点标志
             s.subscriber_tpye subscriber_tpye -- 用户类型
        FROM customeren        cus, -- BOSS 客户表
             fsboss_subscriber s,
             fsboss_customer   c
       WHERE cus.addinfostr3 = s.customerid
         AND s.customerid = c.id;
  BEGIN
    v_cnt              := 0;
    v_cnt_err          := 0;
    v_mr_salechannelid := transfer_dvb_utils_pkg.fun_get_basedata('default',
                                                                  '默认营销渠道');
    v_mr_createcodestr := transfer_dvb_utils_pkg.fun_get_basedata('default',
                                                                  '默认操作员工号');
    v_mr_createid      := transfer_dvb_utils_pkg.fun_get_basedata('default',
                                                                  '默认操作员PK');
    FOR v_subscriber IN c_subscriber LOOP
    
      BEGIN
      
        -- 营销渠道，通过用户PK对应的操作员查找对应的营销渠道
        v_salechannelid := transfer_dvb_utils_pkg.fun_get_basedata(v_subscriber.addinfostr3,
                                                                   '营销渠道');
        IF (v_salechannelid = 0) THEN
          -- 如果没有查到对应的营销渠道，则取默认 营销渠道
          v_salechannelid := v_mr_salechannelid;
        END IF;
      
        -- 确定用户类型
      
        v_subscribertypeid := transfer_dvb_utils_pkg.fun_get_basedata(v_subscriber.subscriber_tpye,
                                                                      '用户类型');
        -- 初始化上次停断状态
        v_laststopstatusid := NULL;
        -- 匹配数字用户状态
        IF (v_subscriber.businessid = 2) THEN
          v_sub_status := transfer_dvb_utils_pkg.fun_get_basedata(v_subscriber.subscriber_status,
                                                                  '用户状态');
        
          -- 如果是数字电视业务的罚停，则罚停日期取原系统中的计费截止日期
          IF (v_sub_status = 2 AND v_subscriber.businessid = 2) THEN
            v_laststopstatusid := v_sub_status;
            v_laststopdt       := v_subscriber.laststopdate;
          END IF;
        
          -- 如果是数字电视业务的暂停，则暂停日期取原系统中的状态变更日期
          IF (v_sub_status = 1 AND v_subscriber.businessid = 2) THEN
            v_laststopstatusid := v_sub_status;
            v_laststopdt       := v_subscriber.lastchangedate;
          END IF;
          -- 匹配宽带用户状态
        ELSIF (v_subscriber.businessid = 3) THEN
        
          --汇巨报表宽带正常用户
          --CASE WHEN pt.Code IN ('3601', '3602') and pd.endvalidfor >= sysdate THEN 1 ELSE 0 END) normal_count,
          IF ((v_subscriber.subscriber_status = 3601 OR
             v_subscriber.subscriber_status = 3602) AND -- 状态为正常、未开通
             v_subscriber.laststopdate >= SYSDATE) THEN
            v_sub_status       := 0; --有效;
            v_laststopstatusid := NULL;
            v_laststopdt       := NULL;
          END IF;
          --CASE WHEN pt.Code IN ('3605', '3609', '3612') or pt.code = '3602' and pd.endvalidfor < sysdate THEN 1 ELSE 0 END) exp_count
          --汇巨报表宽带到期用户
          IF ((v_subscriber.subscriber_status = 3612 OR
             v_subscriber.subscriber_status = 3605) OR
             (v_subscriber.subscriber_status = 3602 AND
             v_subscriber.laststopdate < SYSDATE)) THEN
            v_sub_status       := 0;
            v_laststopstatusid := NULL;
            v_laststopdt       := NULL;
          END IF;
        
          --汇巨报表宽带暂停用户
          --SUM(CASE WHEN pt.Code IN ('3604') THEN 1 ELSE 0 END) SUSPENDED_count
          IF (v_subscriber.subscriber_status = 3604) THEN
            v_sub_status       := 1;
            v_laststopstatusid := 1;
            v_laststopdt       := v_subscriber.lastchangedate;
          END IF;
        
        ELSIF (v_subscriber.businessid = 1) THEN
        
          --汇巨报表模拟正常
          -- SUM(CASE WHEN pt.Code IN ('3601', '3602')   THEN 1 ELSE 0 END) normal_count,
          IF (v_subscriber.subscriber_status = 3601 OR
             v_subscriber.subscriber_status = 3602) THEN
            v_sub_status       := 0; --有效
            v_laststopstatusid := NULL;
            v_laststopdt       := NULL;
          END IF;
        
          --汇巨报表模拟过期
          --SUM(CASE WHEN pt.Code IN ('3605', '3609', '3612')   THEN 1 ELSE 0 END) exp_count,
          IF (v_subscriber.subscriber_status = 3605 OR
             v_subscriber.subscriber_status = 3612) THEN
            v_sub_status       := 2; --有效
            v_laststopstatusid := 2;
            v_laststopdt       := v_subscriber.lastchangedate;
          END IF;
        
          --汇巨报表模拟暂停
          --SUM(CASE WHEN pt.Code IN ('3604') THEN 1 ELSE 0 END) SUSPENDED_count,
        
          IF (v_subscriber.subscriber_status = 3604) THEN
            v_sub_status       := 1; --有效
            v_laststopstatusid := 1;
            v_laststopdt       := v_subscriber.lastchangedate;
          END IF;
        END IF;
        -- 如果用户状态为 罚停，但是终端号为 副端，则需要把用户状态设置为 暂停
        IF (v_sub_status = 2 AND v_subscriber.seqstr > 1) THEN
          v_sub_status := 1;
        END IF;
      
        SELECT seq_subscriberen.nextval INTO v_subscriberid_pk FROM dual;
      
        v_result := transfer_dvb_insert_pkg.fun_insert_subscriberen(
                                                                    
                                                                    p_createdt                => v_subscriber.createdt,
                                                                    p_modifydt                => v_subscriber.modifydt, --应该比较报停报通记录得到的最大受理日期
                                                                    p_salechannelid1          => v_salechannelid, --营销渠道,
                                                                    p_operareaid              => v_subscriber.operareaid,
                                                                    p_urgencypaysignid        => v_subscriber.urgencypaysignid,
                                                                    p_stopsignid              => v_subscriber.stopsignid,
                                                                    p_parentid_fk             => v_subscriber.parentid_fk,
                                                                    p_subscriberid_pk         => v_subscriberid_pk,
                                                                    p_invoicecyctypeid_pk     => v_subscriber.invoicecyctypeid_pk,
                                                                    p_customerid_pk           => v_subscriber.customerid_pk,
                                                                    p_businessid              => v_subscriber.businessid,
                                                                    p_servicestr              => v_subscriber.servicestr, -- 服务号码
                                                                    p_usedcustomerid          => v_subscriber.usedcustomerid,
                                                                    p_defaultaccountid        => v_subscriber.defaultaccountid,
                                                                    p_setupaddrstr            => v_subscriber.setupaddrstr,
                                                                    p_setupaddrcodeid         => v_subscriber.setupaddrcodeid,
                                                                    p_subscriberseqstr        => v_subscriber.seqstr, --终端号
                                                                    p_detailaddrcodestr       => v_subscriber.detailaddrcodestr,
                                                                    p_endworkdt               => v_subscriber.endworkdt,
                                                                    p_subscribertypeid        => v_subscribertypeid,
                                                                    p_pwdstr                  => '123456', -- default '123456'
                                                                    p_startdt                 => v_subscriber.startdt, --同竣工日期
                                                                    p_enddt                   => v_subscriber.enddt,
                                                                    p_contractid              => v_subscriber.contractid,
                                                                    p_ifcontractid            => v_subscriber.ifcontractid,
                                                                    p_operatorid              => v_subscriber.operatorid,
                                                                    p_salechannelid2          => v_salechannelid, --默认营销渠道
                                                                    p_orderlevelid            => v_subscriber.orderlevelid,
                                                                    p_equiptypeid             => v_subscriber.equiptypeid, -- 开通设备
                                                                    p_iscdmuserflag           => v_subscriber.iscdmuserflag,
                                                                    p_preoperitemid           => v_subscriber.preoperitemid,
                                                                    p_prestatusid             => v_subscriber.prestatusid,
                                                                    p_laststopdt              => v_laststopdt, -- 上次暂停时间
                                                                    p_laststartdt             => v_subscriber.laststartdt,
                                                                    p_laststopstatusid        => v_laststopstatusid, -- 最后停断状态
                                                                    p_operwayid               => v_subscriber.operwayid,
                                                                    p_statusid                => v_sub_status, -- 用户状态
                                                                    p_mem                     => v_subscriber.mem,
                                                                    p_createid                => v_mr_createid,
                                                                    p_modifyid                => v_subscriber.modifyid,
                                                                    p_createcodestr           => v_mr_createcodestr,
                                                                    p_modifycodestr           => v_subscriber.modifycodestr,
                                                                    p_terminalid              => v_subscriber.terminalid,
                                                                    p_salechannelid           => v_salechannelid, -- 默认营销渠道
                                                                    p_addinfostr2             => v_subscriber.addinfostr2,
                                                                    p_addinfostr3             => v_subscriber.addinfostr3, -- 原系统操作员所在部门
                                                                    p_activedt                => v_subscriber.activedt,
                                                                    p_authenticationtypeid_pk => v_subscriber.authenticationtypeid, -- 认证类型
                                                                    p_accesspointid           => v_subscriber.accesspointid, -- 接入点
                                                                    p_addinfostr4             => v_subscriber.addinfo4); -- 原系统操作员所在部门);
        v_cnt    := v_cnt + 1;
        IF MOD(v_cnt, 10000) = 0 THEN
          COMMIT;
          transfer_dvb_log_pkg.transfer_log_prc(p_msg => v_cnt ||
                                                         ' subscribers have been loaded in TRANSFER_DVB_LOAD_PKG.load_subscriber_prc.');
        END IF;
      
      EXCEPTION
        WHEN OTHERS THEN
          sql_code  := SQLCODE;
          sql_errm  := SQLERRM;
          v_cnt_err := v_cnt_err + 1;
          transfer_dvb_log_pkg.transfer_err_prc(p_sql_code => sql_code,
                                                p_sql_errm => sql_errm,
                                                p_calledby => 'TRANSFER_DVB_LOAD_PKG.load_subscriber_prc',
                                                p_comments => v_subscriber.customerid_pk,
                                                p_custid   => NULL);
      END;
    END LOOP;
    -- 将存在有效、暂停、罚停用户的客户改为现有
    UPDATE customeren c
       SET c.customerstatusid = 1
     WHERE EXISTS (SELECT 'x'
              FROM subscriberen s
             WHERE s.customerid_pk = c.customerid_pk
               AND s.statusid IN (0, 1, 2));
  
    COMMIT;
  -- 增加数据业务开通记录 【待确定】
    INSERT INTO dabopenstatusen dd
      SELECT seq_dabopenstatusen.nextval,
             s.servicestr,
             0, -- 已经开户
             s.subscriberid_pk,
             SYSDATE,
             NULL,
             7, -- 开通设备 
             seq_dabopenstatusen.currval,
             NULL,
             'OPEN_ACCOUNT'
        FROM subscriberen s
       WHERE s.businessid = 3
         AND s.subscribertypeid = 1083
         AND s.statusid <> 3;
    COMMIT;
    
    -- 增加vod业务开通记录 【待确定】
  
    transfer_dvb_log_pkg.transfer_log_prc(p_msg => 'total ' || v_cnt_err ||
                                                   ' errors in TRANSFER_DVB_LOAD_PKG.load_subscriber_prc.');
    transfer_dvb_log_pkg.transfer_log_prc(p_msg => 'total ' || v_cnt ||
                                                   ' subscriber info loading finished.');
  END;

  PROCEDURE load_logicalresource_prc IS
  
  BEGIN
    INSERT INTO logicresourceen
      (logicresourceid_pk,
       resourcetypeid_pk,
       logicresourcetypeid,
       radiuscodestr,
       statusid,
       createid,
       createcodestr,
       createdt,
       mem)
      SELECT seq_logicresourceen.nextval, -- 逻辑资源标识
             7, -- 资源类型标识 7：认证资源
             1, -- 逻辑资源类型 1：认证资源
             s.servicestr, -- 认证号码
             decode(s.statusid,
                    0,
                    2, -- 状态
                    1,
                    2,
                    2,
                    2),
             s.createid,
             s.createcodestr,
             s.createdt, -- 创建日期
             '抚顺导库' || to_char(SYSDATE, 'yyyymmdd')
        FROM subscriberen s
       WHERE s.businessid = 3 -- 数据业务/*
         AND s.authenticationtypeid_pk = 3 -- 认证类型 = Radius认证  */
         AND s.statusid IN (0, 1, 2)
         AND NOT EXISTS
       (SELECT 'x'
                FROM logicresourceen ll
               WHERE s.servicestr = ll.radiuscodestr);
    COMMIT;
  END;

  PROCEDURE load_phyprod_instance_prc IS
  
    v_instanceid_pk        instanceen.instanceid_pk%TYPE;
    v_subscriberaddonid_pk subscriberaddonen.subscriberaddonid_pk%TYPE;
    v_resourceid           NUMBER;
    v_equipt_type          NUMBER;
    v_productid            NUMBER;
    v_priceplanid          NUMBER;
  
    v_cnt            NUMBER;
    v_cnt_err        NUMBER;
    v_priceplanid_pk priceplanen.priceplanid_pk%TYPE;
    sql_code         VARCHAR2(50);
    sql_errm         VARCHAR2(1000);
  
    CURSOR cur_instance IS
    
      SELECT pi.rescode rescode, -- 物理资源编码
             s.subscriberid_pk subscriberid_pk, -- 用户PK
             NULL packageinstanceid_pk,
             NULL operwayid,
             NULL invoicecycid,
             1 productchildtypeid, -- 产品子类  1：物理产品
             1 salewayid, -- 销售方式 1：购买
             NULL componentid,
             NULL packageid,
             s.endworkdt subscriberstartdt, -- 计费开始日期，取SMS记录的创建时间
             NULL subscriberenddt,
             1 billingflag, -- 产品是否计费 0：计费
             NULL iffullmonthid,
             0 statusid, -- 状态：有效
             s.endworkdt rundt, -- 开通日期，同 计费开始日期
             NULL enddt, -- 计费截止日期，null ，
             pi.mem mem,
             NULL createid,
             NULL modifyid,
             NULL createcodestr,
             NULL modifycodestr,
             NULL terminalid,
             s.endworkdt createdt,
             NULL modifydt,
             s.operareaid operareaid, -- 运营区域
             NULL contractid_pk,
             0 autocontinue, -- 是否自动续订购 ，物理产品默认为 0，不自动续订  系统目前默认是 1
             NULL serviceenddt,
             s.endworkdt finishdt, -- 竣工时间
             NULL preinstanceid,
             NULL packagetypeid,
             pi.resourcespecificationid resourcespecificationid, --汇巨系统中资源目录
             NULL isunifiedcancelid,
             s.customerid_pk customerid_pk,
             pi.equ_type equ_type, -- 资源类型
             s.salechannelid1 salechannel, -- 营销渠道
             pi.productofferingid productid, --汇巨系统中物理产品ID
             pi.marketingplanid marketingplanid, --汇巨系统中营销计划标识
             decode(s.subscriberseqstr, 1, 1, 2) ismain --是否主终端
        FROM subscriberen s, fsboss_phy_instance pi
       WHERE s.addinfostr4 = pi.terminalid;
  BEGIN
  
    v_cnt     := 0;
    v_cnt_err := 0;
  
    FOR c_instance IN cur_instance LOOP
      BEGIN
      
        -- 开通设备
        v_equipt_type := NULL;
        IF (c_instance.equ_type = 1) THEN
          v_equipt_type := 202; --智能卡的开通设备类型：202 同方
        END IF;
        --如果是Eoc设备，则通过资源目录确定其对应到四达boss中的产品
        IF c_instance.equ_type = 9 THEN
          v_productid   := transfer_dvb_utils_pkg.fun_get_basedata(c_instance.resourcespecificationid,
                                                                   '物理产品PK');
          v_priceplanid := transfer_dvb_utils_pkg.fun_get_basedata(c_instance.resourcespecificationid,
                                                                   '物理产品价格计划PK');
        ELSE
          v_productid   := transfer_dvb_utils_pkg.fun_get_basedata(c_instance.ismain ||
                                                                   c_instance.productid,
                                                                   '物理产品PK');
          v_priceplanid := transfer_dvb_utils_pkg.fun_get_basedata(c_instance.ismain ||
                                                                   c_instance.productid,
                                                                   '物理产品价格计划PK');
        END IF;
      
        SELECT seq_instanceen.nextval INTO v_instanceid_pk FROM dual;
        v_result := transfer_dvb_insert_pkg.fun_insert_instanceen(
                                                                  
                                                                  p_instanceid_pk        => v_instanceid_pk, -- 产品实例PK
                                                                  p_subscriberid_pk      => c_instance.subscriberid_pk, -- 用户PK
                                                                  p_packageinstanceid_pk => c_instance.packageinstanceid_pk, -- 套餐产品实例标识
                                                                  p_operwayid            => c_instance.operwayid, -- 运营方式
                                                                  p_productid            => v_productid, -- 产品ID
                                                                  p_invoicecycid         => c_instance.invoicecycid, -- 帐务周期标识 null
                                                                  p_productchildtypeid   => c_instance.productchildtypeid, -- 产品子类：物理产品
                                                                  p_salewayid            => c_instance.salewayid, -- 销售方式：1  购买
                                                                  p_componentid          => c_instance.componentid, -- 包标识
                                                                  p_packageid            => c_instance.packageid, -- 套餐标识
                                                                  p_subscriberstartdt    => c_instance.subscriberstartdt, -- 计费开始日期
                                                                  p_subscriberenddt      => c_instance.subscriberenddt, -- 取消订购时间 null
                                                                  p_billingflag          => c_instance.billingflag, -- 计费标识，是否计费  0：计费
                                                                  p_iffullmonthid        => c_instance.iffullmonthid, -- 是否统一退订
                                                                  p_statusid             => c_instance.statusid, -- 状态：0 有效
                                                                  p_rundt                => c_instance.rundt, -- 开通时间
                                                                  p_enddt                => c_instance.enddt, -- 计费截止时间
                                                                  p_mem                  => c_instance.mem, -- 更改原先的v_resourcecode
                                                                  p_createid             => c_instance.createid,
                                                                  p_modifyid             => c_instance.modifyid,
                                                                  p_createcodestr        => c_instance.createcodestr,
                                                                  p_modifycodestr        => c_instance.modifycodestr,
                                                                  p_terminalid           => c_instance.terminalid,
                                                                  p_salechannelid        => c_instance.salechannel,
                                                                  p_createdt             => c_instance.createdt, -- 创建时间
                                                                  p_modifydt             => c_instance.modifydt,
                                                                  p_salechannelid1       => c_instance.salechannel,
                                                                  p_operareaid           => c_instance.operareaid, -- 运营区域 null
                                                                  p_contractid_pk        => c_instance.contractid_pk, -- 合同标识 null
                                                                  p_autocontinue         => c_instance.autocontinue, -- 自动续订标识 0：补丁续订
                                                                  p_serviceenddt         => NULL, -- 服务停断日期
                                                                  p_finishdt             => c_instance.finishdt, -- 竣工时间
                                                                  p_preinstanceid        => c_instance.preinstanceid,
                                                                  p_packagetypeid        => c_instance.packagetypeid,
                                                                  p_isunifiedcancelid    => c_instance.isunifiedcancelid,
                                                                  p_customerid_pk        => c_instance.customerid_pk -- 客户PK
                                                                  );
      
        SELECT seq_subscriberaddonen.nextval
          INTO v_subscriberaddonid_pk
          FROM dual;
      
        -- 通过资源编码和资源类型取得对应的物理资源标识
        IF c_instance.rescode IS NOT NULL THEN
          v_resourceid := transfer_dvb_utils_pkg.fun_get_resourceid_by_rescode(p_rescode => c_instance.rescode,
                                                                               p_restype => c_instance.equ_type);
        END IF;
      
        v_result := transfer_dvb_insert_pkg.fun_insert_subscriberaddonen(p_subscriberaddonid_pk => v_subscriberaddonid_pk,
                                                                         p_subscriberid_pk      => c_instance.subscriberid_pk, -- 用户标识
                                                                         p_resourceid           => v_resourceid, -- 资源标识
                                                                         p_resourcecodestr      => c_instance.rescode, -- 资源编码
                                                                         p_equiptypeid          => v_equipt_type, -- 设备类型
                                                                         p_startdt              => c_instance.subscriberstartdt, -- 有效起始时间
                                                                         p_enddt                => c_instance.enddt, -- 无效终止时间 null
                                                                         p_statusid             => 1, -- 状态
                                                                         p_mem                  => c_instance.mem,
                                                                         p_createid             => c_instance.createid,
                                                                         p_modifyid             => c_instance.modifyid,
                                                                         p_createcodestr        => c_instance.createcodestr,
                                                                         p_modifycodestr        => c_instance.modifycodestr,
                                                                         p_terminalid           => c_instance.terminalid,
                                                                         p_salechannelid        => c_instance.salechannel,
                                                                         p_createdt             => c_instance.createdt,
                                                                         p_modifydt             => c_instance.modifydt,
                                                                         p_salechannelid1       => c_instance.salechannel,
                                                                         p_operareaid           => c_instance.operareaid, -- 运营区域
                                                                         p_instanceid_pk        => v_instanceid_pk); -- 产品实例标识
      
        INSERT INTO priceinstanceen
          (priceinstanceid_pk,
           instanceid_pk,
           priceplanid_pk,
           startdt,
           enddt,
           ifvalid)
          SELECT seq_priceinstanceen.nextval,
                 v_instanceid_pk,
                 v_priceplanid,
                 c_instance.subscriberstartdt,
                 NULL,
                 1
            FROM dual;
      
        v_cnt := v_cnt + 1;
        IF MOD(v_cnt, 10000) = 0 THEN
          COMMIT;
          transfer_dvb_log_pkg.transfer_log_prc(p_msg => v_cnt ||
                                                         ' phyresources instance have been loaded in transfer_dvb_load_pkg.load_phyprod_instance_prc.');
        END IF;
      
      EXCEPTION
        WHEN OTHERS THEN
          sql_code := SQLCODE;
        
          sql_errm  := SQLERRM;
          v_cnt_err := v_cnt_err + 1;
        
          transfer_dvb_log_pkg.transfer_err_prc(p_sql_code => sql_code,
                                                p_sql_errm => sql_errm,
                                                p_calledby => 'transfer_dvb_load_pkg.load_phyprod_instance_prc',
                                                p_comments => '用户pk:' ||
                                                              c_instance.subscriberid_pk || ';' ||
                                                              c_instance.rescode,
                                                p_custid   => v_priceplanid_pk);
      END;
    END LOOP;
    COMMIT;
    transfer_dvb_log_pkg.transfer_log_prc(p_msg => 'total ' || v_cnt_err ||
                                                   ' errors in transfer_dvb_load_pkg.load_phyprod_instance_prc.');
    transfer_dvb_log_pkg.transfer_log_prc(p_msg => 'total ' || v_cnt ||
                                                   ' phyproduct instance info loading finished.');
  
  END;

  PROCEDURE load_serprod_instance_prc IS
    v_result               NUMBER;
    v_instanceid_pk        instanceen.instanceid_pk%TYPE;
    v_instanceserviceid_pk instanceserviceen.instanceserviceid_pk%TYPE;
    v_productid_pk         instanceen.productid%TYPE;
    v_priceplanid          NUMBER;
    v_societyid            NUMBER;
    v_operareaid           NUMBER;
    v_instance_enddt       DATE;
    v_instance_startdt     DATE;
    v_auto_continue        NUMBER;
    v_serviceenddt         DATE;
    v_cnt                  NUMBER;
    v_cnt_err              NUMBER;
    v_billingflag          NUMBER;
  
    CURSOR cur_instance IS
      SELECT s.subscriberid_pk subscriberid_pk, -- 用户PK
             NULL packageinstanceid_pk,
             NULL operwayid, -- 运营方式 禁用
             fsi.serviceproduct_id serviceproduct_id, -- 产品PK
             NULL invoicecycid, -- 账务周期 禁用
             2 productchildtypeid, -- 产品子类 2：服务产品
             1 salewayid, -- 销售方式
             NULL componentid,
             NULL packageid,
             fsi.subscriberstartdt subscriberstartdt, -- 计费开始日期
             NULL subscriberenddt, -- 取消订购日期  禁用
             NULL iffullmonthid, -- 是否整月  禁用
             fsi.rundt rundt, -- 开通日期
             fsi.enddt enddt, -- 计费截止日期
             fsi.mem mem, -- 取得套餐名称作为备注
             NULL createid,
             NULL modifyid,
             NULL createcodestr,
             NULL modifycodestr,
             NULL terminalid,
             fsi.createdt createdt,
             NULL modifydt,
             s.operareaid operareaid,
             NULL contractid_pk,
             s.laststopdt laststopdt, -- 服务停断日期，取 服务中的 最后停断日期
             fsi.finishdt finishdt, -- 竣工日期，取产品的计费开始日期
             s.customerid_pk customerid_pk,
             decode(s.statusid, 0, 1, 2) service_ins_status, -- 服务实例的状态，用户状态为 0(有效) --> 1：有效  否则为 2：暂停
             c.societyid societyid, -- 社会类别
             s.subscriberseqstr seqid, -- 终端号
             s.salechannelid1 salechannel, -- 营销渠道
             fsi.oldproname oldproname, -- 原系统产品名称
             fsi.export_pro_type export_pro_type, -- 导库用产品类型
             c.custtypeid custtypeid, --客户类型 0 个人，1集团
             s.statusid substatusid, --用户状态
             fsi.terminalid hugeterminalid
        FROM subscriberen        s, -- 用户表
             customeren          c, --客户表
             fsboss_ser_instance fsi -- 服务产品实例临时表
       WHERE c.customerid_pk = s.customerid_pk
         AND fsi.terminalid = s.addinfostr4;
  
    -- 取得某一个产品包含的服务PK
    CURSOR cur_service(p_productid NUMBER) IS
      SELECT sp.serviceid_pk serviceid_pk
        FROM service_producten sp
       WHERE sp.productid_pk = p_productid;
  
  BEGIN
  
    v_cnt     := 0;
    v_cnt_err := 0;
    FOR c_instance IN cur_instance LOOP
      BEGIN
      
        -- 取得社会类别
        v_societyid  := c_instance.societyid; --社会类别
        v_operareaid := c_instance.operareaid; --运营区域
        --获取服务产品对应的新产品pk
        v_productid_pk := transfer_dvb_utils_pkg.fun_get_basedata(c_instance.serviceproduct_id,
                                                                  '服务产品PK');
        v_billingflag  := 0; -- 默认0
        -- 基本包
        IF c_instance.export_pro_type = 1 THEN
          -- 个人客户
          IF c_instance.custtypeid = 0 THEN
            v_auto_continue  := 1;
            v_serviceenddt   := NULL;
            v_instance_enddt := NULL;
            -- 主终端
            IF c_instance.seqid = 1 THEN
              v_priceplanid := transfer_dvb_utils_pkg.fun_get_basedata(c_instance.societyid,
                                                                       '主终端基本包价格计划PK');
              -- 二三终端
            ELSIF c_instance.seqid = 2 OR c_instance.seqid = 3 THEN
              v_priceplanid := transfer_dvb_utils_pkg.fun_get_basedata('default',
                                                                       '二三终端基本包价格计划PK');
              -- 四终端及以上
            ELSE
              v_priceplanid := transfer_dvb_utils_pkg.fun_get_basedata('default',
                                                                       '四终端及以上基本包价格计划PK');
            END IF;
            --正常，罚停 计费开始日期=原来计费截止日期
            IF c_instance.substatusid = 0 OR c_instance.substatusid = 2 THEN
              v_instance_startdt := trunc(c_instance.enddt) + 1;
              -- 暂停的用户基本包计费开始日期 = 当前日期+可使用剩余天数
            END IF;
            IF c_instance.substatusid = 1 AND
               c_instance.laststopdt IS NOT NULL THEN
              v_instance_startdt := trunc(SYSDATE) +
                                    (trunc(c_instance.enddt) -
                                     trunc(c_instance.laststopdt));
            END IF;
          
            -- 集团客户，时段产品
          ELSE
            -- 时段产品， 不自动延续
            v_auto_continue := 0;
            -- 时段产品服务停断日期为用户上次停断时间
            v_serviceenddt := c_instance.laststopdt;
            ---获取服务产品相关的计费开始与计费截止日期
            v_instance_startdt := trunc(c_instance.subscriberstartdt);
          
            v_instance_enddt := trunc(c_instance.enddt) + 1 - (1 / 86400);
            v_priceplanid    := transfer_dvb_utils_pkg.fun_get_basedata('default',
                                                                        '集团基本包价格计划PK');
          END IF;
        
          -- 非基本包,时段产品
        ELSE
        
          -- 时段产品， 不自动延续
          v_auto_continue := 0;
          -- 时段产品服务停断日期为用户上次停断时间
          v_serviceenddt := c_instance.laststopdt;
          ---获取服务产品相关的计费开始与计费截止日期
          v_instance_startdt := trunc(c_instance.subscriberstartdt);
        
          v_instance_enddt := trunc(c_instance.enddt) + 1 - (1 / 86400);
        
          --直接从价格计划表中取得id最小的价格计划
          SELECT MIN(pp.priceplanid_pk)
            INTO v_priceplanid
            FROM priceplanen pp
           WHERE pp.productid_pk = v_productid_pk;
        END IF;
        SELECT seq_instanceen.nextval INTO v_instanceid_pk FROM dual;
        v_result := transfer_dvb_insert_pkg.fun_insert_instanceen(
                                                                  
                                                                  p_instanceid_pk        => v_instanceid_pk, -- 产品实例PK
                                                                  p_subscriberid_pk      => c_instance.subscriberid_pk, -- 用户PK
                                                                  p_packageinstanceid_pk => c_instance.packageinstanceid_pk, -- 套餐实例PK null
                                                                  p_operwayid            => c_instance.operwayid, -- 运营方式 null
                                                                  p_productid            => v_productid_pk, -- 产品PK
                                                                  p_invoicecycid         => c_instance.invoicecycid, -- 帐务周期ID null
                                                                  p_productchildtypeid   => c_instance.productchildtypeid, -- 产品子类 2：服务产品
                                                                  p_salewayid            => c_instance.salewayid, -- 销售方式 1：购买
                                                                  p_componentid          => c_instance.componentid, -- 包PK null
                                                                  p_packageid            => c_instance.packageid, -- 套餐PK null
                                                                  p_subscriberstartdt    => v_instance_startdt, -- 计费开始日期
                                                                  p_subscriberenddt      => v_instance_enddt, -- 取消定购日期 null
                                                                  p_billingflag          => v_billingflag, -- 计费标识
                                                                  p_iffullmonthid        => c_instance.iffullmonthid, -- 是否整月 null
                                                                  p_statusid             => 0, -- 产品实例状态 0：有效
                                                                  p_rundt                => c_instance.createdt, -- 开通时间
                                                                  p_enddt                => v_instance_enddt, -- 计费截止日期  null
                                                                  p_mem                  => c_instance.mem, -- 取得SMS库中订购记录表中的 PK
                                                                  p_createid             => c_instance.createid,
                                                                  p_modifyid             => c_instance.modifyid,
                                                                  p_createcodestr        => c_instance.createcodestr,
                                                                  p_modifycodestr        => c_instance.modifycodestr,
                                                                  p_terminalid           => c_instance.terminalid,
                                                                  p_salechannelid        => c_instance.salechannel,
                                                                  p_createdt             => c_instance.createdt,
                                                                  p_modifydt             => c_instance.modifydt,
                                                                  p_salechannelid1       => c_instance.salechannel,
                                                                  p_operareaid           => c_instance.operareaid, -- 运营区域
                                                                  p_contractid_pk        => c_instance.contractid_pk, -- 合同标识  null
                                                                  p_autocontinue         => v_auto_continue, -- 是否自动续订  1：自动续订
                                                                  p_serviceenddt         => v_instance_enddt, -- 服务停断日期
                                                                  p_finishdt             => c_instance.finishdt, -- 竣工日期
                                                                  p_preinstanceid        => NULL,
                                                                  p_packagetypeid        => NULL,
                                                                  p_isunifiedcancelid    => NULL,
                                                                  p_customerid_pk        => c_instance.customerid_pk);
      
        -- 为产品实例创建服务实例
        FOR v_service IN cur_service(p_productid => v_productid_pk) LOOP
          BEGIN
          
            SELECT seq_instanceserviceen.nextval
              INTO v_instanceserviceid_pk
              FROM dual;
          
            v_result := transfer_dvb_insert_pkg.fun_insert_instanceserviceen(p_instanceid_pk        => v_instanceid_pk,
                                                                             p_serviceid_pk         => v_service.serviceid_pk,
                                                                             p_instanceserviceid_pk => v_instanceserviceid_pk,
                                                                             p_statusid             => c_instance.service_ins_status,
                                                                             p_mem                  => '抚顺倒库',
                                                                             p_createid             => c_instance.createid,
                                                                             p_modifyid             => '',
                                                                             p_createcodestr        => '',
                                                                             p_modifycodestr        => '',
                                                                             p_terminalid           => '',
                                                                             p_salechannelid        => '',
                                                                             p_createdt             => c_instance.createdt,
                                                                             p_modifydt             => '');
          
          EXCEPTION
            WHEN OTHERS THEN
              sql_code  := SQLCODE;
              sql_errm  := SQLERRM;
              v_cnt_err := v_cnt_err + 1;
              transfer_dvb_log_pkg.transfer_err_prc(p_sql_code => sql_code,
                                                    p_sql_errm => sql_errm,
                                                    p_calledby => 'transfer_DVB_LOAD_PKG.load_serprod_instance_prc(intelnal)',
                                                    p_comments => c_instance.hugeterminalid,
                                                    p_custid   => NULL);
            
          END;
        
        END LOOP;
      
        INSERT INTO priceinstanceen
          (priceinstanceid_pk,
           instanceid_pk,
           priceplanid_pk,
           startdt,
           enddt,
           ifvalid)
        
          SELECT seq_priceinstanceen.nextval,
                 v_instanceid_pk,
                 v_priceplanid, -- 价格计划PK
                 c_instance.subscriberstartdt,
                 NULL,
                 1
            FROM dual;
      
        v_cnt := v_cnt + 1;
      
        IF MOD(v_cnt, 10000) = 0 THEN
          COMMIT;
          transfer_dvb_log_pkg.transfer_log_prc(p_msg => v_cnt ||
                                                         ' serproducts have bean loaded in transfer_DVB_LOAD_PKG.load_serprod_instance_prc.');
        END IF;
      
      EXCEPTION
        WHEN OTHERS THEN
          sql_code  := SQLCODE;
          sql_errm  := SQLERRM;
          v_cnt_err := v_cnt_err + 1;
          transfer_dvb_log_pkg.transfer_err_prc(p_sql_code => sql_code,
                                                p_sql_errm => sql_errm,
                                                p_calledby => 'transfer_DVB_LOAD_PKG.load_serprod_instance_prc',
                                                p_comments => 'subscriber_pk:' ||
                                                              c_instance.subscriberid_pk ||
                                                              ';原系统终端ID' ||
                                                              c_instance.hugeterminalid,
                                                p_custid   => c_instance.packageinstanceid_pk);
      END;
    END LOOP;
    COMMIT;
    transfer_dvb_log_pkg.transfer_log_prc(p_msg => 'total ' || v_cnt_err ||
                                                   ' errors in transfer_DVB_LOAD_PKG.load_serprod_instance_prc.');
  
    transfer_dvb_log_pkg.transfer_log_prc(p_msg => 'total ' || v_cnt ||
                                                   ' service product info loading finished.');
  
  END;

  PROCEDURE load_generate_bills IS
    --yyyymmdd
    --------------------------------------
    -----2014-05-11------
    -----startime  hdz---
    -- 用户的基本包的计费开始在导库日到月末最后一天
    -- 这部分用户需要生成欠费账单、欠费用户
    --------------------------------------
    v_writeoff        NUMBER;
    v_invoicecycid_pk NUMBER;
    v_billid_pk       NUMBER;
    v_oweobjectid_pk  NUMBER;
    v_halfday_1       NUMBER;
    v_monthday_1      NUMBER;
    v_perdayfee       NUMBER;
    v_billdate_1      DATE;
    v_billdate_2      DATE;
    v_billingenddt    DATE;
    v_cnt             NUMBER;
    v_cnt_err         NUMBER;
  
    -- 查询导库日到导库月月末到期的用户和产品实例
    CURSOR cur_get_ins IS
      SELECT s.customerid_pk,
             s.defaultaccountid,
             s.subscriberid_pk,
             i.instanceid_pk,
             r.rateitemid_pk, -- 账目类型
             i.productid, -- 产品PK
             r.rateid_pk, -- 资费PK
             ps.priceinstanceid_pk, -- 价格计划实例PK
             ps.priceplanid_pk, -- 价格计划PK
             i.subscriberstartdt, -- 计费开始日期
             r.ratesumid -- 资费
        FROM subscriberen    s, -- 用户表
             instanceen      i, -- 产品实例表
             priceinstanceen ps, -- 价格计划实例
             rateen          r, -- 资费表
             rateplanen      rp -- 资费和价格计划对应关系表
       WHERE s.subscriberid_pk = i.subscriberid_pk
         AND i.instanceid_pk = ps.instanceid_pk
         AND ps.priceplanid_pk = rp.priceplanid_pk
         AND r.rateid_pk = rp.rateid_pk
         AND i.productchildtypeid = 2
         AND -- 服务产品实例
             i.productid = 1122
         AND -- 只处理基本包
             s.statusid NOT IN (1, 2, 3)
         AND -- 用户状态为 正常
             i.enddt IS NULL
         AND -- 计费截止日期
             i.autocontinue = 1
         AND -- 自动延续的产品实例
             i.subscriberstartdt > trunc(SYSDATE)
         AND -- 计费开始日期
             i.subscriberstartdt < to_date('2015-07-01', 'yyyy-mm-dd');
  
  BEGIN
  
    v_writeoff        := 24; -- 默认销账金额
    v_invoicecycid_pk := 1; -- 默认账期编码
    v_result          := 0;
    v_cnt             := 0;
    -- 根据账期查询账期key
    SELECT i.invoicecycid_pk
      INTO v_invoicecycid_pk
      FROM invoicecycen i
     WHERE invoicecycnamestr = to_char(SYSDATE, 'yyyymm');
  
    SELECT trunc(last_day(SYSDATE) + 1) INTO v_billdate_2 FROM dual; -- 导库月下个月的第一天，用于计算残月
  
    v_billingenddt := to_date(to_char(v_billdate_2 - 1, 'yyyy-mm-dd') ||
                              ' 23:59:59',
                              'yyyy-mm-dd HH24:MI:SS');
  
    --生成综合帐单记录
    FOR v_get_ins IN cur_get_ins LOOP
      BEGIN
      
        -- 取得每一个账单的计费起始日期
        v_billdate_1 := v_get_ins.subscriberstartdt;
      
        -- 计算残月天数
        SELECT to_number(trunc(v_billdate_2 - v_billdate_1))
          INTO v_halfday_1
          FROM dual;
      
        -- 计算整月天数
        v_monthday_1 := to_number(to_char(last_day(v_billdate_1), 'dd'));
      
        --计算当月每日应收金额
        v_perdayfee := round(nvl(v_get_ins.ratesumid, 0) / v_monthday_1, 8);
      
        --计算残月应收金额
        v_writeoff := round(v_perdayfee * v_halfday_1, 2);
      
        -- 生成欠费用户
        SELECT seq_oweobjecten.nextval INTO v_oweobjectid_pk FROM dual;
      
        v_result := transfer_dvb_insert_pkg.fun_insert_oweobjecten(p_oweobjectid_pk           => v_oweobjectid_pk,
                                                                   p_customerid               => v_get_ins.customerid_pk,
                                                                   p_accountid                => v_get_ins.defaultaccountid,
                                                                   p_subscriberid             => v_get_ins.subscriberid_pk,
                                                                   p_invoicecycid             => v_invoicecycid_pk, --账务周期
                                                                   p_owetypeid                => 1, -- 欠费类型  2：普通欠费
                                                                   p_owedt                    => v_get_ins.subscriberstartdt,
                                                                   p_owemoneyid               => v_writeoff,
                                                                   p_isauditid                => 1, -- 是否审核
                                                                   p_operwayid                => 1,
                                                                   p_treatstatusid            => 0, -- 欠费用户处理状态  0:欠费
                                                                   p_urgecountid              => 0, -- 催缴次数
                                                                   p_lastedtimedt             => NULL, -- 最近处理日期
                                                                   p_mem                      => '导库欠费用户',
                                                                   p_statusid                 => 1,
                                                                   p_createid                 => NULL,
                                                                   p_modifyid                 => NULL,
                                                                   p_createcodestr            => NULL,
                                                                   p_modifycodestr            => NULL,
                                                                   p_terminalid               => NULL,
                                                                   p_salechannelid            => NULL,
                                                                   p_createdt                 => SYSDATE,
                                                                   p_salechannelid1           => NULL,
                                                                   p_operareaid               => NULL,
                                                                   p_modifydt                 => NULL,
                                                                   p_stoptype                 => 0, -- 欠费主体类型 0：用户
                                                                   p_billids                  => NULL,
                                                                   p_billingeventid           => NULL,
                                                                   p_billingserviceinstanceid => NULL);
      
        -- 生成欠费账单
        SELECT seq_billen.nextval INTO v_billid_pk FROM dual;
      
        v_result := transfer_dvb_insert_pkg.fun_insert_billen(p_billid_pk           => v_billid_pk,
                                                              p_writeoffid          => NULL,
                                                              p_customerid          => v_get_ins.customerid_pk,
                                                              p_subscriberid        => v_get_ins.subscriberid_pk,
                                                              p_accountid           => v_get_ins.defaultaccountid,
                                                              p_rateclasssourceid   => 0, -- 表示 帐务帐目
                                                              p_rateclassid         => v_get_ins.rateitemid_pk, -- 数字电视收视费
                                                              p_invoicecycid        => v_invoicecycid_pk, -- 帐目周期编码
                                                              p_operwayid           => 1, -- 运营方式
                                                              p_origionfeeid        => v_writeoff, -- 账单金额
                                                              p_discountfeeid       => 0,
                                                              p_factfeeid           => v_writeoff, -- 账单金额
                                                              p_billstatusid        => 1, -- 账单状态：欠费
                                                              p_writeoffstatusid    => 0, -- 是否已经销账：未销帐
                                                              p_oweobjectstatusid   => 1, -- 表示'已生成'欠费用户
                                                              p_ifauditid           => 1, -- 已经审核
                                                              p_ifacctokid          => 1, -- 已经出账确认
                                                              p_accttypeid          => 0, -- 出账类型：周期账单
                                                              p_commicollid_pk      => NULL,
                                                              p_billingtaskid       => NULL,
                                                              p_mem                 => '导库补账单',
                                                              p_createid            => NULL,
                                                              p_modifyid            => NULL,
                                                              p_createcodestr       => NULL,
                                                              p_modifycodestr       => NULL,
                                                              p_terminalid          => NULL,
                                                              p_salechannelid       => NULL,
                                                              p_createdt            => SYSDATE,
                                                              p_modifydt            => NULL,
                                                              p_salechannelid1      => NULL,
                                                              p_operareaid          => NULL,
                                                              p_billingstartdt      => v_billdate_1,
                                                              p_billingenddt        => v_billingenddt,
                                                              p_oweobjectid         => v_oweobjectid_pk, -- 欠费用户PK
                                                              p_priceinstanceid     => v_get_ins.priceinstanceid_pk,
                                                              p_priceplanid         => v_get_ins.priceplanid_pk,
                                                              p_rateid              => v_get_ins.rateid_pk,
                                                              p_operitemid          => NULL,
                                                              p_productid           => v_get_ins.productid, -- 产品编码 5：数字电视基本包
                                                              p_instanceid          => v_get_ins.instanceid_pk,
                                                              p_ifprinted           => 0,
                                                              p_packageinstanceid   => NULL, -- 所属套餐实例标识
                                                              p_discountnameliststr => NULL, --已使用优惠名称
                                                              p_refundstate         => 0 --退费状态 0：未退费
                                                              );
      
        v_cnt := v_cnt + 1;
      
        IF MOD(v_cnt, 1000) = 0 THEN
          COMMIT;
          transfer_dvb_log_pkg.transfer_log_prc(p_msg => v_cnt ||
                                                         ' bills have been generated in TRANSFER_DVB_LOAD_PKG.load_generate_bill.');
        END IF;
      
      EXCEPTION
        WHEN OTHERS THEN
          sql_code  := SQLCODE;
          sql_errm  := SQLERRM;
          v_cnt_err := v_cnt_err + 1;
          transfer_dvb_log_pkg.transfer_err_prc(p_sql_code => sql_code,
                                                p_sql_errm => sql_errm,
                                                p_calledby => 'TRANSFER_DVB_LOAD_PKG.load_generate_bills',
                                                p_comments => v_get_ins.instanceid_pk,
                                                p_custid   => NULL);
        
      END;
    END LOOP;
    COMMIT;
  END;

  PROCEDURE prc_del_bad_segment_addr IS
  
    v_address_level_pk NUMBER;
    v_address_fk       NUMBER;
    v_count            NUMBER;
  
    -- 获取地址级别，倒序排列
    CURSOR c IS
      SELECT al.addresslevelid_pk
        FROM addresslevelen al
       WHERE al.statusid = 1
       ORDER BY al.addresslevelid_pk DESC;
  
    -- 查找指定级别的所有地址，并且已经绑定了网格
    CURSOR d(address_level_pk NUMBER) IS
      SELECT a.addressid_fk
        FROM addressen a
       WHERE a.addresslevelid_pk = address_level_pk
         AND a.statusid = 1
         AND a.segmentid_pk IS NOT NULL
       GROUP BY a.addressid_fk;
  BEGIN
    DELETE FROM temp_bad_segment_address;
    COMMIT;
  
    FOR c1 IN c LOOP
      v_address_level_pk := c1.addresslevelid_pk;
      FOR d1 IN d(v_address_level_pk) LOOP
        v_address_fk := d1.addressid_fk;
        -- 查找当前地址的父级地址是否已经绑定了网格，
        -- 如果已经绑定绑定网格则进行记录
        SELECT COUNT(*)
          INTO v_count
          FROM addressen aa
         WHERE aa.addressid_pk = v_address_fk
           AND aa.segmentid_pk IS NOT NULL
           AND aa.statusid = 1
           AND NOT EXISTS
         (SELECT 'x'
                  FROM temp_bad_segment_address ba
                 WHERE ba.address_pk = aa.addressid_pk);
      
        IF v_count > 0 THEN
          v_count := 0;
          INSERT INTO temp_bad_segment_address
            (address_pk)
          VALUES
            (v_address_fk);
        END IF;
      END LOOP;
    END LOOP;
    COMMIT;
  
    DELETE FROM servicesegment_addressen sd
     WHERE sd.addressid_pk IN
           (SELECT address_pk FROM temp_bad_segment_address);
  
    UPDATE addressen aaa
       SET aaa.segmentid_pk = NULL
     WHERE aaa.addressid_pk IN
           (SELECT address_pk FROM temp_bad_segment_address);
    COMMIT;
  END;

END transfer_dvb_load_pkg;
/
