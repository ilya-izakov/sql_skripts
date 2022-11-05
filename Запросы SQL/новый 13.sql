 with art1 as (
		SELECT 
			ITEM_NUM Артикул,
			max( V_DATE) Дата_смены,
			IND_CATEGORY  новая_категория
		FROM KDW.DW_PRICE_HISTORY
		WHERE 
			V_DATE >=(SYSDATE - (@Prompt('2.Период дней','A',,mono,free))  )
			-- and state='1'
			--and (HSZ='064' or HSZ='Т33')
			AND ( DIV_CODE IN @Prompt('1. ТР','A',{'все', 'Т44', 'Т45', 'Т46', 'Т50', 'Т51', 'Т54', 'Т55', 'Т56', 'Т57', 'Т58', 'Т59', 'Т78', 'Т79', 'Т80', 'Т81', 'Т82', 'Т83', 'Т84', 'Т85', 'Т86', 'Т87', 'Т91', 'Т92', 'Т93', 'Т33', 'Т32', 'Т21', 'Т90', 'Т94', 'Т96', 'Т97', 'Т98', 'Т99', 'Т95', 'Т100'},multi,free)
						 OR 'все' IN @Prompt('1. ТР','A',{'все', 'Т44', 'Т45', 'Т46', 'Т50', 'Т51', 'Т54', 'Т55', 'Т56', 'Т57', 'Т58', 'Т59', 'Т78', 'Т79', 'Т80', 'Т81', 'Т82', 'Т83', 'Т84', 'Т85', 'Т86', 'Т87', 'Т91', 'Т92', 'Т93', 'Т33', 'Т32', 'Т21', 'Т90', 'Т94', 'Т96', 'Т97', 'Т98', 'Т99', 'Т95', 'Т100'},multi,free) )
			and IND_CATEGORY in ('П','В','Н','H','R','B')
			AND  ( ITEM_NUM IN (select SET_VALUE from KDW.W_SET_VALUES where set_id  =@Prompt('3. Список товаров','A',,mono,free))  )
			Group by ITEM_NUM, IND_CATEGORY 
			),
	art2 as (
		SELECT   
			price.ITEM_NUM Артикул,
			price.IND_CATEGORY старая_категория
		FROM
			KDW.DW_PRICE_HISTORY price,
			art1
		WHERE
			( price.B_DATE< art1.Дата_смены and price.E_DATE >= art1.Дата_смены )
			and price.state='1'
			 AND  ( price.ITEM_NUM IN (select SET_VALUE from KDW.W_SET_VALUES where set_id  =@Prompt('3. Список товаров','A',,mono,free))  )
			--and (price.HSZ='064' or price.HSZ='Т33')
			AND ( price.DIV_CODE IN @Prompt('1. ТР','A',{'все', 'Т44', 'Т45', 'Т46', 'Т50', 'Т51', 'Т54', 'Т55', 'Т56', 'Т57', 'Т58', 'Т59', 'Т78', 'Т79', 'Т80', 'Т81', 'Т82', 'Т83', 'Т84', 'Т85', 'Т86', 'Т87', 'Т91', 'Т92', 'Т93', 'Т33', 'Т32', 'Т21', 'Т90', 'Т94', 'Т96', 'Т97', 'Т98', 'Т99', 'Т95', 'Т100'},multi,free)
						 OR 'все' IN @Prompt('1. ТР','A',{'все', 'Т44', 'Т45', 'Т46', 'Т50', 'Т51', 'Т54', 'Т55', 'Т56', 'Т57', 'Т58', 'Т59', 'Т78', 'Т79', 'Т80', 'Т81', 'Т82', 'Т83', 'Т84', 'Т85', 'Т86', 'Т87', 'Т91', 'Т92', 'Т93', 'Т33', 'Т32', 'Т21', 'Т90', 'Т94', 'Т96', 'Т97', 'Т98', 'Т99', 'Т95', 'Т100'},multi,free) )
			)
	SELECT
		art1.Артикул,
		art1.Дата_смены,
		art1.новая_категория,
		art2.старая_категория
	from art1, art2
	where art1.Артикул=art2.Артикул
	and art1.новая_категория<> art2.старая_категория
	

  