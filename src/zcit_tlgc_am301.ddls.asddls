@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Tracking Log Consumption View'
@Search.searchable: true
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZCIT_TLGC_AM301
  as projection on ZCIT_TLGI_AM301
{
  key ShipmentId,
  key LogSequence,
  LogTimestamp,
  @Search.defaultSearchElement: true
  LogLocation,
  StatusUpdate,
  Remarks,
  LocalCreatedBy,
  LocalCreatedAt,
  LocalLastChangedBy,
  LocalLastChangedAt,
 
  /* Associations */
  _shipmentHeader : redirected to parent ZCIT_SHPC_AM301
}
