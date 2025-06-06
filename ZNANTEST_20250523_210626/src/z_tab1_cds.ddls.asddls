@AbapCatalog.sqlViewName: 'Z_TAB1_CDS_VIEW'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '表tab1的cds'
define view z_tab1_cds as select from ztab1
//z_tab1_cds为cds实体名  
//@AbapCatalog.sqlViewName: 'xxx'为cds视图，数据库会创建对应的视图，
//data_source_name为透明表
{
    key uuid as Uuid,
    desc1 as Desc1,
    desc2 as Desc2,
    createdate as Createdate,
    creater as Creater,
    age as Age
    
}
