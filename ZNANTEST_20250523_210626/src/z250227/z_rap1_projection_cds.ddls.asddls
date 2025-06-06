@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Travel projection view - Processor'

@Search.searchable: true

@UI.headerInfo: { typeName: 'Travel',
                  typeNamePlural: 'Travels',
                  title: { type: #STANDARD, value: 'TravelID' } }

define root view entity Z_RAP1_PROJECTION_CDS
  as projection on znantest_rap1_cds

{
      @Search.defaultSearchElement: true
      @UI.facet: [ { id: 'Travel',
                     purpose: #STANDARD,
                     type: #IDENTIFICATION_REFERENCE,
                     label: 'Travel',
                     position: 10 } ]
      @UI.identification: [ { position: 10, label: 'Travel ID [1,...,99999999]' } ]
      @UI.lineItem: [ { position: 10, importance: #HIGH } ]
  key travel_id          as TravelID,

      @UI: {
          lineItem:       [ { position: 20, importance: #HIGH } ],
          identification: [ { position: 20 } ],
          selectionField: [ { position: 20 } ] }
      @Consumption.valueHelpDefinition: [{ entity : {name: '/DMO/I_Agency', element: 'AgencyID'  } }]

      @ObjectModel.text.element: ['AgencyName'] ----meaning?
      @Search.defaultSearchElement: true
      agency_id          as AgencyID,

      _Agency.Name       as AgencyName,

      @Consumption.valueHelpDefinition: [ { entity: { name: '/DMO/I_Customer', element: 'CustomerID' } } ]
      @ObjectModel.text.element: [ 'CustomerName' ]
      @Search.defaultSearchElement: true
      @UI.identification: [ { position: 30 } ]
      @UI.lineItem: [ { position: 30, importance: #HIGH } ]
      @UI.selectionField: [ { position: 30 } ]
      customer_id        as CustomerID,

      @UI.hidden: true
      _Customer.LastName as CustomerName,

      @UI.identification: [ { position: 40 } ]
      @UI.lineItem: [ { position: 40, importance: #MEDIUM } ]
      begin_date         as BeginDate,

      @UI.identification: [ { position: 41 } ]
      @UI.lineItem: [ { position: 41, importance: #MEDIUM } ]
      end_date           as EndDate,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      @UI.identification: [ { position: 50, label: 'Total Price' } ]
      @UI.lineItem: [ { position: 50, importance: #MEDIUM } ]
      total_price        as TotalPrice,

      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_Currency', element: 'Currency' } } ]
      currency_code      as CurrencyCode,

      @UI.identification: [ { position: 60, label: 'Remarks' } ]
      description        as Description,

      @UI.hidden: true
      last_changed_at    as LastChangedAt
}
