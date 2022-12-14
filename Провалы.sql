WITH vt_cal_period_rd AS
  (
  SELECT
    cal.YYYY_MM Год_месяц,
    cal.YYYY_W Год_неделя,
    cal.ID_DATE ID_Даты,
    cal.CAL_DATE Дата,
    cal.WORK_DAY Р_день
  FROM
    KDW.DWD_CALENDAR cal
  WHERE
        ( cal.CAL_DATE BETWEEN TO_DATE(@Prompt('11. Дата начала периода ПД','A',,mono,free), 'DD.MM.YYYY')
                           AND TO_DATE(@Prompt('12. Дата окончания периода ПД','A',,mono,free), 'DD.MM.YYYY') )
    AND ( cal.WORK_DAY = 1 )
  )
, vt_cal_period_rd_min AS
  (
  SELECT
    MIN(vt_cal_period_rd.Год_месяц) Год_месяц_Минимум,
    MIN(vt_cal_period_rd.ID_Даты) ID_Даты_Минимум,
    MIN(vt_cal_period_rd.Дата) Дата_Минимум
  FROM
    vt_cal_period_rd
  )
,
  vt_cal_period_rd_max AS
  (
  SELECT
    MAX(vt_cal_period_rd.Год_месяц) Год_месяц_Максимум,
    MAX(vt_cal_period_rd.ID_Даты) ID_Даты_Максимум,
    MAX(vt_cal_period_rd.Дата) Дата_Максимум
  FROM
    vt_cal_period_rd
  )
,
  vt_cal_period_rd_count AS
  (
  SELECT
    COUNT(*) Кол_р_дней
  FROM
    vt_cal_period_rd
  WHERE
    ( vt_cal_period_rd.Р_день = 1 )
  )
,
  vt_min_dual_yyyy_mm AS
  (
  SELECT
    (SELECT vt_cal_period_rd_min.Год_месяц_Минимум FROM vt_cal_period_rd_min) Год_месяц_1
  FROM
    dual
  )
,
  vt_min_dual_id_date AS
  (
  SELECT
    (SELECT vt_cal_period_rd_min.ID_Даты_Минимум FROM vt_cal_period_rd_min) ID_Даты_1
  FROM
    dual
  )
,
  vt_min_dual_date AS
  (
  SELECT
    (SELECT vt_cal_period_rd_min.Дата_Минимум FROM vt_cal_period_rd_min) Дата_1
  FROM
    dual
  )
,
  vt_max_dual_yyyy_mm AS
  (
  SELECT
    (SELECT vt_cal_period_rd_max.Год_месяц_Максимум FROM vt_cal_period_rd_max) Год_месяц_2
  FROM
    dual
  )
,
  vt_max_dual_id_date AS
  (
  SELECT
    (SELECT vt_cal_period_rd_max.ID_Даты_Максимум FROM vt_cal_period_rd_max) ID_Даты_2
  FROM
    dual
  )
,
  vt_max_dual_date AS
  (
  SELECT
    (SELECT vt_cal_period_rd_max.Дата_Максимум FROM vt_cal_period_rd_max) Дата_2
  FROM
    dual
  )
  ,
vt_01_min_dual_date_002 AS
  (
  SELECT
    (SELECT TRUNC(vt_cal_period_rd_min.Дата_Минимум, 'MONTH') FROM vt_cal_period_rd_min) Дата_1
  FROM
    dual
  )
,
  vt_cal_min_01mmyyyy AS
  (
  SELECT
    cal.YYYY_MM Год_месяц,
    cal.ID_DATE ID_Даты,
    cal.CAL_DATE Дата,
    cal.WORK_DAY Р_день
  FROM
    KDW.DWD_CALENDAR cal,
    vt_01_min_dual_date_002
  WHERE
    ( cal.CAL_DATE = vt_01_min_dual_date_002.Дата_1 )
  )
,
  vt_01_min_dual_id_date_002 AS
  (
  SELECT
    (SELECT vt_cal_min_01mmyyyy.ID_Даты FROM vt_cal_min_01mmyyyy) ID_Даты_1
  FROM
    dual
  )
,
vt_01_max_dual_date_002 AS
  (
  SELECT
    (SELECT TRUNC(vt_cal_period_rd_max.Дата_Максимум, 'MONTH') FROM vt_cal_period_rd_max) Дата_2
  FROM
    dual
  )
,
  vt_cal_max_01mmyyyy AS
  (
  SELECT
    cal.YYYY_MM Год_месяц,
    cal.ID_DATE ID_Даты,
    cal.CAL_DATE Дата,
    cal.WORK_DAY Р_день
  FROM
    KDW.DWD_CALENDAR cal,
    vt_01_max_dual_date_002
  WHERE
    ( cal.CAL_DATE = vt_01_max_dual_date_002.Дата_2 )
  )
,
  vt_01_max_dual_id_date_002 AS
  (
  SELECT
    (SELECT vt_cal_max_01mmyyyy.ID_Даты FROM vt_cal_max_01mmyyyy) ID_Даты_2
  FROM
    dual
  )
,
vt_whse_code AS
  (
  SELECT
    mvw_w.ID_WHSE ID_Кода_склада,
    mvw_w.WHSE_CODE Код_склада,
    mvw_w.WHSE_GROUP Код_группы_склада,
    mvw_w.TERR_CODE Код_региона,
    
    CASE
    WHEN mvw_w.TERR_CODE = 0 THEN 'Москва'
    WHEN mvw_w.TERR_CODE = 1 THEN 'С.-Петербург'
    WHEN mvw_w.TERR_CODE = 2 THEN 'Краснодар'
    WHEN mvw_w.TERR_CODE = 3 THEN 'Челябинск'
    WHEN mvw_w.TERR_CODE = 4 THEN 'Н.Новгород'
    WHEN mvw_w.TERR_CODE = 5 THEN 'Новосибирск'
    WHEN mvw_w.TERR_CODE = 6 THEN 'Казань'
    WHEN mvw_w.TERR_CODE = 7 THEN 'Волгоград'
    WHEN mvw_w.TERR_CODE = 8 THEN 'Казань'
    WHEN mvw_w.TERR_CODE = 9 THEN 'Волгоград'
    WHEN mvw_w.TERR_CODE = 10 THEN 'Казань'
    WHEN mvw_w.TERR_CODE = 11 THEN 'Волгоград'
    WHEN mvw_w.TERR_CODE = 12 THEN 'Пермь'
    WHEN mvw_w.TERR_CODE = 13 THEN 'Омск'
    WHEN mvw_w.TERR_CODE = 14 THEN 'Челябинск'
    ELSE 'Не определён' END Регион
    
  FROM
    KDW.DWD_WHSE mvw_w
  WHERE
        ( mvw_w.clp = 'Y' )
    AND ( mvw_w.TERR_CODE = 0 )
  ),
  vt_catalog_tovara_kdw_other_16 AS
    (
    SELECT /*+ materialize */
      mvw_goods.ITEM_NUM Артикул,
	  mvw_w.ID_WHSE ID_Склада,
	  mvw_goods.VOLUME Объём_см3,
	  
      mvw_goods.ITEM_NAME Название_товара,
      mvw_goods.UNIT Ед_изм,
      mvw_goods.DIV_CODE Код_ТР,
      mvw_goods_TS.DIV_NAME Название_ТР,
      mvw_goods.IND_CATEGORY Признак_категория,
      mvw_goods.SKL_OSN СОХ,
      mvw_goods.HSZ ХСЗ,
      mvw.VENDOR_NUM Код_поставщика,
      mvw.VENDOR_NAME Название_поставщика,
      DECODE(NVL(mvw.vend_whse_status, 'D'), 'D', mvw_main_item_v.VEND_PARENT_NUM, mvw.VEND_PARENT_NUM) Код_факт_поставщика,
      DECODE(NVL(mvw.vend_whse_status, 'D'), 'D', mvw_main_item_v.VEND_PARENT_NAME, mvw.VEND_PARENT_NAME) Название_факт_поставщика,
      mvw.PROD_MANAGER Код_МЛ,
      mvw.PROD_MANAGER_NAME Название_МЛ,
      
      mvw.LEAD_TIME + mvw.STOCK_CONTROL СП_ЧКЗ,
      
      mvw.quota МТП,
      mvw.SUPPLY_TYPE Форма_снабжения
      
    FROM
      KDW.DW_GOODS mvw_goods,
      KDW.DWD_DIVISION mvw_goods_TS,
      KDW.DWE_ITEM_G mvw_item_g,
      KDW.DWD_U_OPER mvw_g_oper,
      KDW.DWE_MAIN_VEND_WHSE mvw,
      KDW.DWE_MAIN_ITEM_V mvw_main_item_v,
      KDW.DWD_WHSE mvw_w,
      vt_whse_code
 
     
    WHERE
         ( mvw_goods_TS.DIV_CODE = mvw_goods.DIV_CODE AND mvw_goods_TS.DIV_TYPE = 2 AND mvw_goods_TS.IS_CURRENT = 'Y' )
      AND ( mvw_goods.ITEM_NUM = mvw_item_g.ITEM_NUM )
      AND ( mvw_goods.bayer = mvw_g_oper.user_code(+) )
      
      AND ( mvw_goods.ITEM_NUM = mvw.ITEM_NUM(+) )
      AND ( mvw.VEND_WHSE_STATUS <> 'D' )
      AND ( mvw.ITEM_NUM = mvw_main_item_v.ITEM_NUM )
      
      AND ( mvw_goods.SKL_OSN = mvw_w.WHSE_CODE )
      AND ( mvw_w.WHSE_GROUP = mvw.WHSE_CODE )
      
      AND ( mvw_goods.SKL_OSN = vt_whse_code.Код_склада )
	  AND ( mvw_goods_TS.DIV_CODE='Т93')
	AND (mvw_goods.IND_CATEGORY='D' or mvw_goods.IND_CATEGORY='О' or mvw_goods.IND_CATEGORY='O')
    )
	, 
	
  art as (
  SELECT
	--dwf_int_m_d_all.ID_STAT_DATE ID_Даты_отчёта,
	dwf_int_m_d_all.ITEM_NUM Артикул ,
   -- vt_whse_code.Код_склада Код_склада,
   dwf_int_m_d_all.ID_DATE Дата
   --,
    --1 Кол_ПД,
    --dwf_int_m_d_all.REM_IN ТЗ_в_свободе,
    --dwf_int_m_d_all.MOVE_QTY ПР_по_ПД,
    --dwf_int_m_d_all.ADJ_QTY ПР_ограниченный_по_ПД*/
	
  FROM
    KDW.DWF_ITN_MAIN_DATA_ALL dwf_int_m_d_all,
   vt_01_max_dual_id_date_002,
   vt_catalog_tovara_kdw_other_16,
  vt_whse_code
  WHERE
        ( dwf_int_m_d_all.ID_STAT_DATE = vt_01_max_dual_id_date_002.ID_Даты_2 )
    AND ( dwf_int_m_d_all.ID_WHSE = vt_whse_code.ID_Кода_склада )
	AND vt_catalog_tovara_kdw_other_16.Артикул=dwf_int_m_d_all.ITEM_NUM
 -- AND ( dwf_int_m_d_all.ITEM_NUM in ( '866287','1301531','1422169','954119','1413525' ))
	 )
	 ,
	 
vt_dis_art as( 
	SELECT
    DISTINCT
    dwf_int_m_d_all.ITEM_NUM Артикул
  FROM
    KDW.DWF_ITN_MAIN_DATA_ALL dwf_int_m_d_all,
    vt_01_max_dual_id_date_002,
    vt_cal_period_rd,
    vt_cal_period_rd_count,
	vt_catalog_tovara_kdw_other_16,
    vt_whse_code
  WHERE
        ( dwf_int_m_d_all.ID_STAT_DATE = vt_01_max_dual_id_date_002.ID_Даты_2 )
    AND ( dwf_int_m_d_all.ID_DATE = vt_cal_period_rd.ID_Даты )
    AND ( dwf_int_m_d_all.ID_WHSE = vt_whse_code.ID_Кода_склада )
	AND vt_catalog_tovara_kdw_other_16.Артикул=dwf_int_m_d_all.ITEM_NUM
    --AND ( dwf_int_m_d_all.ITEM_NUM in ( '866287','1301531','1422169','954119','1413525' ))
	 )
	 ,
	 
vt_dec as (
	SELECT vt_dis_art.Артикул Артикул, 
	 vt_cal_period_rd.ID_Даты ID_Даты,
    vt_cal_period_rd.Дата Дата
	FROM vt_dis_art, vt_cal_period_rd
	 )
	 , 
	 
vt_art as(
	select/*
	art.ID_Даты_отчёта ID_Даты_отчёта,
	-- art.Артикул Артикул,
    art.Код_склада Код_склада,
	art.Кол_ПД Кол_ПД,
    art.ТЗ_в_свободе ТЗ_в_свободе,
    art.ПР_по_ПД ПР_по_ПД,
    art.ПР_ограниченный_по_ПД ПР_ограниченный_по_ПД,*/
	case when art.Артикул is NULL then '1' ELSE '0' END as ПР_ПД,
	vt_dec.Артикул Артикул,
	vt_dec.Дата Дата

	 from art,
	 vt_dec
	 where 
	 art.Артикул(+) = vt_dec.Артикул 
	 and art.Дата(+) = vt_dec.ID_Даты
	 ORDER BY vt_dec.Артикул, vt_dec.ID_Даты
	 )
	 , 
	 
vt_art_2  as(
	select/*
	art.ID_Даты_отчёта ID_Даты_отчёта,
	-- art.Артикул Артикул,
    art.Код_склада Код_склада,
	art.Кол_ПД Кол_ПД,
    art.ТЗ_в_свободе ТЗ_в_свободе,
    art.ПР_по_ПД ПР_по_ПД,
    art.ПР_ограниченный_по_ПД ПР_ограниченный_по_ПД,*/
	case when art.Артикул is NULL then '1' ELSE '0' END as ПР_ПД_2,
	vt_dec.Артикул Артикул_2,
	vt_dec.Дата Дата_2

	 from art,
	 vt_dec
	 where 
	 art.Артикул(+) = vt_dec.Артикул
	 and art.Дата(+) = vt_dec.ID_Даты
	 ORDER BY vt_dec.Артикул, vt_dec.ID_Даты
	 )
	 ,
	 
vt_date_min as (SELECT vt_art.Артикул Артикул, vt_art.Дата Дата, vt_art.ПР_ПД ПР_ПД,
	  (select min(vt_art_2.Дата_2)
	 from vt_art_2
	 where   vt_art_2.Артикул_2 = vt_art.Артикул
        and vt_art_2.ПР_ПД_2 = vt_art.ПР_ПД
        and vt_art_2.Дата_2 <= vt_art.Дата
        and vt_art_2.Дата_2 >(
		select
		max( vt_art_2.Дата_2)
        from
            vt_art_2 
        where
            vt_art_2.Артикул_2 = vt_art.Артикул
            and vt_art_2.ПР_ПД_2 != vt_art.ПР_ПД
            and vt_art_2.Дата_2 <= vt_art.Дата)
	 
	 ) as Мин_дата
	 From vt_art
	 order by vt_art.Артикул, vt_art.Дата
	 )
	 , 
	 
vt_table as(
		select 
	 DISTINCT
	 vt_date_min.Артикул Артикул,
	 vt_date_min.Мин_дата Дата
	 --, count(*) Кол_во
	from vt_date_min
	where vt_date_min.ПР_ПД='1'
	GROUP by  vt_date_min.Артикул, vt_date_min.Мин_дата
	)
	,

vt_table_proval as(
	 select 
	 Distinct
	 vt_table.Артикул Артикул,
	 Count(*) Кол_во_провалов
	 from vt_table
	group by vt_table.Артикул
	)
	,
vt_pd_01 AS(
  SELECT
    dwf_int_m_d_all.ID_STAT_DATE ID_Даты_отчёта,
    dwf_int_m_d_all.ITEM_NUM Артикул,
    vt_whse_code.Код_склада,
    vt_cal_period_rd.Дата,
    
    vt_cal_period_rd_count.Кол_р_дней,
    1 Кол_ПД,
    dwf_int_m_d_all.REM_IN ТЗ_в_свободе,
    dwf_int_m_d_all.MOVE_QTY ПР_по_ПД,
    dwf_int_m_d_all.ADJ_QTY ПР_ограниченный_по_ПД
  FROM
    KDW.DWF_ITN_MAIN_DATA_ALL dwf_int_m_d_all,
    vt_01_max_dual_id_date_002,
    vt_cal_period_rd,
    vt_cal_period_rd_count,
	vt_catalog_tovara_kdw_other_16,
    vt_whse_code
  WHERE
        ( dwf_int_m_d_all.ID_STAT_DATE = vt_01_max_dual_id_date_002.ID_Даты_2 )
    AND ( dwf_int_m_d_all.ID_DATE = vt_cal_period_rd.ID_Даты )
    AND ( dwf_int_m_d_all.ID_WHSE = vt_whse_code.ID_Кода_склада )
	AND vt_catalog_tovara_kdw_other_16.Артикул=dwf_int_m_d_all.ITEM_NUM
	-- and ( dwf_int_m_d_all.MOVE_QTY<>dwf_int_m_d_all.ADJ_QTY )
   --AND ( dwf_int_m_d_all.ITEM_NUM in ( '866287','1301531','1422169','954119','1413525' ))
	   )
		, 
vt_pd_02 AS
  (
  SELECT
    vt_pd_01.ID_Даты_отчёта ID_Даты_отчёта,
    vt_pd_01.Артикул Артикул,
    vt_pd_01.Код_склада Код_склада,
    
    vt_pd_01.Кол_р_дней Кол_р_дней,
    
    SUM(vt_pd_01.Кол_ПД) Кол_ПД,
    SUM(vt_pd_01.Кол_ПД) / vt_pd_01.Кол_р_дней Доступность,
    AVG(vt_pd_01.ТЗ_в_свободе) ТЗ_в_свободе_среднее,
    SUM(vt_pd_01.ПР_по_ПД) ПР_по_ПД,
    SUM(vt_pd_01.ПР_ограниченный_по_ПД) ПР_ограниченный_по_ПД,
	MIN(vt_pd_01.ТЗ_в_свободе) мин_ТЗ_в_свободе
  FROM
    vt_pd_01
  GROUP BY
    vt_pd_01.ID_Даты_отчёта,
    vt_pd_01.Артикул,
    vt_pd_01.Код_склада,
    
    vt_pd_01.Кол_р_дней
  )
  ,
  
vt_priznak_pik as(  
  SELECT
   dwf_int_m_d_all.ITEM_NUM Артикул,
    1 Признак_пика
  FROM
    KDW.DWF_ITN_MAIN_DATA_ALL dwf_int_m_d_all,
    vt_01_max_dual_id_date_002,
    vt_cal_period_rd,
    vt_cal_period_rd_count,
    vt_whse_code
  WHERE
        ( dwf_int_m_d_all.ID_STAT_DATE = vt_01_max_dual_id_date_002.ID_Даты_2 )
    AND ( dwf_int_m_d_all.ID_DATE = vt_cal_period_rd.ID_Даты )
    AND ( dwf_int_m_d_all.ID_WHSE = vt_whse_code.ID_Кода_склада )
	and ( dwf_int_m_d_all.MOVE_QTY<>dwf_int_m_d_all.ADJ_QTY )
  )
  ,
  
vt_mo as(
	SELECT
  dis.ITEM_NUM Артикул,
  dis.MO МО,
  dis.VO VO,
  (dis.MO*vt_catalog_tovara_kdw_other_16.Объём_см3)/1000000 МО_объем
  from 
  KDW.DWF_ITN_STATS dis,
  vt_01_max_dual_id_date_002,
  vt_catalog_tovara_kdw_other_16,
  vt_whse_code
  where
  dis.ID_STAT_DATE=vt_01_max_dual_id_date_002.ID_Даты_2
  AND dis.ITEM_NUM=vt_catalog_tovara_kdw_other_16.Артикул
  and dis.ID_WHSE=vt_whse_code.ID_Кода_склада
  )
  
SELECT 
	vt_pd_02.ID_Даты_отчёта,
    vt_pd_02.Артикул,
    vt_pd_02.Код_склада,
    vt_pd_02.Кол_р_дней,
    vt_pd_02.Кол_ПД,
    vt_pd_02.Доступность,
    vt_pd_02.ТЗ_в_свободе_среднее,
    vt_pd_02.ПР_по_ПД,
	vt_pd_02.ПР_ограниченный_по_ПД,
	
	 
	  
    vt_catalog_tovara_kdw_other_16.Название_товара,
    vt_catalog_tovara_kdw_other_16.Ед_изм,
    vt_catalog_tovara_kdw_other_16.Код_ТР,
    vt_catalog_tovara_kdw_other_16.Название_ТР,
    vt_catalog_tovara_kdw_other_16.Признак_категория,
    vt_catalog_tovara_kdw_other_16.СОХ,
    vt_catalog_tovara_kdw_other_16.ХСЗ,
    vt_catalog_tovara_kdw_other_16.Код_поставщика,
    vt_catalog_tovara_kdw_other_16.Название_поставщика,
    vt_catalog_tovara_kdw_other_16.Код_факт_поставщика,
    vt_catalog_tovara_kdw_other_16.Название_факт_поставщика,
    vt_catalog_tovara_kdw_other_16.Код_МЛ,
    vt_catalog_tovara_kdw_other_16.Название_МЛ,
      
    vt_catalog_tovara_kdw_other_16.СП_ЧКЗ,
      

	
	vt_table_proval.Кол_во_провалов, 
	vt_priznak_pik.Признак_пика, 
	
	vt_mo.VO, 
	vt_mo.МО, 
	vt_mo.МО_объем
from 
	vt_pd_02, 
  vt_table_proval, 
  vt_priznak_pik, 
  vt_catalog_tovara_kdw_other_16,
  vt_mo
where 
 vt_pd_02.Артикул=vt_table_proval.Артикул(+)
  AND vt_pd_02.Артикул=vt_priznak_pik.Артикул(+)
  and vt_pd_02.Артикул=vt_mo.Артикул(+)
  AND vt_catalog_tovara_kdw_other_16.Артикул=vt_pd_02.Артикул