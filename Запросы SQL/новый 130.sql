SELECT   
  R_ITEM.ITEM_NUM,
  R_ITEM.ITEM_NAME,
  R_WHSE.TERR_CODE,
  R_WHSE.WHSE_CODE,
  SUM(( (ITEM_R.ON_HAND + ITEM_R.DAMAGED) ))
FROM
  KDW.DWD_ITEM  R_ITEM,
  KDW.DWD_WHSE  R_WHSE,
  KDW.DWF_ITEM_R  ITEM_R
WHERE
  ( R_ITEM.ID_ITEM=ITEM_R.ID_ITEM  )
  AND  ( ITEM_R.ID_WHSE=R_WHSE.ID_WHSE  )
  AND  (
  R_WHSE.TERR_CODE  IN  @variable('Регион')
  AND  R_ITEM.IND_CATEGORY  IN  ('В', 'П')
  AND  ( ITEM_R.ID_DATE = (SELECT kdw.getDateID(TO_DATE(@Prompt('2. Дата окончания периода','A',,mono,free), 'DD.MM.YYYY')) FROM dual)  )
  AND  R_WHSE.WHSE_TYPE  =  1
  )
GROUP BY
  R_ITEM.ITEM_NUM, 
  R_ITEM.ITEM_NAME, 
  R_WHSE.TERR_CODE, 
  R_WHSE.WHSE_CODE
HAVING
  ( 
  SUM(( (ITEM_R.ON_HAND + ITEM_R.DAMAGED) ))  >  0
  )
