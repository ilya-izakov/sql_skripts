SELECT   
  VENDOR_PO_L.VENDOR_NUM,
  VENDOR_PO_L.VEND_NAME,
  WHSE_PO_L.WHSE_CODE,
  PO_DATE_PO_L.CAL_DATE,
  ITEM_PO_L.ITEM_NUM,
  ITEM_PO_L.ITEM_NAME,
  ITEM_PO_L.ITEM_TYPE,
  PO_L.PO_NUM,
  PO_L.SPEC_NUM,
  OTHER_PO_L.PO_STATUS,
  POL_SHIP_VEND.VEND_NAME,
  POL_SHIP_VEND.VENDOR_NUM,
  SUM(( PO_L.QTY_ORDERED )),
  SUM(( PO_L.QTY_RECEIVED )),
  DECODE (NVL (MVW_po_l.vend_whse_status,'D'),'D',MIV_po_l.PROD_MANAGER,MVW_po_l.PROD_MANAGER),
  DECODE(NVL(MVW_po_l.vend_whse_status,'D'),'D',MIV_po_l.PROD_MANAGER_NAME,MVW_po_l.PROD_MANAGER_NAME),
  SUM(( PO_L.UNIT_COST )*( PO_L.QTY_RECEIVED )),
  
  un_cost.UNIT_COST

FROM
  KDW.DWD_VENDOR  VENDOR_PO_L,
  KDW.DWD_WHSE  WHSE_PO_L,
  KDW.DWD_CALENDAR  PO_DATE_PO_L,
  KDW.DWD_ITEM  ITEM_PO_L,
  KDW.DWF_PO_L  PO_L,
  KDW.DWD_PO_L_OTHER  OTHER_PO_L,
  KDW.DWD_VENDOR  POL_SHIP_VEND,
  KDW.DWE_MAIN_ITEM_V  MIV_po_l,
  KDW.DWE_MAIN_VEND_WHSE  MVW_po_l,
		(  SELECT 
		DISTINCT 
		c.item_num item_num,
		c.UNIT_COST UNIT_COST,
		c.PO_L_ID  PO_L_ID,
		c.ID_PO_DATE
		FROM 
		KDW.DWF_PO_NEW_COST_ORDER c) un_cost
WHERE
  ( PO_L.ID_PO_DATE=PO_DATE_PO_L.ID_DATE  )
  
  AND un_cost.PO_L_ID = PO_L.PO_L_ID
  AND un_cost.ITEM_NUM = PO_L.ITEM_NUM
  AND un_cost.ID_PO_DATE = PO_L.ID_PO_DATE
  
  AND  ( OTHER_PO_L.ID_PO_L_OTHER=PO_L.ID_PO_L_OTHER  )
  AND  ( ITEM_PO_L.ID_ITEM=PO_L.ID_ITEM  )
  AND  ( PO_L.ID_WHSE=WHSE_PO_L.ID_WHSE  )
  AND  ( PO_L.ID_VENDOR=VENDOR_PO_L.ID_VENDOR  )
  AND  ( MIV_po_l.ITEM_NUM=PO_L.ITEM_NUM  )
  AND  ( POL_SHIP_VEND.ID_VENDOR=PO_L.ID_SHIP_VENDOR  )
  AND  ( PO_L.ID_WHSE=MVW_po_l.ID_WHSE(+) and PO_L.ITEM_NUM=MVW_po_l.ITEM_NUM(+)  )
  AND  (
  ( ITEM_PO_L.ITEM_NUM IN @Prompt('4. Артикул','A',,multi,free) OR 'все' IN @Prompt('4. Артикул','A',,multi,free)  )
  AND  ( PO_DATE_PO_L.CAL_DATE  BETWEEN 
TO_DATE(@Prompt('1. Дата начала периода','A',,mono,free), 'DD.MM.YYYY') AND  
TO_DATE(@Prompt('2. Дата окончания периода','A',,mono,free), 'DD.MM.YYYY')  )
  )
GROUP BY
  VENDOR_PO_L.VENDOR_NUM, 
  VENDOR_PO_L.VEND_NAME, 
  WHSE_PO_L.WHSE_CODE, 
  PO_DATE_PO_L.CAL_DATE, 
  ITEM_PO_L.ITEM_NUM, 
  ITEM_PO_L.ITEM_NAME, 
  ITEM_PO_L.ITEM_TYPE, 
  PO_L.PO_NUM, 
  PO_L.SPEC_NUM, 
  OTHER_PO_L.PO_STATUS, 
  POL_SHIP_VEND.VEND_NAME, 
  POL_SHIP_VEND.VENDOR_NUM, 
  DECODE (NVL (MVW_po_l.vend_whse_status,'D'),'D',MIV_po_l.PROD_MANAGER,MVW_po_l.PROD_MANAGER), 
  DECODE(NVL(MVW_po_l.vend_whse_status,'D'),'D',MIV_po_l.PROD_MANAGER_NAME,MVW_po_l.PROD_MANAGER_NAME),
  
   un_cost.UNIT_COST

