@AbapCatalog.sqlViewName: 'Z_TAB2_CDS_VIEW'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '表tab2的cds'
define view Z_tab2_cds as select from ztab2 
inner join ztab1 on ztab2.tab1id = ztab1.uuid 
inner join ztab3 on ztab2.tab13d = ztab3.uuid 

{
    key ztab1.uuid as Uuid,
    key ztab2.uuid as ztab2_Uuid,
    ztab1.desc1 as Desc1,
    ztab1.desc2 as Desc2,
    ztab1.createdate as Createdate,
    ztab1.creater as Creater,
    ztab1.age as Age,
    ztab2.desc2 as ztab2_Desc2,
    ztab2.createdate as ztab2_Createdate,
    ztab2.creater as ztab2_Creater,
    ztab2.age as ztab2_Age,
    ztab2.tab1id as ztab2_Tab1id,
    ztab2.tab13d as ztab2_Tab13d
}

