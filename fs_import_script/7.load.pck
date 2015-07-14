CREATE OR REPLACE PACKAGE transfer_dvb_load_pkg IS

  -- Author  : HUDAZHU
  -- Created : 2014/9/1 10:31:08 AM
  -- Purpose :

  sql_code VARCHAR2(50);
  sql_errm VARCHAR2(1000);
  v_result NUMBER(1);

  PROCEDURE load_addrinfo_prc; -- �����ַ����

  PROCEDURE load_operator; -- �������Ա��ֻ��ӪҵԱ�������Ӫ�������Ͳֿ�

  PROCEDURE load_servicesegment; -- �����������ַ�Ĺ�ϵ�����������Ա�Ĺ�ϵ

  PROCEDURE load_grid_prc; -- ���뷽������

  PROCEDURE load_phyresource_prc; --����������Դ������ֻ�������ܿ�����

  PROCEDURE load_customer_prc; --����ͻ����˻�������˱���֧���������������ϵ

  PROCEDURE load_deposit_prc; -- ����Ѻ��

  PROCEDURE load_subscriber_prc; --�����û������趨���ն��û����ն˺�

  PROCEDURE load_logicalresource_prc; -- �����߼���Դ

  PROCEDURE load_phyprod_instance_prc; -- ���������Ʒʵ��

  PROCEDURE load_serprod_instance_prc; -- ��������Ʒʵ��

  PROCEDURE load_generate_bills; -- ���ɵ����յ��µ׵�Ƿ���ʵ�

  PROCEDURE prc_del_bad_segment_addr; -- �����ַ������Ĺ�ϵ

END transfer_dvb_load_pkg;
/
CREATE OR REPLACE PACKAGE BODY transfer_dvb_load_pkg IS

  -- ������ʱ����BOSSϵͳ�ĵ�ַ����Ϣ

  PROCEDURE load_addrinfo_prc IS
    v_level_count        NUMBER;
    v_addressid_pk       addressen.addressid_pk%TYPE;
    v_addresscodestr     addressen.addresscodestr%TYPE;
    v_detailaddressstr   addressen.detailaddressstr%TYPE;
    v_addressfullnamestr addressen.addressfullnamestr%TYPE;
    v_mem                addressen.mem%TYPE;
    v_result             NUMBER(1);
  
    -- ���ݵ�ǰ�����ѯ��Ӧ��ַ
    CURSOR cursor_current_level_address(level_id NUMBER) IS
      SELECT * FROM fsboss_places t WHERE t.address_level = level_id;
  
  BEGIN
  
    -- ѭ���ڶ������ڰ˼���ַ
    FOR level_id IN 2 .. 8 LOOP
      v_level_count := 1;
      BEGIN
        -- ���뵱ǰ�����ַ
        FOR c_current_level_addr IN cursor_current_level_address(level_id) LOOP
          BEGIN
            v_level_count        := v_level_count + 1;
            v_addresscodestr     := lpad(to_char(v_level_count),
                                         c_current_level_addr.add_level_code_length,
                                         '0'); -- ��ַ��,���ݵ�ַ���볤����0
            v_detailaddressstr   := c_current_level_addr.parent_full_name_code ||
                                    v_addresscodestr; -- ��ַȫ�Ʊ���
            v_addressfullnamestr := c_current_level_addr.parent_full_name ||
                                    c_current_level_addr.name; -- ��ַȫ��
            v_mem                := c_current_level_addr.id; -- ԭϵͳid
          
            SELECT seq_addressen.nextval INTO v_addressid_pk FROM dual;
            v_result := transfer_dvb_insert_pkg.fun_insert_addressen(p_addressid_pk       => v_addressid_pk, -- ��ַPK
                                                                     p_addressid_fk       => c_current_level_addr.parentid_in_starboss,
                                                                     p_addresslevelid_pk  => c_current_level_addr.address_level,
                                                                     p_addressnamestr     => c_current_level_addr.name,
                                                                     p_addresscodestr     => v_addresscodestr,
                                                                     p_detailaddressstr   => v_detailaddressstr,
                                                                     p_addressabstr       => NULL,
                                                                     p_statusid           => 1, -- ��ַ״̬Ĭ����Ч
                                                                     p_mem                => v_mem,
                                                                     p_createid           => NULL,
                                                                     p_modifyid           => NULL,
                                                                     p_createcodestr      => NULL,
                                                                     p_modifycodestr      => NULL,
                                                                     p_terminalid         => NULL,
                                                                     p_salechannelid      => NULL,
                                                                     p_createdt           => c_current_level_addr.startlifecycle, -- ����ʱ��ȡԭϵͳʱ��
                                                                     p_modifydt           => NULL,
                                                                     p_addressfullnamestr => v_addressfullnamestr);
            -- �����ַ��չ��Ϣ
            INSERT INTO addrexinfoen a
              (a.addrexinfoid_pk,
               a.addressid_pk,
               a.mem,
               a.createdt,
               a.statusid,
               a.structdt) -- ģ���źŹ�ͣ����
            VALUES
              (seq_addrexinfoen.nextval,
               v_addressid_pk,
               NULL,
               SYSDATE,
               1,
               c_current_level_addr.analogsignalstopdate);
          
            -- ���µ�ַ��starboss�еĵ�ַid
            UPDATE fsboss_places fp
               SET fp.id_in_starboss = v_addressid_pk
             WHERE fp.id = c_current_level_addr.id;
            -- ������ʱ���б�����ַ�����¼���ַ���ϼ���ַid���ϼ���ַȫ�Ʊ��룬�ϼ���ַȫ��
            UPDATE fsboss_places fp
               SET fp.parentid_in_starboss  = v_addressid_pk,
                   fp.parent_full_name_code = v_detailaddressstr,
                   fp.parent_full_name      = v_addressfullnamestr
             WHERE fp.parentid = c_current_level_addr.id;
            COMMIT;
          END;
        END LOOP;
        -- ��starboss�еĶ�Ӧ��ַid����¥���������ʱ�����Ӧ�ֶ�
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
      --����Ա
      INSERT INTO operatoren o
        (operatorid_pk,
         deptid_pk,
         operlevelid_pk, --�����ȼ�
         addressid_pk, -- �ɲ�����ַ
         raynodeeid_pk, -- ��ڵ�
         operatorcodestr,
         operatorpwdstr,
         operatornamestr,
         operatortypeid, --����Ա����
         operatorstatusid,
         startdt,
         enddt,
         mem)
      VALUES
        (v_operator_id,
         v_old_operator.starboss_operid_pk,
         1002, --��ͨ����Ա
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
      --����Ա��Ӫ������
      INSERT INTO operator_salechannelen os
      VALUES
        (v_old_operator.starboss_salechannel_id, v_operator_id, 1);
    
      --����Ա����Ӫ����
      FOR v_operarea IN operareas LOOP
        INSERT INTO operator_operareaen oo
        VALUES
          (v_operarea.operareaid_pk, v_operator_id);
      END LOOP;
      --����Ա���ɫ,��ӪҵԱ�������ɫ�Ͳֿ�
      IF v_old_operator.starboss_salechannel_id <> 1 THEN
        INSERT INTO operator_roleen
          (roleid_pk, operatorid_pk, ifgrantid)
        VALUES
          (1003, v_operator_id, 1);
        --����Ա��ֿ�
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
    CURSOR cur_servicesegment_address IS -- ��������id��ѯ���������
      SELECT a.addressid_pk, s.segmentid_pk
        FROM fsboss_areamanagesections sa, addressen a, servicesegmenten s
       WHERE a.mem = sa.managesectionid
         AND s.mem = sa.areaid;
    CURSOR cur_servicesegment_operator IS -- ��ѯ�����Ĳ���Ա
      SELECT s.segmentid_pk, o.operatorid_pk
        FROM servicesegmenten s, fsboss_areas a, operatoren o
       WHERE s.segmenttype = 1 -- ��ѯ ��Ԫ���� ���͵�����
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
        -- ����0��Ԫ
        SELECT seq_uniten.nextval INTO v_zero_unitid_pk FROM dual;
        v_result := transfer_dvb_insert_pkg.fun_insert_uniten(p_unitid_pk      => v_zero_unitid_pk,
                                                              p_unitnamestr    => 'UnitInfo',
                                                              p_unitcodestr    => 'UnitInfo',
                                                              p_unitnum        => 0,
                                                              p_addressid      => c_building.id_in_starboss,
                                                              p_subnum         => c_building.attachementnum, -- ���з�����
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
        -- ����0¥��
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
          -- ���ɵ�Ԫ
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
            -- ����¥��
            -- ¥��ֻ������һ��,ֻ���ڵ�Ԫ��Ϊ1 ��ʱ�������¥��,�������ȡ��ǰ¥��idΪ¥��id
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
              -- �洢�ײ�¥��pk,���ӷ���ʱ���Ը����ײ�pkƴ����ǰ¥��pk
              IF floornum = 1 THEN
                v_first_level_pk := v_floorid_pk;
              END IF;
            END IF;
          
            FOR murotonum IN 1 .. c_building.murotonum LOOP
              -- ���ɷ���
              SELECT seq_murotoen.nextval INTO v_murotoid_pk FROM dual;
              v_grid_code := unitnum || '-' || floornum || '-' || murotonum;
              -- ���Ҷ�Ӧ����ַ,����ҵ��򷽸����,���򲻿���
              SELECT COUNT(*)
                INTO v_count_muroto
                FROM fsboss_manageaddresses_fs fma
               WHERE fma.connectioncode = v_grid_code
                 AND fma.managesectionid = c_building.managesectionid;
            
              IF v_count_muroto > 0 THEN
                -- ���������ַ,������Ч��������������ͻ��Ĺ�ϵ
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
                -- ��β�������ַ������Ϊ��Ч
                v_isenable := 0;
              END IF;
            
              v_result := transfer_dvb_insert_pkg.fun_insert_murotoen(p_murotoid_pk    => v_murotoid_pk,
                                                                      p_murotonamestr  => v_grid_code,
                                                                      p_murotocodestr  => v_grid_code,
                                                                      p_murotonum      => murotonum,
                                                                      p_addressid      => c_building.id_in_starboss,
                                                                      p_floorid        => v_first_level_pk +
                                                                                          floornum - 1, -- ¥��Ϊ�ײ�pk�ӵ�ǰ¥��-1
                                                                      p_unitid         => v_unitid_pk, -- ��Ԫ
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
          -- �������еķ���
          SELECT seq_murotoen.nextval INTO v_murotoid_pk FROM dual;
          v_result            := transfer_dvb_insert_pkg.fun_insert_murotoen(p_murotoid_pk    => v_murotoid_pk,
                                                                             p_murotonamestr  => 'Y' || '-' ||
                                                                                                 v_count_attachement,
                                                                             p_murotocodestr  => 'Y' || '-' ||
                                                                                                 v_count_attachement,
                                                                             p_murotonum      => v_count_attachement,
                                                                             p_addressid      => c_building.id_in_starboss,
                                                                             p_floorid        => v_zero_floorid_pk, -- ¥��
                                                                             p_unitid         => v_zero_unitid_pk, -- ��Ԫ
                                                                             p_isenable       => 1,
                                                                             p_statusid       => 1,
                                                                             p_mem            => c_attachment.originalname, -- ԭ��ַ��Ϣ
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
          -- �������з�����ͻ��Ĺ�ϵ
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
  
    v_resource_code VARCHAR2(50); -- ��Դ����
  
    v_cnt     NUMBER;
    v_cnt_err NUMBER;
  
    CURSOR cur_phyresource IS
    
      SELECT ph.statusid pr_status, -- ��Դ״̬
             NULL cardcataid_pk, -- ��Ŀ¼��ʶ,ֻ����Դ�ǳ�ֵ����������
             NULL servicestr, -- ������루δ�ã�
             TRIM(ph.code) resourcecodestr, -- ��Դ����
             TRIM(ph.macaddressid) phyresourceincodestr, -- �ڲ�����
             nvl(ph.startlifecycle,
                 to_date('20000101 10:10:10', 'yyyymmdd hh24:mi:ss')) outdt, -- ����ʱ��
             NULL outpriceid, -- �����۸�
             NULL stockstr, -- ����(����)
             nvl(ph.startlifecycle,
                 to_date('20000101 10:10:10', 'yyyymmdd hh24:mi:ss')) comedt, -- ���ʱ��
             NULL pwdstr,
             nvl(ph.startlifecycle,
                 to_date('20000101 10:10:10', 'yyyymmdd hh24:mi:ss')) startdt, -- ��Ч��ʼʱ��
             nvl(ph.endlifecycle,
                 to_date('99991231 10:10:10', 'yyyymmdd hh24:mi:ss')) enddt, -- ��Ч��ֹʱ��
             1 stockitemtypeid, -- �����Ŀ���� δʹ��
             NULL countunitid, -- ������Դ������λ����ǰδʹ��
             1 countid, -- ��Դ�������������л���Դ��˵Ϊ1
             NULL containtypeid, -- ��������ǰδʹ��
             NULL validatecodestr, -- ��Դ��֤��
             ph.providerid providerid, -- ���̴���
             ph.version hardwareversionstr, -- Ӳ���汾
             NULL historyversionstr, -- ԭʼ����汾
             1 statusid, -- ��Դ״̬ ��1Ϊ��Ч
             '��˳����' mem, -- ��ע
             NULL createid,
             NULL modifyid,
             NULL createcodestr,
             NULL modifycodestr,
             NULL terminalid,
             NULL salechannelid, -- Ӫ��������ʵ�����ݿ���Ϊ null  ER�ĵ��в����ڸ��ֶ�
             nvl(ph.startlifecycle,
                 to_date('20000101 10:10:10', 'yyyymmdd hh24:mi:ss')) createdt, -- ��¼��������
             NULL modifydt,
             NULL proposetypeid, -- ö�����ͣ�������Դ����;�����������ۻ�����������
             NULL curversionstr, -- ������Դ�ĵ�ǰ����汾
             NULL clientnostr, -- ������ClientNo,ֻ�����ڻ���������Դ
             NULL isbindid, -- �Ƿ������ԣ�Ĭ�ϲ����
             NULL targetsalechannelid, -- ����Ŀ���������û���¼���⡢�����Ȳ�����Ŀ������
             NULL packagecodestr, -- ��Դ���ڵ����
             NULL specificationid_pk, -- ��Դ��������ͺ�ID������Դ����ͺű��Ӧ��
             ph.keeperid keeperid, -- �ֿ�
             ph.equiptype equiptype, --��Դ����
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
                                                                                                                                       '�ֿ�'), -- �ֿ�
                                                                     p_cardcataid_pk        => c_phyresource.cardcataid_pk,
                                                                     p_containerid_pk       => transfer_dvb_utils_pkg.fun_get_basedata(c_phyresource.keeperid,
                                                                                                                                       '��λ'), -- ��λ
                                                                     p_resourcetypeid       => c_phyresource.equiptype, -- ��Դ����
                                                                     p_resourcecataid_pk    => transfer_dvb_utils_pkg.fun_get_basedata(c_phyresource.resourcecata,
                                                                                                                                       '��ԴĿ¼'), -- ��ԴĿ¼
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
                                                                                                                                       '���״̬'), -- ���״̬,
                                                                     p_phyresourcestatusid  => transfer_dvb_utils_pkg.fun_get_basedata(c_phyresource.pr_status,
                                                                                                                                       '��Դ״̬'), -- ������Դ״̬
                                                                     p_stockitemtypeid      => c_phyresource.stockitemtypeid,
                                                                     p_countunitid          => c_phyresource.countunitid,
                                                                     p_countid              => c_phyresource.countid,
                                                                     p_containtypeid        => c_phyresource.containtypeid,
                                                                     p_thirdid              => transfer_dvb_utils_pkg.fun_get_basedata(c_phyresource.providerid,
                                                                                                                                       '��Ӧ��'), -- �������
                                                                     p_validatecodestr      => c_phyresource.validatecodestr,
                                                                     p_factorycodestr       => c_phyresource.providerid,
                                                                     p_hardwareversionstr   => c_phyresource.hardwareversionstr,
                                                                     p_historyversionstr    => c_phyresource.historyversionstr,
                                                                     p_statusid             => c_phyresource.statusid,
                                                                     p_mem                  => c_phyresource.mem, -- ͨ�����ڽ��б�ע
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
             
             -- �ͻ�������ȥ���ո�
             REPLACE(custinfo.name, ' ', '') customernamestr,
             
             custinfo.code customercodestr,
             
             -- ֤������
             custinfo.partyidentificationtypeid certificatetypeid,
             
             -- ֤������
             REPLACE(custinfo.partyidentificationno, ' ', '') certcodestr,
             
             -- ��ϵ�绰
             REPLACE(custinfo.telephoneno, ' ', '') linktelstr,
             
             -- �ƶ��绰
             REPLACE(custinfo.mobileno, ' ', '') mobilestr,
             
             -- ��ϵ��
             REPLACE(nvl(custinfo.contanctmanname, custinfo.name), ' ', '') linkmanstr, -- ��ϵ�ˣ�ȡ�ÿո�
             
             NULL zipcodestr,
             
             -- �ͻ���ϵ��ַ��ȡ ��� ϵͳ�ڵĿͻ������ĵ�ַ��Ϣ
             '����ʡ��˳��' || p.fullname || m.murotonamestr contactaddrstr,
             
             NULL detailaddrcodestr,
             
             -- ע�����ڣ�ԭϵͳ��û��ע������
             nvl(custinfo.startlifecycle,
                 to_date('20000101 10:10:10', 'yyyymmdd hh24:mi:ss')) enroldt,
             
             decode(custinfo.genderid, 202, 0, 201, 1, NULL) sexstr,
             
             NULL vacationid,
             
             NULL birthdaydt,
             
             NULL certenddt,
             NULL certregionaddrstr,
             NULL companytypestr,
             
             -- ʹ�þ�ϵͳ��ʶ ��¼SMSϵͳ�Ŀͻ�����
             TRIM(custinfo.optionalcode) oldsysid,
             
             --������
             custinfo.customerlevelid societyid,
             --��Ӫ���򣺸�˳
             custinfo.operationroleid operareaid,
             --�ͻ�״̬
             0 customerstatusid, -- ȫ����Ϊ���ǣ����������Ƿ����û����޸�
             --��������
             1 salechannelid, -- ȫ����ӦΪĬ��Ӫҵ��
             --��ϸ��ַ,���������
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
             custinfo.id userid, -- ��޿ͻ�id
             p.id_in_starboss custaddressid, -- ��ַ
             custinfo.murotoid murotoid -- �ͻ���Ӧ�����id
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
                                                                '��Ӫ����');
        SELECT seq_customeren.nextval INTO v_customerid FROM dual;
        v_result := transfer_dvb_insert_pkg.fun_insert_customeren(p_customerid_pk   => v_customerid,
                                                                  p_addressid       => v_customer.custaddressid,
                                                                  p_customerid_fk   => v_customer.customerid_fk,
                                                                  p_customernamestr => v_customer.customernamestr,
                                                                  p_customercodestr => v_customer.customercodestr, -- �ͻ�����
                                                                  p_custtypeid      => v_customer.customertypeid, -- �ͻ�����
                                                                  
                                                                  p_certificatetypeid => transfer_dvb_utils_pkg.fun_get_basedata(v_customer.certificatetypeid,
                                                                                                                                 '֤������'), -- ֤������,
                                                                  p_certcodestr       => v_customer.certcodestr, -- ֤������
                                                                  p_linktelstr        => v_customer.mobilestr,-- ���ֻ���Ϊ��ϵ�绰 v_customer.linktelstr, -- ��ϵ�绰
                                                                  p_mobilestr         => v_customer.mobilestr, -- �ֻ�
                                                                  p_customeraddrstr   => v_customer.customeraddrstr, -- ��ϸ��ַ
                                                                  p_customerstatusid  => v_customer.customerstatusid, -- �ͻ�״̬
                                                                  p_linkmanstr        => v_customer.linkmanstr, -- ��ϵ��
                                                                  p_zipcodestr        => v_customer.zipcodestr,
                                                                  p_contactaddrstr    => v_customer.contactaddrstr, -- ��ϵ��ַ
                                                                  p_detailaddrcodestr => v_customer.detailaddrcodestr,
                                                                  p_pwdstr            => transfer_dvb_utils_pkg.cust_pwd,
                                                                  p_enroldt           => v_customer.enroldt,
                                                                  p_salechannelid1    => v_customer.salechannelid, --��������
                                                                  p_sexstr            => v_customer.sexstr,
                                                                  p_vacationid        => v_customer.vacationid,
                                                                  p_birthdaydt        => v_customer.birthdaydt,
                                                                  p_societyid         => transfer_dvb_utils_pkg.fun_get_basedata(v_customer.societyid,
                                                                                                                                 '������'), -- ������
                                                                  p_certenddt         => v_customer.certenddt,
                                                                  p_certregionaddrstr => v_customer.certregionaddrstr,
                                                                  p_companytypestr    => v_customer.companytypestr,
                                                                  p_oldsysid          => v_customer.oldsysid,
                                                                  p_emailstr          => v_customer.emailstr,
                                                                  p_faxcodestr        => v_customer.faxcodestr,
                                                                  p_companyaddrstr    => v_customer.companyaddrstr,
                                                                  p_companynetaddrstr => v_customer.companynetaddrstr,
                                                                  p_customerlevelid   => 1023, -- �ͻ����� Ĭ����ͨ�ͻ�
                                                                  p_vipstr            => v_customer.vipstr,
                                                                  p_logoffreasonid    => v_customer.logoffreasonid,
                                                                  p_logoffdt          => v_customer.logoffdt,
                                                                  p_restorereasonid   => v_customer.restorereasonid,
                                                                  p_restoredt         => v_customer.restoredt,
                                                                  p_vodflagid         => v_customer.vodflagid,
                                                                  p_mem               => v_customer.mem,
                                                                  p_createid          => 2, -- ��������Ա�������պ�ͳ��
                                                                  p_modifyid          => v_customer.modifyid,
                                                                  p_createcodestr     => 'Import',
                                                                  p_modifycodestr     => v_customer.modifycodestr,
                                                                  p_terminalid        => v_customer.terminalid,
                                                                  p_salechannelid     => v_customer.salechannelid,
                                                                  p_createdt          => v_customer.createdt,
                                                                  p_modifydt          => v_customer.modifydt,
                                                                  p_operareaid        => v_operareaid, -- ��Ӫ����
                                                                  p_addinfostr2       => '��˳����',
                                                                  p_addinfostr1       => NULL,
                                                                  p_addinfostr3       => v_customer.userid, -- ���ϵͳ�ͻ�PK
                                                                  p_addinfostr4       => v_customer.mem,
                                                                  p_encryptpwdstr     => transfer_dvb_utils_pkg.cust_pwd);
        -- Ϊ�ͻ������˻�
        SELECT seq_accounten.nextval INTO v_accountid_pk FROM dual;
        v_result := transfer_dvb_insert_pkg.fun_insert_accounten(p_accountid_pk   => v_accountid_pk, -- �˻�PK
                                                                 p_customerid_pk  => v_customerid, -- �ͻ�PK
                                                                 p_accountcodestr => lpad(v_accountid_pk,
                                                                                          12,
                                                                                          '0'), -- �˻����룬�˻�PK ��λ 0���ܳ� 12λ
                                                                 -- �˻����ƣ��ͻ����� + ҵ�����ƣ���Ҫ����ϵͳ�������趨��ȷ���Ƿ�Ϊ�ĸ�ҵ�񴴽��˻���
                                                                 p_accountnamestr => v_customer.customernamestr ||
                                                                                     '-����ҵ���ʻ�',
                                                                 p_isdefaultid    => 1, -- �Ƿ�Ĭ���ʻ���������
                                                                 p_postwayid      => 0, -- �˵��ʼķ�ʽ����ͨ�ʼ�
                                                                 p_postaddrstr    => v_customer.contactaddrstr, -- �ʼĵ�ַ���ͻ���ϵ��ַ
                                                                 p_zipcodestr     => NULL,
                                                                 p_logoffreasonid => NULL,
                                                                 p_businessid     => 0, --����ҵ�񣺹���ҵ�񣬿��Դ���������˱�������֧�ֶ�ҵ��
                                                                 p_statusid       => 1, -- ״̬����Ч
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
                                                                 p_operareaid     => v_operareaid); -- ��Ӫ����
      
        -- ��������˱�
        SELECT seq_acctbooken.nextval INTO v_acctbookid_pk FROM dual;
        v_result := transfer_dvb_insert_pkg.fun_insert_acctbooken(p_acctbookid_pk    => v_acctbookid_pk,
                                                                  p_balancetypeid_pk => 0,
                                                                  p_acctbooknamestr  => v_customer.customernamestr ||
                                                                                        '-����ҵ���ʻ���ͨԤ������',
                                                                  p_acctbookcodestr  => lpad(v_acctbookid_pk,
                                                                                             12,
                                                                                             '0') || '0',
                                                                  p_startdt          => v_customer.createdt,
                                                                  p_enddt            => NULL,
                                                                  p_balanceid        => 0, -- ���
                                                                  p_cycle_upperid    => 0, -- �۷���߶�
                                                                  p_cycle_lowerid    => 0, -- �۷���Ͷ�
                                                                  p_statusid         => 1, -- ״̬ ��Ч
                                                                  p_mem              => NULL,
                                                                  p_createid         => v_customer.createid,
                                                                  p_modifyid         => v_customer.modifyid,
                                                                  p_createcodestr    => NULL,
                                                                  p_modifycodestr    => NULL,
                                                                  p_terminalid       => NULL,
                                                                  p_salechannelid    => NULL,
                                                                  p_createdt         => v_customer.createdt,
                                                                  p_salechannelid1   => NULL,
                                                                  p_operareaid       => NULL, -- ��Ӫ����
                                                                  p_modifydt         => v_customer.modifydt,
                                                                  p_deductpriid      => 0, -- �ۿ����ȼ� 0 Ϊ���
                                                                  p_customerid       => v_customerid, -- �ͻ���ʶ
                                                                  p_objtypeid        => 1, -- ����������  1���˻�
                                                                  p_objid            => v_accountid_pk); -- �ʻ�PK��������
      
        -- ����֧������
        SELECT seq_payprojecten.nextval INTO v_payprojectid_pk FROM dual;
      
        v_result := transfer_dvb_insert_pkg.fun_insert_payprojecten(p_payprojectid_pk    => v_payprojectid_pk,
                                                                    p_paymethodid_pk     => 111, -- ��������  �ֽ�
                                                                    p_acctbookid_pk      => v_acctbookid_pk, -- ����˱�PK
                                                                    p_accountid_pk       => v_accountid_pk, -- �˻�PK
                                                                    p_paytypeid          => 1, -- ���ѷ�ʽ
                                                                    p_priid              => 0, -- ���ȼ�
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
                                                                    p_operareaid         => NULL, -- ��Ӫ����
                                                                    p_statusid           => 1);
        -- �����������ϵ
        SELECT seq_acctbalanceobjen.nextval
          INTO v_accbalanceobjid_pk
          FROM dual;
      
        v_result := transfer_dvb_insert_pkg.fun_insert_acctbalanceobjen(p_accbalanceobjid_pk => v_accbalanceobjid_pk,
                                                                        p_acctbookid_pk      => v_acctbookid_pk, -- ����˱�PK
                                                                        p_objtypeid          => 1, -- ����˱��������ʻ���1
                                                                        p_objid              => v_accountid_pk, -- �˻�PK
                                                                        p_mem                => NULL,
                                                                        p_createid           => v_customer.createid,
                                                                        p_modifyid           => v_customer.modifyid,
                                                                        p_createcodestr      => NULL,
                                                                        p_modifycodestr      => NULL,
                                                                        p_terminalid         => NULL,
                                                                        p_salechannelid      => NULL,
                                                                        p_createdt           => v_customer.createdt,
                                                                        p_salechannelid1     => NULL,
                                                                        p_operareaid         => NULL, -- ��Ӫ����
                                                                        p_modifydt           => v_customer.modifyid,
                                                                        p_statusid           => 1);
        -- �����ͻ��뷽��Ĺ�ϵ
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
             111 paymethodid_pk, --ǰ̨�ֽ�
             c.customerid_pk customerid_pk,
             0 tradetypeid, --0 ���1 ���˿�
             0 paymentstatusid, --0 �����ɣ�1�ѷ���
             dp.amount amountid,
             dp.startlifecycle paymentdt,
             0 ifcheckid, --1�Ѷ��ˣ�0δ����
             1 ifproofid, --���ʱ�־��Ĭ��Ϊ0
             0 ifchargeid,
             '����-�տ���:' || dp.employee_name mem,
             dp.startlifecycle createdt,
             dp.organizationunit_id salechannelid1,
             1 operareaid,
             dp.pricetypeid rateclasstype --��Ŀ����
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
                                                                                                                                  'Ӫ������'),
                                                                 p_operareaid          => v_payments.operareaid,
                                                                 p_resourceid_pk       => NULL,
                                                                 p_developid           => NULL);
      
        SELECT seq_depositrecorden.nextval INTO v_deposit_pk FROM dual;
      
        v_result := transfer_dvb_insert_pkg.fun_insert_depositrecorden(p_depositrecordid_pk => v_deposit_pk,
                                                                       p_noteid_pk          => NULL,
                                                                       p_customerid_pk      => v_payments.customerid_pk,
                                                                       p_rateclasstypeid    => transfer_dvb_utils_pkg.fun_get_basedata(v_payments.rateclasstype,
                                                                                                                                       'Ѻ����Ŀ'),
                                                                       p_depositamountid    => v_payments.amountid,
                                                                       p_paymentid          => v_paymenten_pk,
                                                                       p_statusid           => 0, -- 0 ��Ч��1 ����
                                                                       p_operatetypeid      => 0, -- 0�շѣ�1�˷�
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
                                                                                                                                       'Ӫ������'),
                                                                       
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
    v_sub_status       NUMBER; -- �û�״̬
    v_laststopdt       DATE; -- �ϴ���ͣʱ��
    v_laststopstatusid NUMBER;
    v_salechannelid    NUMBER;
    v_mr_salechannelid NUMBER; -- Ӫҵ��
    v_mr_createcodestr VARCHAR2(10);
    v_mr_createid      NUMBER;
    v_subscribertypeid NUMBER; -- �û�����
    v_result           NUMBER(1);
    sql_code           VARCHAR2(50);
    sql_errm           VARCHAR2(1000);
    CURSOR c_subscriber IS
    
      SELECT s.startlifecycle createdt, -- ��������
             s.statuschangedate modifydt,
             cus.operareaid operareaid, -- ��Ӫ����
             1 urgencypaysignid, -- �Ƿ�߽�   0 ��ʾ ȡ���߽� 1 ��ʾ�߽�
             1 stopsignid, -- �Ƿ�ͣ��   0 ��ʾ ȡ��ͣ�� 1 ��ʾͣ��
             NULL parentid_fk, -- �ϼ��û���ʶ
             NULL subscriberid_pk, -- �û���ʶ
             1 invoicecyctypeid_pk, -- �����������ͱ�ʶ  1���£�  ȡ�ԣ�Invoicecyctypeen
             cus.customerid_pk customerid_pk, -- �ͻ�PK
             s.type_of_service businessid, -- ҵ��PK  ģ��ҵ��
             s.servicestr servicestr, -- ������루�ص㣩
             cus.customerid_pk usedcustomerid, -- ʹ�ÿͻ���ʶ
             (SELECT ac.accountid_pk
                FROM accounten ac
               WHERE ac.customerid_pk = cus.customerid_pk) defaultaccountid, -- Ĭ���ʻ�PK
             cus.customeraddrstr setupaddrstr, -- ��װ��ַ��ȡ �ͻ�����ϵ��ַ
             cus.addressid setupaddrcodeid, -- ��װ��ַ���룬ȡ�ͻ��ĵ�ַPK
             NULL detailaddrcodestr, -- ��ϸ��ַ����
             s.startlifecycle endworkdt, -- ����ʱ��
             NULL pwdstr,
             s.startlifecycle startdt, -- ��Ч��ʼʱ��
             NULL enddt,
             NULL contractid,
             NULL ifcontractid,
             NULL operatorid,
             NULL orderlevelid,
             0 iscdmuserflag,
             NULL preoperitemid,
             NULL prestatusid,
             s.statusid subscriber_status, -- �û�״̬״̬
             NULL laststartdt,
             1 operwayid,
             s.mem mem, -- ��ע
             NULL createid,
             NULL modifyid,
             NULL createcodestr,
             NULL modifycodestr,
             NULL terminalid,
             s.masterid addinfostr1, --��¼terminals_fs���ϼ��û���־
             cus.societyid addinfostr2, -- �������������ڲ�ѯ �۸�ƻ�
             s.organizationunit_id addinfostr3, --ͨ����޲���Ա���ڲ��Ż�ȡ�û���Ӫ������
             s.startvalidfor activedt, -- ��������
             NULL equ_type, -- ��Դ����
             s.statuschangedate lastchangedate, -- �ϴ�ͣ��ʱ��
             s.endvalidfor laststopdate, --���ϵͳ�д��ڵ�����ͣ�������˿ͻ���ͣ���ϴ���ͣʱ�䱣��Ϊ��Ʒ�ļƷѽ�ֹ����
             s.seqstr seqstr, -- �ն˱��
             NULL servid, -- ����PK
             s.authenticationtypeid authenticationtypeid, -- ��֤����
             s.equiptypeid equiptypeid,
             cus.oldsysid oldsysid, -- ��ϵͳ��ʶ
             s.terminalid addinfo4, -- ���ϵͳ���ն�id
             s.accesspointid accesspointid, --���ֵ����û�������־
             s.subscriber_tpye subscriber_tpye -- �û�����
        FROM customeren        cus, -- BOSS �ͻ���
             fsboss_subscriber s,
             fsboss_customer   c
       WHERE cus.addinfostr3 = s.customerid
         AND s.customerid = c.id;
  BEGIN
    v_cnt              := 0;
    v_cnt_err          := 0;
    v_mr_salechannelid := transfer_dvb_utils_pkg.fun_get_basedata('default',
                                                                  'Ĭ��Ӫ������');
    v_mr_createcodestr := transfer_dvb_utils_pkg.fun_get_basedata('default',
                                                                  'Ĭ�ϲ���Ա����');
    v_mr_createid      := transfer_dvb_utils_pkg.fun_get_basedata('default',
                                                                  'Ĭ�ϲ���ԱPK');
    FOR v_subscriber IN c_subscriber LOOP
    
      BEGIN
      
        -- Ӫ��������ͨ���û�PK��Ӧ�Ĳ���Ա���Ҷ�Ӧ��Ӫ������
        v_salechannelid := transfer_dvb_utils_pkg.fun_get_basedata(v_subscriber.addinfostr3,
                                                                   'Ӫ������');
        IF (v_salechannelid = 0) THEN
          -- ���û�в鵽��Ӧ��Ӫ����������ȡĬ�� Ӫ������
          v_salechannelid := v_mr_salechannelid;
        END IF;
      
        -- ȷ���û�����
      
        v_subscribertypeid := transfer_dvb_utils_pkg.fun_get_basedata(v_subscriber.subscriber_tpye,
                                                                      '�û�����');
        -- ��ʼ���ϴ�ͣ��״̬
        v_laststopstatusid := NULL;
        -- ƥ�������û�״̬
        IF (v_subscriber.businessid = 2) THEN
          v_sub_status := transfer_dvb_utils_pkg.fun_get_basedata(v_subscriber.subscriber_status,
                                                                  '�û�״̬');
        
          -- ��������ֵ���ҵ��ķ�ͣ����ͣ����ȡԭϵͳ�еļƷѽ�ֹ����
          IF (v_sub_status = 2 AND v_subscriber.businessid = 2) THEN
            v_laststopstatusid := v_sub_status;
            v_laststopdt       := v_subscriber.laststopdate;
          END IF;
        
          -- ��������ֵ���ҵ�����ͣ������ͣ����ȡԭϵͳ�е�״̬�������
          IF (v_sub_status = 1 AND v_subscriber.businessid = 2) THEN
            v_laststopstatusid := v_sub_status;
            v_laststopdt       := v_subscriber.lastchangedate;
          END IF;
          -- ƥ�����û�״̬
        ELSIF (v_subscriber.businessid = 3) THEN
        
          --��ޱ����������û�
          --CASE WHEN pt.Code IN ('3601', '3602') and pd.endvalidfor >= sysdate THEN 1 ELSE 0 END) normal_count,
          IF ((v_subscriber.subscriber_status = 3601 OR
             v_subscriber.subscriber_status = 3602) AND -- ״̬Ϊ������δ��ͨ
             v_subscriber.laststopdate >= SYSDATE) THEN
            v_sub_status       := 0; --��Ч;
            v_laststopstatusid := NULL;
            v_laststopdt       := NULL;
          END IF;
          --CASE WHEN pt.Code IN ('3605', '3609', '3612') or pt.code = '3602' and pd.endvalidfor < sysdate THEN 1 ELSE 0 END) exp_count
          --��ޱ����������û�
          IF ((v_subscriber.subscriber_status = 3612 OR
             v_subscriber.subscriber_status = 3605) OR
             (v_subscriber.subscriber_status = 3602 AND
             v_subscriber.laststopdate < SYSDATE)) THEN
            v_sub_status       := 0;
            v_laststopstatusid := NULL;
            v_laststopdt       := NULL;
          END IF;
        
          --��ޱ�������ͣ�û�
          --SUM(CASE WHEN pt.Code IN ('3604') THEN 1 ELSE 0 END) SUSPENDED_count
          IF (v_subscriber.subscriber_status = 3604) THEN
            v_sub_status       := 1;
            v_laststopstatusid := 1;
            v_laststopdt       := v_subscriber.lastchangedate;
          END IF;
        
        ELSIF (v_subscriber.businessid = 1) THEN
        
          --��ޱ���ģ������
          -- SUM(CASE WHEN pt.Code IN ('3601', '3602')   THEN 1 ELSE 0 END) normal_count,
          IF (v_subscriber.subscriber_status = 3601 OR
             v_subscriber.subscriber_status = 3602) THEN
            v_sub_status       := 0; --��Ч
            v_laststopstatusid := NULL;
            v_laststopdt       := NULL;
          END IF;
        
          --��ޱ���ģ�����
          --SUM(CASE WHEN pt.Code IN ('3605', '3609', '3612')   THEN 1 ELSE 0 END) exp_count,
          IF (v_subscriber.subscriber_status = 3605 OR
             v_subscriber.subscriber_status = 3612) THEN
            v_sub_status       := 2; --��Ч
            v_laststopstatusid := 2;
            v_laststopdt       := v_subscriber.lastchangedate;
          END IF;
        
          --��ޱ���ģ����ͣ
          --SUM(CASE WHEN pt.Code IN ('3604') THEN 1 ELSE 0 END) SUSPENDED_count,
        
          IF (v_subscriber.subscriber_status = 3604) THEN
            v_sub_status       := 1; --��Ч
            v_laststopstatusid := 1;
            v_laststopdt       := v_subscriber.lastchangedate;
          END IF;
        END IF;
        -- ����û�״̬Ϊ ��ͣ�������ն˺�Ϊ ���ˣ�����Ҫ���û�״̬����Ϊ ��ͣ
        IF (v_sub_status = 2 AND v_subscriber.seqstr > 1) THEN
          v_sub_status := 1;
        END IF;
      
        SELECT seq_subscriberen.nextval INTO v_subscriberid_pk FROM dual;
      
        v_result := transfer_dvb_insert_pkg.fun_insert_subscriberen(
                                                                    
                                                                    p_createdt                => v_subscriber.createdt,
                                                                    p_modifydt                => v_subscriber.modifydt, --Ӧ�ñȽϱ�ͣ��ͨ��¼�õ��������������
                                                                    p_salechannelid1          => v_salechannelid, --Ӫ������,
                                                                    p_operareaid              => v_subscriber.operareaid,
                                                                    p_urgencypaysignid        => v_subscriber.urgencypaysignid,
                                                                    p_stopsignid              => v_subscriber.stopsignid,
                                                                    p_parentid_fk             => v_subscriber.parentid_fk,
                                                                    p_subscriberid_pk         => v_subscriberid_pk,
                                                                    p_invoicecyctypeid_pk     => v_subscriber.invoicecyctypeid_pk,
                                                                    p_customerid_pk           => v_subscriber.customerid_pk,
                                                                    p_businessid              => v_subscriber.businessid,
                                                                    p_servicestr              => v_subscriber.servicestr, -- �������
                                                                    p_usedcustomerid          => v_subscriber.usedcustomerid,
                                                                    p_defaultaccountid        => v_subscriber.defaultaccountid,
                                                                    p_setupaddrstr            => v_subscriber.setupaddrstr,
                                                                    p_setupaddrcodeid         => v_subscriber.setupaddrcodeid,
                                                                    p_subscriberseqstr        => v_subscriber.seqstr, --�ն˺�
                                                                    p_detailaddrcodestr       => v_subscriber.detailaddrcodestr,
                                                                    p_endworkdt               => v_subscriber.endworkdt,
                                                                    p_subscribertypeid        => v_subscribertypeid,
                                                                    p_pwdstr                  => '123456', -- default '123456'
                                                                    p_startdt                 => v_subscriber.startdt, --ͬ��������
                                                                    p_enddt                   => v_subscriber.enddt,
                                                                    p_contractid              => v_subscriber.contractid,
                                                                    p_ifcontractid            => v_subscriber.ifcontractid,
                                                                    p_operatorid              => v_subscriber.operatorid,
                                                                    p_salechannelid2          => v_salechannelid, --Ĭ��Ӫ������
                                                                    p_orderlevelid            => v_subscriber.orderlevelid,
                                                                    p_equiptypeid             => v_subscriber.equiptypeid, -- ��ͨ�豸
                                                                    p_iscdmuserflag           => v_subscriber.iscdmuserflag,
                                                                    p_preoperitemid           => v_subscriber.preoperitemid,
                                                                    p_prestatusid             => v_subscriber.prestatusid,
                                                                    p_laststopdt              => v_laststopdt, -- �ϴ���ͣʱ��
                                                                    p_laststartdt             => v_subscriber.laststartdt,
                                                                    p_laststopstatusid        => v_laststopstatusid, -- ���ͣ��״̬
                                                                    p_operwayid               => v_subscriber.operwayid,
                                                                    p_statusid                => v_sub_status, -- �û�״̬
                                                                    p_mem                     => v_subscriber.mem,
                                                                    p_createid                => v_mr_createid,
                                                                    p_modifyid                => v_subscriber.modifyid,
                                                                    p_createcodestr           => v_mr_createcodestr,
                                                                    p_modifycodestr           => v_subscriber.modifycodestr,
                                                                    p_terminalid              => v_subscriber.terminalid,
                                                                    p_salechannelid           => v_salechannelid, -- Ĭ��Ӫ������
                                                                    p_addinfostr2             => v_subscriber.addinfostr2,
                                                                    p_addinfostr3             => v_subscriber.addinfostr3, -- ԭϵͳ����Ա���ڲ���
                                                                    p_activedt                => v_subscriber.activedt,
                                                                    p_authenticationtypeid_pk => v_subscriber.authenticationtypeid, -- ��֤����
                                                                    p_accesspointid           => v_subscriber.accesspointid, -- �����
                                                                    p_addinfostr4             => v_subscriber.addinfo4); -- ԭϵͳ����Ա���ڲ���);
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
    -- ��������Ч����ͣ����ͣ�û��Ŀͻ���Ϊ����
    UPDATE customeren c
       SET c.customerstatusid = 1
     WHERE EXISTS (SELECT 'x'
              FROM subscriberen s
             WHERE s.customerid_pk = c.customerid_pk
               AND s.statusid IN (0, 1, 2));
  
    COMMIT;
  -- ��������ҵ��ͨ��¼ ����ȷ����
    INSERT INTO dabopenstatusen dd
      SELECT seq_dabopenstatusen.nextval,
             s.servicestr,
             0, -- �Ѿ�����
             s.subscriberid_pk,
             SYSDATE,
             NULL,
             7, -- ��ͨ�豸 
             seq_dabopenstatusen.currval,
             NULL,
             'OPEN_ACCOUNT'
        FROM subscriberen s
       WHERE s.businessid = 3
         AND s.subscribertypeid = 1083
         AND s.statusid <> 3;
    COMMIT;
    
    -- ����vodҵ��ͨ��¼ ����ȷ����
  
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
      SELECT seq_logicresourceen.nextval, -- �߼���Դ��ʶ
             7, -- ��Դ���ͱ�ʶ 7����֤��Դ
             1, -- �߼���Դ���� 1����֤��Դ
             s.servicestr, -- ��֤����
             decode(s.statusid,
                    0,
                    2, -- ״̬
                    1,
                    2,
                    2,
                    2),
             s.createid,
             s.createcodestr,
             s.createdt, -- ��������
             '��˳����' || to_char(SYSDATE, 'yyyymmdd')
        FROM subscriberen s
       WHERE s.businessid = 3 -- ����ҵ��/*
         AND s.authenticationtypeid_pk = 3 -- ��֤���� = Radius��֤  */
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
    
      SELECT pi.rescode rescode, -- ������Դ����
             s.subscriberid_pk subscriberid_pk, -- �û�PK
             NULL packageinstanceid_pk,
             NULL operwayid,
             NULL invoicecycid,
             1 productchildtypeid, -- ��Ʒ����  1�������Ʒ
             1 salewayid, -- ���۷�ʽ 1������
             NULL componentid,
             NULL packageid,
             s.endworkdt subscriberstartdt, -- �Ʒѿ�ʼ���ڣ�ȡSMS��¼�Ĵ���ʱ��
             NULL subscriberenddt,
             1 billingflag, -- ��Ʒ�Ƿ�Ʒ� 0���Ʒ�
             NULL iffullmonthid,
             0 statusid, -- ״̬����Ч
             s.endworkdt rundt, -- ��ͨ���ڣ�ͬ �Ʒѿ�ʼ����
             NULL enddt, -- �Ʒѽ�ֹ���ڣ�null ��
             pi.mem mem,
             NULL createid,
             NULL modifyid,
             NULL createcodestr,
             NULL modifycodestr,
             NULL terminalid,
             s.endworkdt createdt,
             NULL modifydt,
             s.operareaid operareaid, -- ��Ӫ����
             NULL contractid_pk,
             0 autocontinue, -- �Ƿ��Զ������� �������ƷĬ��Ϊ 0�����Զ�����  ϵͳĿǰĬ���� 1
             NULL serviceenddt,
             s.endworkdt finishdt, -- ����ʱ��
             NULL preinstanceid,
             NULL packagetypeid,
             pi.resourcespecificationid resourcespecificationid, --���ϵͳ����ԴĿ¼
             NULL isunifiedcancelid,
             s.customerid_pk customerid_pk,
             pi.equ_type equ_type, -- ��Դ����
             s.salechannelid1 salechannel, -- Ӫ������
             pi.productofferingid productid, --���ϵͳ�������ƷID
             pi.marketingplanid marketingplanid, --���ϵͳ��Ӫ���ƻ���ʶ
             decode(s.subscriberseqstr, 1, 1, 2) ismain --�Ƿ����ն�
        FROM subscriberen s, fsboss_phy_instance pi
       WHERE s.addinfostr4 = pi.terminalid;
  BEGIN
  
    v_cnt     := 0;
    v_cnt_err := 0;
  
    FOR c_instance IN cur_instance LOOP
      BEGIN
      
        -- ��ͨ�豸
        v_equipt_type := NULL;
        IF (c_instance.equ_type = 1) THEN
          v_equipt_type := 202; --���ܿ��Ŀ�ͨ�豸���ͣ�202 ͬ��
        END IF;
        --�����Eoc�豸����ͨ����ԴĿ¼ȷ�����Ӧ���Ĵ�boss�еĲ�Ʒ
        IF c_instance.equ_type = 9 THEN
          v_productid   := transfer_dvb_utils_pkg.fun_get_basedata(c_instance.resourcespecificationid,
                                                                   '�����ƷPK');
          v_priceplanid := transfer_dvb_utils_pkg.fun_get_basedata(c_instance.resourcespecificationid,
                                                                   '�����Ʒ�۸�ƻ�PK');
        ELSE
          v_productid   := transfer_dvb_utils_pkg.fun_get_basedata(c_instance.ismain ||
                                                                   c_instance.productid,
                                                                   '�����ƷPK');
          v_priceplanid := transfer_dvb_utils_pkg.fun_get_basedata(c_instance.ismain ||
                                                                   c_instance.productid,
                                                                   '�����Ʒ�۸�ƻ�PK');
        END IF;
      
        SELECT seq_instanceen.nextval INTO v_instanceid_pk FROM dual;
        v_result := transfer_dvb_insert_pkg.fun_insert_instanceen(
                                                                  
                                                                  p_instanceid_pk        => v_instanceid_pk, -- ��Ʒʵ��PK
                                                                  p_subscriberid_pk      => c_instance.subscriberid_pk, -- �û�PK
                                                                  p_packageinstanceid_pk => c_instance.packageinstanceid_pk, -- �ײͲ�Ʒʵ����ʶ
                                                                  p_operwayid            => c_instance.operwayid, -- ��Ӫ��ʽ
                                                                  p_productid            => v_productid, -- ��ƷID
                                                                  p_invoicecycid         => c_instance.invoicecycid, -- �������ڱ�ʶ null
                                                                  p_productchildtypeid   => c_instance.productchildtypeid, -- ��Ʒ���ࣺ�����Ʒ
                                                                  p_salewayid            => c_instance.salewayid, -- ���۷�ʽ��1  ����
                                                                  p_componentid          => c_instance.componentid, -- ����ʶ
                                                                  p_packageid            => c_instance.packageid, -- �ײͱ�ʶ
                                                                  p_subscriberstartdt    => c_instance.subscriberstartdt, -- �Ʒѿ�ʼ����
                                                                  p_subscriberenddt      => c_instance.subscriberenddt, -- ȡ������ʱ�� null
                                                                  p_billingflag          => c_instance.billingflag, -- �Ʒѱ�ʶ���Ƿ�Ʒ�  0���Ʒ�
                                                                  p_iffullmonthid        => c_instance.iffullmonthid, -- �Ƿ�ͳһ�˶�
                                                                  p_statusid             => c_instance.statusid, -- ״̬��0 ��Ч
                                                                  p_rundt                => c_instance.rundt, -- ��ͨʱ��
                                                                  p_enddt                => c_instance.enddt, -- �Ʒѽ�ֹʱ��
                                                                  p_mem                  => c_instance.mem, -- ����ԭ�ȵ�v_resourcecode
                                                                  p_createid             => c_instance.createid,
                                                                  p_modifyid             => c_instance.modifyid,
                                                                  p_createcodestr        => c_instance.createcodestr,
                                                                  p_modifycodestr        => c_instance.modifycodestr,
                                                                  p_terminalid           => c_instance.terminalid,
                                                                  p_salechannelid        => c_instance.salechannel,
                                                                  p_createdt             => c_instance.createdt, -- ����ʱ��
                                                                  p_modifydt             => c_instance.modifydt,
                                                                  p_salechannelid1       => c_instance.salechannel,
                                                                  p_operareaid           => c_instance.operareaid, -- ��Ӫ���� null
                                                                  p_contractid_pk        => c_instance.contractid_pk, -- ��ͬ��ʶ null
                                                                  p_autocontinue         => c_instance.autocontinue, -- �Զ�������ʶ 0����������
                                                                  p_serviceenddt         => NULL, -- ����ͣ������
                                                                  p_finishdt             => c_instance.finishdt, -- ����ʱ��
                                                                  p_preinstanceid        => c_instance.preinstanceid,
                                                                  p_packagetypeid        => c_instance.packagetypeid,
                                                                  p_isunifiedcancelid    => c_instance.isunifiedcancelid,
                                                                  p_customerid_pk        => c_instance.customerid_pk -- �ͻ�PK
                                                                  );
      
        SELECT seq_subscriberaddonen.nextval
          INTO v_subscriberaddonid_pk
          FROM dual;
      
        -- ͨ����Դ�������Դ����ȡ�ö�Ӧ��������Դ��ʶ
        IF c_instance.rescode IS NOT NULL THEN
          v_resourceid := transfer_dvb_utils_pkg.fun_get_resourceid_by_rescode(p_rescode => c_instance.rescode,
                                                                               p_restype => c_instance.equ_type);
        END IF;
      
        v_result := transfer_dvb_insert_pkg.fun_insert_subscriberaddonen(p_subscriberaddonid_pk => v_subscriberaddonid_pk,
                                                                         p_subscriberid_pk      => c_instance.subscriberid_pk, -- �û���ʶ
                                                                         p_resourceid           => v_resourceid, -- ��Դ��ʶ
                                                                         p_resourcecodestr      => c_instance.rescode, -- ��Դ����
                                                                         p_equiptypeid          => v_equipt_type, -- �豸����
                                                                         p_startdt              => c_instance.subscriberstartdt, -- ��Ч��ʼʱ��
                                                                         p_enddt                => c_instance.enddt, -- ��Ч��ֹʱ�� null
                                                                         p_statusid             => 1, -- ״̬
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
                                                                         p_operareaid           => c_instance.operareaid, -- ��Ӫ����
                                                                         p_instanceid_pk        => v_instanceid_pk); -- ��Ʒʵ����ʶ
      
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
                                                p_comments => '�û�pk:' ||
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
      SELECT s.subscriberid_pk subscriberid_pk, -- �û�PK
             NULL packageinstanceid_pk,
             NULL operwayid, -- ��Ӫ��ʽ ����
             fsi.serviceproduct_id serviceproduct_id, -- ��ƷPK
             NULL invoicecycid, -- �������� ����
             2 productchildtypeid, -- ��Ʒ���� 2�������Ʒ
             1 salewayid, -- ���۷�ʽ
             NULL componentid,
             NULL packageid,
             fsi.subscriberstartdt subscriberstartdt, -- �Ʒѿ�ʼ����
             NULL subscriberenddt, -- ȡ����������  ����
             NULL iffullmonthid, -- �Ƿ�����  ����
             fsi.rundt rundt, -- ��ͨ����
             fsi.enddt enddt, -- �Ʒѽ�ֹ����
             fsi.mem mem, -- ȡ���ײ�������Ϊ��ע
             NULL createid,
             NULL modifyid,
             NULL createcodestr,
             NULL modifycodestr,
             NULL terminalid,
             fsi.createdt createdt,
             NULL modifydt,
             s.operareaid operareaid,
             NULL contractid_pk,
             s.laststopdt laststopdt, -- ����ͣ�����ڣ�ȡ �����е� ���ͣ������
             fsi.finishdt finishdt, -- �������ڣ�ȡ��Ʒ�ļƷѿ�ʼ����
             s.customerid_pk customerid_pk,
             decode(s.statusid, 0, 1, 2) service_ins_status, -- ����ʵ����״̬���û�״̬Ϊ 0(��Ч) --> 1����Ч  ����Ϊ 2����ͣ
             c.societyid societyid, -- ������
             s.subscriberseqstr seqid, -- �ն˺�
             s.salechannelid1 salechannel, -- Ӫ������
             fsi.oldproname oldproname, -- ԭϵͳ��Ʒ����
             fsi.export_pro_type export_pro_type, -- �����ò�Ʒ����
             c.custtypeid custtypeid, --�ͻ����� 0 ���ˣ�1����
             s.statusid substatusid, --�û�״̬
             fsi.terminalid hugeterminalid
        FROM subscriberen        s, -- �û���
             customeren          c, --�ͻ���
             fsboss_ser_instance fsi -- �����Ʒʵ����ʱ��
       WHERE c.customerid_pk = s.customerid_pk
         AND fsi.terminalid = s.addinfostr4;
  
    -- ȡ��ĳһ����Ʒ�����ķ���PK
    CURSOR cur_service(p_productid NUMBER) IS
      SELECT sp.serviceid_pk serviceid_pk
        FROM service_producten sp
       WHERE sp.productid_pk = p_productid;
  
  BEGIN
  
    v_cnt     := 0;
    v_cnt_err := 0;
    FOR c_instance IN cur_instance LOOP
      BEGIN
      
        -- ȡ��������
        v_societyid  := c_instance.societyid; --������
        v_operareaid := c_instance.operareaid; --��Ӫ����
        --��ȡ�����Ʒ��Ӧ���²�Ʒpk
        v_productid_pk := transfer_dvb_utils_pkg.fun_get_basedata(c_instance.serviceproduct_id,
                                                                  '�����ƷPK');
        v_billingflag  := 0; -- Ĭ��0
        -- ������
        IF c_instance.export_pro_type = 1 THEN
          -- ���˿ͻ�
          IF c_instance.custtypeid = 0 THEN
            v_auto_continue  := 1;
            v_serviceenddt   := NULL;
            v_instance_enddt := NULL;
            -- ���ն�
            IF c_instance.seqid = 1 THEN
              v_priceplanid := transfer_dvb_utils_pkg.fun_get_basedata(c_instance.societyid,
                                                                       '���ն˻������۸�ƻ�PK');
              -- �����ն�
            ELSIF c_instance.seqid = 2 OR c_instance.seqid = 3 THEN
              v_priceplanid := transfer_dvb_utils_pkg.fun_get_basedata('default',
                                                                       '�����ն˻������۸�ƻ�PK');
              -- ���ն˼�����
            ELSE
              v_priceplanid := transfer_dvb_utils_pkg.fun_get_basedata('default',
                                                                       '���ն˼����ϻ������۸�ƻ�PK');
            END IF;
            --��������ͣ �Ʒѿ�ʼ����=ԭ���Ʒѽ�ֹ����
            IF c_instance.substatusid = 0 OR c_instance.substatusid = 2 THEN
              v_instance_startdt := trunc(c_instance.enddt) + 1;
              -- ��ͣ���û��������Ʒѿ�ʼ���� = ��ǰ����+��ʹ��ʣ������
            END IF;
            IF c_instance.substatusid = 1 AND
               c_instance.laststopdt IS NOT NULL THEN
              v_instance_startdt := trunc(SYSDATE) +
                                    (trunc(c_instance.enddt) -
                                     trunc(c_instance.laststopdt));
            END IF;
          
            -- ���ſͻ���ʱ�β�Ʒ
          ELSE
            -- ʱ�β�Ʒ�� ���Զ�����
            v_auto_continue := 0;
            -- ʱ�β�Ʒ����ͣ������Ϊ�û��ϴ�ͣ��ʱ��
            v_serviceenddt := c_instance.laststopdt;
            ---��ȡ�����Ʒ��صļƷѿ�ʼ��Ʒѽ�ֹ����
            v_instance_startdt := trunc(c_instance.subscriberstartdt);
          
            v_instance_enddt := trunc(c_instance.enddt) + 1 - (1 / 86400);
            v_priceplanid    := transfer_dvb_utils_pkg.fun_get_basedata('default',
                                                                        '���Ż������۸�ƻ�PK');
          END IF;
        
          -- �ǻ�����,ʱ�β�Ʒ
        ELSE
        
          -- ʱ�β�Ʒ�� ���Զ�����
          v_auto_continue := 0;
          -- ʱ�β�Ʒ����ͣ������Ϊ�û��ϴ�ͣ��ʱ��
          v_serviceenddt := c_instance.laststopdt;
          ---��ȡ�����Ʒ��صļƷѿ�ʼ��Ʒѽ�ֹ����
          v_instance_startdt := trunc(c_instance.subscriberstartdt);
        
          v_instance_enddt := trunc(c_instance.enddt) + 1 - (1 / 86400);
        
          --ֱ�ӴӼ۸�ƻ�����ȡ��id��С�ļ۸�ƻ�
          SELECT MIN(pp.priceplanid_pk)
            INTO v_priceplanid
            FROM priceplanen pp
           WHERE pp.productid_pk = v_productid_pk;
        END IF;
        SELECT seq_instanceen.nextval INTO v_instanceid_pk FROM dual;
        v_result := transfer_dvb_insert_pkg.fun_insert_instanceen(
                                                                  
                                                                  p_instanceid_pk        => v_instanceid_pk, -- ��Ʒʵ��PK
                                                                  p_subscriberid_pk      => c_instance.subscriberid_pk, -- �û�PK
                                                                  p_packageinstanceid_pk => c_instance.packageinstanceid_pk, -- �ײ�ʵ��PK null
                                                                  p_operwayid            => c_instance.operwayid, -- ��Ӫ��ʽ null
                                                                  p_productid            => v_productid_pk, -- ��ƷPK
                                                                  p_invoicecycid         => c_instance.invoicecycid, -- ��������ID null
                                                                  p_productchildtypeid   => c_instance.productchildtypeid, -- ��Ʒ���� 2�������Ʒ
                                                                  p_salewayid            => c_instance.salewayid, -- ���۷�ʽ 1������
                                                                  p_componentid          => c_instance.componentid, -- ��PK null
                                                                  p_packageid            => c_instance.packageid, -- �ײ�PK null
                                                                  p_subscriberstartdt    => v_instance_startdt, -- �Ʒѿ�ʼ����
                                                                  p_subscriberenddt      => v_instance_enddt, -- ȡ���������� null
                                                                  p_billingflag          => v_billingflag, -- �Ʒѱ�ʶ
                                                                  p_iffullmonthid        => c_instance.iffullmonthid, -- �Ƿ����� null
                                                                  p_statusid             => 0, -- ��Ʒʵ��״̬ 0����Ч
                                                                  p_rundt                => c_instance.createdt, -- ��ͨʱ��
                                                                  p_enddt                => v_instance_enddt, -- �Ʒѽ�ֹ����  null
                                                                  p_mem                  => c_instance.mem, -- ȡ��SMS���ж�����¼���е� PK
                                                                  p_createid             => c_instance.createid,
                                                                  p_modifyid             => c_instance.modifyid,
                                                                  p_createcodestr        => c_instance.createcodestr,
                                                                  p_modifycodestr        => c_instance.modifycodestr,
                                                                  p_terminalid           => c_instance.terminalid,
                                                                  p_salechannelid        => c_instance.salechannel,
                                                                  p_createdt             => c_instance.createdt,
                                                                  p_modifydt             => c_instance.modifydt,
                                                                  p_salechannelid1       => c_instance.salechannel,
                                                                  p_operareaid           => c_instance.operareaid, -- ��Ӫ����
                                                                  p_contractid_pk        => c_instance.contractid_pk, -- ��ͬ��ʶ  null
                                                                  p_autocontinue         => v_auto_continue, -- �Ƿ��Զ�����  1���Զ�����
                                                                  p_serviceenddt         => v_instance_enddt, -- ����ͣ������
                                                                  p_finishdt             => c_instance.finishdt, -- ��������
                                                                  p_preinstanceid        => NULL,
                                                                  p_packagetypeid        => NULL,
                                                                  p_isunifiedcancelid    => NULL,
                                                                  p_customerid_pk        => c_instance.customerid_pk);
      
        -- Ϊ��Ʒʵ����������ʵ��
        FOR v_service IN cur_service(p_productid => v_productid_pk) LOOP
          BEGIN
          
            SELECT seq_instanceserviceen.nextval
              INTO v_instanceserviceid_pk
              FROM dual;
          
            v_result := transfer_dvb_insert_pkg.fun_insert_instanceserviceen(p_instanceid_pk        => v_instanceid_pk,
                                                                             p_serviceid_pk         => v_service.serviceid_pk,
                                                                             p_instanceserviceid_pk => v_instanceserviceid_pk,
                                                                             p_statusid             => c_instance.service_ins_status,
                                                                             p_mem                  => '��˳����',
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
                 v_priceplanid, -- �۸�ƻ�PK
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
                                                              ';ԭϵͳ�ն�ID' ||
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
    -- �û��Ļ������ļƷѿ�ʼ�ڵ����յ���ĩ���һ��
    -- �ⲿ���û���Ҫ����Ƿ���˵���Ƿ���û�
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
  
    -- ��ѯ�����յ���������ĩ���ڵ��û��Ͳ�Ʒʵ��
    CURSOR cur_get_ins IS
      SELECT s.customerid_pk,
             s.defaultaccountid,
             s.subscriberid_pk,
             i.instanceid_pk,
             r.rateitemid_pk, -- ��Ŀ����
             i.productid, -- ��ƷPK
             r.rateid_pk, -- �ʷ�PK
             ps.priceinstanceid_pk, -- �۸�ƻ�ʵ��PK
             ps.priceplanid_pk, -- �۸�ƻ�PK
             i.subscriberstartdt, -- �Ʒѿ�ʼ����
             r.ratesumid -- �ʷ�
        FROM subscriberen    s, -- �û���
             instanceen      i, -- ��Ʒʵ����
             priceinstanceen ps, -- �۸�ƻ�ʵ��
             rateen          r, -- �ʷѱ�
             rateplanen      rp -- �ʷѺͼ۸�ƻ���Ӧ��ϵ��
       WHERE s.subscriberid_pk = i.subscriberid_pk
         AND i.instanceid_pk = ps.instanceid_pk
         AND ps.priceplanid_pk = rp.priceplanid_pk
         AND r.rateid_pk = rp.rateid_pk
         AND i.productchildtypeid = 2
         AND -- �����Ʒʵ��
             i.productid = 1122
         AND -- ֻ���������
             s.statusid NOT IN (1, 2, 3)
         AND -- �û�״̬Ϊ ����
             i.enddt IS NULL
         AND -- �Ʒѽ�ֹ����
             i.autocontinue = 1
         AND -- �Զ������Ĳ�Ʒʵ��
             i.subscriberstartdt > trunc(SYSDATE)
         AND -- �Ʒѿ�ʼ����
             i.subscriberstartdt < to_date('2015-07-01', 'yyyy-mm-dd');
  
  BEGIN
  
    v_writeoff        := 24; -- Ĭ�����˽��
    v_invoicecycid_pk := 1; -- Ĭ�����ڱ���
    v_result          := 0;
    v_cnt             := 0;
    -- �������ڲ�ѯ����key
    SELECT i.invoicecycid_pk
      INTO v_invoicecycid_pk
      FROM invoicecycen i
     WHERE invoicecycnamestr = to_char(SYSDATE, 'yyyymm');
  
    SELECT trunc(last_day(SYSDATE) + 1) INTO v_billdate_2 FROM dual; -- �������¸��µĵ�һ�죬���ڼ������
  
    v_billingenddt := to_date(to_char(v_billdate_2 - 1, 'yyyy-mm-dd') ||
                              ' 23:59:59',
                              'yyyy-mm-dd HH24:MI:SS');
  
    --�����ۺ��ʵ���¼
    FOR v_get_ins IN cur_get_ins LOOP
      BEGIN
      
        -- ȡ��ÿһ���˵��ļƷ���ʼ����
        v_billdate_1 := v_get_ins.subscriberstartdt;
      
        -- �����������
        SELECT to_number(trunc(v_billdate_2 - v_billdate_1))
          INTO v_halfday_1
          FROM dual;
      
        -- ������������
        v_monthday_1 := to_number(to_char(last_day(v_billdate_1), 'dd'));
      
        --���㵱��ÿ��Ӧ�ս��
        v_perdayfee := round(nvl(v_get_ins.ratesumid, 0) / v_monthday_1, 8);
      
        --�������Ӧ�ս��
        v_writeoff := round(v_perdayfee * v_halfday_1, 2);
      
        -- ����Ƿ���û�
        SELECT seq_oweobjecten.nextval INTO v_oweobjectid_pk FROM dual;
      
        v_result := transfer_dvb_insert_pkg.fun_insert_oweobjecten(p_oweobjectid_pk           => v_oweobjectid_pk,
                                                                   p_customerid               => v_get_ins.customerid_pk,
                                                                   p_accountid                => v_get_ins.defaultaccountid,
                                                                   p_subscriberid             => v_get_ins.subscriberid_pk,
                                                                   p_invoicecycid             => v_invoicecycid_pk, --��������
                                                                   p_owetypeid                => 1, -- Ƿ������  2����ͨǷ��
                                                                   p_owedt                    => v_get_ins.subscriberstartdt,
                                                                   p_owemoneyid               => v_writeoff,
                                                                   p_isauditid                => 1, -- �Ƿ����
                                                                   p_operwayid                => 1,
                                                                   p_treatstatusid            => 0, -- Ƿ���û�����״̬  0:Ƿ��
                                                                   p_urgecountid              => 0, -- �߽ɴ���
                                                                   p_lastedtimedt             => NULL, -- �����������
                                                                   p_mem                      => '����Ƿ���û�',
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
                                                                   p_stoptype                 => 0, -- Ƿ���������� 0���û�
                                                                   p_billids                  => NULL,
                                                                   p_billingeventid           => NULL,
                                                                   p_billingserviceinstanceid => NULL);
      
        -- ����Ƿ���˵�
        SELECT seq_billen.nextval INTO v_billid_pk FROM dual;
      
        v_result := transfer_dvb_insert_pkg.fun_insert_billen(p_billid_pk           => v_billid_pk,
                                                              p_writeoffid          => NULL,
                                                              p_customerid          => v_get_ins.customerid_pk,
                                                              p_subscriberid        => v_get_ins.subscriberid_pk,
                                                              p_accountid           => v_get_ins.defaultaccountid,
                                                              p_rateclasssourceid   => 0, -- ��ʾ ������Ŀ
                                                              p_rateclassid         => v_get_ins.rateitemid_pk, -- ���ֵ������ӷ�
                                                              p_invoicecycid        => v_invoicecycid_pk, -- ��Ŀ���ڱ���
                                                              p_operwayid           => 1, -- ��Ӫ��ʽ
                                                              p_origionfeeid        => v_writeoff, -- �˵����
                                                              p_discountfeeid       => 0,
                                                              p_factfeeid           => v_writeoff, -- �˵����
                                                              p_billstatusid        => 1, -- �˵�״̬��Ƿ��
                                                              p_writeoffstatusid    => 0, -- �Ƿ��Ѿ����ˣ�δ����
                                                              p_oweobjectstatusid   => 1, -- ��ʾ'������'Ƿ���û�
                                                              p_ifauditid           => 1, -- �Ѿ����
                                                              p_ifacctokid          => 1, -- �Ѿ�����ȷ��
                                                              p_accttypeid          => 0, -- �������ͣ������˵�
                                                              p_commicollid_pk      => NULL,
                                                              p_billingtaskid       => NULL,
                                                              p_mem                 => '���ⲹ�˵�',
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
                                                              p_oweobjectid         => v_oweobjectid_pk, -- Ƿ���û�PK
                                                              p_priceinstanceid     => v_get_ins.priceinstanceid_pk,
                                                              p_priceplanid         => v_get_ins.priceplanid_pk,
                                                              p_rateid              => v_get_ins.rateid_pk,
                                                              p_operitemid          => NULL,
                                                              p_productid           => v_get_ins.productid, -- ��Ʒ���� 5�����ֵ��ӻ�����
                                                              p_instanceid          => v_get_ins.instanceid_pk,
                                                              p_ifprinted           => 0,
                                                              p_packageinstanceid   => NULL, -- �����ײ�ʵ����ʶ
                                                              p_discountnameliststr => NULL, --��ʹ���Ż�����
                                                              p_refundstate         => 0 --�˷�״̬ 0��δ�˷�
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
  
    -- ��ȡ��ַ���𣬵�������
    CURSOR c IS
      SELECT al.addresslevelid_pk
        FROM addresslevelen al
       WHERE al.statusid = 1
       ORDER BY al.addresslevelid_pk DESC;
  
    -- ����ָ����������е�ַ�������Ѿ���������
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
        -- ���ҵ�ǰ��ַ�ĸ�����ַ�Ƿ��Ѿ���������
        -- ����Ѿ��󶨰���������м�¼
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
