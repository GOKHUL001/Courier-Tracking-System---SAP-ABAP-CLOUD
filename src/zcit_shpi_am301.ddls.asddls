@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root Interface View – Shipment Header'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZCIT_SHPI_AM301
  as select from zcit_shpt_am301 as ShipHeader
  composition [0..*] of ZCIT_TLGI_AM301 as _trackinglog
{
  key shipmentid          as ShipmentId,
  sendername              as SenderName,
  receivername            as ReceiverName,
  origin                  as Origin,
  destination             as Destination,
  bookingdate             as BookingDate,
  expecteddelivery        as ExpectedDelivery,
  currentlocation         as CurrentLocation,
  status                  as Status,
  @Semantics.quantity.unitOfMeasure: 'TimeUnit'
  deliverytime            as DeliveryTime,
  timeunit                as TimeUnit,
  delayflag               as DelayFlag,
  progresspct             as ProgressPct,
  @Semantics.user.createdBy: true
  local_created_by        as LocalCreatedBy,
  @Semantics.systemDateTime.createdAt: true
  local_created_at        as LocalCreatedAt,
  @Semantics.user.lastChangedBy: true
  local_last_changed_by   as LocalLastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at   as LocalLastChangedAt,
 
 case status
    when 'PENDING'    then 2
    when 'IN_TRANSIT' then 5
    when 'DELIVERED'  then 3
    when 'CANCELLED'  then 1
    else                   0
  end                    as StatusCriticality,
 
  /* Associations */
  _trackinglog
}
