@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Child Interface View – Tracking Log'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MIXED
}
define view entity ZCIT_TLGI_AM301
  as select from zcit_tlgt_am301
  association to parent ZCIT_SHPI_AM301 as _shipmentHeader
    on $projection.ShipmentId = _shipmentHeader.ShipmentId
{
  key shipmentid      as ShipmentId,
  key logsequence     as LogSequence,
  logtimestamp        as LogTimestamp,
  loglocation         as LogLocation,
  statusupdate        as StatusUpdate,
  remarks             as Remarks,
  @Semantics.user.createdBy: true
  local_created_by    as LocalCreatedBy,
  @Semantics.systemDateTime.createdAt: true
  local_created_at    as LocalCreatedAt,
  @Semantics.user.lastChangedBy: true
  local_last_changed_by  as LocalLastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at  as LocalLastChangedAt,
 
  /* Associations */
  _shipmentHeader
}
