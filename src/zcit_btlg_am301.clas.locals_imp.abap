CLASS lhc_TrackingLog DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE TrackingLog.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE TrackingLog.

    METHODS read FOR READ
      IMPORTING keys FOR READ TrackingLog RESULT result.

    METHODS rba_ShipmentHeader FOR READ
      IMPORTING keys_rba FOR READ TrackingLog\_shipmentHeader
      FULL result_requested RESULT result LINK association_links.

ENDCLASS.

CLASS lhc_TrackingLog IMPLEMENTATION.

  METHOD update.
    DATA ls_tlog TYPE zcit_tlgt_am301.
    LOOP AT entities INTO DATA(ls_ent).
      ls_tlog = CORRESPONDING #( ls_ent MAPPING FROM ENTITY ).
      IF ls_tlog-shipmentid IS NOT INITIAL.
        SELECT FROM zcit_tlgt_am301
          FIELDS logsequence
          WHERE shipmentid  = @ls_tlog-shipmentid
          AND   logsequence = @ls_tlog-logsequence
          INTO TABLE @DATA(lt_chk).
        IF sy-subrc EQ 0.
          DATA(lo_util) = zcit_util_am301=>get_instance( ).
          lo_util->set_tlog_value(
            EXPORTING im_tlog    = ls_tlog
            IMPORTING ex_created = DATA(lv_ok) ).
          IF lv_ok = abap_true.
            APPEND VALUE #(
              shipmentid  = ls_tlog-shipmentid
              logsequence = ls_tlog-logsequence )
              TO mapped-trackinglog.
          ENDIF.
        ELSE.
          APPEND VALUE #(
            shipmentid  = ls_tlog-shipmentid
            logsequence = ls_tlog-logsequence )
            TO failed-trackinglog.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD delete.
    DATA(lo_util) = zcit_util_am301=>get_instance( ).
    LOOP AT keys INTO DATA(ls_key).
      lo_util->set_tlog_del(
        im_key = VALUE #(
          shipmentid  = ls_key-shipmentid
          logsequence = ls_key-logsequence ) ).
      APPEND VALUE #(
        shipmentid  = ls_key-shipmentid
        logsequence = ls_key-logsequence )
        TO mapped-trackinglog.
    ENDLOOP.
  ENDMETHOD.

  METHOD read.
    LOOP AT keys INTO DATA(ls_key).
      SELECT SINGLE FROM zcit_tlgt_am301
        FIELDS *
        WHERE shipmentid  = @ls_key-shipmentid
        AND   logsequence = @ls_key-logsequence
        INTO @DATA(ls_tlog).
      IF sy-subrc = 0.
        APPEND CORRESPONDING #( ls_tlog ) TO result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD rba_ShipmentHeader.
    LOOP AT keys_rba INTO DATA(ls_key).
      SELECT SINGLE FROM zcit_shpt_am301
        FIELDS *
        WHERE shipmentid = @ls_key-shipmentid
        INTO @DATA(ls_ship).
      IF sy-subrc = 0.
        APPEND CORRESPONDING #( ls_ship ) TO result.
        APPEND VALUE #(
          source-shipmentid  = ls_key-shipmentid
          source-logsequence = ls_key-logsequence
          target-shipmentid  = ls_ship-shipmentid )
          TO association_links.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
