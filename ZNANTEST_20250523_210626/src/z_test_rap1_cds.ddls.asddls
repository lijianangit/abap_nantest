@AbapCatalog.sqlViewName: 'Z_TEST_RAP1_VIEW'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Z_test_Rap1_cds'
@Metadata.ignorePropagatedAnnotations: true
define view Z_test_Rap1_cds as select from ztestrap1
{
    key uuid as Uuid,
    carrier_id as CarrierId,
    connection_id as ConnectionId,
    airport_from_id as AirportFromId,
    country_from as CountryFrom,
    airport_to_id as AirportToId,
    country_to as CountryTo
}
