select * 
from
(

select
mp.item_num,
mp.ABC0,
sum(mp.pr) over (partition by mp.ABC0 order by mp.pr desc ) as dolya,

case
when sum(mp.pr) over (partition by mp.ABC0 order by mp.pr desc ) <= 0.8 then 'A'
when sum(mp.pr) over (partition by mp.ABC0 order by mp.pr desc ) >0.95 then 'C'
else 'B'
end abc

from


(

select
bb.item_num, 
bb.ABC0,
sum(bb.V) as docs,
sum(sum(bb.V)) over (partition by bb.dd, bb.ABC0) as ditog,
sum(bb.V)/ sum(sum(bb.V)) over (partition by bb.dd, bb.ABC0) pr
 from
 
 (

SELECT   
  zs.ITEM_NUM,
  zs.V,
  
  --zs.DOCS_3M_CNT,
  zso.ABC0,
  1 dd
 -- , R_ITEM_W.AVAIL_CALC_METHOD
FROM
  KDW.DWF_ZGL_STAT  zs,
  KDW.DWD_ZGL_STAT_OTHER  zso,
  KDW.DWD_WHSE  zs_w,
  KDW.DWD_WHSE  zs_defw,
  KDW.DWD_ITEM  zs_i
 , KDW.DWD_ITEM_W  R_ITEM_W,
  KDW.DWE_ITEM_G  zs_item_g

  
  WHERE
  ( zso.ID_ZGL_STAT_OTHER=zs.ID_ZGL_STAT_OTHER  )
  AND  ( zs.ID_ITEM=zs_i.ID_ITEM  )
  AND  ( zs.ID_WHSE=zs_w.ID_WHSE  )
  and ( zs.ITEM_NUM=zs_item_g.ITEM_NUM  )
  and  (zs_item_g.ITEM_G2 NOT IN ( '5304' , '5308'))
  
  and (zs_i.SKL_OSN =zs_defw.WHSE_CODE
  AND  zs_w.WHSE_CODE  =  zs_defw.GRP_COUNT
  AND  zs_w.TERR_CODE  =  '0'
  AND  zs_w.WHSE_TYPE  =  1
  AND  zs_i.HSZ  =  '064'
  AND  zs_i.STATE  =  1
 AND ( (zs_i.item_ts  NOT IN  ('T06', 'Т106', 'T75', 'Т46', 'Т54', 'Т92', 'Т94', 'Т112', 'Т113', 'Т114','Т115', 'Т107')  AND  zso.ABC0  IN  ('A', 'B')) or (zs_i.item_ts = 'Т80' and zso.ABC0 in ('A') and (zs_item_g.ITEM_G2 IN ( '1828' , '1829') or  zs_item_g.ITEM_G4 in ('18260705')) ))
 AND  zs_i.IND_CATEGORY  IN  ('О', 'D')
 -- AND  zs_i.item_ts  NOT IN  ('Т32', 'Т44', 'Т06', 'Т75')
 -- AND  zso.ABC0  IN  ('A', 'B')
  AND  ( zs.id_date = (SELECT kdw.getZGLDateID FROM dual )  ))
  AND  ( zs.ITEM_NUM = R_ITEM_W.ITEM_NUM(+) and zs_i.SKL_OSN(+) = R_ITEM_W.WHSE_CODE and R_ITEM_W.IS_CURRENT = 'Y' ) 
  AND  R_ITEM_W.AVAIL_CALC_METHOD in ('1', '5')
  

  


) bb

group by
bb.item_num,
bb.ABC0,
bb.dd

order by
bb.item_num ASC,
bb.ABC0 ASC

)mp
 
) a,

(

SELECT   
  KDW.DW_GOODS.ITEM_NUM,
  g_item_g.DESC_1,
  g_item_g.DESC_2,
  g_item_g.DESC_3,
  KDW.DW_GOODS.ITEM_NAME,
  KDW.DW_GOODS.IND_CATEGORY,
  KDW.DW_GOODS.DIV_CODE,
  goods_TS.DIV_NAME,
  KDW.DW_GOODS.DEF_WHSE_OPT,
  g_item_g.TRADE_MARK_NAME
FROM
  KDW.DW_GOODS,
  KDW.DWE_ITEM_G  g_item_g,
  KDW.DWD_DIVISION  goods_TS
WHERE
  ( g_item_g.ITEM_NUM=KDW.DW_GOODS.ITEM_NUM  )
  AND  ( goods_TS.DIV_CODE=KDW.DW_GOODS.DIV_CODE and goods_TS.DIV_TYPE=2  AND goods_TS.IS_CURRENT = 'Y'  )
  AND  (
  KDW.DW_GOODS.STATE  =  1
  AND  KDW.DW_GOODS.HSZ  =  '064'
  AND  KDW.DW_GOODS.IND_CATEGORY  IN  ('О', 'D')
  AND  KDW.DW_GOODS.DIV_CODE  NOT IN  ('T06', 'Т106', 'T75', 'Т46', 'Т54', 'Т92', 'Т94', 'Т112', 'Т113', 'Т114', 'Т115', 'Т107', 'Т45', 'Т80')
  and  (g_item_g.ITEM_G2 NOT IN ( '5304' , '5308'))
  )

) i,


(
select
	zs.item_num,
	CASE when mvw.PROD_MANAGER IN ('dnv64', 'kmvt15', 'kta_su', 'kvp64', 'pad64', 'sint15') then zs.MO_ALL else zs.MO end as M,
	zso.ABC_VOLUME,
	zs.VO V,
	zs1.AVG_MOVE_3M		
from
	kdw.DWF_ITN_STATS zs,
	KDW.DWD_ZGL_STAT_OTHER  zso,
	KDW.DWD_WHSE  zs_w,
    KDW.DWD_WHSE  zs_defw,
	KDW.DWD_ITEM  zs_i,
	KDW.DWE_ITEM_G  zs_item_g,
	KDW.DWF_ZGL_STAT  zs1,
	KDW.DWE_MAIN_VEND_WHSE mvw
where
	zs.item_num=zs_i.item_num 
	AND zs_i.item_num=zs1.item_num
	AND zs_i.item_num=mvw.ITEM_NUM
	AND mvw.VEND_WHSE_STATUS <> 'D' 
	AND zs_i.SKL_OSN =mvw.WHSE_CODE
	AND zso.ID_ZGL_STAT_OTHER=zs1.ID_ZGL_STAT_OTHER
	AND zs1.id_whse= zs_w.id_whse
	AND zs.id_whse=zs_w.id_whse
	AND zs_i.STATE  =  1
	AND zs_w.TERR_CODE  =  '0'
	AND zs_w.WHSE_TYPE  =  1
	AND zs_i.HSZ  =  '064'
	AND zs_i.IND_CATEGORY  IN  ('О', 'D')
	AND zs_i.IS_CURRENT='Y'
	AND zs_i.SKL_OSN =zs_defw.WHSE_CODE
	AND zs_w.WHSE_CODE  =  zs_defw.GRP_COUNT
	AND zs_i.ITEM_NUM=zs_item_g.ITEM_NUM  
	AND zs_item_g.ITEM_G2 NOT IN ( '5304' , '5308')
	AND ( (zs_i.item_ts  NOT IN  ('T06', 'Т106', 'T75', 'Т46', 'Т54', 'Т92', 'Т94', 'Т112', 'Т113', 'Т114', 'Т115', 'Т107')  AND  zso.ABC0  IN  ('A', 'B')) or (zs_i.item_ts = 'Т80' and zso.ABC0 IN ('A') and (zs_item_g.ITEM_G2 IN ( '1828' , '1829') or zs_item_g.ITEM_G4 in ('18260705'))))
	AND ( zs.id_stat_date = (SELECT kdw.getZGLDateID FROM dual )  )
	AND ( zs1.id_date = (SELECT kdw.getZGLDateID FROM dual )  )
) m,
(
SELECT   
  mvw.ITEM_NUM,
  mvw.VENDOR_NUM,
  mvw.VENDOR_NAME,
  mvw.LEAD_TIME,
  mvw.STOCK_CONTROL,
  mvw.TIME_GARANT,
  mvw.PROD_MANAGER_NAME,
  mvw.PROD_MANAGER,
  mvw_w.WHSE_CODE,
  case when mvw.PROD_MANAGER in ('kvp64', 'dnv64', 'kta_su', 'pad64', 'sint15') then 'imp' else 'lok' end geo
FROM
  KDW.DWE_MAIN_VEND_WHSE  mvw,
  KDW.DWD_WHSE  mvw_w,
  KDW.DW_GOODS  mvw_goods,
  KDW.DWD_ITEM  mvw_i,
   KDW.DWE_ITEM_G  mvw_item_g
WHERE
  ( mvw_i.ITEM_NUM = mvw.ITEM_NUM AND mvw_i.IS_CURRENT = 'Y'  )
  AND  ( mvw.ID_WHSE=mvw_w.ID_WHSE  )
  AND  ( mvw.VEND_WHSE_STATUS <> 'D'  )
  AND  ( mvw.ITEM_NUM=mvw_goods.ITEM_NUM  )
  AND  (
  
    mvw.WHSE_CODE  =  mvw_goods.SKL_OSN
  AND  mvw_w.WHSE_TYPE  =  1
  AND  mvw_w.TERR_CODE  =  '0'
  AND  mvw_goods.HSZ  =  '064'
  AND  mvw_i.STATE  =  1
  AND  mvw_goods.IND_CATEGORY  IN  ('О', 'D')
  AND  mvw_goods.DIV_CODE  NOT IN  ('T06', 'Т106', 'T75', 'Т46', 'Т54', 'Т92', 'Т94', 'Т112', 'Т113', 'Т114', 'Т115', 'Т107', 'Т45', 'Т80')
  AND  ( mvw.ITEM_NUM = mvw_item_g.ITEM_NUM  )
  AND (mvw_item_g.ITEM_G2 NOT IN ( '5304' , '5308'))
  
  )

) p,
(
SELECT   
  R_ITEM_W.ITEM_NUM,
  SUM(R_ITEM_W.SAFE_STOCK),
  SUM(R_ITEM_W.COMM_LIMIT),
  SUM(R_ITEM_W.COMM_LIMIT_VP),
  SUM(R_ITEM_W.DEAL_LIMIT),
  SUM(R_ITEM_W.COMM_LIMIT_ORD_OPT),
  R_ITEM_W.TYPE_LIMIT,
  R_ITEM_W.AVAIL_CALC_METHOD

  FROM
  KDW.DW_GOODS,
  KDW.DWD_ITEM_W  R_ITEM_W,
  KDW.DWE_ITEM_G  ITEM_G
WHERE
   (KDW.DW_GOODS.STATE  =  1)
  AND  KDW.DW_GOODS.HSZ  =  '064'
  AND  KDW.DW_GOODS.IND_CATEGORY  IN  ('О', 'D')
  AND  KDW.DW_GOODS.DIV_CODE  NOT IN  ('T06', 'Т106', 'T75', 'Т46', 'Т54', 'Т92', 'Т94', 'Т112', 'Т113', 'Т114', 'Т115', 'Т107', 'Т45', 'Т80') 
  AND R_ITEM_W.ITEM_NUM = KDW.DW_GOODS.ITEM_NUM
  AND R_ITEM_W.WHSE_CODE = KDW.DW_GOODS.SKL_OSN
  AND R_ITEM_W.IS_CURRENT = 'Y'  
  
  AND  (  R_ITEM_W.ITEM_NUM=ITEM_G.ITEM_NUM  )
  AND  ( ITEM_G.ITEM_G2 NOT IN ( '5304' , '5308'))
  
  group by
   R_ITEM_W.TYPE_LIMIT,
   R_ITEM_W.AVAIL_CALC_METHOD,
   R_ITEM_W.ITEM_NUM

) l,

(
SELECT   
  R_ITEM.ITEM_NUM,
  R_ITEM.CROSS_DOCKING,
  SUM(( ITEM_R.ON_HAND )),
  SUM(( ITEM_R.COMMITTED_QTY ))
FROM
  KDW.DWD_ITEM  R_ITEM,
  KDW.DWF_ITEM_R  ITEM_R,
  KDW.DWD_WHSE  R_WHSE,

  KDW.DWD_CALENDAR  R_CAL,
  KDW.DWE_ITEM_G  ITEM_G
WHERE
  ( ITEM_R.ID_DATE=R_CAL.ID_DATE  )
  AND  ( R_ITEM.ID_ITEM=ITEM_R.ID_ITEM  )

     AND  ( ITEM_R.ITEM_NUM=ITEM_G.ITEM_NUM  )
	 AND (ITEM_G.ITEM_G2 NOT IN ( '5304' , '5308'))
  
  AND  ( ITEM_R.ID_WHSE=R_WHSE.ID_WHSE  )
  AND  ( R_WHSE.WHSE_CODE  =  R_ITEM.SKL_OSN)
  AND  R_ITEM.HSZ  =  '064'
  AND  R_ITEM.STATE  =  1
  AND  R_ITEM.IND_CATEGORY  IN  ('D', 'О')
  AND  R_ITEM.ITEM_TS  NOT IN  ('T06', 'Т106', 'T75', 'Т46', 'Т54', 'Т92', 'Т94', 'Т112', 'Т113', 'Т114', 'Т115', 'Т107', 'Т45', 'Т80')
  AND  ( R_CAL.IS_CURRENT = 'Y'  )
  
GROUP BY
  R_ITEM.ITEM_NUM, 
  R_ITEM.CROSS_DOCKING

  ) o,
  
  (
  
  SELECT ITEM_NUM, uslpokol
FROM 
(
SELECT a.item_num, a.uslpokol, nvl(b.reg, '0') reg FROM 
(
WITH 
  TMain AS (
    
  SELECT   
  rownum as rn,  
  G_ITEM_PROMOA.ITEM_NUM,
 G_ITEM_PROMOA.ACTION_AM as uslpokol,
 case when G_PROMOA.PRICE_REGION is null then '0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60' else G_PROMOA.PRICE_REGION  end   AS str 
FROM
KDW.DWE_ITEM_PROMOA  G_ITEM_PROMOA ,
KDW.DWE_PROMOA  G_PROMOA
 WHERE
 TO_DATE(sysdate) BETWEEN G_ITEM_PROMOA.START_DATE (+) AND G_ITEM_PROMOA.END_DATE (+) 
 AND  (G_ITEM_PROMOA.PROMOA_ID=G_PROMOA.PROMOA_ID  )
  AND  (G_ITEM_PROMOA.TIME_DELETED  IS NULL  OR   G_ITEM_PROMOA.TIME_DELETED  >=  TO_DATE(sysdate))
  AND  G_ITEM_PROMOA.ACTION_TYPE  =  '3'
--  and  G_ITEM_PROMOA.ITEM_NUM='1000801'
  and G_ITEM_PROMOA.MKTYPE_ID='P002' /*Ц Упаковка*/
) 
            
 SELECT item_num, max(uslpokol) as uslpokol,  regexp_substr(tmain.str, '[^,]+', 1, level) AS str
FROM tmain
connect by regexp_substr(tmain.str, '[^,]+', 1, level) is not null
         and rn = prior rn
         and prior dbms_random.value is not null
group by 
 item_num,
 regexp_substr(tmain.str, '[^,]+', 1, level)
 
 ) a, 
 
 (
 SELECT PARENT_REG, PRICE_REGION, DESC_1, 
  CASE WHEN PRICE_REGION IN ('3', '14', '46', '51') THEN '14' 
	 WHEN PRICE_REGION IN ('13') THEN '13' 
	 WHEN PRICE_REGION IN ('12') THEN '12' 
	 WHEN PRICE_REGION IN ('11', '44', '7', '9') THEN '11' 
	 WHEN PRICE_REGION IN ('10', '6', '8', '35', '36', '37', '38', '39') THEN '6' 
	 WHEN PRICE_REGION IN ('17', '42', '45', '5', '50') THEN '5' 
     WHEN PRICE_REGION IN ('2', '40', '43', '53') THEN '2' 
     WHEN PRICE_REGION IN ('1', '41', '47', '48', '49') THEN '1'
     ELSE '0'
	 END REG FROM KDW.DWE_PRICE_REGION 
 ) b 
 
 WHERE a.str=b.price_region(+)
 GROUP BY a.item_num, a.uslpokol, nvl(b.reg, '0') 
 )
 WHERE reg='0'
 
  
  ) w
  
  
  
  
where a.item_num=i.item_num(+)
and a.item_num=m.item_num(+)
and a.item_num=p.item_num(+)
and a.item_num=l.item_num(+)
and a.item_num=o.item_num(+)
AND a.item_num=w.item_num(+)