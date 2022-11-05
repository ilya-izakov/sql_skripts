Select 
  ol_w.WHSE_CODE,
  ol.COMMITTED_QTY,
  ol.SHIPPED_QTY,
  ol.ITEM_NUM,
  ol_i.ITEM_NAME,
  ol_i.IND_CATEGORY,
  ol_main_v.VENDOR_NUM,
  ol_main_v.VENDOR_NAME,
  ol_main_v.STOCK_CONTROL,
  ol_main_v.LEAD_TIME,
  oj.ORDER_NUM,
  oj.DIV_CODE,
  oj_o.NEW_STAT,
  oj_o.NEW_STAT_NAME,
  oj.REQUEST_DATE,
  ol.ID_USER_CREATED,
  op.USER_CODE,
  op.USER_NAME,
  DECODE(NVL(mvw.vend_whse_status, 'D'), 'D', mvw_main_item_v.VEND_PARENT_NAME, mvw.VEND_PARENT_NAME),
  DECODE(NVL(mvw.vend_whse_status, 'D'), 'D', mvw_main_item_v.VEND_PARENT_NUM, mvw.VEND_PARENT_NUM)
FROM
(SELECT 
  ol_w.WHSE_CODE,
  ol.COMMITTED_QTY,
  ol.SHIPPED_QTY,
  ol.ITEM_NUM,
  ol_i.ITEM_NAME,
  ol_i.IND_CATEGORY,
  ol_main_v.VENDOR_NUM,
  ol_main_v.VENDOR_NAME,
  ol_main_v.STOCK_CONTROL,
  ol_main_v.LEAD_TIME,
  oj.ORDER_NUM,
  oj.DIV_CODE,
  oj_o.NEW_STAT,
  oj_o.NEW_STAT_NAME,
  oj.REQUEST_DATE,
  ol.ID_USER_CREATED,
  DECODE(NVL(mvw.vend_whse_status, 'D'), 'D', mvw_main_item_v.VEND_PARENT_NAME, mvw.VEND_PARENT_NAME),
  DECODE(NVL(mvw.vend_whse_status, 'D'), 'D', mvw_main_item_v.VEND_PARENT_NUM, mvw.VEND_PARENT_NUM)
  FROM
  KDW.DWF_ORD_L  ol,
  KDW.DWD_WHSE  ol_w,
  KDW.DWD_ITEM  ol_i,
  KDW.DWE_MAIN_ITEM_V  ol_main_v,
  KDW.DWF_ORD_L_CD_J  oj,
  KDW.DWD_ORD_L_CD_J_OTHER  oj_o,
  KDW.DWE_MAIN_VEND_WHSE  mvw,
  KDW.DWE_MAIN_ITEM_V  mvw_main_item_v
WHERE
 ( ol.ID_WHSE=ol_w.ID_WHSE  )
  AND  ( ol.ID_ITEM=ol_i.ID_ITEM  )
  AND  ( ol.ITEM_NUM=ol_main_v.ITEM_NUM  )
  AND  ( oj.ORD_L_ID=ol.ORD_L_ID )
  AND  ( oj_o.ID_ORD_L_CD_J_OTHER=oj.ID_ORD_L_CD_J_OTHER )
  AND  ( mvw.ITEM_NUM=ol.ITEM_NUM)
  AND  (mvw.WHSE_CODE=ol_w.WHSE_CODE)
  AND ( mvw.VEND_WHSE_STATUS <> 'D'  )
  AND  ( mvw.ITEM_NUM = mvw_main_item_v.ITEM_NUM )
  AND  (
  ( ol.ID_ORDER_DATE BETWEEN (SELECT kdw.getDateID(TO_DATE(@Prompt('1. Дата начала периода','A',,mono,free), 'DD.MM.YYYY')) FROM dual) AND  (SELECT kdw.getDateID(TO_DATE(@Prompt('2. Дата окончания периода','A',,mono,free), 'DD.MM.YYYY')) FROM dual )  )
  AND  ( ol.ITEM_NUM IN @Prompt('5. Артикул','A',,multi,free) OR 'все' IN @Prompt('5. Артикул','A',,multi,free)  )
  ))
  LEFT JOIN 
  (select *
  from 
  KDW.DWD_U_OPER op)
  on op.ID_U_OPER=ol.ID_USER_CREATED