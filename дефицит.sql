with t as 
    ( 
	select 
		z.item_num, 
		--z.whse_code whse, 
		z.cal_date calc_date
		--,z.mo
		--,z.svb
		, ff
	from
	(
		SELECT art.item_num , 
		--art.whse_code, 
		sum(nvl(ost.svb,0)) svb, 
		art.cal_date,
		case when sum(nvl(ost.svb,0))=0 then 1 else 0 end ff
		from
	(
			SELECT   
		  CAL_DNI.CAL_DATE, s.item_num, CAL_DNI.id_DATE
		FROM
		  KDW.DWD_CALENDAR  CAL_DNI,
	  (SELECT   
		q.ITEM_NUM
		FROM
			( SELECT   
				KDW.DW_GOODS.ITEM_NUM
  
		FROM
			KDW.DW_GOODS,
			KDW.DWE_MAIN_ITEM_V  G_MAIN_ITEM_V,
			KDW.DWD_DIVISION  goods_TS
		WHERE
			( KDW.DW_GOODS.ITEM_NUM=G_MAIN_ITEM_V.ITEM_NUM  )
			AND  ( goods_TS.DIV_CODE=KDW.DW_GOODS.DIV_CODE and goods_TS.DIV_TYPE=2  AND goods_TS.IS_CURRENT = 'Y'  )
			AND  (
			KDW.DW_GOODS.STATE  =  1
			AND  KDW.DW_GOODS.IND_CATEGORY  IN @Prompt('5. Категории из списка значений-->','A',{'О', 'D', 'Т'},multi,Constrained)
			AND  ( KDW.DW_GOODS.DIV_CODE IN
			@Prompt('4. ТC','A',,multi,free) OR 'все'  IN @Prompt('4. ТC','A',,multi,free)))
 ) q 
) s
	WHERE
   ( CAL_DNI.CAL_DATE BETWEEN TO_DATE(@Prompt('1. Дата начала периода','A',,mono,free), 'DD.MM.YYYY')  AND  TO_DATE(@Prompt('2. Дата окончания периода','A',,mono,free), 'DD.MM.YYYY')  )
  
 ) ART,
 (SELECT   
  ITEM_R.ID_DATE,
  R_ITEM.ITEM_NUM,
  SUM(( ITEM_R.ON_HAND )) ost,
  SUM(( ITEM_R.ON_HAND )) - SUM(( ITEM_R.COMMITTED_QTY )) svb
FROM
  KDW.DWD_WHSE  R_WHSE,
  KDW.DWF_ITEM_R  ITEM_R,
  KDW.DWD_ITEM  R_ITEM, 
  KDW.DWD_CALENDAR R_CAL
  
WHERE
  ( ITEM_R.ID_DATE=R_CAL.ID_DATE  )
 AND ( R_ITEM.ID_ITEM=ITEM_R.ID_ITEM  )
 AND  ( ITEM_R.ID_WHSE=R_WHSE.ID_WHSE  )
 AND R_ITEM.STATE  =  1
AND ( (R_ITEM.ITEM_TS  IN @Prompt('4. ТC','A',,multi,free) OR 'все'  IN @Prompt('4. ТC','A',,multi,free))  )  
AND  ( ITEM_R.ID_DATE  BETWEEN (SELECT kdw.getDateID(TO_DATE(@Prompt('1. Дата начала периода','A',,mono,free), 'DD.MM.YYYY')) FROM dual) AND (SELECT kdw.getDateID(TO_DATE(@Prompt('2. Дата окончания периода','A',,mono,free), 'DD.MM.YYYY')) FROM dual)  )
AND  ( (R_WHSE.WHSE_CODE IN @Prompt('7. Код склада','A',,multi,free) OR 'все' IN @Prompt('7. Код склада','A',,multi,free))  )
  
  
 
  group by    
  ITEM_R.ID_DATE,
    R_ITEM.ITEM_NUM
  
  ) ost,

	(
	SELECT   
		zs.ITEM_NUM,
		  zs.M as mo,
		  CAL_DNI.id_date
	FROM
		  KDW.DWF_ZGL_STAT  zs,
		  KDW.DWD_WHSE  zs_w,
		  KDW.DWD_WHSE  zs_defw,
		  KDW.DWD_DIVISION  zs_ts,
		  KDW.DWD_ITEM  zs_i,
		  KDW.DWD_CALENDAR  CAL_DNI
	WHERE
		  ( zs.ID_ITEM=zs_i.ID_ITEM  )
		  AND  ( zs.ID_WHSE=zs_w.ID_WHSE  )
		  and ( ( CAL_DNI.CAL_DATE BETWEEN TO_DATE(@Prompt('1. Дата начала периода','A',,mono,free), 'DD.MM.YYYY')  AND  TO_DATE(@Prompt('2. Дата окончания периода','A',,mono,free), 'DD.MM.YYYY')  ))
		  AND  ( zs.ID_ITEM_TS_DIV=zs_ts.ID_DIV  )
		  AND  ( zs_i.SKL_OSN=zs_defw.WHSE_CODE  )
		  AND  ( zs_ts.DIV_TYPE=2  )
		   AND zs_i.STATE  =  1
		--  AND  zs_i.IND_CATEGORY  =  'О'
		  AND  (
		  zs_w.WHSE_CODE  =  zs_defw.GRP_COUNT
		  AND  ( zs_ts.div_code  IN @Prompt('4. ТC','A',,multi,free) OR 'все'  IN @Prompt('4. ТC','A',,multi,free) )
		  AND  ( zs.id_date = (SELECT kdw.getZGLDateID FROM dual )  )
		  )

) m
 
  where  
  art.item_num=ost.item_num(+)
  and art.id_date=ost.id_date(+)
  and art.item_num=m.item_num(+)
  and art.id_date=m.id_date(+)
  --and art.WHSE_CODE=ost.WHSE_CODE(+)
  group by
  art.item_num,
  art.cal_date
 ) z
where  
--z.svb<z.mo
--group by
--z.item_num
--,z.whse_code
 ff= 1 

 
 )

select item_num, cc, sd,ed --, TO_CHAR((sd), 'YYYY_MM') ym 

from 
(
select item_num, min(calc_date) as sd, max(calc_date) as ed, count(1) as cc
  from (
         select item_num, calc_date, grp_id0, 
                ceil(row_number() over(partition by grp_id0 order by item_num, calc_date)/31) as grp_id1
          from (
                 select item_num, calc_date, calc_date - row_number() over(order by item_num, calc_date) grp_id0
                   from t
                  order by item_num, calc_date
               ) v0
       )v1
 group by item_num, grp_id0, grp_id1
 order by min(calc_date)
  
  ) a
-- where  cc=1

  
  
  
  
  
  
  
  
  
  
  
  
  
  