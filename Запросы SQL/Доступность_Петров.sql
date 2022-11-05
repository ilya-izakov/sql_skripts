with
params as

(
SELECT a.*, 
ce.ID_DAte as deID,
cb.ID_Date as dbID,
kdw.getZGLDateID(dateend) as ZGLID
FROM(
SELECT * FROM
(
SELECT MAX(CAL_DATE) dateend
FROM
(Select cal_date, row_number() over (order by cal_date asc) as npp
FROM KDW.DWD_CALENDAR
WHERE work_day=1 
and cal_date < trunc(sysdate) 
and cal_date > trunc(sysdate-30)
ORDER BY cal_date asc)
)
,
(

SELECT Cal_DATE datebeg
FROM
(
Select cal_date, row_number() over (order by cal_date asc) as npp
FROM KDW.DWD_CALENDAR
WHERE work_day=1 
and cal_date < trunc(sysdate) and cal_date > trunc(sysdate-30)
ORDER BY cal_date asc
)
WHERE npp = (SELECT MAX(npp)-4 FROM (Select cal_date, row_number() over (order by cal_date asc) as npp FROM KDW.DWD_CALENDAR WHERE work_day=1  and cal_date < trunc(sysdate) and cal_date > trunc(sysdate)-30 ORDER BY cal_date asc)) 

)
) a
INNER JOIN KDW.DWD_CAlendar cb on cb.cal_date=a.datebeg 
inner join KDW.DWD_CAlendar ce on ce.cal_date=a.dateend 

),

i as

  (
   SELECT   
     R_CAL.yyyy_w,
     R_ITEM.sgrp_name,
     R_ITEM.short_name,
     R_ITEM.regcatalog,
     R_ITEM.ind_category,
     R_ITEM.item_num,
     R_ITEM.item_ts ts,
     R_ITEM.ITEM_TS_NAME ts_name,
    R_CAL.ID_DATE,
    g_main_item_v.vendor_num,
    g_main_item_v.vendor_name,
    g_main_item_v.prod_manager,
    g_main_item_v.prod_manager_name,
    g_item_g.item_g1,
    g_item_g.desc_1,
    g_item_g.item_g2,
    g_item_g.desc_2,
    g_item_g.item_g3,
    g_item_g.desc_3,
    g_item_g.item_g4,
    g_item_g.desc_4,
    g_item_g.item_g5,
    g_item_g.desc_5,
  --  R_item.avail_calc_method,
    g_item_g.BRAND_ID, 
    g_item_g.BRAND_NAME, 
    g_item_g.TRADE_MARK_ID, 
    g_item_g.TRADE_MARK_NAME,
    g_item_g.Prod_manager_NAME bayer, 
    r_cal.cal_date
  FROM
    KDW.DWD_ITEM  R_ITEM,
    KDW.DWD_CALENDAR  R_CAL,
    kdw.DWE_MAIN_VEND_WHSE g_main_item_v,
    kdw.dwe_item_g g_item_g,
    params
 WHERE
             
( r_cal.id_date BETWEEN R_ITEM.id_b_date AND R_ITEM.id_e_date  )
    and ( g_main_item_v.item_num = R_ITEM.item_num)
       and ( R_ITEM.item_num = g_item_g.item_num)
--	     and (g_main_item_v.vend_whse_status='A')
	       and (R_ITEM.SKL_OSN=g_main_item_v.WHSE_CODE(+) )
             AND ( R_CAL.CAL_DATE BETWEEN (SELECT datebeg from params)
                                      AND (SELECT dateend from params) )         
  
             

   AND  R_ITEM.IND_CATEGORY  in ('О', 'D')
   AND R_CAL.WORK_DAY=1
   AND   STATE = 1
   AND  (R_ITEM.item_ts in 
 ('Т32','Т35','Т61','Т62','Т63','Т64','Т65','Т66','Т67','Т68','Т69','Т70','Т44','Т45','Т46','Т50','Т51','Т54','Т55','Т56','Т57','Т58','Т59','Т78','Т79','Т80','Т81','Т82','Т83','Т84','Т85','Т86','Т87','Т91','Т92','Т93','Т90','Т94','Т95','Т96','Т97','Т98','Т99','Т33','Т100','Т107','Т108','Т109','Т110','Т111', 'Т112', 'Т113', 'Т114', 'Т115')
   ) 
),

o as

(
  SELECT
--/*+ INDEX(ITEM_R,i1_item_r_f) */   
    R_CAL.yyyy_w,
    R_ITEM.item_num,
    R_CAL.ID_DATE, 
    SUM(ITEM_R.ON_HAND) ost,
    SUM(ITEM_R.COMMITTED_QTY) videl,
    SUM(R_ITEM_W.Safe_stock) rz,
    CASE WHEN SUM(ITEM_R.tfer_in)<0 THEN 0 ELSE SUM(ITEM_R.tfer_in) end as tfer_in,
    r_cal.work_day,
	NVL(max(R_item_w.avail_calc_method),0) avail_calc_method
  FROM
    KDW.DWD_ITEM  R_ITEM,
    KDW.DWD_WHSE  R_WHSE,
    KDW.DWF_ITEM_R  ITEM_R,
    KDW.DWD_CALENDAR  R_CAL,
    kdw.dwd_item_w r_item_w,
  params
 WHERE
   ( ITEM_R.ID_DATE=R_CAL.ID_DATE  )
   AND  ( ITEM_R.ID_ITEM=R_ITEM.ID_ITEM )
   AND  ( ITEM_R.ID_WHSE=R_WHSE.ID_WHSE )
   and (r_item_w.id_item_w = item_r.id_item_w) 
   
   AND ( R_CAL.CAL_DATE BETWEEN (SELECT datebeg from params)
                            AND (SELECT dateend from params) )
              
   AND  R_ITEM.IND_CATEGORY  in('О', 'D')
   and R_WHSE.terr_code = '0' 
   and r_whse.clp = 'Y'
   AND R_CAL.WORK_DAY=1
   AND  (R_ITEM.item_ts in ('Т32','Т35','Т61','Т62','Т63','Т64','Т65','Т66','Т67','Т68','Т69','Т70','Т44','Т45','Т46','Т50','Т51','Т54','Т55','Т56','Т57','Т58','Т59','Т78','Т79','Т80','Т81','Т82','Т83','Т84','Т85','Т86','Т87','Т91','Т92','Т93','Т90','Т94','Т95','Т96','Т97','Т98','Т99','Т33','Т100','Т107','Т108','Т109','Т110','Т111', 'Т112', 'Т113', 'Т114', 'Т115')
   ) 
   GROUP BY
   R_ITEM.item_num, 
   R_CAL.ID_DAte,
   r_cal.work_day,
   R_CAL.yyyy_w 
   
   
),

  VP_FIKTIV AS
  (
  SELECT
    KDW.DWE_OPEN_WHSE_T_L.OPEN_DATE - 1 AS OPEN_DATE_CORRECT,
    KDW.DWE_OPEN_WHSE_T_L.ITEM_NUM,
    KDW.DWE_OPEN_WHSE_T_L.QTY_ORDERED
  FROM
    KDW.DWE_OPEN_WHSE_T_L,
    KDW.DW_GOODS ow_g,
    KDW.DW_PRICE_HISTORY ow_ph,
    KDW.DWD_WHSE ow_fw,
    KDW.DWD_WHSE ow_tw
  WHERE
        ( KDW.DWE_OPEN_WHSE_T_L.FROM_WHSE_CODE = ow_fw.WHSE_CODE )
    AND ( KDW.DWE_OPEN_WHSE_T_L.TO_WHSE_CODE = ow_tw.WHSE_CODE )
    AND ( KDW.DWE_OPEN_WHSE_T_L.ITEM_NUM = ow_g.ITEM_NUM )
    AND ( KDW.DWE_OPEN_WHSE_T_L.ITEM_NUM = ow_ph.ITEM_NUM AND KDW.DWE_OPEN_WHSE_T_L.OPEN_DATE BETWEEN ow_ph.B_DATE AND ow_ph.E_DATE )
    AND ( KDW.DWE_OPEN_WHSE_T_L.OPEN_DATE BETWEEN ( (SELECT datebeg from params)+1)
                                              AND ( (SELECT dateend from params)+1) )
    AND ( ow_ph.STATE = 1 )
    AND ( ow_fw.WHSE_CODE = '000' )
    AND ( ow_ph.DIV_CODE IN  ('Т32','Т35','Т33','Т61','Т62','Т63','Т64','Т65','Т66','Т67','Т68','Т69','Т70','Т44','Т45','Т46','Т50','Т51','Т54','Т55','Т56','Т57','Т58','Т59','Т78','Т79','Т80','Т81','Т82','Т83','Т84','Т85','Т86','Т87','Т91','Т92','Т93','Т90','Т94','Т95','Т96','Т97','Т98','Т99','Т70','Т100','Т107','Т108','Т109', 'Т110', 'Т111', 'Т112', 'Т113', 'Т114', 'Т115') )
    AND ( ow_tw.terr_code = '0' and ow_tw.clp = 'Y'  )
  
),


stat as

(   SELECT   
     s.item_num,
     sum(NVL(s.m, 0)) AS m,
     sum(NVL(s.f, 0)) AS f,
     sum(NVL(s.v, 0)) AS v
   FROM
     KDW.DWD_WHSE  R_WHSE,
     kdw.dwf_zgl_stat s,
   params
   WHERE
      s.id_whse = R_WHSE.id_whse 
     AND  R_WHSE. terr_code = '0' 
	 and r_whse.clp = 'Y' 
     AND s.id_date = (SELECT ZGLID from params)
        and s.N>5
   group by s.item_num
  ),
  
 
 
pred as
(
SELECT   
  KDW.DWE_OPEN_PROF_L.OPEN_DATE - 1 AS DATE_pred,
  KDW.DWE_OPEN_PROF_L.ITEM_NUM,
  SUM(KDW.DWE_OPEN_PROF_L.COMMITTED_QTY) vid1
FROM
  KDW.DWE_OPEN_PROF_L,
  KDW.DWD_WHSE  op_w
WHERE
  ( KDW.DWE_OPEN_PROF_L.WHSE_CODE=op_w.WHSE_CODE  )
  AND  (
  KDW.DWE_OPEN_PROF_L.CUST_NUM  =  '103329'
  AND  ( KDW.DWE_OPEN_PROF_L.OPEN_DATE  BETWEEN ( (SELECT datebeg from params)+1)
                                            AND ( (SELECT dateend from params)+1) )
  AND  KDW.DWE_OPEN_PROF_L.PROF_DATE  >  '01-03-2022 00:00:00'
  AND  op_w.TERR_CODE  =  '0'
  )
GROUP BY
  KDW.DWE_OPEN_PROF_L.OPEN_DATE,
  KDW.DWE_OPEN_PROF_L.ITEM_NUM
),
 
 
  
a as
 
 (  SELECT i.ts, i.ts_name, i.item_num, i.sgrp_name, i.short_name, i.regcatalog, i.ind_category, o.id_date, o.work_day,
               NVL(m,0) m, NVL(f,0) f, NVL(v,0) v, 
               i.vendor_num, i.vendor_name,
               i.prod_manager, i.prod_manager_name, i.item_g1, i.desc_1, i.item_g2, i.desc_2, i.item_g3, i.desc_3,
               i.item_g4, i.desc_4, i.item_g5, i.desc_5, i.bayer,
               CASE 
                 WHEN  o.avail_calc_method <> 5 THEN NVL(ost,0) - NVL(videl,0)
                 WHEN   o.avail_calc_method = 5 THEN NVL(ost,0) - NVL(videl,0) + NVL(VP_FIKTIV.QTY_ORDERED,0)
                ELSE 99999999 end ost,
			   CASE 
                 WHEN  o.avail_calc_method <> 5 THEN NVL(ost,0) - NVL(videl,0)+NVL(pred.vid1,0)
                 WHEN   o.avail_calc_method = 5 THEN NVL(ost,0) - NVL(videl,0) + NVL(VP_FIKTIV.QTY_ORDERED,0) +NVL(pred.vid1,0)
                ELSE 99999999 end ost1,
BRAND_ID,  BRAND_NAME, TRADE_MARK_ID, TRADE_MARK_NAME, i.yyyy_w
  FROM
      i,
      o,
	  VP_FIKTIV,
	  pred,
      stat
 WHERE i.item_num = o.item_num(+) and i.item_num = stat.item_num(+)
        and  i.id_date = o.id_date(+) and i.yyyy_w=o.yyyy_w(+)
		and i.item_num = VP_FIKTIV.item_num (+) and i.cal_date = VP_FIKTIV.OPEN_DATE_CORRECT(+)
		and i.item_num = pred.item_num (+)  and i.cal_date = pred.DATE_pred (+)
 ), 
 
dd as

(
SELECT SUM(work_day) wd, yyyy_w 
FROM KDW.DWD_CALENDAR,
   params

WHERE 
( CAL_DATE BETWEEN (SELECT datebeg from params)
               AND (SELECT dateend from params) )
      
group by yyyy_w
),



top
as
(
SELECT
  g.ITEM_NUM Артикул,
  '1_канцтов' Признак_списка
FROM
  KDW.DW_GOODS g
WHERE
  ( g.ITEM_NUM IN (SELECT SET_VALUE FROM KDW.W_SET_VALUES WHERE set_id = 122115231 ) )

UNION

SELECT
  g.ITEM_NUM Артикул,
  '2_мебель' Признак_списка
FROM
  KDW.DW_GOODS g
  
WHERE
  ( g.ITEM_NUM IN (SELECT SET_VALUE FROM KDW.W_SET_VALUES WHERE set_id = 53791673 ) )

UNION

SELECT
  g.ITEM_NUM Артикул,
  '3_ро_сиз' Признак_списка
FROM
  KDW.DW_GOODS g
WHERE
  ( g.ITEM_NUM IN (SELECT SET_VALUE FROM KDW.W_SET_VALUES WHERE set_id = 135399471 ) )
  
/*UNION

SELECT
  g.ITEM_NUM Артикул,
  '4_ядро' Признак_списка
FROM
  KDW.DW_GOODS g
WHERE
  ( g.ITEM_NUM IN (SELECT SET_VALUE FROM KDW.W_SET_VALUES WHERE set_id = 126841027 ) )*/
),



topv
as
(
SELECT
  g.ITEM_NUM Артикул,
  '4_ABC_встреч' Признак_списка_02
FROM
  KDW.DW_GOODS g
WHERE
  ( g.ITEM_NUM IN (SELECT SET_VALUE FROM KDW.W_SET_VALUES WHERE set_id = 134600613 ) )
),  



topo
as
(
SELECT
  g.ITEM_NUM Артикул,
  '5_ABC_оборот' Признак_списка_03
FROM
  KDW.DW_GOODS g
WHERE
  ( g.ITEM_NUM IN (SELECT SET_VALUE FROM KDW.W_SET_VALUES WHERE set_id = 134607457 ) ) 
),


 
otdel as
(
select 
vendor_num, /*код_мл*/
whse_code,  /*отдел*/
v_text      /*глав.отдел*/
from 
kdw.lika_vend
),


moskow as

(
SELECT item_num,ts, ts_name, sgrp_name, short_name, regcatalog, ind_category, m, f, v, arto,
             fo, vo, art_kr, f_krt, v_krt, art_kr_1, f_krt_1, v_krt_1,
             vend, prod_manager,  prod_manager_name,
             item_g1, item_g2, item_g3, item_g4, item_g5, it,
             BRAND_ID,  BRAND_NAME, TRADE_MARK_ID, TRADE_MARK_NAME,
            yyyy_w, Признак_списка, Признак_списка_02, Признак_списка_03,
            case when art_kr = 0 then 0 else 1 end arttt,
            case when art_kr_1 = 0 then 0 else 1 end arttt1, bayer
from (
SELECT item_num,ts, ts_name, sgrp_name, short_name, regcatalog, ind_category, m, f, v, dd.wd arto,
             dd.wd*f fo, dd.wd*v vo,   
                      SUM((CASE WHEN ost < 0.5*m OR (ost=0 AND m=0) THEN 1
                                WHEN ost = 0.5*m THEN 0.5
                                WHEN ost > 0.5*m and ost <= 0.8*m then 0.2 
                           ELSE 0 END)) art_kr,
                      f*SUM(CASE WHEN ost < 0.5*m OR (ost=0 AND m=0) THEN 1
                                WHEN ost = 0.5*m THEN 0.5
                                WHEN ost > 0.5*m and ost <= 0.8*m then 0.2 
                           ELSE 0 END) f_krt,
                      v*SUM(CASE WHEN ost < 0.5*m OR (ost=0 AND m=0) THEN 1
                                WHEN ost = 0.5*m THEN 0.5
                                WHEN ost > 0.5*m and ost <= 0.8*m then 0.2 
                           ELSE 0 END) v_krt,
					  SUM((CASE WHEN ost1 < 0.5*m OR (ost1=0 AND m=0) THEN 1
                                WHEN ost1 = 0.5*m THEN 0.5
                                WHEN ost1 > 0.5*m and ost1 <= 0.8*m then 0.2 
                           ELSE 0 END)) art_kr_1,
                      f*SUM(CASE WHEN ost1 < 0.5*m OR (ost1=0 AND m=0) THEN 1
                                WHEN ost1 = 0.5*m THEN 0.5
                                WHEN ost1 > 0.5*m and ost1 <= 0.8*m then 0.2 
                           ELSE 0 END) f_krt_1,
                      v*SUM(CASE WHEN ost1 < 0.5*m OR (ost1=0 AND m=0) THEN 1
                                WHEN ost1 = 0.5*m THEN 0.5
                                WHEN ost1 > 0.5*m and ost1 <= 0.8*m then 0.2 
                           ELSE 0 END) v_krt_1,   
 vendor_num||' '||vendor_name vend, prod_manager,  prod_manager_name,
             item_g1||' '||desc_1 item_g1, item_g2||' '||desc_2 item_g2, item_g3||' '||desc_3 item_g3,
             item_g4||' '||desc_4 item_g4, item_g5||' '||desc_5 item_g5, item_num||' '||short_name it,
             BRAND_ID,  BRAND_NAME, TRADE_MARK_ID, TRADE_MARK_NAME,
            a.yyyy_w, bayer, top.Признак_списка, topv.Признак_списка_02, topo.Признак_списка_03
 FROM a, dd, top, topv, topo
where
      a.yyyy_w = dd.yyyy_w
  and a.item_num = top.Артикул(+)
  and a.item_num = topv.Артикул(+)
  and a.item_num = topo.Артикул(+)

GROUP BY item_num,ts, ts_name, sgrp_name, short_name, regcatalog, ind_category, 
m, f, v, dd.wd, dd.wd*f, dd.wd*v, vendor_num, vendor_name,
               prod_manager, prod_manager_name, item_g1, desc_1, item_g2, desc_2, item_g3, desc_3, item_g4, desc_4, item_g5, desc_5,
               BRAND_ID,  BRAND_NAME, TRADE_MARK_ID, TRADE_MARK_NAME, a.yyyy_w, bayer, top.Признак_списка, topv.Признак_списка_02, topo.Признак_списка_03
)

WHERE ts in ('Т32','Т35','Т61','Т62','Т63','Т64','Т65','Т66','Т67','Т68','Т69','Т70','Т44','Т45','Т46','Т50','Т51','Т54','Т55','Т56','Т57','Т58','Т59','Т78','Т79','Т80','Т81','Т82','Т83','Т84','Т85','Т86','Т87','Т91','Т92','Т93','Т90','Т94','Т95','Т96','Т97','Т98','Т99','Т33','Т100','Т107','Т108','Т109','Т110','Т111', 'Т112', 'Т113', 'Т114', 'Т115')
),



moskow_2 as
(
SELECT
  moskow.item_num Артикул_,
  moskow.short_name Название_Артикула,
  moskow.ind_category Категория,
  '0' Регион,
  moskow.ts ТР,
  moskow.ts_name Название_ТР,
  moskow.item_g1 Название_ТН,
  moskow.item_g2 Название_ТК,
  moskow.item_g3 Название_ТГ,
  moskow.item_g4 Название_АГ,
  moskow.vend Поставщик,
  moskow.prod_manager Код_МЛ,
  moskow.prod_manager_name Логист,
  moskow.Признак_списка,
  moskow.Признак_списка_02,
  moskow.Признак_списка_03,
  otdel.vendor_num Код_логиста,
  otdel.whse_code Отдел,
  otdel.v_text Глав_отдел,
  SUM(moskow.V_KRT) Частота_спроса_за_КД,
  SUM(moskow.VO) СД_Частота_спроса,
  SUM(moskow.V_KRT_1) Частота_спроса_ПС
	
FROM
  moskow
 left join otdel on moskow.prod_manager = otdel.vendor_num
GROUP BY
  moskow.item_num,
  moskow.short_name,
  moskow.ind_category,
  '0',
  moskow.ts,
  moskow.ts_name,
  moskow.item_g1,
  moskow.item_g2,
  moskow.item_g3,
  moskow.item_g4,
  moskow.vend,
  moskow.prod_manager,
  moskow.prod_manager_name,
  moskow.Признак_списка,
  moskow.Признак_списка_02,
  moskow.Признак_списка_03,
  otdel.vendor_num,
  otdel.whse_code,
  otdel.v_text
),


reg_spis as

(
select SET_VALUE reg from KDW.W_SET_VALUES where set_id=68733702
),



region as
(
SELECT art_gl, tss, ts, ts_name, sgrp_name, short_name,  gl_ind_category, m, f, v, arto, reg,
       fo, vo, wd - art_kr art_kr, f*wd - f_krt f_krt, v*wd - v_krt v_krt, it, wd, artt, 
       art_kr kk, top.Признак_списка, topv.Признак_списка_02, topo.Признак_списка_03,
       (case when wd - art_kr > 0 then 1 else 0 end) col_kr, last_ost, last_vid
from
  top, topv, topo,
  (
SELECT art_gl, ts tss, ts||' '||ts_name ts, ts_name, sgrp_name, short_name,  gl_ind_category, m, f, v, dd.wd arto,
             dd.wd*f fo, dd.wd*v vo, dd.wd,  reg,
                      SUM(CASE WHEN ost >m THEN 1 ELSE 0 END)  art_kr,
             f*SUM((CASE WHEN ost>m THEN 1 ELSE 0 END)) f_krt,
             v*SUM((CASE WHEN ost>m THEN 1 ELSE 0 END)) v_krt, art_gl||' '||short_name it,
             artt, 
             sum(decode(num,1,ost1,0)) as last_ost, sum(decode(num,1,videl,0)) as last_vid
FROM ( 
SELECT i.ts, i.ts_name, i.ART_GL, o.id_date, NVL(m,0) m, NVL(f,0) f, NVL(v,0) v, 
       i.short_name, i.gl_ind_category, i.sgrp_name, i.reg,
               NVL(CASE 
                 WHEN NVL(avail_calc_method,0) <> 5 THEN NVL(ost,0) - NVL(videl,0)
                 ELSE NVL(ost,0) - NVL(videl,0) + (CASE WHEN NVL(o.tfer_in,0)<0 THEN 0 ELSE NVL(o.tfer_in,0) END)
                end,0) ost, nvl(videl,0) videl, artt, ost1, num
  FROM
  (
 SELECT     
   R_ITEM.gl_item_ts ts,
     R_ITEM.ART_GL,
     r_item.gl_short_name short_name, 
     R_ITEM.GL_ITEM_TS_NAME ts_name,
     R_ITEM.GL_IND_CATEGORY,
     R_ITEM.gl_sgrp_name sgrp_name,
     1 artt,
reg_spis.reg
   FROM
     KDW.DWD_ITEM  R_ITEM,
reg_spis ,
     (select
    distinct z.item_num, w.terr_code
   from
    kdw.DWE_ZAPRET_VP_HISTORY z,
                                kdw.dwd_whse w
  where
    (SELECT dateend FROM params)  BETWEEN z.b_date AND z.e_date
    and z.WHSE_CODE in ('01B','01R','02M','02V','04P','05H','1L5','092','0B3','0MX','0K3','CKL')
                                and w.whse_code=z.whse_code
    and z.VALUE='N') zvp
  WHERE
     (SELECT deID FROM params)
            BETWEEN R_ITEM.id_b_date AND R_ITEM.id_e_date 
     AND  R_ITEM.ITEM_NUM=zvp.ITEM_NUM
    and  zvp.terr_code=reg_spis.reg
--and reg_spis.reg in ('0', '1') 
       and  (R_ITEM.GL_IND_CATEGORY IN ('О', 'D') )
     AND R_ITEM.ITEM_NUM=R_ITEM.ART_GL
   ) i,
   
  (
  SELECT     
    
  R_ITEM.ART_GL,
    R_CAL.ID_DATE, 
  R_WHSE.TERR_CODE,
    SUM(ITEM_R.ON_HAND + ITEM_R.DAMAGED)  ost,
    SUM(ITEM_R.ON_HAND + ITEM_R.DAMAGED)  ost1,
    SUM(ITEM_R.COMMITTED_QTY) videl,
    SUM(R_ITEM_W.Safe_stock) rz,
    CASE WHEN SUM(ITEM_R.tfer_in)>0 THEN SUM(ITEM_R.tfer_in) else 0 end as tfer_in,
    max(R_ITEM_W.AVAIL_CALC_METHOD) avail_calc_method,
    row_number() over (partition by r_item.art_gl order by r_cal.id_date desc) num,
    r_cal.work_day
  FROM
    (SELECT * FROM KDW.DWD_ITEM WHERE (SELECT deID from params)
     BETWEEN id_b_date AND id_e_date) R_ITEM
    INNER JOIN KDW.DWF_ITEM_R  ITEM_R on ITEM_R.item_num=R_ITEM.item_num
    INNER JOIN KDW.DWD_WHSE  R_WHSE on ITEM_R.ID_WHSE=R_WHSE.ID_WHSE
    INNER JOIN kdw.dwd_item_w r_item_w on r_item_w.id_item_w = item_r.id_item_w
    INNER JOIN (SELECT * FROM KDW.DWD_CALENDAR WHERE    ( CAL_DATE BETWEEN (SELECT datebeg from params)
             AND (SELECT dateend from params) ) )R_CAL on  ITEM_R.ID_DATE=R_CAL.ID_DATE     
 WHERE
   R_WHSE.WHSE_CODE  in ('01B','01R','02M','02V','04P','05H','1L5','092','0B3','0MX','0K3','CKL')
   and  R_ITEM.GL_IND_CATEGORY IN ('О', 'D')
   AND R_CAL.WORK_DAY=1
 GROUP BY
   R_ITEM.ART_GL, 
   R_CAL.ID_DATE,
   r_cal.work_day,
   R_WHSE.TERR_CODE
order by r_cal.id_date desc
  ) o,
  (
   SELECT   
     R_ITEM.ART_GL,
   R_WHSE.TERR_CODE,
     SUM(NVL(s.m, 0)) AS m,
     SUM(NVL(s.f, 0)) AS f,
     SUM(NVL(s.v, 0)) AS v
   FROM
     KDW.DWD_ITEM  R_ITEM
     INNER JOIN kdw.dwf_zgl_stat s on R_ITEM.ITEM_num=s.ITEM_num 
     INNER JOIN KDW.DWD_WHSE  R_WHSE on s.id_whse = R_WHSE.id_whse 
     
   WHERE
  R_WHSE.WHSE_CODE  in ('01B','01R','02M','02V','04P','05H','1L5','092','0B3','0MX','0K3','CKL')
 AND (SELECT deID from params)
       BETWEEN R_ITEM.id_b_date AND R_ITEM.id_e_date
     AND  R_WHSE.WHSE_TYPE  =  1
     AND s.id_date =(SELECT ZGLID from params)
       and n > 5
       and   (r_item.ind_category in ('О', 'U', 'D') )
   GROUP BY
         R_ITEM.ART_GL,
    R_WHSE.TERR_CODE     
  ) statt
 WHERE i.art_gl=o.art_gl(+) AND i.art_gl=statt.art_gl(+) 
 and i.reg=o.terr_code(+) and i.reg=statt.terr_code(+)
 )a,
 (
           SELECT SUM(work_day) wd FROM   KDW.DWD_CALENDAR
           WHERE CAL_DATE BETWEEN (SELECT datebeg from params)
             AND (SELECT dateend from params)
) dd
where ts in ('Т15','Т16','Т35','Т61','Т62','Т63','Т64','Т65','Т66','Т67','Т68','Т69','Т70','Т44','Т45','Т46','Т50','Т51','Т54','Т55','Т56','Т57','Т58','Т59','Т78','Т79','Т80','Т81','Т82','Т83','Т84','Т85','Т86','Т87','Т91','Т92','Т93','Т90','Т94','Т95','Т96','Т97','Т98','Т99','Т33','Т100','Т32','Т107','Т108','Т109','Т110','Т111', 'Т112', 'Т113', 'Т114', 'Т115')
GROUP BY art_gl, ts, ts_name, sgrp_name, short_name,  gl_ind_category,  
m, f, v, dd.wd, dd.wd*f, dd.wd*v, artt, reg
)
WHERE
  art_gl = top.Артикул(+)
  and art_gl = topv.Артикул(+)
  and art_gl = topo.Артикул(+)
),



region_2 as
(
SELECT
  region.art_gl Артикул_,
  region.short_name Название_Артикула,
  region.gl_ind_category Категория,
  region.reg Регион,
  region.tss ТР,
  region.ts_name Название_ТР,
  'ТН' Название_ТН,
  'ТК' Название_ТК,
  'ТГ' Название_ТГ,
  'АГ' Название_АГ,
  'Москва' Поставщик,
  'Код_МЛ' Код_МЛ,
  'Логист' Логист,
  region.Признак_списка,
  region.Признак_списка_02,
  region.Признак_списка_03,
  'Код_логиста' Код_логиста,
  'Отдел' Отдел,
  'Глав_отдел' Глав_отдел,
  SUM(region.v_krt) Частота_спроса_за_КД,
  SUM(region.vo) СД_Частота_спроса,
  SUM(region.v_krt) Частота_спроса_ПС
  
FROM
  region
GROUP BY
  region.art_gl,
  region.short_name,
  region.gl_ind_category,
  region.reg,
  region.tss,
  region.ts_name,
  'ТН',
  'ТК',
  'ТГ',
  'АГ',
  'Москва',
  'Код_МЛ',
  'Логист',
  region.Признак_списка,
  region.Признак_списка_02,
  region.Признак_списка_03,
  'Код_логиста',
  'Отдел',
  'Глав_отдел'
 
)





SELECT
  moskow_2.Артикул_,
  moskow_2.Название_Артикула,
  moskow_2.Категория,
  moskow_2.Регион,
  moskow_2.ТР,
  moskow_2.Название_ТР,
  moskow_2.Название_ТН,
  moskow_2.Название_ТК,
  moskow_2.Название_ТГ,
  moskow_2.Название_АГ,
  moskow_2.Поставщик,
  moskow_2.Код_МЛ,
  moskow_2.Логист,
  moskow_2.Признак_списка,
  moskow_2.Признак_списка_02,
  moskow_2.Признак_списка_03,
  nvl(moskow_2.Отдел, moskow_2.Логист) Отдел,
  nvl(moskow_2.Глав_отдел, moskow_2.Логист) Глав_отдел,
  moskow_2.Частота_спроса_за_КД,
  moskow_2.СД_Частота_спроса,
  moskow_2.Частота_спроса_ПС,
  (case 
       when moskow_2.ТР in ('Т45') then 'Расходные материалы'
	   when moskow_2.ТР in ('Т50','Т51') then 'Канцтовары'
       when moskow_2.ТР in ('Т54','Т46','Т56','Т94','Т107','Т108', 'Т112', 'Т113', 'Т114', 'Т115') then 'Компьютеры.Печатающая техника.Телефония'
       when moskow_2.ТР in ('Т57','Т58','Т59') then 'Папки и Деловая бумажная продукция. Демооборудование. Товары для торговли.'
       when moskow_2.ТР in ('Т78','Т100') then 'Продукты питания. Бутилированная вода'
       when moskow_2.ТР in ('Т80','Т81','Т32') then 'Товары для учебы и творчества. Праздничная продукция'
       when moskow_2.ТР in ('Т82','Т93','Т97') then 'Товары HoReCa'
       when moskow_2.ТР in ('Т95','Т87','Т96','Т55') then 'Техника для офиса.Теле и видеотехника'
       when moskow_2.ТР in ('Т83','Т98','Т99') then 'Рабочая одежда и СИЗ'
       when moskow_2.ТР in ('Т90','Т91','Т85') then 'Товары для красоты и здоровья. Инструменты и мелкий ремонт (интернет-ассортимента)'
       when moskow_2.ТР in ('Т84','Т109','Т110','Т111') then 'Хозяйственные товары'
       when moskow_2.ТР in ('Т44') then 'Бумага для офисной техники'
       when moskow_2.ТР in ('Т92') then 'Бытовая техника'
       when moskow_2.ТР in ('Т33') then 'Мебель'
       Else 'Прочие'	   
   end ) КМ
FROM
  moskow_2

UNION

SELECT
  region_2.Артикул_,
  region_2.Название_Артикула,
  region_2.Категория,
  region_2.Регион,
  region_2.ТР,
  region_2.Название_ТР,
  region_2.Название_ТН,
  region_2.Название_ТК,
  region_2.Название_ТГ,
  region_2.Название_АГ,
  region_2.Поставщик,
  region_2.Код_МЛ,
  region_2.Логист,
  region_2.Признак_списка,
  region_2.Признак_списка_02,
  region_2.Признак_списка_03,
  nvl(region_2.Отдел, region_2.Логист) Отдел,
  nvl(region_2.Глав_отдел, region_2.Логист) Глав_отдел,
  region_2.Частота_спроса_за_КД,
  region_2.СД_Частота_спроса,
  region_2.Частота_спроса_ПС,
    (case 
       when region_2.ТР in ('Т45') then 'Расходные материалы'
	   when region_2.ТР in ('Т50','Т51') then 'Канцтовары'
       when region_2.ТР in ('Т54','Т46','Т56','Т94','Т107','Т108', 'Т112', 'Т113', 'Т114', 'Т115') then 'Компьютеры.Печатающая техника.Телефония'
       when region_2.ТР in ('Т57','Т58','Т59') then 'Папки и Деловая бумажная продукция. Демооборудование. Товары для торговли.'
       when region_2.ТР in ('Т78','Т100') then 'Продукты питания. Бутилированная вода'
       when region_2.ТР in ('Т80','Т81','Т32') then 'Товары для учебы и творчества. Праздничная продукция'
       when region_2.ТР in ('Т82','Т93','Т97') then 'Товары HoReCa'
       when region_2.ТР in ('Т95','Т87','Т96','Т55') then 'Техника для офиса.Теле и видеотехника'
       when region_2.ТР in ('Т83','Т98','Т99') then 'Рабочая одежда и СИЗ'
       when region_2.ТР in ('Т90','Т91','Т85') then 'Товары для красоты и здоровья. Инструменты и мелкий ремонт (интернет-ассортимента)'
       when region_2.ТР in ('Т84','Т109','Т110','Т111') then 'Хозяйственные товары'
       when region_2.ТР in ('Т44') then 'Бумага для офисной техники'
       when region_2.ТР in ('Т92') then 'Бытовая техника'
       when region_2.ТР in ('Т33') then 'Мебель'
       Else 'Прочие'	   
   end ) КМ
FROM
  region_2  
