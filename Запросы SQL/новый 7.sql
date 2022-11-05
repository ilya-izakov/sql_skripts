WITH logist as 
(SELECT
  mvw.STOCK_CONTROL + mvw.LEAD_TIME as  Дн,
  mvw_main_item_v.VENDOR_NUM as  Код_пост,
  mvw_main_item_v.VENDOR_NAME as  Наименование_поставщика,
  DECODE(NVL(mvw.vend_whse_status, 'D'), 'D', mvw_main_item_v.VEND_PARENT_NAME, mvw.VEND_PARENT_NAME) as  Наименование_грузоотправителя ,
  DECODE(NVL(mvw.vend_whse_status, 'D'), 'D', mvw_main_item_v.VEND_PARENT_NUM, mvw.VEND_PARENT_NUM) as  Код_груз ,
  mvw.ITEM_NUM
FROM
  KDW.DWE_MAIN_VEND_WHSE  mvw,
  KDW.DWE_MAIN_ITEM_V  mvw_main_item_v,
  KDW.DW_GOODS g
WHERE
   mvw.VEND_WHSE_STATUS <> 'D' 
  AND  ( mvw.ITEM_NUM = mvw_main_item_v.ITEM_NUM )
  AND  ( mvw.whse_code=g.skl_osn)
  AND  mvw.ITEM_NUM=g.ITEM_NUM
  ),
  tovar as 
  (
	SELECT 
  ol_w.WHSE_CODE as Склад_заказа,
  ol_i.skl_osn as  СОХ,
  ol.ORDER_NUM as  N_Зак_ВП,
  oj.DIV_CODE as  Отдел,
  ol.ITEM_NUM as  Товар,
  ol_i.IND_CATEGORY as  К,
  ol_i.ITEM_NAME as  Наименование,
  ol.SHIPPED_QTY as  Выписано,
  ol.COMMITTED_QTY as  Выделено,
  oj.NEW_STAT as  С,
  oj.NEW_STAT_NAME as  Статус,
  op.USER_CODE as  Менеджер,
  op.USER_NAME as  ФИО_Менеджера,
  oj.REQUEST_DATE as  Поставка  
	FROM
  KDW.DWF_ORD_L  ol,
  KDW.DWD_WHSE  ol_w,
  KDW.DWD_ITEM  ol_i,
  KDW.DWF_ORD_L_CD_J  oj,
  KDW.DWD_U_OPER op
	WHERE ( ol.ID_WHSE=ol_w.ID_WHSE )
  AND ( op.ID_U_OPER(+)=ol.ID_USER_CREATED )
  AND ( ol.ID_ITEM=ol_i.ID_ITEM  )
  AND ( oj.ORD_L_ID(+)=ol.ORD_L_ID )
  AND (
  ( ol.ID_ORDER_DATE BETWEEN (SELECT kdw.getDateID(TO_DATE(@Prompt('1. Дата начала периода','A',,mono,free), 'DD.MM.YYYY')) FROM dual) AND  (SELECT kdw.getDateID(TO_DATE(@Prompt('2. Дата окончания периода','A',,mono,free), 'DD.MM.YYYY')) FROM dual )  )
  AND ( ol.ITEM_NUM IN @Prompt('5. Артикул','A',,multi,free) OR 'все' IN @Prompt('5. Артикул','A',,multi,free)  ) )
  )
  Select *
  From 
  logist,
  tovar
  WHERE
  logist.ITEM_NUM(+)=tovar.Товар 