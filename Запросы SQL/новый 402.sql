with top
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
)

SELECT 
  ad.ITEM_NUM Артикул_,
  ad.item_name Название_Артикула,
  ad.ind_category Категория,
  ad.terr_code Регион,
  ad.div_code ТР,
  ad.div_name Название_ТР,
  ad.tn Название_ТН,
  ad.tk Название_ТК,
  ad.tg Название_ТГ,
  ad.ag Название_АГ,
  ad.vendor_num||' '||ad.vendor_name Поставщик,
  ad.ml_code Код_МЛ,
  ad.ml_name Логист,
  top.Признак_списка,
  topv.Признак_списка_02,
  topo.Признак_списка_03,
  nvl(otdel.whse_code, otdel.vendor_num) Отдел,
  nvl(otdel.v_text, otdel.vendor_num) Глав_отдел,

  (case 
       when ad.div_code in ('Т45') then 'Расходные материалы'
	   when ad.div_code in ('Т50','Т51') then 'Канцтовары'
       when ad.div_code in ('Т54','Т46','Т56','Т94','Т107','Т108', 'Т112', 'Т113', 'Т114', 'Т115') then 'Компьютеры.Печатающая техника.Телефония'
       when ad.div_code in ('Т57','Т58','Т59') then 'Папки и Деловая бумажная продукция. Демооборудование. Товары для торговли.'
       when ad.div_code in ('Т78','Т100') then 'Продукты питания. Бутилированная вода'
       when ad.div_code in ('Т80','Т81','Т32') then 'Товары для учебы и творчества. Праздничная продукция'
       when ad.div_code in ('Т82','Т93','Т97') then 'Товары HoReCa'
       when ad.div_code in ('Т95','Т87','Т96','Т55') then 'Техника для офиса.Теле и видеотехника'
       when ad.div_code in ('Т83','Т98','Т99') then 'Рабочая одежда и СИЗ'
       when ad.div_code in ('Т90','Т91','Т85') then 'Товары для красоты и здоровья. Инструменты и мелкий ремонт (интернет-ассортимента)'
       when ad.div_code in ('Т84','Т109','Т110','Т111') then 'Хозяйственные товары'
       when ad.div_code in ('Т44') then 'Бумага для офисной техники'
       when ad.div_code in ('Т92') then 'Бытовая техника'
       when ad.div_code in ('Т33') then 'Мебель'
       Else 'Прочие'	   
   end ) КМ



FROM LSPOST.A_DOSTUPNOST ad,
top,
topv,
topo,
otdel
WHERE ad.ITEM_NUM = top.Артикул(+)
AND ad.ITEM_NUM = topv.Артикул(+)
AND ad.ITEM_NUM = topo.Артикул(+)
AND ad.ml_code = otdel.vendor_num(+)


