#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	АвтоЗаголовок = Ложь;
	ФлажокРазрешитЗполнитьДатаПоставки = Ложь;
	ФлажокРазрешитЗполнитьНоменклатурнуюГруппу = Ложь;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ОтменитьИЗакрыть(Команда)  

	Закрыть();
	
КонецПроцедуры

&НаКлиенте
Процедура ЗакрытьИЗаполнить(Команда)
	
	Результат = Новый Структура();
	Если ФлажокРазрешитЗполнитьДатаПоставки Тогда
		Результат.Вставить("ДатаПоставки", ЗначениеДатаПоставки);
	КонецЕсли;
	
	Если ФлажокРазрешитЗполнитьНоменклатурнуюГруппу Тогда
		Результат.Вставить("НоменклатурнаяГруппа", ЗначениеНоменклатурнаяГруппа);
	КонецЕсли;
	
	Закрыть(Результат);
	
КонецПроцедуры

#КонецОбласти
