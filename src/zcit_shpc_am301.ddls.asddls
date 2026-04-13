@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Shipment Header Consumption View'
@Search.searchable: true
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZCIT_SHPC_AM301
  provider contract transactional_query
  as projection on ZCIT_SHPI_AM301
{
  key ShipmentId,
  SenderName,
  ReceiverName,
  Origin,
  @Search.defaultSearchElement: true
  Destination,
  BookingDate,
  ExpectedDelivery,
  CurrentLocation,
  Status,
  StatusCriticality,
  @Semantics.quantity.unitOfMeasure: 'TimeUnit'
  DeliveryTime,
  TimeUnit,
  DelayFlag,
  ProgressPct,
  LocalCreatedBy,
  LocalCreatedAt,
  LocalLastChangedBy,
  LocalLastChangedAt,
 
  /* Associations */
  _trackinglog : redirected to composition child ZCIT_TLGC_AM301
}
