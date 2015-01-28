CREATE OR REPLACE PACKAGE "TRANSFER_DVB_INSERT_PKG" IS

  sql_code VARCHAR2(50);

  sql_errm VARCHAR2(1000);

  FUNCTION fun_insert_addressen(p_addressid_pk       addressen.addressid_pk%TYPE,
                                p_addressid_fk       addressen.addressid_fk%TYPE,
                                p_addresslevelid_pk  addressen.addresslevelid_pk%TYPE,
                                p_addressnamestr     addressen.addressnamestr%TYPE,
                                p_addresscodestr     addressen.addresscodestr%TYPE,
                                p_detailaddressstr   addressen.detailaddressstr%TYPE,
                                p_addressabstr       addressen.addressabstr%TYPE,
                                p_statusid           addressen.statusid%TYPE,
                                p_mem                addressen.mem%TYPE,
                                p_createid           addressen.createid%TYPE,
                                p_modifyid           addressen.modifyid%TYPE,
                                p_createcodestr      addressen.createcodestr%TYPE,
                                p_modifycodestr      addressen.modifycodestr%TYPE,
                                p_terminalid         addressen.terminalid%TYPE,
                                p_salechannelid      addressen.salechannelid%TYPE,
                                p_createdt           addressen.createdt%TYPE,
                                p_modifydt           addressen.modifydt%TYPE,
                                p_addressfullnamestr addressen.addressfullnamestr%TYPE)
    RETURN NUMBER;

  FUNCTION fun_insert_phyresourceen(p_resourceid_pk        phyresourceen.resourceid_pk%TYPE,
                                    p_stockid_pk           phyresourceen.stockid_pk%TYPE,
                                    p_cardcataid_pk        phyresourceen.cardcataid_pk%TYPE,
                                    p_containerid_pk       phyresourceen.containerid_pk%TYPE,
                                    p_resourcetypeid       phyresourceen.resourcetypeid%TYPE,
                                    p_resourcecataid_pk    phyresourceen.resourcecataid_pk%TYPE,
                                    p_servicestr           phyresourceen.servicestr%TYPE,
                                    p_resourcecodestr      phyresourceen.resourcecodestr%TYPE,
                                    p_phyresourceincodestr phyresourceen.phyresourceincodestr%TYPE,
                                    p_outdt                phyresourceen.outdt%TYPE,
                                    p_outpriceid           phyresourceen.outpriceid%TYPE,
                                    p_stockstr             phyresourceen.stockstr%TYPE,
                                    p_comedt               phyresourceen.comedt%TYPE,
                                    p_pwdstr               phyresourceen.pwdstr%TYPE,
                                    p_startdt              phyresourceen.startdt%TYPE,
                                    p_enddt                phyresourceen.enddt%TYPE,
                                    p_stockstatusid        phyresourceen.stockstatusid%TYPE,
                                    p_phyresourcestatusid  phyresourceen.phyresourcestatusid%TYPE,
                                    p_stockitemtypeid      phyresourceen.stockitemtypeid%TYPE,
                                    p_countunitid          phyresourceen.countunitid%TYPE,
                                    p_countid              phyresourceen.countid%TYPE,
                                    p_containtypeid        phyresourceen.containtypeid%TYPE,
                                    p_thirdid              phyresourceen.thirdid%TYPE,
                                    p_validatecodestr      phyresourceen.validatecodestr%TYPE,
                                    p_factorycodestr       phyresourceen.factorycodestr%TYPE,
                                    p_hardwareversionstr   phyresourceen.hardwareversionstr%TYPE,
                                    p_historyversionstr    phyresourceen.historyversionstr%TYPE,
                                    p_statusid             phyresourceen.statusid%TYPE,
                                    p_mem                  phyresourceen.mem%TYPE,
                                    p_createid             phyresourceen.createid%TYPE,
                                    p_modifyid             phyresourceen.modifyid%TYPE,
                                    p_createcodestr        phyresourceen.createcodestr%TYPE,
                                    p_modifycodestr        phyresourceen.modifycodestr%TYPE,
                                    p_terminalid           phyresourceen.terminalid%TYPE,
                                    p_salechannelid        phyresourceen.salechannelid%TYPE,
                                    p_createdt             phyresourceen.createdt%TYPE,
                                    p_modifydt             phyresourceen.modifydt%TYPE,
                                    p_proposetypeid        phyresourceen.proposetypeid%TYPE,
                                    p_curversionstr        phyresourceen.curversionstr%TYPE,
                                    p_clientnostr          phyresourceen.clientnostr%TYPE,
                                    p_isbindid             phyresourceen.isbindid%TYPE,
                                    p_targetsalechannelid  phyresourceen.targetsalechannelid%TYPE,
                                    p_packagecodestr       phyresourceen.packagecodestr%TYPE,
                                    p_specificationid_pk   phyresourceen.specificationid_pk%TYPE)
  
   RETURN NUMBER;

  FUNCTION fun_insert_customeren(p_customerid_pk customeren.customerid_pk%TYPE,
                                 
                                 p_addressid customeren.addressid%TYPE,
                                 
                                 p_customerid_fk customeren.customerid_fk%TYPE,
                                 
                                 p_customernamestr customeren.customernamestr%TYPE,
                                 
                                 p_customercodestr customeren.customercodestr%TYPE,
                                 
                                 p_custtypeid customeren.custtypeid%TYPE,
                                 
                                 p_certificatetypeid customeren.certificatetypeid%TYPE,
                                 
                                 p_certcodestr customeren.certcodestr%TYPE,
                                 
                                 p_linktelstr customeren.linktelstr%TYPE,
                                 
                                 p_mobilestr customeren.mobilestr%TYPE,
                                 
                                 p_customeraddrstr customeren.customeraddrstr%TYPE,
                                 
                                 p_customerstatusid customeren.customerstatusid%TYPE,
                                 
                                 p_linkmanstr customeren.linkmanstr%TYPE,
                                 
                                 p_zipcodestr customeren.zipcodestr%TYPE,
                                 
                                 p_contactaddrstr customeren.contactaddrstr%TYPE,
                                 
                                 p_detailaddrcodestr customeren.detailaddrcodestr%TYPE,
                                 
                                 p_pwdstr customeren.pwdstr%TYPE,
                                 
                                 p_enroldt customeren.enroldt%TYPE,
                                 
                                 p_salechannelid1 customeren.salechannelid1%TYPE,
                                 
                                 p_sexstr customeren.sexstr%TYPE,
                                 
                                 p_vacationid customeren.vacationid%TYPE,
                                 
                                 p_birthdaydt customeren.birthdaydt%TYPE,
                                 
                                 p_societyid customeren.societyid%TYPE,
                                 
                                 p_certenddt customeren.certenddt%TYPE,
                                 
                                 p_certregionaddrstr customeren.certregionaddrstr%TYPE,
                                 
                                 p_companytypestr customeren.companytypestr%TYPE,
                                 
                                 p_oldsysid customeren.oldsysid%TYPE,
                                 
                                 p_emailstr customeren.emailstr%TYPE,
                                 
                                 p_faxcodestr customeren.faxcodestr%TYPE,
                                 
                                 p_companyaddrstr customeren.companyaddrstr%TYPE,
                                 
                                 p_companynetaddrstr customeren.companynetaddrstr%TYPE,
                                 
                                 p_customerlevelid customeren.customerlevelid%TYPE,
                                 
                                 p_vipstr customeren.vipstr%TYPE,
                                 
                                 p_logoffreasonid customeren.logoffreasonid%TYPE,
                                 
                                 p_logoffdt customeren.logoffdt%TYPE,
                                 
                                 p_restorereasonid customeren.restorereasonid%TYPE,
                                 
                                 p_restoredt customeren.restoredt%TYPE,
                                 
                                 p_vodflagid customeren.vodflagid%TYPE,
                                 
                                 p_mem customeren.mem%TYPE,
                                 
                                 p_createid customeren.createid%TYPE,
                                 
                                 p_modifyid customeren.modifyid%TYPE,
                                 
                                 p_createcodestr customeren.createcodestr%TYPE,
                                 
                                 p_modifycodestr customeren.modifycodestr%TYPE,
                                 
                                 p_terminalid customeren.terminalid%TYPE,
                                 
                                 p_salechannelid customeren.salechannelid%TYPE,
                                 
                                 p_createdt customeren.createdt%TYPE,
                                 
                                 p_modifydt customeren.modifydt%TYPE,
                                 
                                 p_operareaid customeren.operareaid%TYPE,
                                 
                                 p_addinfostr1 customeren.addinfostr1%TYPE,
                                 
                                 p_addinfostr2 customeren.addinfostr2%TYPE,
                                 
                                 p_addinfostr3 customeren.addinfostr3%TYPE,
                                 
                                 p_addinfostr4 customeren.addinfostr4%TYPE,
                                 
                                 p_encryptpwdstr customeren.encryptpwdstr%TYPE)
  
   RETURN NUMBER
  
    --==============================================================================
    -- 导入客户数据
    --==============================================================================
  
  ;

  --------------------------------------------
  FUNCTION fun_insert_accounten(p_accountid_pk accounten.accountid_pk%TYPE,
                                
                                p_customerid_pk accounten.customerid_pk%TYPE,
                                
                                p_accountcodestr accounten.accountcodestr%TYPE,
                                
                                p_accountnamestr accounten.accountnamestr%TYPE,
                                
                                p_isdefaultid accounten.isdefaultid%TYPE,
                                
                                p_postwayid accounten.postwayid%TYPE,
                                
                                p_postaddrstr accounten.postaddrstr%TYPE,
                                
                                p_zipcodestr accounten.zipcodestr%TYPE,
                                
                                p_logoffreasonid accounten.logoffreasonid%TYPE,
                                
                                p_businessid accounten.businessid%TYPE,
                                
                                p_statusid accounten.statusid%TYPE,
                                
                                p_mem accounten.mem%TYPE,
                                
                                p_createid accounten.createid%TYPE,
                                
                                p_modifyid accounten.modifyid%TYPE,
                                
                                p_createcodestr accounten.createcodestr%TYPE,
                                
                                p_modifycodestr accounten.modifycodestr%TYPE,
                                
                                p_terminalid accounten.terminalid%TYPE,
                                
                                p_salechannelid accounten.salechannelid%TYPE,
                                
                                p_createdt accounten.createdt%TYPE,
                                
                                p_modifydt accounten.modifydt%TYPE,
                                
                                p_salechannelid1 accounten.salechannelid1%TYPE,
                                
                                p_operareaid accounten.operareaid%TYPE)
  
   RETURN NUMBER
  
    --==============================================================================
  
    -- 导入账户数据
  
    --==============================================================================
  
  ;

  ---------------------------------

  FUNCTION fun_insert_acctbooken(p_acctbookid_pk    acctbooken.acctbookid_pk%TYPE,
                                 p_balancetypeid_pk acctbooken.balancetypeid_pk%TYPE,
                                 p_acctbooknamestr  acctbooken.acctbooknamestr%TYPE,
                                 p_acctbookcodestr  acctbooken.acctbookcodestr%TYPE,
                                 p_startdt          acctbooken.startdt%TYPE,
                                 p_enddt            acctbooken.enddt%TYPE,
                                 p_balanceid        acctbooken.balanceid%TYPE,
                                 p_cycle_upperid    acctbooken.cycle_upperid%TYPE,
                                 p_cycle_lowerid    acctbooken.cycle_lowerid%TYPE,
                                 p_statusid         acctbooken.statusid%TYPE,
                                 p_mem              acctbooken.mem%TYPE,
                                 p_createid         acctbooken.createid%TYPE,
                                 p_modifyid         acctbooken.modifyid%TYPE,
                                 p_createcodestr    acctbooken.createcodestr%TYPE,
                                 p_modifycodestr    acctbooken.modifycodestr%TYPE,
                                 p_terminalid       acctbooken.terminalid%TYPE,
                                 p_salechannelid    acctbooken.salechannelid%TYPE,
                                 p_createdt         acctbooken.createdt%TYPE,
                                 p_salechannelid1   acctbooken.salechannelid1%TYPE,
                                 p_operareaid       acctbooken.operareaid%TYPE,
                                 p_modifydt         acctbooken.modifydt%TYPE,
                                 p_deductpriid      acctbooken.deductpriid%TYPE,
                                 p_customerid       acctbooken.customerid%TYPE,
                                 p_objtypeid        acctbooken.objtypeid%TYPE,
                                 p_objid            acctbooken.objid%TYPE)
  
   RETURN NUMBER
  
    --==============================================================================
  
    -- 导入余额账本数据
  
    --==============================================================================
  
  ;

  ---------------------------

  FUNCTION fun_insert_payprojecten(p_payprojectid_pk payprojecten.payprojectid_pk%TYPE,
                                   
                                   p_paymethodid_pk payprojecten.paymethodid_pk%TYPE,
                                   
                                   p_acctbookid_pk payprojecten.acctbookid_pk%TYPE,
                                   
                                   p_accountid_pk payprojecten.accountid_pk%TYPE,
                                   
                                   p_paytypeid payprojecten.paytypeid%TYPE,
                                   
                                   p_priid payprojecten.priid%TYPE,
                                   
                                   p_bankid payprojecten.bankid%TYPE,
                                   
                                   p_bankaccountcodestr payprojecten.bankaccountcodestr%TYPE,
                                   
                                   p_bankaccountnamestr payprojecten.bankaccountnamestr%TYPE,
                                   
                                   p_bankaccounttypestr payprojecten.bankaccounttypestr%TYPE,
                                   
                                   p_creditvalidatedt payprojecten.creditvalidatedt%TYPE,
                                   
                                   p_mem payprojecten.mem%TYPE,
                                   
                                   p_createid payprojecten.createid%TYPE,
                                   
                                   p_modifyid payprojecten.modifyid%TYPE,
                                   
                                   p_createcodestr payprojecten.createcodestr%TYPE,
                                   
                                   p_modifycodestr payprojecten.modifycodestr%TYPE,
                                   
                                   p_terminalid payprojecten.terminalid%TYPE,
                                   
                                   p_salechannelid payprojecten.salechannelid%TYPE,
                                   
                                   p_createdt payprojecten.createdt%TYPE,
                                   
                                   p_modifydt payprojecten.modifydt%TYPE,
                                   
                                   p_salechannelid1 payprojecten.salechannelid1%TYPE,
                                   
                                   p_operareaid payprojecten.operareaid%TYPE,
                                   
                                   p_statusid payprojecten.statusid%TYPE)
  
   RETURN NUMBER
  
    --==============================================================================
  
    -- 导入支付方案数据
  
    --==============================================================================
  ;

  ----------------------------

  FUNCTION fun_insert_acctbalanceobjen(p_accbalanceobjid_pk acctbalanceobjen.accbalanceobjid_pk%TYPE,
                                       
                                       p_acctbookid_pk acctbalanceobjen.acctbookid_pk%TYPE,
                                       
                                       p_objtypeid acctbalanceobjen.objtypeid%TYPE,
                                       
                                       p_objid acctbalanceobjen.objid%TYPE,
                                       
                                       p_mem acctbalanceobjen.mem%TYPE,
                                       
                                       p_createid acctbalanceobjen.createid%TYPE,
                                       
                                       p_modifyid acctbalanceobjen.modifyid%TYPE,
                                       
                                       p_createcodestr acctbalanceobjen.createcodestr%TYPE,
                                       
                                       p_modifycodestr acctbalanceobjen.modifycodestr%TYPE,
                                       
                                       p_terminalid acctbalanceobjen.terminalid%TYPE,
                                       
                                       p_salechannelid acctbalanceobjen.salechannelid%TYPE,
                                       
                                       p_createdt acctbalanceobjen.createdt%TYPE,
                                       
                                       p_salechannelid1 acctbalanceobjen.salechannelid1%TYPE,
                                       
                                       p_operareaid acctbalanceobjen.operareaid%TYPE,
                                       
                                       p_modifydt acctbalanceobjen.modifydt%TYPE,
                                       
                                       p_statusid acctbalanceobjen.statusid%TYPE)
  
   RETURN NUMBER
  
    --==============================================================================
  
    -- 导入 余额对象关系 数据
  
    --==============================================================================
  
  ;

  --==============================================================================

  -- 导入 用户 数据

  --==============================================================================

  FUNCTION fun_insert_subscriberen(p_createdt subscriberen.createdt%TYPE,
                                   
                                   p_modifydt subscriberen.modifydt%TYPE,
                                   
                                   p_salechannelid1 subscriberen.salechannelid1%TYPE,
                                   
                                   p_operareaid subscriberen.operareaid%TYPE,
                                   
                                   p_urgencypaysignid subscriberen.urgencypaysignid%TYPE,
                                   
                                   p_stopsignid subscriberen.stopsignid%TYPE,
                                   
                                   p_parentid_fk subscriberen.parentid_fk%TYPE,
                                   
                                   p_subscriberid_pk subscriberen.subscriberid_pk%TYPE,
                                   
                                   p_invoicecyctypeid_pk subscriberen.invoicecyctypeid_pk%TYPE,
                                   
                                   p_customerid_pk subscriberen.customerid_pk%TYPE,
                                   
                                   p_businessid subscriberen.businessid%TYPE,
                                   
                                   p_servicestr subscriberen.servicestr%TYPE,
                                   
                                   p_usedcustomerid subscriberen.usedcustomerid%TYPE,
                                   
                                   p_defaultaccountid subscriberen.defaultaccountid%TYPE,
                                   
                                   p_setupaddrstr subscriberen.setupaddrstr%TYPE,
                                   
                                   p_setupaddrcodeid subscriberen.setupaddrcodeid%TYPE,
                                   
                                   p_subscriberseqstr subscriberen.subscriberseqstr%TYPE,
                                   
                                   p_detailaddrcodestr subscriberen.detailaddrcodestr%TYPE,
                                   
                                   p_endworkdt subscriberen.endworkdt%TYPE,
                                   
                                   p_subscribertypeid subscriberen.subscribertypeid%TYPE,
                                   
                                   p_pwdstr subscriberen.pwdstr%TYPE,
                                   
                                   p_startdt subscriberen.startdt%TYPE,
                                   
                                   p_enddt subscriberen.enddt%TYPE,
                                   
                                   p_contractid subscriberen.contractid%TYPE,
                                   
                                   p_ifcontractid subscriberen.ifcontractid%TYPE,
                                   
                                   p_operatorid subscriberen.operatorid%TYPE,
                                   
                                   p_salechannelid2 subscriberen.salechannelid2%TYPE,
                                   
                                   p_orderlevelid subscriberen.orderlevelid%TYPE,
                                   
                                   p_equiptypeid subscriberen.equiptypeid%TYPE,
                                   
                                   p_iscdmuserflag subscriberen.iscdmuserflag%TYPE,
                                   
                                   p_preoperitemid subscriberen.preoperitemid%TYPE,
                                   
                                   p_prestatusid subscriberen.prestatusid%TYPE,
                                   
                                   p_laststopdt subscriberen.laststopdt%TYPE,
                                   
                                   p_laststartdt subscriberen.laststartdt%TYPE,
                                   
                                   p_laststopstatusid subscriberen.laststopstatusid%TYPE,
                                   
                                   p_operwayid subscriberen.operwayid%TYPE,
                                   
                                   p_statusid subscriberen.statusid%TYPE,
                                   
                                   p_mem subscriberen.mem%TYPE,
                                   
                                   p_createid subscriberen.createid%TYPE,
                                   
                                   p_modifyid subscriberen.modifyid%TYPE,
                                   
                                   p_createcodestr subscriberen.createcodestr%TYPE,
                                   
                                   p_modifycodestr subscriberen.modifycodestr%TYPE,
                                   
                                   p_terminalid subscriberen.terminalid%TYPE,
                                   
                                   p_salechannelid subscriberen.salechannelid%TYPE,
                                   
                                   p_addinfostr2 subscriberen.addinfostr2%TYPE,
                                   
                                   p_addinfostr3 subscriberen.addinfostr3%TYPE,
                                   
                                   p_activedt subscriberen.activedt%TYPE,
                                   
                                   p_authenticationtypeid_pk subscriberen.authenticationtypeid_pk%TYPE, -- 认证类型
                                   
                                   p_accesspointid subscriberen.accesspointid%TYPE, -- 接入点
                                   
                                   p_addinfostr4 subscriberen.addinfostr4%TYPE
                                   
                                   )
  
   RETURN NUMBER;

  --==============================================================================

  -- 导入产品实例数据

  --==============================================================================

  FUNCTION fun_insert_instanceen(p_instanceid_pk instanceen.instanceid_pk%TYPE,
                                 
                                 p_subscriberid_pk instanceen.subscriberid_pk%TYPE,
                                 
                                 p_packageinstanceid_pk instanceen.packageinstanceid_pk%TYPE,
                                 
                                 p_operwayid instanceen.operwayid%TYPE,
                                 
                                 p_productid instanceen.productid%TYPE,
                                 
                                 p_invoicecycid instanceen.invoicecycid%TYPE,
                                 
                                 p_productchildtypeid instanceen.productchildtypeid%TYPE,
                                 
                                 p_salewayid instanceen.salewayid%TYPE,
                                 
                                 p_componentid instanceen.componentid%TYPE,
                                 
                                 p_packageid instanceen.packageid%TYPE,
                                 
                                 p_subscriberstartdt instanceen.subscriberstartdt%TYPE,
                                 
                                 p_subscriberenddt instanceen.subscriberenddt%TYPE,
                                 
                                 p_billingflag instanceen.billingflag%TYPE,
                                 
                                 p_iffullmonthid instanceen.iffullmonthid%TYPE,
                                 
                                 p_statusid instanceen.statusid%TYPE,
                                 
                                 p_rundt instanceen.rundt%TYPE,
                                 
                                 p_enddt instanceen.enddt%TYPE,
                                 
                                 p_mem instanceen.mem%TYPE,
                                 
                                 p_createid instanceen.createid%TYPE,
                                 
                                 p_modifyid instanceen.modifyid%TYPE,
                                 
                                 p_createcodestr instanceen.createcodestr%TYPE,
                                 
                                 p_modifycodestr instanceen.modifycodestr%TYPE,
                                 
                                 p_terminalid instanceen.terminalid%TYPE,
                                 
                                 p_salechannelid instanceen.salechannelid%TYPE,
                                 
                                 p_createdt instanceen.createdt%TYPE,
                                 
                                 p_modifydt instanceen.modifydt%TYPE,
                                 
                                 p_salechannelid1 instanceen.salechannelid1%TYPE,
                                 
                                 p_operareaid instanceen.operareaid%TYPE,
                                 
                                 p_contractid_pk instanceen.contractid_pk%TYPE,
                                 
                                 p_autocontinue instanceen.autocontinue%TYPE,
                                 
                                 p_serviceenddt instanceen.serviceenddt%TYPE,
                                 
                                 p_finishdt instanceen.finishdt%TYPE,
                                 
                                 p_preinstanceid instanceen.preinstanceid%TYPE,
                                 
                                 p_packagetypeid instanceen.packagetypeid%TYPE,
                                 
                                 p_isunifiedcancelid instanceen.isunifiedcancelid%TYPE,
                                 
                                 p_customerid_pk instanceen.customerid_pk%TYPE)
  
   RETURN NUMBER
  
    --==============================================================================
  
    -- 导入产品实例数据
  
    --==============================================================================
  
  ;

  --==============================================================================

  -- 用户扩展信息，资源占用表

  --==============================================================================
  FUNCTION fun_insert_subscriberaddonen(p_subscriberaddonid_pk subscriberaddonen.subscriberaddonid_pk%TYPE,
                                        
                                        p_subscriberid_pk subscriberaddonen.subscriberid_pk%TYPE,
                                        
                                        p_resourceid subscriberaddonen.resourceid%TYPE,
                                        
                                        p_resourcecodestr subscriberaddonen.resourcecodestr%TYPE,
                                        
                                        p_equiptypeid subscriberaddonen.equiptypeid%TYPE,
                                        
                                        p_startdt subscriberaddonen.startdt%TYPE,
                                        
                                        p_enddt subscriberaddonen.enddt%TYPE,
                                        
                                        p_statusid subscriberaddonen.statusid%TYPE,
                                        
                                        p_mem subscriberaddonen.mem%TYPE,
                                        
                                        p_createid subscriberaddonen.createid%TYPE,
                                        
                                        p_modifyid subscriberaddonen.modifyid%TYPE,
                                        
                                        p_createcodestr subscriberaddonen.createcodestr%TYPE,
                                        
                                        p_modifycodestr subscriberaddonen.modifycodestr%TYPE,
                                        
                                        p_terminalid subscriberaddonen.terminalid%TYPE,
                                        
                                        p_salechannelid subscriberaddonen.salechannelid%TYPE,
                                        
                                        p_createdt subscriberaddonen.createdt%TYPE,
                                        
                                        p_modifydt subscriberaddonen.modifydt%TYPE,
                                        
                                        p_salechannelid1 subscriberaddonen.salechannelid1%TYPE,
                                        
                                        p_operareaid subscriberaddonen.operareaid%TYPE,
                                        
                                        p_instanceid_pk subscriberaddonen.instanceid_pk%TYPE)
  
   RETURN NUMBER
  
    --==============================================================================
  
    -- 用户扩展信息，资源占用表
  
    --==============================================================================
  
  ;

  FUNCTION fun_insert_instanceserviceen(p_instanceid_pk        instanceserviceen.instanceid_pk%TYPE,
                                        p_serviceid_pk         instanceserviceen.serviceid_pk %TYPE,
                                        p_instanceserviceid_pk instanceserviceen.instanceserviceid_pk%TYPE,
                                        p_statusid             instanceserviceen.statusid %TYPE,
                                        p_mem                  instanceserviceen.mem %TYPE,
                                        p_createid             instanceserviceen.createid %TYPE,
                                        p_modifyid             instanceserviceen.modifyid %TYPE,
                                        p_createcodestr        instanceserviceen.createcodestr %TYPE,
                                        p_modifycodestr        instanceserviceen.modifycodestr%TYPE,
                                        p_terminalid           instanceserviceen.terminalid%TYPE,
                                        p_salechannelid        instanceserviceen.salechannelid %TYPE,
                                        p_createdt             instanceserviceen.createdt %TYPE,
                                        p_modifydt             instanceserviceen.modifydt %TYPE)
  
   RETURN NUMBER
  
    --==============================================================================
  
    -- 导入服务实例
  
    --==============================================================================
  
  ;

  --导入账单
  FUNCTION fun_insert_billen(p_billid_pk           billen.billid_pk%TYPE,
                             p_writeoffid          billen.writeoffid%TYPE,
                             p_customerid          billen.customerid%TYPE,
                             p_subscriberid        billen.subscriberid%TYPE,
                             p_accountid           billen.accountid%TYPE,
                             p_rateclasssourceid   billen.rateclasssourceid%TYPE,
                             p_rateclassid         billen.rateclassid%TYPE,
                             p_invoicecycid        billen.invoicecycid%TYPE,
                             p_operwayid           billen.operwayid%TYPE,
                             p_origionfeeid        billen.origionfeeid%TYPE,
                             p_discountfeeid       billen.discountfeeid%TYPE,
                             p_factfeeid           billen.factfeeid%TYPE,
                             p_billstatusid        billen.billstatusid%TYPE,
                             p_writeoffstatusid    billen.writeoffstatusid%TYPE,
                             p_oweobjectstatusid   billen.oweobjectstatusid%TYPE,
                             p_ifauditid           billen.ifauditid%TYPE,
                             p_ifacctokid          billen.ifacctokid%TYPE,
                             p_accttypeid          billen.accttypeid%TYPE,
                             p_commicollid_pk      billen.commicollid_pk%TYPE,
                             p_billingtaskid       billen.billingtaskid%TYPE,
                             p_mem                 billen.mem%TYPE,
                             p_createid            billen.createid%TYPE,
                             p_modifyid            billen.modifyid%TYPE,
                             p_createcodestr       billen.createcodestr%TYPE,
                             p_modifycodestr       billen.modifycodestr%TYPE,
                             p_terminalid          billen.terminalid%TYPE,
                             p_salechannelid       billen.salechannelid%TYPE,
                             p_createdt            billen.createdt%TYPE,
                             p_modifydt            billen.modifydt%TYPE,
                             p_salechannelid1      billen.salechannelid1%TYPE,
                             p_operareaid          billen.operareaid%TYPE,
                             p_billingstartdt      billen.billingstartdt%TYPE,
                             p_billingenddt        billen.billingenddt%TYPE,
                             p_oweobjectid         billen.oweobjectid%TYPE,
                             p_priceinstanceid     billen.priceinstanceid%TYPE,
                             p_priceplanid         billen.priceplanid%TYPE,
                             p_rateid              billen.rateid%TYPE,
                             p_operitemid          billen.operitemid%TYPE,
                             p_productid           billen.productid%TYPE,
                             p_instanceid          billen.instanceid%TYPE,
                             p_ifprinted           billen.ifprinted%TYPE,
                             p_packageinstanceid   billen.packageinstanceid%TYPE,
                             p_discountnameliststr billen.discountnameliststr%TYPE,
                             p_refundstate         billen.refundstate%TYPE)
  
   RETURN NUMBER;

  -- 导入 欠费用户
  FUNCTION fun_insert_oweobjecten(p_oweobjectid_pk           oweobjecten.oweobjectid_pk%TYPE,
                                  p_customerid               oweobjecten.customerid%TYPE,
                                  p_accountid                oweobjecten.accountid%TYPE,
                                  p_subscriberid             oweobjecten.subscriberid%TYPE,
                                  p_invoicecycid             oweobjecten.invoicecycid%TYPE,
                                  p_owetypeid                oweobjecten.owetypeid%TYPE,
                                  p_owedt                    oweobjecten.owedt%TYPE,
                                  p_owemoneyid               oweobjecten.owemoneyid%TYPE,
                                  p_isauditid                oweobjecten.isauditid%TYPE,
                                  p_operwayid                oweobjecten.operwayid%TYPE,
                                  p_treatstatusid            oweobjecten.treatstatusid%TYPE,
                                  p_urgecountid              oweobjecten.urgecountid%TYPE,
                                  p_lastedtimedt             oweobjecten.lastedtimedt%TYPE,
                                  p_mem                      oweobjecten.mem%TYPE,
                                  p_statusid                 oweobjecten.statusid%TYPE,
                                  p_createid                 oweobjecten.createid%TYPE,
                                  p_modifyid                 oweobjecten.modifyid%TYPE,
                                  p_createcodestr            oweobjecten.createcodestr%TYPE,
                                  p_modifycodestr            oweobjecten.modifycodestr%TYPE,
                                  p_terminalid               oweobjecten.terminalid%TYPE,
                                  p_salechannelid            oweobjecten.salechannelid%TYPE,
                                  p_createdt                 oweobjecten.createdt%TYPE,
                                  p_salechannelid1           oweobjecten.salechannelid1%TYPE,
                                  p_operareaid               oweobjecten.operareaid%TYPE,
                                  p_modifydt                 oweobjecten.modifydt%TYPE,
                                  p_stoptype                 oweobjecten.stoptype%TYPE,
                                  p_billids                  oweobjecten.billids%TYPE,
                                  p_billingeventid           oweobjecten.billingeventid%TYPE,
                                  p_billingserviceinstanceid oweobjecten.billingserviceinstanceid%TYPE)
  
   RETURN NUMBER;

  -- 插入销账记录
  FUNCTION fun_insert_writeoffen(p_writeoffid_pk            writeoffen.writeoffid_pk%TYPE,
                                 p_customerid_pk            writeoffen.customerid_pk%TYPE,
                                 p_accountid_pk             writeoffen.accountid_pk%TYPE,
                                 p_paymethodid_pk           writeoffen.paymethodid_pk%TYPE,
                                 p_paymentid_pk             writeoffen.paymentid_pk%TYPE,
                                 p_noteid_pk                writeoffen.noteid_pk%TYPE,
                                 p_subscriberid_pk          writeoffen.subscriberid_pk%TYPE,
                                 p_invoicecycid_pk          writeoffen.invoicecycid_pk%TYPE,
                                 p_writeoffstatusid         writeoffen.writeoffstatusid%TYPE,
                                 p_latefeemoneyid           writeoffen.latefeemoneyid%TYPE,
                                 p_exlatefeemoneyid         writeoffen.exlatefeemoneyid%TYPE,
                                 p_moneyid                  writeoffen.moneyid%TYPE,
                                 p_usebalanceid             writeoffen.usebalanceid%TYPE,
                                 p_mem                      writeoffen.mem%TYPE,
                                 p_createid                 writeoffen.createid%TYPE,
                                 p_modifyid                 writeoffen.modifyid%TYPE,
                                 p_createcodestr            writeoffen.createcodestr%TYPE,
                                 p_modifycodestr            writeoffen.modifycodestr%TYPE,
                                 p_terminalid               writeoffen.terminalid%TYPE,
                                 p_salechannelid            writeoffen.salechannelid%TYPE,
                                 p_createdt                 writeoffen.createdt%TYPE,
                                 p_salechannelid1           writeoffen.salechannelid1%TYPE,
                                 p_operareaid               writeoffen.operareaid%TYPE,
                                 p_modifydt                 writeoffen.modifydt%TYPE,
                                 p_billingeventid           writeoffen.billingeventid%TYPE,
                                 p_billingserviceinstanceid writeoffen.billingserviceinstanceid%TYPE)
    RETURN NUMBER;
  /***押金记录*/
  FUNCTION fun_insert_depositrecorden(p_depositrecordid_pk  depositrecorden.depositrecordid_pk%TYPE,
                                      p_noteid_pk           depositrecorden.noteid_pk%TYPE,
                                      p_customerid_pk       depositrecorden.customerid_pk%TYPE,
                                      p_rateclasstypeid     depositrecorden.rateclasstypeid%TYPE,
                                      p_depositamountid     depositrecorden.depositamountid%TYPE,
                                      p_paymentid           depositrecorden.paymentid%TYPE,
                                      p_statusid            depositrecorden.statusid%TYPE,
                                      p_operatetypeid       depositrecorden.operatetypeid%TYPE,
                                      p_enddt               depositrecorden.enddt%TYPE,
                                      p_tenancydonewayid    depositrecorden.tenancydonewayid%TYPE,
                                      p_mem                 depositrecorden.mem%TYPE,
                                      p_createid            depositrecorden.createid%TYPE,
                                      p_modifyid            depositrecorden.modifyid%TYPE,
                                      p_createcodestr       depositrecorden.createcodestr%TYPE,
                                      p_modifycodestr       depositrecorden.modifycodestr%TYPE,
                                      p_terminalid          depositrecorden.terminalid%TYPE,
                                      p_salechannelid       depositrecorden.salechannelid%TYPE,
                                      p_createdt            depositrecorden.createdt%TYPE,
                                      p_modifydt            depositrecorden.modifydt%TYPE,
                                      p_salechannelid1      depositrecorden.salechannelid1%TYPE,
                                      p_operareaid          depositrecorden.operareaid%TYPE,
                                      p_depositsettlementid depositrecorden.depositsettlementid%TYPE,
                                      p_productinstanceid   depositrecorden.productinstanceid%TYPE,
                                      p_priceinstanceid     depositrecorden.priceinstanceid%TYPE,
                                      p_subscriberid        depositrecorden.subscriberid%TYPE,
                                      p_priceplanid         depositrecorden.priceplanid%TYPE,
                                      p_productid           depositrecorden.productid%TYPE
                                      
                                      ) RETURN NUMBER;

  --付款记录
  FUNCTION fun_insert_paymenten(p_paymentid_pk        paymenten.paymentid_pk%TYPE,
                                p_accountid_pk        paymenten.accountid_pk%TYPE,
                                p_paymethodid_pk      paymenten.paymethodid_pk%TYPE,
                                p_customerid_pk       paymenten.customerid_pk%TYPE,
                                p_tradetypeid         paymenten.tradetypeid%TYPE,
                                p_paymentstatusid     paymenten.paymentstatusid%TYPE,
                                p_amountid            paymenten.amountid%TYPE,
                                p_paymentdt           paymenten.paymentdt%TYPE,
                                p_checkcodestr        paymenten.checkcodestr%TYPE,
                                p_checksrcstr         paymenten.checksrcstr%TYPE,
                                p_checkvaliddt        paymenten.checkvaliddt%TYPE,
                                p_bankterminalstr     paymenten.bankterminalstr%TYPE,
                                p_bankcodestr         paymenten.bankcodestr%TYPE,
                                p_bankaccountcodestr  paymenten.bankaccountcodestr%TYPE,
                                p_bankdealstr         paymenten.bankdealstr%TYPE,
                                p_bankacceptstr       paymenten.bankacceptstr%TYPE,
                                p_bankoperatorstr     paymenten.bankoperatorstr%TYPE,
                                p_ifcheckid           paymenten.ifcheckid%TYPE,
                                p_ifproofid           paymenten.ifproofid%TYPE,
                                p_ifchargeid          paymenten.ifchargeid%TYPE,
                                p_operatedserialnbrid paymenten.operatedserialnbrid%TYPE,
                                p_chancollid_pk       paymenten.chancollid_pk%TYPE,
                                p_mem                 paymenten.mem%TYPE,
                                p_createid            paymenten.createid%TYPE,
                                p_modifyid            paymenten.modifyid%TYPE,
                                p_createcodestr       paymenten.createcodestr%TYPE,
                                p_modifycodestr       paymenten.modifycodestr%TYPE,
                                p_terminalid          paymenten.terminalid%TYPE,
                                p_salechannelid       paymenten.salechannelid%TYPE,
                                p_createdt            paymenten.createdt%TYPE,
                                p_modifydt            paymenten.modifydt%TYPE,
                                p_salechannelid1      paymenten.salechannelid1%TYPE,
                                p_operareaid          paymenten.operareaid%TYPE,
                                p_resourceid_pk       paymenten.resourceid_pk%TYPE,
                                p_developid           paymenten.developid%TYPE
                                
                                ) RETURN NUMBER;

  FUNCTION fun_insert_uniten(p_unitid_pk      uniten.unitid_pk%TYPE,
                             p_unitnamestr    uniten.unitnamestr%TYPE,
                             p_unitcodestr    uniten.unitcodestr%TYPE,
                             p_unitnum        uniten.unitnum%TYPE,
                             p_addressid      uniten.addressid%TYPE,
                             p_subnum         uniten.subnum%TYPE,
                             p_statusid       uniten.statusid%TYPE,
                             p_mem            uniten.mem%TYPE,
                             p_createid       uniten.createid%TYPE,
                             p_modifyid       uniten.modifyid%TYPE,
                             p_createcodestr  uniten.createcodestr%TYPE,
                             p_modifycodestr  uniten.modifycodestr%TYPE,
                             p_terminalid     uniten.terminalid%TYPE,
                             p_salechannelid  uniten.salechannelid%TYPE,
                             p_createdt       uniten.createdt%TYPE,
                             p_modifydt       uniten.modifydt%TYPE,
                             p_salechannelid1 uniten.salechannelid1%TYPE,
                             p_operareaid     uniten.operareaid%TYPE
                             
                             ) RETURN NUMBER;
  -------------------------
  --------插入楼层------
  -------------------------------
  FUNCTION fun_insert_flooren(p_floorid_pk     flooren.floorid_pk%TYPE,
                              p_floornamestr   flooren.floornamestr%TYPE,
                              p_floorcodestr   flooren.floorcodestr%TYPE,
                              p_floornum       flooren.floornum%TYPE,
                              p_addressid      flooren.addressid%TYPE,
                              p_statusid       flooren.statusid%TYPE,
                              p_mem            flooren.mem%TYPE,
                              p_createid       flooren.createid%TYPE,
                              p_modifyid       flooren.modifyid%TYPE,
                              p_createcodestr  flooren.createcodestr%TYPE,
                              p_modifycodestr  flooren.modifycodestr%TYPE,
                              p_terminalid     flooren.terminalid%TYPE,
                              p_salechannelid  flooren.salechannelid%TYPE,
                              p_createdt       flooren.createdt%TYPE,
                              p_modifydt       flooren.modifydt%TYPE,
                              p_salechannelid1 flooren.salechannelid1%TYPE,
                              p_operareaid     flooren.operareaid%TYPE
                              
                              ) RETURN NUMBER;
  -------------------------
  --------插入方格------
  -------------------------------
  FUNCTION fun_insert_murotoen(p_murotoid_pk    murotoen.murotoid_pk%TYPE,
                               p_murotonamestr  murotoen.murotonamestr%TYPE,
                               p_murotocodestr  murotoen.murotocodestr%TYPE,
                               p_murotonum      murotoen.murotonum%TYPE,
                               p_addressid      murotoen.addressid%TYPE,
                               p_floorid        murotoen.floorid%TYPE,
                               p_unitid         murotoen.unitid%TYPE,
                               p_isenable       murotoen.isenable%TYPE,
                               p_statusid       murotoen.statusid%TYPE,
                               p_mem            murotoen.mem%TYPE,
                               p_createid       murotoen.createid%TYPE,
                               p_modifyid       murotoen.modifyid%TYPE,
                               p_createcodestr  murotoen.createcodestr%TYPE,
                               p_modifycodestr  murotoen.modifycodestr%TYPE,
                               p_terminalid     murotoen.terminalid%TYPE,
                               p_salechannelid  murotoen.salechannelid%TYPE,
                               p_createdt       murotoen.createdt%TYPE,
                               p_modifydt       murotoen.modifydt%TYPE,
                               p_salechannelid1 murotoen.salechannelid1%TYPE,
                               p_operareaid     murotoen.operareaid%TYPE
                               
                               ) RETURN NUMBER;

END;
/
CREATE OR REPLACE PACKAGE BODY "TRANSFER_DVB_INSERT_PKG" IS

  FUNCTION fun_insert_addressen(p_addressid_pk       addressen.addressid_pk%TYPE,
                                p_addressid_fk       addressen.addressid_fk%TYPE,
                                p_addresslevelid_pk  addressen.addresslevelid_pk%TYPE,
                                p_addressnamestr     addressen.addressnamestr%TYPE,
                                p_addresscodestr     addressen.addresscodestr%TYPE,
                                p_detailaddressstr   addressen.detailaddressstr%TYPE,
                                p_addressabstr       addressen.addressabstr%TYPE,
                                p_statusid           addressen.statusid%TYPE,
                                p_mem                addressen.mem%TYPE,
                                p_createid           addressen.createid%TYPE,
                                p_modifyid           addressen.modifyid%TYPE,
                                p_createcodestr      addressen.createcodestr%TYPE,
                                p_modifycodestr      addressen.modifycodestr%TYPE,
                                p_terminalid         addressen.terminalid%TYPE,
                                p_salechannelid      addressen.salechannelid%TYPE,
                                p_createdt           addressen.createdt%TYPE,
                                p_modifydt           addressen.modifydt%TYPE,
                                p_addressfullnamestr addressen.addressfullnamestr%TYPE)
    RETURN NUMBER
  
   IS
  
  BEGIN
  
    INSERT INTO addressen
      (addressid_pk,
       addressid_fk,
       addresslevelid_pk,
       addressnamestr,
       addresscodestr,
       detailaddressstr,
       addressabstr,
       statusid,
       mem,
       createid,
       modifyid,
       createcodestr,
       modifycodestr,
       terminalid,
       salechannelid,
       createdt,
       modifydt,
       addressfullnamestr)
    
    VALUES
    
      (p_addressid_pk,
       p_addressid_fk,
       p_addresslevelid_pk,
       p_addressnamestr,
       p_addresscodestr,
       p_detailaddressstr,
       p_addressabstr,
       p_statusid,
       p_mem,
       p_createid,
       p_modifyid,
       p_createcodestr,
       p_modifycodestr,
       p_terminalid,
       p_salechannelid,
       p_createdt,
       p_modifydt,
       p_addressfullnamestr);
  
    RETURN(1);
  END;

  FUNCTION fun_insert_phyresourceen(p_resourceid_pk phyresourceen.resourceid_pk%TYPE,
                                    
                                    p_stockid_pk phyresourceen.stockid_pk%TYPE,
                                    
                                    p_cardcataid_pk phyresourceen.cardcataid_pk%TYPE,
                                    
                                    p_containerid_pk phyresourceen.containerid_pk%TYPE,
                                    
                                    p_resourcetypeid phyresourceen.resourcetypeid%TYPE,
                                    
                                    p_resourcecataid_pk phyresourceen.resourcecataid_pk%TYPE,
                                    
                                    p_servicestr phyresourceen.servicestr%TYPE,
                                    
                                    p_resourcecodestr phyresourceen.resourcecodestr%TYPE,
                                    
                                    p_phyresourceincodestr phyresourceen.phyresourceincodestr%TYPE,
                                    
                                    p_outdt phyresourceen.outdt%TYPE,
                                    
                                    p_outpriceid phyresourceen.outpriceid%TYPE,
                                    
                                    p_stockstr phyresourceen.stockstr%TYPE,
                                    
                                    p_comedt phyresourceen.comedt%TYPE,
                                    
                                    p_pwdstr phyresourceen.pwdstr%TYPE,
                                    
                                    p_startdt phyresourceen.startdt%TYPE,
                                    
                                    p_enddt phyresourceen.enddt%TYPE,
                                    
                                    p_stockstatusid phyresourceen.stockstatusid%TYPE,
                                    
                                    p_phyresourcestatusid phyresourceen.phyresourcestatusid%TYPE,
                                    
                                    p_stockitemtypeid phyresourceen.stockitemtypeid%TYPE,
                                    
                                    p_countunitid phyresourceen.countunitid%TYPE,
                                    
                                    p_countid phyresourceen.countid%TYPE,
                                    
                                    p_containtypeid phyresourceen.containtypeid%TYPE,
                                    
                                    p_thirdid phyresourceen.thirdid%TYPE,
                                    
                                    p_validatecodestr phyresourceen.validatecodestr%TYPE,
                                    
                                    p_factorycodestr phyresourceen.factorycodestr%TYPE,
                                    
                                    p_hardwareversionstr phyresourceen.hardwareversionstr%TYPE,
                                    
                                    p_historyversionstr phyresourceen.historyversionstr%TYPE,
                                    
                                    p_statusid phyresourceen.statusid%TYPE,
                                    
                                    p_mem phyresourceen.mem%TYPE,
                                    
                                    p_createid phyresourceen.createid%TYPE,
                                    
                                    p_modifyid phyresourceen.modifyid%TYPE,
                                    
                                    p_createcodestr phyresourceen.createcodestr%TYPE,
                                    
                                    p_modifycodestr phyresourceen.modifycodestr%TYPE,
                                    
                                    p_terminalid phyresourceen.terminalid%TYPE,
                                    
                                    p_salechannelid phyresourceen.salechannelid%TYPE,
                                    
                                    p_createdt phyresourceen.createdt%TYPE,
                                    
                                    p_modifydt phyresourceen.modifydt%TYPE,
                                    
                                    p_proposetypeid phyresourceen.proposetypeid%TYPE,
                                    
                                    p_curversionstr phyresourceen.curversionstr%TYPE,
                                    
                                    p_clientnostr phyresourceen.clientnostr%TYPE,
                                    
                                    p_isbindid phyresourceen.isbindid%TYPE,
                                    
                                    p_targetsalechannelid phyresourceen.targetsalechannelid%TYPE,
                                    
                                    p_packagecodestr phyresourceen.packagecodestr%TYPE,
                                    
                                    p_specificationid_pk phyresourceen.specificationid_pk%TYPE)
  
   RETURN NUMBER
  
    --==============================================================================
    -- 导入物理资源
  
    --==============================================================================
  
   IS
  
  BEGIN
  
    INSERT /*+ append */
    INTO phyresourceen
    
      (resourceid_pk,
       
       stockid_pk,
       
       cardcataid_pk,
       
       containerid_pk,
       
       resourcetypeid,
       
       resourcecataid_pk,
       
       servicestr,
       
       resourcecodestr,
       
       phyresourceincodestr,
       
       outdt,
       
       outpriceid,
       
       stockstr,
       
       comedt,
       
       pwdstr,
       
       startdt,
       
       enddt,
       
       stockstatusid,
       
       phyresourcestatusid,
       
       stockitemtypeid,
       
       countunitid,
       
       countid,
       
       containtypeid,
       
       thirdid,
       
       validatecodestr,
       
       factorycodestr,
       
       hardwareversionstr,
       
       historyversionstr,
       
       statusid,
       
       mem,
       
       createid,
       
       modifyid,
       
       createcodestr,
       
       modifycodestr,
       
       terminalid,
       
       salechannelid,
       
       createdt,
       
       modifydt,
       
       proposetypeid,
       
       curversionstr,
       
       clientnostr,
       
       isbindid,
       
       targetsalechannelid,
       
       packagecodestr,
       
       specificationid_pk)
    
    VALUES
    
      (p_resourceid_pk,
       
       p_stockid_pk,
       
       p_cardcataid_pk,
       
       p_containerid_pk,
       
       p_resourcetypeid,
       
       p_resourcecataid_pk,
       
       p_servicestr,
       
       p_resourcecodestr,
       
       p_phyresourceincodestr,
       
       p_outdt,
       
       p_outpriceid,
       
       p_stockstr,
       
       p_comedt,
       
       p_pwdstr,
       
       p_startdt,
       
       p_enddt,
       
       p_stockstatusid,
       
       p_phyresourcestatusid,
       
       p_stockitemtypeid,
       
       p_countunitid,
       
       p_countid,
       
       p_containtypeid,
       
       p_thirdid,
       
       p_validatecodestr,
       
       p_factorycodestr,
       
       p_hardwareversionstr,
       
       p_historyversionstr,
       
       p_statusid,
       
       p_mem,
       
       p_createid,
       
       p_modifyid,
       
       p_createcodestr,
       
       p_modifycodestr,
       
       p_terminalid,
       
       p_salechannelid,
       
       p_createdt,
       
       p_modifydt,
       
       p_proposetypeid,
       
       p_curversionstr,
       
       p_clientnostr,
       
       p_isbindid,
       
       p_targetsalechannelid,
       
       p_packagecodestr,
       
       p_specificationid_pk);
  
    RETURN(1);
  
  EXCEPTION
  
    WHEN OTHERS THEN
    
      sql_code := SQLCODE;
    
      sql_errm := SQLERRM;
    
      transfer_dvb_log_pkg.transfer_err_prc(p_sql_code => sql_code,
                                            
                                            p_sql_errm => sql_errm,
                                            
                                            p_calledby => 'transfer_DVB_INSERT_PKG.fun_insert_phyresourceen',
                                            
                                            p_comments => '',
                                            
                                            p_custid => NULL);
    
      RETURN(0);
    
  END;

  --------------------------------------------------

  FUNCTION fun_insert_customeren(p_customerid_pk customeren.customerid_pk%TYPE,
                                 
                                 p_addressid customeren.addressid%TYPE,
                                 
                                 p_customerid_fk customeren.customerid_fk%TYPE,
                                 
                                 p_customernamestr customeren.customernamestr%TYPE,
                                 
                                 p_customercodestr customeren.customercodestr%TYPE,
                                 
                                 p_custtypeid customeren.custtypeid%TYPE,
                                 
                                 p_certificatetypeid customeren.certificatetypeid%TYPE,
                                 
                                 p_certcodestr customeren.certcodestr%TYPE,
                                 
                                 p_linktelstr customeren.linktelstr%TYPE,
                                 
                                 p_mobilestr customeren.mobilestr%TYPE,
                                 
                                 p_customeraddrstr customeren.customeraddrstr%TYPE,
                                 
                                 p_customerstatusid customeren.customerstatusid%TYPE,
                                 
                                 p_linkmanstr customeren.linkmanstr%TYPE,
                                 
                                 p_zipcodestr customeren.zipcodestr%TYPE,
                                 
                                 p_contactaddrstr customeren.contactaddrstr%TYPE,
                                 
                                 p_detailaddrcodestr customeren.detailaddrcodestr%TYPE,
                                 
                                 p_pwdstr customeren.pwdstr%TYPE,
                                 
                                 p_enroldt customeren.enroldt%TYPE,
                                 
                                 p_salechannelid1 customeren.salechannelid1%TYPE,
                                 
                                 p_sexstr customeren.sexstr%TYPE,
                                 
                                 p_vacationid customeren.vacationid%TYPE,
                                 
                                 p_birthdaydt customeren.birthdaydt%TYPE,
                                 
                                 p_societyid customeren.societyid%TYPE,
                                 
                                 p_certenddt customeren.certenddt%TYPE,
                                 
                                 p_certregionaddrstr customeren.certregionaddrstr%TYPE,
                                 
                                 p_companytypestr customeren.companytypestr%TYPE,
                                 
                                 p_oldsysid customeren.oldsysid%TYPE,
                                 
                                 p_emailstr customeren.emailstr%TYPE,
                                 
                                 p_faxcodestr customeren.faxcodestr%TYPE,
                                 
                                 p_companyaddrstr customeren.companyaddrstr%TYPE,
                                 
                                 p_companynetaddrstr customeren.companynetaddrstr%TYPE,
                                 
                                 p_customerlevelid customeren.customerlevelid%TYPE,
                                 
                                 p_vipstr customeren.vipstr%TYPE,
                                 
                                 p_logoffreasonid customeren.logoffreasonid%TYPE,
                                 
                                 p_logoffdt customeren.logoffdt%TYPE,
                                 
                                 p_restorereasonid customeren.restorereasonid%TYPE,
                                 
                                 p_restoredt customeren.restoredt%TYPE,
                                 
                                 p_vodflagid customeren.vodflagid%TYPE,
                                 
                                 p_mem customeren.mem%TYPE,
                                 
                                 p_createid customeren.createid%TYPE,
                                 
                                 p_modifyid customeren.modifyid%TYPE,
                                 
                                 p_createcodestr customeren.createcodestr%TYPE,
                                 
                                 p_modifycodestr customeren.modifycodestr%TYPE,
                                 
                                 p_terminalid customeren.terminalid%TYPE,
                                 
                                 p_salechannelid customeren.salechannelid%TYPE,
                                 
                                 p_createdt customeren.createdt%TYPE,
                                 
                                 p_modifydt customeren.modifydt%TYPE,
                                 
                                 p_operareaid customeren.operareaid%TYPE,
                                 
                                 p_addinfostr1 customeren.addinfostr1%TYPE,
                                 
                                 p_addinfostr2 customeren.addinfostr2%TYPE,
                                 
                                 p_addinfostr3 customeren.addinfostr3%TYPE,
                                 
                                 p_addinfostr4 customeren.addinfostr4%TYPE,
                                 
                                 p_encryptpwdstr customeren.encryptpwdstr%TYPE)
  
   RETURN NUMBER
  
    --==============================================================================
  
    --导入客户数据:customeren
  
    --==============================================================================
  
   IS
  
    sql_code VARCHAR2(50);
  
    sql_errm VARCHAR2(200);
  
  BEGIN
  
    INSERT INTO customeren
    
      (customerid_pk,
       
       addressid,
       
       customerid_fk,
       
       customernamestr,
       
       customercodestr,
       
       custtypeid,
       
       certificatetypeid,
       
       certcodestr,
       
       linktelstr,
       
       mobilestr,
       
       customeraddrstr,
       
       customerstatusid,
       
       linkmanstr,
       
       zipcodestr,
       
       contactaddrstr,
       
       detailaddrcodestr,
       
       pwdstr,
       
       enroldt,
       
       salechannelid1,
       
       sexstr,
       
       vacationid,
       
       birthdaydt,
       
       societyid,
       
       certenddt,
       
       certregionaddrstr,
       
       companytypestr,
       
       oldsysid,
       
       emailstr,
       
       faxcodestr,
       
       companyaddrstr,
       
       companynetaddrstr,
       
       customerlevelid,
       
       vipstr,
       
       logoffreasonid,
       
       logoffdt,
       
       restorereasonid,
       
       restoredt,
       
       vodflagid,
       
       mem,
       
       createid,
       
       modifyid,
       
       createcodestr,
       
       modifycodestr,
       
       terminalid,
       
       salechannelid,
       
       createdt,
       
       modifydt,
       
       operareaid,
       
       addinfostr1,
       
       addinfostr2,
       
       addinfostr3,
       
       addinfostr4,
       
       encryptpwdstr)
    
    VALUES
    
      (p_customerid_pk,
       
       p_addressid,
       
       p_customerid_fk,
       
       p_customernamestr,
       
       p_customercodestr,
       
       p_custtypeid,
       
       p_certificatetypeid,
       
       p_certcodestr,
       
       p_linktelstr,
       
       p_mobilestr,
       
       p_customeraddrstr,
       
       p_customerstatusid,
       
       p_linkmanstr,
       
       p_zipcodestr,
       
       p_contactaddrstr,
       
       p_detailaddrcodestr,
       
       p_pwdstr,
       
       p_enroldt,
       
       p_salechannelid1,
       
       p_sexstr,
       
       p_vacationid,
       
       p_birthdaydt,
       
       p_societyid,
       
       p_certenddt,
       
       p_certregionaddrstr,
       
       p_companytypestr,
       
       p_oldsysid,
       
       p_emailstr,
       
       p_faxcodestr,
       
       p_companyaddrstr,
       
       p_companynetaddrstr,
       
       p_customerlevelid,
       
       p_vipstr,
       
       p_logoffreasonid,
       
       p_logoffdt,
       
       p_restorereasonid,
       
       p_restoredt,
       
       p_vodflagid,
       
       p_mem,
       
       p_createid,
       
       p_modifyid,
       
       p_createcodestr,
       
       p_modifycodestr,
       
       p_terminalid,
       
       p_salechannelid,
       
       p_createdt,
       
       p_modifydt,
       
       p_operareaid,
       
       p_addinfostr1,
       
       p_addinfostr2,
       
       p_addinfostr3,
       
       p_addinfostr4,
       
       p_encryptpwdstr);
  
    RETURN(1);
  
  EXCEPTION
  
    WHEN OTHERS THEN
    
      sql_code := SQLCODE;
    
      sql_errm := SQLERRM;
    
      transfer_dvb_log_pkg.transfer_err_prc(p_sql_code => sql_code,
                                            
                                            p_sql_errm => sql_errm,
                                            
                                            p_calledby => 'transfer_DVB_INSERT_PKG.fun_insert_customeren',
                                            
                                            p_comments => '',
                                            
                                            p_custid => NULL);
    
      RETURN(0);
    
  END;
  -------------------------------

  FUNCTION fun_insert_accounten(p_accountid_pk accounten.accountid_pk%TYPE,
                                
                                p_customerid_pk accounten.customerid_pk%TYPE,
                                
                                p_accountcodestr accounten.accountcodestr%TYPE,
                                
                                p_accountnamestr accounten.accountnamestr%TYPE,
                                
                                p_isdefaultid accounten.isdefaultid%TYPE,
                                
                                p_postwayid accounten.postwayid%TYPE,
                                
                                p_postaddrstr accounten.postaddrstr%TYPE,
                                
                                p_zipcodestr accounten.zipcodestr%TYPE,
                                
                                p_logoffreasonid accounten.logoffreasonid%TYPE,
                                
                                p_businessid accounten.businessid%TYPE,
                                
                                p_statusid accounten.statusid%TYPE,
                                
                                p_mem accounten.mem%TYPE,
                                
                                p_createid accounten.createid%TYPE,
                                
                                p_modifyid accounten.modifyid%TYPE,
                                
                                p_createcodestr accounten.createcodestr%TYPE,
                                
                                p_modifycodestr accounten.modifycodestr%TYPE,
                                
                                p_terminalid accounten.terminalid%TYPE,
                                
                                p_salechannelid accounten.salechannelid%TYPE,
                                
                                p_createdt accounten.createdt%TYPE,
                                
                                p_modifydt accounten.modifydt%TYPE,
                                
                                p_salechannelid1 accounten.salechannelid1%TYPE,
                                
                                p_operareaid accounten.operareaid%TYPE)
  
   RETURN NUMBER
  
    --==============================================================================
  
    -- 导入账户数据：accounten
  
    --==============================================================================
  
   IS
  
  BEGIN
  
    INSERT INTO accounten
    
      (accountid_pk,
       
       customerid_pk,
       
       accountcodestr,
       
       accountnamestr,
       
       isdefaultid,
       
       postwayid,
       
       postaddrstr,
       
       zipcodestr,
       
       logoffreasonid,
       
       businessid,
       
       statusid,
       
       mem,
       
       createid,
       
       modifyid,
       
       createcodestr,
       
       modifycodestr,
       
       terminalid,
       
       salechannelid,
       
       createdt,
       
       modifydt,
       
       salechannelid1,
       
       operareaid)
    
    VALUES
    
      (p_accountid_pk,
       
       p_customerid_pk,
       
       p_accountcodestr,
       
       p_accountnamestr,
       
       p_isdefaultid,
       
       p_postwayid,
       
       p_postaddrstr,
       
       p_zipcodestr,
       
       p_logoffreasonid,
       
       p_businessid,
       
       p_statusid,
       
       p_mem,
       
       p_createid,
       
       p_modifyid,
       
       p_createcodestr,
       
       p_modifycodestr,
       
       p_terminalid,
       
       p_salechannelid,
       
       p_createdt,
       
       p_modifydt,
       
       p_salechannelid1,
       
       p_operareaid);
  
    RETURN(1);
  
  EXCEPTION
  
    WHEN OTHERS THEN
    
      sql_code := SQLCODE;
    
      sql_errm := SQLERRM;
    
      transfer_dvb_log_pkg.transfer_err_prc(p_sql_code => sql_code,
                                            
                                            p_sql_errm => sql_errm,
                                            
                                            p_calledby => 'transfer_DVB_INSERT_PKG.fun_insert_accounten',
                                            
                                            p_comments => 'p_customerid_pk:=' ||
                                                          p_customerid_pk,
                                            
                                            p_custid => NULL);
    
      RETURN(0);
    
  END;

  -------------------------------------------------

  FUNCTION fun_insert_acctbooken(p_acctbookid_pk    acctbooken.acctbookid_pk%TYPE,
                                 p_balancetypeid_pk acctbooken.balancetypeid_pk%TYPE,
                                 p_acctbooknamestr  acctbooken.acctbooknamestr%TYPE,
                                 p_acctbookcodestr  acctbooken.acctbookcodestr%TYPE,
                                 p_startdt          acctbooken.startdt%TYPE,
                                 p_enddt            acctbooken.enddt%TYPE,
                                 p_balanceid        acctbooken.balanceid%TYPE,
                                 p_cycle_upperid    acctbooken.cycle_upperid%TYPE,
                                 p_cycle_lowerid    acctbooken.cycle_lowerid%TYPE,
                                 p_statusid         acctbooken.statusid%TYPE,
                                 p_mem              acctbooken.mem%TYPE,
                                 p_createid         acctbooken.createid%TYPE,
                                 p_modifyid         acctbooken.modifyid%TYPE,
                                 p_createcodestr    acctbooken.createcodestr%TYPE,
                                 p_modifycodestr    acctbooken.modifycodestr%TYPE,
                                 p_terminalid       acctbooken.terminalid%TYPE,
                                 p_salechannelid    acctbooken.salechannelid%TYPE,
                                 p_createdt         acctbooken.createdt%TYPE,
                                 p_salechannelid1   acctbooken.salechannelid1%TYPE,
                                 p_operareaid       acctbooken.operareaid%TYPE,
                                 p_modifydt         acctbooken.modifydt%TYPE,
                                 p_deductpriid      acctbooken.deductpriid%TYPE,
                                 p_customerid       acctbooken.customerid%TYPE,
                                 p_objtypeid        acctbooken.objtypeid%TYPE,
                                 p_objid            acctbooken.objid%TYPE)
  
   RETURN NUMBER
  --==============================================================================
    --导入 余额账本数据：acctbooken
    --==============================================================================
   IS
  BEGIN
    INSERT INTO acctbooken
      (acctbookid_pk,
       balancetypeid_pk,
       acctbooknamestr,
       acctbookcodestr,
       startdt,
       enddt,
       balanceid,
       cycle_upperid,
       cycle_lowerid,
       statusid,
       mem,
       createid,
       modifyid,
       createcodestr,
       modifycodestr,
       terminalid,
       salechannelid,
       createdt,
       salechannelid1,
       operareaid,
       modifydt,
       deductpriid,
       customerid,
       objtypeid,
       objid)
    VALUES
      (p_acctbookid_pk,
       p_balancetypeid_pk,
       p_acctbooknamestr,
       p_acctbookcodestr,
       p_startdt,
       p_enddt,
       p_balanceid,
       p_cycle_upperid,
       p_cycle_lowerid,
       p_statusid,
       p_mem,
       p_createid,
       p_modifyid,
       p_createcodestr,
       p_modifycodestr,
       p_terminalid,
       p_salechannelid,
       p_createdt,
       p_salechannelid1,
       p_operareaid,
       p_modifydt,
       p_deductpriid,
       p_customerid,
       p_objtypeid,
       p_objid);
  
    RETURN(1);
  EXCEPTION
    WHEN OTHERS THEN
      sql_code := SQLCODE;
      sql_errm := SQLERRM;
      transfer_dvb_log_pkg.transfer_err_prc(p_sql_code => sql_code,
                                            p_sql_errm => sql_errm,
                                            p_calledby => 'transfer_DVB_INSERT_PKG.fun_insert_acctbooken',
                                            p_comments => 'p_acctbookid_pk' ||
                                                          p_acctbookid_pk,
                                            p_custid   => NULL);
      RETURN(0);
  END;

  -------------------------------------------

  FUNCTION fun_insert_payprojecten(p_payprojectid_pk payprojecten.payprojectid_pk%TYPE,
                                   
                                   p_paymethodid_pk payprojecten.paymethodid_pk%TYPE,
                                   
                                   p_acctbookid_pk payprojecten.acctbookid_pk%TYPE,
                                   
                                   p_accountid_pk payprojecten.accountid_pk%TYPE,
                                   
                                   p_paytypeid payprojecten.paytypeid%TYPE,
                                   
                                   p_priid payprojecten.priid%TYPE,
                                   
                                   p_bankid payprojecten.bankid%TYPE,
                                   
                                   p_bankaccountcodestr payprojecten.bankaccountcodestr%TYPE,
                                   
                                   p_bankaccountnamestr payprojecten.bankaccountnamestr%TYPE,
                                   
                                   p_bankaccounttypestr payprojecten.bankaccounttypestr%TYPE,
                                   
                                   p_creditvalidatedt payprojecten.creditvalidatedt%TYPE,
                                   
                                   p_mem payprojecten.mem%TYPE,
                                   
                                   p_createid payprojecten.createid%TYPE,
                                   
                                   p_modifyid payprojecten.modifyid%TYPE,
                                   
                                   p_createcodestr payprojecten.createcodestr%TYPE,
                                   
                                   p_modifycodestr payprojecten.modifycodestr%TYPE,
                                   
                                   p_terminalid payprojecten.terminalid%TYPE,
                                   
                                   p_salechannelid payprojecten.salechannelid%TYPE,
                                   
                                   p_createdt payprojecten.createdt%TYPE,
                                   
                                   p_modifydt payprojecten.modifydt%TYPE,
                                   
                                   p_salechannelid1 payprojecten.salechannelid1%TYPE,
                                   
                                   p_operareaid payprojecten.operareaid%TYPE,
                                   
                                   p_statusid payprojecten.statusid%TYPE)
  
   RETURN NUMBER
  
    --==============================================================================
  
    -- 导入支付方案数据：payprojecten
  
    --==============================================================================
  
   IS
  
  BEGIN
  
    INSERT INTO payprojecten
    
      (payprojectid_pk,
       
       paymethodid_pk,
       
       acctbookid_pk,
       
       accountid_pk,
       
       paytypeid,
       
       priid,
       
       bankid,
       
       bankaccountcodestr,
       
       bankaccountnamestr,
       
       bankaccounttypestr,
       
       creditvalidatedt,
       
       mem,
       
       createid,
       
       modifyid,
       
       createcodestr,
       
       modifycodestr,
       
       terminalid,
       
       salechannelid,
       
       createdt,
       
       modifydt,
       
       salechannelid1,
       
       operareaid,
       
       statusid)
    
    VALUES
    
      (p_payprojectid_pk,
       
       p_paymethodid_pk,
       
       p_acctbookid_pk,
       
       p_accountid_pk,
       
       p_paytypeid,
       
       p_priid,
       
       p_bankid,
       
       p_bankaccountcodestr,
       
       p_bankaccountnamestr,
       
       p_bankaccounttypestr,
       
       p_creditvalidatedt,
       
       p_mem,
       
       p_createid,
       
       p_modifyid,
       
       p_createcodestr,
       
       p_modifycodestr,
       
       p_terminalid,
       
       p_salechannelid,
       
       p_createdt,
       
       p_modifydt,
       
       p_salechannelid1,
       
       p_operareaid,
       
       p_statusid);
  
    RETURN(1);
  
  EXCEPTION
  
    WHEN OTHERS THEN
    
      sql_code := SQLCODE;
    
      sql_errm := SQLERRM;
    
      transfer_dvb_log_pkg.transfer_err_prc(p_sql_code => sql_code,
                                            
                                            p_sql_errm => sql_errm,
                                            
                                            p_calledby => 'transfer_DVB_INSERT_PKG.fun_insert_payprojecten',
                                            
                                            p_comments => 'p_accountid_pk' ||
                                                          p_accountid_pk,
                                            
                                            p_custid => NULL);
    
      RETURN(0);
    
  END;
  ---------------------------------------------

  FUNCTION fun_insert_acctbalanceobjen(p_accbalanceobjid_pk acctbalanceobjen.accbalanceobjid_pk%TYPE,
                                       
                                       p_acctbookid_pk acctbalanceobjen.acctbookid_pk%TYPE,
                                       
                                       p_objtypeid acctbalanceobjen.objtypeid%TYPE,
                                       
                                       p_objid acctbalanceobjen.objid%TYPE,
                                       
                                       p_mem acctbalanceobjen.mem%TYPE,
                                       
                                       p_createid acctbalanceobjen.createid%TYPE,
                                       
                                       p_modifyid acctbalanceobjen.modifyid%TYPE,
                                       
                                       p_createcodestr acctbalanceobjen.createcodestr%TYPE,
                                       
                                       p_modifycodestr acctbalanceobjen.modifycodestr%TYPE,
                                       
                                       p_terminalid acctbalanceobjen.terminalid%TYPE,
                                       
                                       p_salechannelid acctbalanceobjen.salechannelid%TYPE,
                                       
                                       p_createdt acctbalanceobjen.createdt%TYPE,
                                       
                                       p_salechannelid1 acctbalanceobjen.salechannelid1%TYPE,
                                       
                                       p_operareaid acctbalanceobjen.operareaid%TYPE,
                                       
                                       p_modifydt acctbalanceobjen.modifydt%TYPE,
                                       
                                       p_statusid acctbalanceobjen.statusid%TYPE)
  
   RETURN NUMBER
  
    --==============================================================================
  
    -- 导入 余额对象关系数据：acctbalanceobjen
  
    --==============================================================================
  
   IS
  
  BEGIN
  
    INSERT INTO acctbalanceobjen
    
      (accbalanceobjid_pk,
       
       acctbookid_pk,
       
       objtypeid,
       
       objid,
       
       mem,
       
       createid,
       
       modifyid,
       
       createcodestr,
       
       modifycodestr,
       
       terminalid,
       
       salechannelid,
       
       createdt,
       
       salechannelid1,
       
       operareaid,
       
       modifydt,
       
       statusid)
    
    VALUES
    
      (p_accbalanceobjid_pk,
       
       p_acctbookid_pk,
       
       p_objtypeid,
       
       p_objid,
       
       p_mem,
       
       p_createid,
       
       p_modifyid,
       
       p_createcodestr,
       
       p_modifycodestr,
       
       p_terminalid,
       
       p_salechannelid,
       
       p_createdt,
       
       p_salechannelid1,
       
       p_operareaid,
       
       p_modifydt,
       
       p_statusid);
  
    RETURN(1);
  
  EXCEPTION
  
    WHEN OTHERS THEN
    
      sql_code := SQLCODE;
    
      sql_errm := SQLERRM;
    
      transfer_dvb_log_pkg.transfer_err_prc(p_sql_code => sql_code,
                                            
                                            p_sql_errm => sql_errm,
                                            
                                            p_calledby => 'transfer_DVB_INSERT_PKG.fun_insert_acctbalanceobjen',
                                            
                                            p_comments => 'p_acctbookid_pk' ||
                                                          p_acctbookid_pk,
                                            
                                            p_custid => NULL);
    
      RETURN(0);
    
  END;

  ----------------------------------------
  ----  导入用户数据
  ----------------------------------------

  FUNCTION fun_insert_subscriberen(p_createdt subscriberen.createdt%TYPE,
                                   
                                   p_modifydt subscriberen.modifydt%TYPE,
                                   
                                   p_salechannelid1 subscriberen.salechannelid1%TYPE,
                                   
                                   p_operareaid subscriberen.operareaid%TYPE,
                                   
                                   p_urgencypaysignid subscriberen.urgencypaysignid%TYPE,
                                   
                                   p_stopsignid subscriberen.stopsignid%TYPE,
                                   
                                   p_parentid_fk subscriberen.parentid_fk%TYPE,
                                   
                                   p_subscriberid_pk subscriberen.subscriberid_pk%TYPE,
                                   
                                   p_invoicecyctypeid_pk subscriberen.invoicecyctypeid_pk%TYPE,
                                   
                                   p_customerid_pk subscriberen.customerid_pk%TYPE,
                                   
                                   p_businessid subscriberen.businessid%TYPE,
                                   
                                   p_servicestr subscriberen.servicestr%TYPE,
                                   
                                   p_usedcustomerid subscriberen.usedcustomerid%TYPE,
                                   
                                   p_defaultaccountid subscriberen.defaultaccountid%TYPE,
                                   
                                   p_setupaddrstr subscriberen.setupaddrstr%TYPE,
                                   
                                   p_setupaddrcodeid subscriberen.setupaddrcodeid%TYPE,
                                   
                                   p_subscriberseqstr subscriberen.subscriberseqstr%TYPE,
                                   
                                   p_detailaddrcodestr subscriberen.detailaddrcodestr%TYPE,
                                   
                                   p_endworkdt subscriberen.endworkdt%TYPE,
                                   
                                   p_subscribertypeid subscriberen.subscribertypeid%TYPE,
                                   
                                   p_pwdstr subscriberen.pwdstr%TYPE,
                                   
                                   p_startdt subscriberen.startdt%TYPE,
                                   
                                   p_enddt subscriberen.enddt%TYPE,
                                   
                                   p_contractid subscriberen.contractid%TYPE,
                                   
                                   p_ifcontractid subscriberen.ifcontractid%TYPE,
                                   
                                   p_operatorid subscriberen.operatorid%TYPE,
                                   
                                   p_salechannelid2 subscriberen.salechannelid2%TYPE,
                                   
                                   p_orderlevelid subscriberen.orderlevelid%TYPE,
                                   
                                   p_equiptypeid subscriberen.equiptypeid%TYPE,
                                   
                                   p_iscdmuserflag subscriberen.iscdmuserflag%TYPE,
                                   
                                   p_preoperitemid subscriberen.preoperitemid%TYPE,
                                   
                                   p_prestatusid subscriberen.prestatusid%TYPE,
                                   
                                   p_laststopdt subscriberen.laststopdt%TYPE,
                                   
                                   p_laststartdt subscriberen.laststartdt%TYPE,
                                   
                                   p_laststopstatusid subscriberen.laststopstatusid%TYPE,
                                   
                                   p_operwayid subscriberen.operwayid%TYPE,
                                   
                                   p_statusid subscriberen.statusid%TYPE,
                                   
                                   p_mem subscriberen.mem%TYPE,
                                   
                                   p_createid subscriberen.createid%TYPE,
                                   
                                   p_modifyid subscriberen.modifyid%TYPE,
                                   
                                   p_createcodestr subscriberen.createcodestr%TYPE,
                                   
                                   p_modifycodestr subscriberen.modifycodestr%TYPE,
                                   
                                   p_terminalid subscriberen.terminalid%TYPE,
                                   
                                   p_salechannelid subscriberen.salechannelid%TYPE,
                                   
                                   p_addinfostr2 subscriberen.addinfostr2%TYPE,
                                   
                                   p_addinfostr3 subscriberen.addinfostr3%TYPE,
                                   
                                   p_activedt subscriberen.activedt%TYPE,
                                   
                                   p_authenticationtypeid_pk subscriberen.authenticationtypeid_pk%TYPE, -- 认证类型
                                   
                                   p_accesspointid subscriberen.accesspointid%TYPE, -- 接入点
                                   
                                   p_addinfostr4 subscriberen.addinfostr4%TYPE
                                   
                                   )
  
   RETURN NUMBER
  
    --==============================================================================
  
    ----  导入用户数据
  
    --==============================================================================
  
   IS
  
  BEGIN
  
    INSERT INTO subscriberen
    
      (createdt,
       
       modifydt,
       
       salechannelid1,
       
       operareaid,
       
       urgencypaysignid,
       
       stopsignid,
       
       parentid_fk,
       
       subscriberid_pk,
       
       invoicecyctypeid_pk,
       
       customerid_pk,
       
       businessid,
       
       servicestr,
       
       usedcustomerid,
       
       defaultaccountid,
       
       setupaddrstr,
       
       setupaddrcodeid,
       
       subscriberseqstr,
       
       detailaddrcodestr,
       
       endworkdt,
       
       subscribertypeid,
       
       pwdstr,
       
       startdt,
       
       enddt,
       
       contractid,
       
       ifcontractid,
       
       operatorid,
       
       salechannelid2,
       
       orderlevelid,
       
       equiptypeid,
       
       iscdmuserflag,
       
       preoperitemid,
       
       prestatusid,
       
       laststopdt,
       
       laststartdt,
       
       laststopstatusid,
       
       operwayid,
       
       statusid,
       
       mem,
       
       createid,
       
       modifyid,
       
       createcodestr,
       
       modifycodestr,
       
       terminalid,
       
       salechannelid,
       
       addinfostr2,
       
       addinfostr3,
       
       activedt,
       
       authenticationtypeid_pk,
       
       accesspointid,
       addinfostr4
       
       )
    
    VALUES
    
      (p_createdt,
       
       p_modifydt,
       
       p_salechannelid1,
       
       p_operareaid,
       
       p_urgencypaysignid,
       
       p_stopsignid,
       
       p_parentid_fk,
       
       p_subscriberid_pk,
       
       p_invoicecyctypeid_pk,
       
       p_customerid_pk,
       
       p_businessid,
       
       p_servicestr,
       
       p_usedcustomerid,
       
       p_defaultaccountid,
       
       p_setupaddrstr,
       
       p_setupaddrcodeid,
       
       p_subscriberseqstr,
       
       p_detailaddrcodestr,
       
       p_endworkdt,
       
       p_subscribertypeid,
       
       p_pwdstr,
       
       p_startdt,
       
       p_enddt,
       
       p_contractid,
       
       p_ifcontractid,
       
       p_operatorid,
       
       p_salechannelid2,
       
       p_orderlevelid,
       
       p_equiptypeid,
       
       p_iscdmuserflag,
       
       p_preoperitemid,
       
       p_prestatusid,
       
       p_laststopdt,
       
       p_laststartdt,
       
       p_laststopstatusid,
       
       p_operwayid,
       
       p_statusid,
       
       p_mem,
       
       p_createid,
       
       p_modifyid,
       
       p_createcodestr,
       
       p_modifycodestr,
       
       p_terminalid,
       
       p_salechannelid,
       
       p_addinfostr2,
       
       p_addinfostr3,
       
       p_activedt,
       
       p_authenticationtypeid_pk,
       
       p_accesspointid,
       
       p_addinfostr4);
  
    RETURN(1);
  
  EXCEPTION
  
    WHEN OTHERS THEN
    
      sql_code := SQLCODE;
    
      sql_errm := SQLERRM;
    
      transfer_dvb_log_pkg.transfer_err_prc(p_sql_code => sql_code,
                                            
                                            p_sql_errm => sql_errm,
                                            
                                            p_calledby => 'transfer_DVB_INSERT_PKG.fun_insert_subscriberen',
                                            
                                            p_comments => '',
                                            
                                            p_custid => NULL);
    
      RETURN(0);
    
  END;

  FUNCTION fun_insert_instanceen(p_instanceid_pk instanceen.instanceid_pk%TYPE,
                                 
                                 p_subscriberid_pk instanceen.subscriberid_pk%TYPE,
                                 
                                 p_packageinstanceid_pk instanceen.packageinstanceid_pk%TYPE,
                                 
                                 p_operwayid instanceen.operwayid%TYPE,
                                 
                                 p_productid instanceen.productid%TYPE,
                                 
                                 p_invoicecycid instanceen.invoicecycid%TYPE,
                                 
                                 p_productchildtypeid instanceen.productchildtypeid%TYPE,
                                 
                                 p_salewayid instanceen.salewayid%TYPE,
                                 
                                 p_componentid instanceen.componentid%TYPE,
                                 
                                 p_packageid instanceen.packageid%TYPE,
                                 
                                 p_subscriberstartdt instanceen.subscriberstartdt%TYPE,
                                 
                                 p_subscriberenddt instanceen.subscriberenddt%TYPE,
                                 
                                 p_billingflag instanceen.billingflag%TYPE,
                                 
                                 p_iffullmonthid instanceen.iffullmonthid%TYPE,
                                 
                                 p_statusid instanceen.statusid%TYPE,
                                 
                                 p_rundt instanceen.rundt%TYPE,
                                 
                                 p_enddt instanceen.enddt%TYPE,
                                 
                                 p_mem instanceen.mem%TYPE,
                                 
                                 p_createid instanceen.createid%TYPE,
                                 
                                 p_modifyid instanceen.modifyid%TYPE,
                                 
                                 p_createcodestr instanceen.createcodestr%TYPE,
                                 
                                 p_modifycodestr instanceen.modifycodestr%TYPE,
                                 
                                 p_terminalid instanceen.terminalid%TYPE,
                                 
                                 p_salechannelid instanceen.salechannelid%TYPE,
                                 
                                 p_createdt instanceen.createdt%TYPE,
                                 
                                 p_modifydt instanceen.modifydt%TYPE,
                                 
                                 p_salechannelid1 instanceen.salechannelid1%TYPE,
                                 
                                 p_operareaid instanceen.operareaid%TYPE,
                                 
                                 p_contractid_pk instanceen.contractid_pk%TYPE,
                                 
                                 p_autocontinue instanceen.autocontinue%TYPE,
                                 
                                 p_serviceenddt instanceen.serviceenddt%TYPE,
                                 
                                 p_finishdt instanceen.finishdt%TYPE,
                                 
                                 p_preinstanceid instanceen.preinstanceid%TYPE,
                                 
                                 p_packagetypeid instanceen.packagetypeid%TYPE,
                                 
                                 p_isunifiedcancelid instanceen.isunifiedcancelid%TYPE,
                                 
                                 p_customerid_pk instanceen.customerid_pk%TYPE)
  
   RETURN NUMBER
  
    --==============================================================================
  
    -- 导入产品实例数据
  
    --==============================================================================
  
   IS
  
  BEGIN
  
    INSERT INTO instanceen
    
      (instanceid_pk,
       
       subscriberid_pk,
       
       packageinstanceid_pk,
       
       operwayid,
       
       productid,
       
       invoicecycid,
       
       productchildtypeid,
       
       salewayid,
       
       componentid,
       
       packageid,
       
       subscriberstartdt,
       
       subscriberenddt,
       
       billingflag,
       
       iffullmonthid,
       
       statusid,
       
       rundt,
       
       enddt,
       
       mem,
       
       createid,
       
       modifyid,
       
       createcodestr,
       
       modifycodestr,
       
       terminalid,
       
       salechannelid,
       
       createdt,
       
       modifydt,
       
       salechannelid1,
       
       operareaid,
       
       contractid_pk,
       
       autocontinue,
       
       serviceenddt,
       
       finishdt,
       
       preinstanceid,
       
       packagetypeid,
       
       isunifiedcancelid,
       
       customerid_pk)
    
    VALUES
    
      (p_instanceid_pk,
       
       p_subscriberid_pk,
       
       p_packageinstanceid_pk,
       
       p_operwayid,
       
       p_productid,
       
       p_invoicecycid,
       
       p_productchildtypeid,
       
       p_salewayid,
       
       p_componentid,
       
       p_packageid,
       
       p_subscriberstartdt,
       
       p_subscriberenddt,
       
       p_billingflag,
       
       p_iffullmonthid,
       
       p_statusid,
       
       p_rundt,
       
       p_enddt,
       
       p_mem,
       
       p_createid,
       
       p_modifyid,
       
       p_createcodestr,
       
       p_modifycodestr,
       
       p_terminalid,
       
       p_salechannelid,
       
       p_createdt,
       
       p_modifydt,
       
       p_salechannelid1,
       
       p_operareaid,
       
       p_contractid_pk,
       
       p_autocontinue,
       
       p_serviceenddt,
       
       p_finishdt,
       
       p_preinstanceid,
       
       p_packagetypeid,
       
       p_isunifiedcancelid,
       
       p_customerid_pk);
  
    RETURN(1);
  
  EXCEPTION
  
    WHEN OTHERS THEN
    
      sql_code := SQLCODE;
    
      sql_errm := SQLERRM;
    
      transfer_dvb_log_pkg.transfer_err_prc(p_sql_code => sql_code,
                                            
                                            p_sql_errm => sql_errm,
                                            
                                            p_calledby => 'transfer_DVB_INSERT_PKG.fun_insert_instanceen',
                                            
                                            p_comments => '',
                                            
                                            p_custid => NULL);
    
      RETURN(0);
    
  END;

  FUNCTION fun_insert_subscriberaddonen(p_subscriberaddonid_pk subscriberaddonen.subscriberaddonid_pk%TYPE,
                                        
                                        p_subscriberid_pk subscriberaddonen.subscriberid_pk%TYPE,
                                        
                                        p_resourceid subscriberaddonen.resourceid%TYPE,
                                        
                                        p_resourcecodestr subscriberaddonen.resourcecodestr%TYPE,
                                        
                                        p_equiptypeid subscriberaddonen.equiptypeid%TYPE,
                                        
                                        p_startdt subscriberaddonen.startdt%TYPE,
                                        
                                        p_enddt subscriberaddonen.enddt%TYPE,
                                        
                                        p_statusid subscriberaddonen.statusid%TYPE,
                                        
                                        p_mem subscriberaddonen.mem%TYPE,
                                        
                                        p_createid subscriberaddonen.createid%TYPE,
                                        
                                        p_modifyid subscriberaddonen.modifyid%TYPE,
                                        
                                        p_createcodestr subscriberaddonen.createcodestr%TYPE,
                                        
                                        p_modifycodestr subscriberaddonen.modifycodestr%TYPE,
                                        
                                        p_terminalid subscriberaddonen.terminalid%TYPE,
                                        
                                        p_salechannelid subscriberaddonen.salechannelid%TYPE,
                                        
                                        p_createdt subscriberaddonen.createdt%TYPE,
                                        
                                        p_modifydt subscriberaddonen.modifydt%TYPE,
                                        
                                        p_salechannelid1 subscriberaddonen.salechannelid1%TYPE,
                                        
                                        p_operareaid subscriberaddonen.operareaid%TYPE,
                                        
                                        p_instanceid_pk subscriberaddonen.instanceid_pk%TYPE)
  
   RETURN NUMBER
  
    --==============================================================================
  
    -- 导入用户扩展信息，资源占用
  
    --==============================================================================
  
   IS
  
  BEGIN
  
    INSERT INTO subscriberaddonen
    
      (subscriberaddonid_pk,
       
       subscriberid_pk,
       
       resourceid,
       
       resourcecodestr,
       
       equiptypeid,
       
       startdt,
       
       enddt,
       
       statusid,
       
       mem,
       
       createid,
       
       modifyid,
       
       createcodestr,
       
       modifycodestr,
       
       terminalid,
       
       salechannelid,
       
       createdt,
       
       modifydt,
       
       salechannelid1,
       
       operareaid,
       
       instanceid_pk)
    
    VALUES
    
      (p_subscriberaddonid_pk,
       
       p_subscriberid_pk,
       
       p_resourceid,
       
       p_resourcecodestr,
       
       p_equiptypeid,
       
       p_startdt,
       
       p_enddt,
       
       p_statusid,
       
       p_mem,
       
       p_createid,
       
       p_modifyid,
       
       p_createcodestr,
       
       p_modifycodestr,
       
       p_terminalid,
       
       p_salechannelid,
       
       p_createdt,
       
       p_modifydt,
       
       p_salechannelid1,
       
       p_operareaid,
       
       p_instanceid_pk);
  
    RETURN(1);
  
  EXCEPTION
  
    WHEN OTHERS THEN
    
      sql_code := SQLCODE;
    
      sql_errm := SQLERRM;
    
      transfer_dvb_log_pkg.transfer_err_prc(p_sql_code => sql_code,
                                            
                                            p_sql_errm => sql_errm,
                                            
                                            p_calledby => 'transfer_DVB_INSERT_PKG.fun_insert_subscriberaddonen',
                                            
                                            p_comments => '',
                                            
                                            p_custid => NULL);
    
      RETURN(0);
    
  END;

  FUNCTION fun_insert_instanceserviceen(p_instanceid_pk        instanceserviceen.instanceid_pk%TYPE,
                                        p_serviceid_pk         instanceserviceen.serviceid_pk %TYPE,
                                        p_instanceserviceid_pk instanceserviceen.instanceserviceid_pk%TYPE,
                                        p_statusid             instanceserviceen.statusid %TYPE,
                                        p_mem                  instanceserviceen.mem %TYPE,
                                        p_createid             instanceserviceen.createid %TYPE,
                                        p_modifyid             instanceserviceen.modifyid %TYPE,
                                        p_createcodestr        instanceserviceen.createcodestr %TYPE,
                                        p_modifycodestr        instanceserviceen.modifycodestr%TYPE,
                                        p_terminalid           instanceserviceen.terminalid%TYPE,
                                        p_salechannelid        instanceserviceen.salechannelid %TYPE,
                                        p_createdt             instanceserviceen.createdt %TYPE,
                                        p_modifydt             instanceserviceen.modifydt %TYPE)
    RETURN NUMBER
  
    --==============================================================================
  
    -- 导入服务实例
  
    --==============================================================================
  
   IS
  
  BEGIN
  
    INSERT INTO instanceserviceen
    
      (instanceid_pk,
       serviceid_pk,
       instanceserviceid_pk,
       statusid,
       mem,
       createid,
       modifyid,
       createcodestr,
       modifycodestr,
       terminalid,
       salechannelid,
       createdt,
       modifydt)
    
    VALUES
    
      (p_instanceid_pk,
       p_serviceid_pk,
       p_instanceserviceid_pk,
       p_statusid,
       p_mem,
       p_createid,
       p_modifyid,
       p_createcodestr,
       p_modifycodestr,
       p_terminalid,
       p_salechannelid,
       p_createdt,
       p_modifydt);
  
    RETURN(1);
  
  EXCEPTION
  
    WHEN OTHERS THEN
    
      sql_code := SQLCODE;
    
      sql_errm := SQLERRM;
    
      transfer_dvb_log_pkg.transfer_err_prc(p_sql_code => sql_code,
                                            
                                            p_sql_errm => sql_errm,
                                            
                                            p_calledby => 'transfer_DVB_INSERT_PKG.fun_insert_instanceserviceen',
                                            
                                            p_comments => '',
                                            
                                            p_custid => NULL);
    
      RETURN(0);
    
  END;

  -----------------------
  ---------插入账单记录
  -----------------------------
  FUNCTION fun_insert_billen(p_billid_pk           billen.billid_pk%TYPE,
                             p_writeoffid          billen.writeoffid%TYPE,
                             p_customerid          billen.customerid%TYPE,
                             p_subscriberid        billen.subscriberid%TYPE,
                             p_accountid           billen.accountid%TYPE,
                             p_rateclasssourceid   billen.rateclasssourceid%TYPE,
                             p_rateclassid         billen.rateclassid%TYPE,
                             p_invoicecycid        billen.invoicecycid%TYPE,
                             p_operwayid           billen.operwayid%TYPE,
                             p_origionfeeid        billen.origionfeeid%TYPE,
                             p_discountfeeid       billen.discountfeeid%TYPE,
                             p_factfeeid           billen.factfeeid%TYPE,
                             p_billstatusid        billen.billstatusid%TYPE,
                             p_writeoffstatusid    billen.writeoffstatusid%TYPE,
                             p_oweobjectstatusid   billen.oweobjectstatusid%TYPE,
                             p_ifauditid           billen.ifauditid%TYPE,
                             p_ifacctokid          billen.ifacctokid%TYPE,
                             p_accttypeid          billen.accttypeid%TYPE,
                             p_commicollid_pk      billen.commicollid_pk%TYPE,
                             p_billingtaskid       billen.billingtaskid%TYPE,
                             p_mem                 billen.mem%TYPE,
                             p_createid            billen.createid%TYPE,
                             p_modifyid            billen.modifyid%TYPE,
                             p_createcodestr       billen.createcodestr%TYPE,
                             p_modifycodestr       billen.modifycodestr%TYPE,
                             p_terminalid          billen.terminalid%TYPE,
                             p_salechannelid       billen.salechannelid%TYPE,
                             p_createdt            billen.createdt%TYPE,
                             p_modifydt            billen.modifydt%TYPE,
                             p_salechannelid1      billen.salechannelid1%TYPE,
                             p_operareaid          billen.operareaid%TYPE,
                             p_billingstartdt      billen.billingstartdt%TYPE,
                             p_billingenddt        billen.billingenddt%TYPE,
                             p_oweobjectid         billen.oweobjectid%TYPE,
                             p_priceinstanceid     billen.priceinstanceid%TYPE,
                             p_priceplanid         billen.priceplanid%TYPE,
                             p_rateid              billen.rateid%TYPE,
                             p_operitemid          billen.operitemid%TYPE,
                             p_productid           billen.productid%TYPE,
                             p_instanceid          billen.instanceid%TYPE,
                             p_ifprinted           billen.ifprinted%TYPE,
                             p_packageinstanceid   billen.packageinstanceid%TYPE,
                             p_discountnameliststr billen.discountnameliststr%TYPE,
                             p_refundstate         billen.refundstate%TYPE)
  
   RETURN NUMBER IS
  BEGIN
    INSERT INTO billen
      (billid_pk,
       writeoffid,
       customerid,
       subscriberid,
       accountid,
       rateclasssourceid,
       rateclassid,
       invoicecycid,
       operwayid,
       origionfeeid,
       discountfeeid,
       factfeeid,
       billstatusid,
       writeoffstatusid,
       oweobjectstatusid,
       ifauditid,
       ifacctokid,
       accttypeid,
       commicollid_pk,
       billingtaskid,
       mem,
       createid,
       modifyid,
       createcodestr,
       modifycodestr,
       terminalid,
       salechannelid,
       createdt,
       modifydt,
       salechannelid1,
       operareaid,
       billingstartdt,
       billingenddt,
       oweobjectid,
       priceinstanceid,
       billen.priceplanid,
       rateid,
       operitemid,
       productid,
       instanceid,
       ifprinted,
       packageinstanceid,
       discountnameliststr,
       refundstate)
    VALUES
      (p_billid_pk,
       p_writeoffid,
       p_customerid,
       p_subscriberid,
       p_accountid,
       p_rateclasssourceid,
       p_rateclassid,
       p_invoicecycid,
       p_operwayid,
       p_origionfeeid,
       p_discountfeeid,
       p_factfeeid,
       p_billstatusid,
       p_writeoffstatusid,
       p_oweobjectstatusid,
       p_ifauditid,
       p_ifacctokid,
       p_accttypeid,
       p_commicollid_pk,
       p_billingtaskid,
       p_mem,
       p_createid,
       p_modifyid,
       p_createcodestr,
       p_modifycodestr,
       p_terminalid,
       p_salechannelid,
       p_createdt,
       p_modifydt,
       p_salechannelid1,
       p_operareaid,
       p_billingstartdt,
       p_billingenddt,
       p_oweobjectid,
       p_priceinstanceid,
       p_priceplanid,
       p_rateid,
       p_operitemid,
       p_productid,
       p_instanceid,
       p_ifprinted,
       p_packageinstanceid,
       p_discountnameliststr,
       p_refundstate);
    RETURN(1);
  END;

  ---------------------
  ---------插入欠费用户信息
  -----------------------------
  FUNCTION fun_insert_oweobjecten(p_oweobjectid_pk           oweobjecten.oweobjectid_pk%TYPE,
                                  p_customerid               oweobjecten.customerid%TYPE,
                                  p_accountid                oweobjecten.accountid%TYPE,
                                  p_subscriberid             oweobjecten.subscriberid%TYPE,
                                  p_invoicecycid             oweobjecten.invoicecycid%TYPE,
                                  p_owetypeid                oweobjecten.owetypeid%TYPE,
                                  p_owedt                    oweobjecten.owedt%TYPE,
                                  p_owemoneyid               oweobjecten.owemoneyid%TYPE,
                                  p_isauditid                oweobjecten.isauditid%TYPE,
                                  p_operwayid                oweobjecten.operwayid%TYPE,
                                  p_treatstatusid            oweobjecten.treatstatusid%TYPE,
                                  p_urgecountid              oweobjecten.urgecountid%TYPE,
                                  p_lastedtimedt             oweobjecten.lastedtimedt%TYPE,
                                  p_mem                      oweobjecten.mem%TYPE,
                                  p_statusid                 oweobjecten.statusid%TYPE,
                                  p_createid                 oweobjecten.createid%TYPE,
                                  p_modifyid                 oweobjecten.modifyid%TYPE,
                                  p_createcodestr            oweobjecten.createcodestr%TYPE,
                                  p_modifycodestr            oweobjecten.modifycodestr%TYPE,
                                  p_terminalid               oweobjecten.terminalid%TYPE,
                                  p_salechannelid            oweobjecten.salechannelid%TYPE,
                                  p_createdt                 oweobjecten.createdt%TYPE,
                                  p_salechannelid1           oweobjecten.salechannelid1%TYPE,
                                  p_operareaid               oweobjecten.operareaid%TYPE,
                                  p_modifydt                 oweobjecten.modifydt%TYPE,
                                  p_stoptype                 oweobjecten.stoptype%TYPE,
                                  p_billids                  oweobjecten.billids%TYPE,
                                  p_billingeventid           oweobjecten.billingeventid%TYPE,
                                  p_billingserviceinstanceid oweobjecten.billingserviceinstanceid%TYPE)
  
   RETURN NUMBER
  
   IS
  BEGIN
    INSERT INTO oweobjecten
      (oweobjectid_pk,
       customerid,
       accountid,
       subscriberid,
       invoicecycid,
       owetypeid,
       owedt,
       owemoneyid,
       isauditid,
       operwayid,
       treatstatusid,
       urgecountid,
       lastedtimedt,
       mem,
       statusid,
       createid,
       modifyid,
       createcodestr,
       modifycodestr,
       terminalid,
       salechannelid,
       createdt,
       salechannelid1,
       operareaid,
       modifydt,
       stoptype,
       billids,
       billingeventid,
       billingserviceinstanceid)
    VALUES
      (p_oweobjectid_pk,
       p_customerid,
       p_accountid,
       p_subscriberid,
       p_invoicecycid,
       p_owetypeid,
       p_owedt,
       p_owemoneyid,
       p_isauditid,
       p_operwayid,
       p_treatstatusid,
       p_urgecountid,
       p_lastedtimedt,
       p_mem,
       p_statusid,
       p_createid,
       p_modifyid,
       p_createcodestr,
       p_modifycodestr,
       p_terminalid,
       p_salechannelid,
       p_createdt,
       p_salechannelid1,
       p_operareaid,
       p_modifydt,
       p_stoptype,
       p_billids,
       p_billingeventid,
       p_billingserviceinstanceid);
    RETURN(1);
  END;

  -------------------------
  --------插入销账信息------
  -------------------------------
  FUNCTION fun_insert_writeoffen(p_writeoffid_pk            writeoffen.writeoffid_pk%TYPE,
                                 p_customerid_pk            writeoffen.customerid_pk%TYPE,
                                 p_accountid_pk             writeoffen.accountid_pk%TYPE,
                                 p_paymethodid_pk           writeoffen.paymethodid_pk%TYPE,
                                 p_paymentid_pk             writeoffen.paymentid_pk%TYPE,
                                 p_noteid_pk                writeoffen.noteid_pk%TYPE,
                                 p_subscriberid_pk          writeoffen.subscriberid_pk%TYPE,
                                 p_invoicecycid_pk          writeoffen.invoicecycid_pk%TYPE,
                                 p_writeoffstatusid         writeoffen.writeoffstatusid%TYPE,
                                 p_latefeemoneyid           writeoffen.latefeemoneyid%TYPE,
                                 p_exlatefeemoneyid         writeoffen.exlatefeemoneyid%TYPE,
                                 p_moneyid                  writeoffen.moneyid%TYPE,
                                 p_usebalanceid             writeoffen.usebalanceid%TYPE,
                                 p_mem                      writeoffen.mem%TYPE,
                                 p_createid                 writeoffen.createid%TYPE,
                                 p_modifyid                 writeoffen.modifyid%TYPE,
                                 p_createcodestr            writeoffen.createcodestr%TYPE,
                                 p_modifycodestr            writeoffen.modifycodestr%TYPE,
                                 p_terminalid               writeoffen.terminalid%TYPE,
                                 p_salechannelid            writeoffen.salechannelid%TYPE,
                                 p_createdt                 writeoffen.createdt%TYPE,
                                 p_salechannelid1           writeoffen.salechannelid1%TYPE,
                                 p_operareaid               writeoffen.operareaid%TYPE,
                                 p_modifydt                 writeoffen.modifydt%TYPE,
                                 p_billingeventid           writeoffen.billingeventid%TYPE,
                                 p_billingserviceinstanceid writeoffen.billingserviceinstanceid%TYPE)
    RETURN NUMBER IS
  BEGIN
    INSERT INTO writeoffen
      (writeoffid_pk,
       customerid_pk,
       accountid_pk,
       paymethodid_pk,
       paymentid_pk,
       noteid_pk,
       subscriberid_pk,
       invoicecycid_pk,
       writeoffstatusid,
       latefeemoneyid,
       exlatefeemoneyid,
       moneyid,
       usebalanceid,
       mem,
       createid,
       modifyid,
       createcodestr,
       modifycodestr,
       terminalid,
       salechannelid,
       createdt,
       salechannelid1,
       operareaid,
       modifydt,
       billingeventid,
       billingserviceinstanceid)
    VALUES
      (p_writeoffid_pk,
       p_customerid_pk,
       p_accountid_pk,
       p_paymethodid_pk,
       p_paymentid_pk,
       p_noteid_pk,
       p_subscriberid_pk,
       p_invoicecycid_pk,
       p_writeoffstatusid,
       p_latefeemoneyid,
       p_exlatefeemoneyid,
       p_moneyid,
       p_usebalanceid,
       p_mem,
       p_createid,
       p_modifyid,
       p_createcodestr,
       p_modifycodestr,
       p_terminalid,
       p_salechannelid,
       p_createdt,
       p_salechannelid1,
       p_operareaid,
       p_modifydt,
       p_billingeventid,
       p_billingserviceinstanceid);
    RETURN(1);
  END;

  -------------------------
  --------插入押金记录------
  -------------------------------
  FUNCTION fun_insert_depositrecorden(p_depositrecordid_pk  depositrecorden.depositrecordid_pk%TYPE,
                                      p_noteid_pk           depositrecorden.noteid_pk%TYPE,
                                      p_customerid_pk       depositrecorden.customerid_pk%TYPE,
                                      p_rateclasstypeid     depositrecorden.rateclasstypeid%TYPE,
                                      p_depositamountid     depositrecorden.depositamountid%TYPE,
                                      p_paymentid           depositrecorden.paymentid%TYPE,
                                      p_statusid            depositrecorden.statusid%TYPE,
                                      p_operatetypeid       depositrecorden.operatetypeid%TYPE,
                                      p_enddt               depositrecorden.enddt%TYPE,
                                      p_tenancydonewayid    depositrecorden.tenancydonewayid%TYPE,
                                      p_mem                 depositrecorden.mem%TYPE,
                                      p_createid            depositrecorden.createid%TYPE,
                                      p_modifyid            depositrecorden.modifyid%TYPE,
                                      p_createcodestr       depositrecorden.createcodestr%TYPE,
                                      p_modifycodestr       depositrecorden.modifycodestr%TYPE,
                                      p_terminalid          depositrecorden.terminalid%TYPE,
                                      p_salechannelid       depositrecorden.salechannelid%TYPE,
                                      p_createdt            depositrecorden.createdt%TYPE,
                                      p_modifydt            depositrecorden.modifydt%TYPE,
                                      p_salechannelid1      depositrecorden.salechannelid1%TYPE,
                                      p_operareaid          depositrecorden.operareaid%TYPE,
                                      p_depositsettlementid depositrecorden.depositsettlementid%TYPE,
                                      p_productinstanceid   depositrecorden.productinstanceid%TYPE,
                                      p_priceinstanceid     depositrecorden.priceinstanceid%TYPE,
                                      p_subscriberid        depositrecorden.subscriberid%TYPE,
                                      p_priceplanid         depositrecorden.priceplanid%TYPE,
                                      p_productid           depositrecorden.productid%TYPE
                                      
                                      ) RETURN NUMBER IS
  BEGIN
    INSERT INTO depositrecorden
      (depositrecordid_pk,
       noteid_pk,
       customerid_pk,
       rateclasstypeid,
       depositamountid,
       paymentid,
       statusid,
       operatetypeid,
       enddt,
       tenancydonewayid,
       mem,
       createid,
       modifyid,
       createcodestr,
       modifycodestr,
       terminalid,
       salechannelid,
       createdt,
       modifydt,
       salechannelid1,
       operareaid,
       depositsettlementid,
       productinstanceid,
       priceinstanceid,
       subscriberid,
       priceplanid,
       productid)
    VALUES
      (p_depositrecordid_pk,
       p_noteid_pk,
       p_customerid_pk,
       p_rateclasstypeid,
       p_depositamountid,
       p_paymentid,
       p_statusid,
       p_operatetypeid,
       p_enddt,
       p_tenancydonewayid,
       p_mem,
       p_createid,
       p_modifyid,
       p_createcodestr,
       p_modifycodestr,
       p_terminalid,
       p_salechannelid,
       p_createdt,
       p_modifydt,
       p_salechannelid1,
       p_operareaid,
       p_depositsettlementid,
       p_productinstanceid,
       p_priceinstanceid,
       p_subscriberid,
       p_priceplanid,
       p_productid);
    RETURN(1);
  END;

  -------------------------
  --------插入付款记录------
  -------------------------------
  FUNCTION fun_insert_paymenten(p_paymentid_pk        paymenten.paymentid_pk%TYPE,
                                p_accountid_pk        paymenten.accountid_pk%TYPE,
                                p_paymethodid_pk      paymenten.paymethodid_pk%TYPE,
                                p_customerid_pk       paymenten.customerid_pk%TYPE,
                                p_tradetypeid         paymenten.tradetypeid%TYPE,
                                p_paymentstatusid     paymenten.paymentstatusid%TYPE,
                                p_amountid            paymenten.amountid%TYPE,
                                p_paymentdt           paymenten.paymentdt%TYPE,
                                p_checkcodestr        paymenten.checkcodestr%TYPE,
                                p_checksrcstr         paymenten.checksrcstr%TYPE,
                                p_checkvaliddt        paymenten.checkvaliddt%TYPE,
                                p_bankterminalstr     paymenten.bankterminalstr%TYPE,
                                p_bankcodestr         paymenten.bankcodestr%TYPE,
                                p_bankaccountcodestr  paymenten.bankaccountcodestr%TYPE,
                                p_bankdealstr         paymenten.bankdealstr%TYPE,
                                p_bankacceptstr       paymenten.bankacceptstr%TYPE,
                                p_bankoperatorstr     paymenten.bankoperatorstr%TYPE,
                                p_ifcheckid           paymenten.ifcheckid%TYPE,
                                p_ifproofid           paymenten.ifproofid%TYPE,
                                p_ifchargeid          paymenten.ifchargeid%TYPE,
                                p_operatedserialnbrid paymenten.operatedserialnbrid%TYPE,
                                p_chancollid_pk       paymenten.chancollid_pk%TYPE,
                                p_mem                 paymenten.mem%TYPE,
                                p_createid            paymenten.createid%TYPE,
                                p_modifyid            paymenten.modifyid%TYPE,
                                p_createcodestr       paymenten.createcodestr%TYPE,
                                p_modifycodestr       paymenten.modifycodestr%TYPE,
                                p_terminalid          paymenten.terminalid%TYPE,
                                p_salechannelid       paymenten.salechannelid%TYPE,
                                p_createdt            paymenten.createdt%TYPE,
                                p_modifydt            paymenten.modifydt%TYPE,
                                p_salechannelid1      paymenten.salechannelid1%TYPE,
                                p_operareaid          paymenten.operareaid%TYPE,
                                p_resourceid_pk       paymenten.resourceid_pk%TYPE,
                                p_developid           paymenten.developid%TYPE
                                
                                ) RETURN NUMBER IS
  BEGIN
    INSERT INTO paymenten
      (paymentid_pk,
       accountid_pk,
       paymethodid_pk,
       customerid_pk,
       tradetypeid,
       paymentstatusid,
       amountid,
       paymentdt,
       checkcodestr,
       checksrcstr,
       checkvaliddt,
       bankterminalstr,
       bankcodestr,
       bankaccountcodestr,
       bankdealstr,
       bankacceptstr,
       bankoperatorstr,
       ifcheckid,
       ifproofid,
       ifchargeid,
       operatedserialnbrid,
       chancollid_pk,
       mem,
       createid,
       modifyid,
       createcodestr,
       modifycodestr,
       terminalid,
       salechannelid,
       createdt,
       modifydt,
       salechannelid1,
       operareaid,
       resourceid_pk,
       developid)
    VALUES
      (p_paymentid_pk,
       p_accountid_pk,
       p_paymethodid_pk,
       p_customerid_pk,
       p_tradetypeid,
       p_paymentstatusid,
       p_amountid,
       p_paymentdt,
       p_checkcodestr,
       p_checksrcstr,
       p_checkvaliddt,
       p_bankterminalstr,
       p_bankcodestr,
       p_bankaccountcodestr,
       p_bankdealstr,
       p_bankacceptstr,
       p_bankoperatorstr,
       p_ifcheckid,
       p_ifproofid,
       p_ifchargeid,
       p_operatedserialnbrid,
       p_chancollid_pk,
       p_mem,
       p_createid,
       p_modifyid,
       p_createcodestr,
       p_modifycodestr,
       p_terminalid,
       p_salechannelid,
       p_createdt,
       p_modifydt,
       p_salechannelid1,
       p_operareaid,
       p_resourceid_pk,
       p_developid);
    RETURN(1);
  END;
  -------------------------
  --------插入单元------
  -------------------------------
  FUNCTION fun_insert_uniten(p_unitid_pk      uniten.unitid_pk%TYPE,
                             p_unitnamestr    uniten.unitnamestr%TYPE,
                             p_unitcodestr    uniten.unitcodestr%TYPE,
                             p_unitnum        uniten.unitnum%TYPE,
                             p_addressid      uniten.addressid%TYPE,
                             p_subnum         uniten.subnum%TYPE,
                             p_statusid       uniten.statusid%TYPE,
                             p_mem            uniten.mem%TYPE,
                             p_createid       uniten.createid%TYPE,
                             p_modifyid       uniten.modifyid%TYPE,
                             p_createcodestr  uniten.createcodestr%TYPE,
                             p_modifycodestr  uniten.modifycodestr%TYPE,
                             p_terminalid     uniten.terminalid%TYPE,
                             p_salechannelid  uniten.salechannelid%TYPE,
                             p_createdt       uniten.createdt%TYPE,
                             p_modifydt       uniten.modifydt%TYPE,
                             p_salechannelid1 uniten.salechannelid1%TYPE,
                             p_operareaid     uniten.operareaid%TYPE
                             
                             ) RETURN NUMBER IS
  BEGIN
    INSERT INTO uniten
      (unitid_pk,
       unitnamestr,
       unitcodestr,
       unitnum,
       addressid,
       subnum,
       statusid,
       mem,
       createid,
       modifyid,
       createcodestr,
       modifycodestr,
       terminalid,
       salechannelid,
       createdt,
       modifydt,
       salechannelid1,
       operareaid)
    VALUES
      (p_unitid_pk,
       p_unitnamestr,
       p_unitcodestr,
       p_unitnum,
       p_addressid,
       p_subnum,
       p_statusid,
       p_mem,
       p_createid,
       p_modifyid,
       p_createcodestr,
       p_modifycodestr,
       p_terminalid,
       p_salechannelid,
       p_createdt,
       p_modifydt,
       p_salechannelid1,
       p_operareaid);
    RETURN(1);
  END;

  -------------------------
  --------插入楼层------
  -------------------------------
  FUNCTION fun_insert_flooren(p_floorid_pk     flooren.floorid_pk%TYPE,
                              p_floornamestr   flooren.floornamestr%TYPE,
                              p_floorcodestr   flooren.floorcodestr%TYPE,
                              p_floornum       flooren.floornum%TYPE,
                              p_addressid      flooren.addressid%TYPE,
                              p_statusid       flooren.statusid%TYPE,
                              p_mem            flooren.mem%TYPE,
                              p_createid       flooren.createid%TYPE,
                              p_modifyid       flooren.modifyid%TYPE,
                              p_createcodestr  flooren.createcodestr%TYPE,
                              p_modifycodestr  flooren.modifycodestr%TYPE,
                              p_terminalid     flooren.terminalid%TYPE,
                              p_salechannelid  flooren.salechannelid%TYPE,
                              p_createdt       flooren.createdt%TYPE,
                              p_modifydt       flooren.modifydt%TYPE,
                              p_salechannelid1 flooren.salechannelid1%TYPE,
                              p_operareaid     flooren.operareaid%TYPE
                              
                              ) RETURN NUMBER IS
  BEGIN
    INSERT INTO flooren
      (floorid_pk,
       floornamestr,
       floorcodestr,
       floornum,
       addressid,
       statusid,
       mem,
       createid,
       modifyid,
       createcodestr,
       modifycodestr,
       terminalid,
       salechannelid,
       createdt,
       modifydt,
       salechannelid1,
       operareaid)
    VALUES
      (p_floorid_pk,
       p_floornamestr,
       p_floorcodestr,
       p_floornum,
       p_addressid,
       p_statusid,
       p_mem,
       p_createid,
       p_modifyid,
       p_createcodestr,
       p_modifycodestr,
       p_terminalid,
       p_salechannelid,
       p_createdt,
       p_modifydt,
       p_salechannelid1,
       p_operareaid);
    RETURN(1);
  END;

  -------------------------
  --------插入方格------
  -------------------------------
  FUNCTION fun_insert_murotoen(p_murotoid_pk    murotoen.murotoid_pk%TYPE,
                               p_murotonamestr  murotoen.murotonamestr%TYPE,
                               p_murotocodestr  murotoen.murotocodestr%TYPE,
                               p_murotonum      murotoen.murotonum%TYPE,
                               p_addressid      murotoen.addressid%TYPE,
                               p_floorid        murotoen.floorid%TYPE,
                               p_unitid         murotoen.unitid%TYPE,
                               p_isenable       murotoen.isenable%TYPE,
                               p_statusid       murotoen.statusid%TYPE,
                               p_mem            murotoen.mem%TYPE,
                               p_createid       murotoen.createid%TYPE,
                               p_modifyid       murotoen.modifyid%TYPE,
                               p_createcodestr  murotoen.createcodestr%TYPE,
                               p_modifycodestr  murotoen.modifycodestr%TYPE,
                               p_terminalid     murotoen.terminalid%TYPE,
                               p_salechannelid  murotoen.salechannelid%TYPE,
                               p_createdt       murotoen.createdt%TYPE,
                               p_modifydt       murotoen.modifydt%TYPE,
                               p_salechannelid1 murotoen.salechannelid1%TYPE,
                               p_operareaid     murotoen.operareaid%TYPE
                               
                               ) RETURN NUMBER IS
  BEGIN
    INSERT INTO murotoen
      (murotoid_pk,
       murotonamestr,
       murotocodestr,
       murotonum,
       addressid,
       floorid,
       unitid,
       isenable,
       statusid,
       mem,
       createid,
       modifyid,
       createcodestr,
       modifycodestr,
       terminalid,
       salechannelid,
       createdt,
       modifydt,
       salechannelid1,
       operareaid)
    VALUES
      (p_murotoid_pk,
       p_murotonamestr,
       p_murotocodestr,
       p_murotonum,
       p_addressid,
       p_floorid,
       p_unitid,
       p_isenable,
       p_statusid,
       p_mem,
       p_createid,
       p_modifyid,
       p_createcodestr,
       p_modifycodestr,
       p_terminalid,
       p_salechannelid,
       p_createdt,
       p_modifydt,
       p_salechannelid1,
       p_operareaid);
    RETURN(1);
  END;

END;
/
