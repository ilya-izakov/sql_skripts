SELECT 
  mvw.STOCK_CONTROL + mvw.LEAD_TIME as "Дн",
  ol_w.WHSE_CODE as "Склад заказа",
  ol_i.SKL_OSN as "СОХ"
  ol.ORDER_NUM as "N Зак/ВП",
  oj.DIV_CODE as "Отдел",
  ol.ITEM_NUM as "Товар",
  ol_i.IND_CATEGORY as "К",
  ol_i.ITEM_NAME as "Наименование",
  ol.SHIPPED_QTY as "Выписано",
  ol.COMMITTED_QTY as "Выделено",
  oj.NEW_STAT as "С",
  oj.NEW_STAT_NAME as "Статус",
  op.USER_CODE as "Менеджер",
  op.USER_NAME as "ФИО Менеджера",
  oj.REQUEST_DATE as "Поставка",
  mvw_main_item_v.VENDOR_NUM as "Код пост",
  mvw_main_item_v.VENDOR_NAME as "Наименование поставщика",
  DECODE(NVL(mvw.vend_whse_status, 'D'), 'D', mvw_main_item_v.VEND_PARENT_NAME, mvw.VEND_PARENT_NAME) as "Наименование грузоотправителя",
  DECODE(NVL(mvw.vend_whse_status, 'D'), 'D', mvw_main_item_v.VEND_PARENT_NUM, mvw.VEND_PARENT_NUM) as "Код груз-л"
  FROM
  KDW.DWF_ORD_L  ol,
  KDW.DWD_WHSE  ol_w,
  KDW.DWD_ITEM  ol_i,
  KDW.DWF_ORD_L_CD_J  oj,
  KDW.DWE_MAIN_VEND_WHSE  mvw,
  KDW.DWE_MAIN_ITEM_V  mvw_main_item_v,
  KDW.DWD_U_OPER op

  

  
WHERE ( ol.ID_WHSE=ol_w.ID_WHSE )
  AND ( op.ID_U_OPER(+)=ol.ID_USER_CREATED )
  AND  ( ol.ID_ITEM=ol_i.ID_ITEM  )
  --AND   (ol_i.IS_CURRENT='Y')
  AND  ( oj.ORD_L_ID(+)=ol.ORD_L_ID )
  AND  ( mvw.ITEM_NUM(+)=ol.ITEM_NUM)
  AND  ( mvw.ID_WHSE(+)=ol.ID_WHSE )
  AND  ( mvw.VEND_WHSE_STATUS <> 'D' )
  AND  ( mvw.ITEM_NUM = mvw_main_item_v.ITEM_NUM )
  AND  (
  ( ol.ID_ORDER_DATE BETWEEN (SELECT kdw.getDateID(TO_DATE(@Prompt('1. Дата начала периода','A',,mono,free), 'DD.MM.YYYY')) FROM dual) AND  (SELECT kdw.getDateID(TO_DATE(@Prompt('2. Дата окончания периода','A',,mono,free), 'DD.MM.YYYY')) FROM dual )  )
  AND  ( ol.ITEM_NUM IN @Prompt('5. Артикул','A',,multi,free) OR 'все' IN @Prompt('5. Артикул','A',,multi,free)  )
  )
  AND ol.ORDER_NUM='13249773'