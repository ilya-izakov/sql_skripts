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
  art as (
	SELECT
    dwf_int_m_d_all.ID_STAT_DATE ID_Даты_отчёта,
	dwf_int_m_d_all.ITEM_NUM Артикул,
    vt_whse_code.Код_склада Код_склада,
   dwf_int_m_d_all.ID_DATE Дата,
    1 Кол_ПД,
    dwf_int_m_d_all.REM_IN ТЗ_в_свободе,
    dwf_int_m_d_all.MOVE_QTY ПР_по_ПД,
    dwf_int_m_d_all.ADJ_QTY ПР_ограниченный_по_ПД
	
  FROM
    KDW.DWF_ITN_MAIN_DATA_ALL dwf_int_m_d_all,
   vt_01_max_dual_id_date_002,
  vt_whse_code
  WHERE
        ( dwf_int_m_d_all.ID_STAT_DATE = vt_01_max_dual_id_date_002.ID_Даты_2 )
    AND ( dwf_int_m_d_all.ID_WHSE = vt_whse_code.ID_Кода_склада )
    AND ( dwf_int_m_d_all.ITEM_NUM in ( '866287','1301531','1487624','1478573','784578','1514486','1482262','1384115','1496144','803425','1488234') )
	 ),
	 vt_dis_art as( 
	 SELECT
    DISTINCT
    dwf_int_m_d_all.ITEM_NUM Артикул
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
    AND ( dwf_int_m_d_all.ITEM_NUM in ( '866287','1301531','1487624','1478573','784578','1514486','1482262','1384115','1496144','803425','1488234') )
	 ),
	 vt_dec as (
	 SELECT vt_dis_art.Артикул Артикул, 
	 vt_cal_period_rd.ID_Даты ID_Даты,
    vt_cal_period_rd.Дата Дата
	 FROM vt_dis_art, vt_cal_period_rd
	 ), 
	 vt_art as(
	select
	art.ID_Даты_отчёта ID_Даты_отчёта,
	-- art.Артикул Артикул,
    art.Код_склада Код_склада,
	art.Кол_ПД Кол_ПД,
    art.ТЗ_в_свободе ТЗ_в_свободе,
    art.ПР_по_ПД ПР_по_ПД,
    art.ПР_ограниченный_по_ПД ПР_ограниченный_по_ПД,
	case when art.Артикул is NULL then '1' ELSE '0' END as ПР_ПД,
	vt_dec.Артикул Артикул,
	vt_dec.Дата Дата

	 from art,
	 vt_dec
	 where 
	 art.Артикул(+) = vt_dec.Артикул 
	 and art.Дата(+) = vt_dec.ID_Даты
	 ORDER BY vt_dec.Артикул, vt_dec.ID_Даты
	 ), 
	 vt_art_2  as(
	select
	
	-- art.Артикул Артикул,
    art.Код_склада Код_склада,
	art.Кол_ПД Кол_ПД,
    art.ТЗ_в_свободе ТЗ_в_свободе,
    art.ПР_по_ПД ПР_по_ПД,
    art.ПР_ограниченный_по_ПД ПР_ограниченный_по_ПД,
	case when art.Артикул is NULL then '1' ELSE '0' END as ПР_ПД_2,
	vt_dec.Артикул Артикул_2,
	vt_dec.Дата Дата_2

	 from art,
	 vt_dec
	 where 
	 art.Артикул(+) = vt_dec.Артикул
	 and art.Дата(+) = vt_dec.ID_Даты
	 ORDER BY vt_dec.Артикул, vt_dec.ID_Даты
	 ),
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
	 order by vt_art.Артикул, vt_art.Дата)
	 
	 select
Distinct
vt_date_min.Артикул,
vt_date_min.Мин_дата,
Count(*)
from vt_date_min
where vt_date_min.ПР_ПД='1'
group by vt_date_min.Артикул,
vt_date_min.Мин_дата