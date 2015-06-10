
SELECT 'create index ' || ui.index_name || ' on ' || ui.table_name || ' (' ||
       uu.cols || ');'
  FROM user_indexes ui,
       (SELECT uic2.index_name,
               to_char(substr(wm_concat(uic2.column_name), 0, 3999)) cols
          FROM (SELECT uic.index_name, uic.column_name, uic.column_position
                  FROM user_ind_columns uic
                 ORDER BY uic.column_position) uic2
         GROUP BY uic2.index_name) uu
 WHERE ui.index_name = uu.index_name
 and ui.table_name IN ('PAYMENTITEMS_FS',
                         'CUSTOMERACCOUNTBALANCES_FS',
                         'PAYMENTS_FS',
                         'CUSTOMERACCOUNTS_FS',
                         'EMPLOYEE_ORGANIZATIONUNIT',
                         'PLACES',
                         'MANAGEADDRESSES_FS',
                         'CUSTOMERS_FS',
                         'PRODUCTS_FS',
                         'PRODUCTOFFERINGATTRIBUTES',
                         'SIMPLETYPES',
                         'TERMINALS_FS',
                         'TERMINALSPECIFICATIONS',
                         'SMARTCARDS_FS',
                         'PRODUCTPHYSICALRESOURCES_FS',
                         'PRODUCTOFFERINGS',
                         'PRODUCTSERVICES_FS',
                         'USERSERVICES_FS',
                         'USERS_FS',
                         'TERMINALS_FS',
                         'EOCS_FS',
                         'PREFERENTIALPOLICIES',
                         'ORGANIZATIONUNITINFOS',
                         'AREAS',
                         'AREAMANAGESECTIONS',
                         'SMARTCARDSPECIFICATIONS',
                         'PHYSICALRESOURCEENTRYITEMS_FS',
                         'PHYSICALRESOURCEENTRIES_FS',
                         'SETTOPBOXS_FS',
                         'SETTOPBOXSPECIFICATIONS',
                         'EOCSPECIFICATIONS',
                         'CUSTOMERLEVELAGREEMENTS_FS');
