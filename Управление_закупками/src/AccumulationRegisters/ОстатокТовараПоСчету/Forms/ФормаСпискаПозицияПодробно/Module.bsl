#Область ОбработчикиСобытийФормы  

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("Отбор") Тогда
		
		Если Параметры.Отбор.Свойство("ВнутреннийЗаказ") Тогда 	
			ВнутреннийЗаказ = Параметры.Отбор.ВнутреннийЗаказ;	
		КонецЕсли;
		
		Если Параметры.Отбор.Свойство("Номенклатура") Тогда 	
			Номенклатура = Параметры.Отбор.Номенклатура;
		КонецЕсли;
		
		Если Параметры.Отбор.Свойство("ДополнительныеХарактеристикиНоменклатуры") Тогда	
			ДополнительныеХарактеристикиНоменклатуры = Параметры.Отбор.ДополнительныеХарактеристикиНоменклатуры;
		КонецЕсли;
		
		Если Параметры.Отбор.Свойство("ЕдиницаИзмерения") Тогда	
			ЕдиницаИзмерения = Параметры.Отбор.ЕдиницаИзмерения;
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти
