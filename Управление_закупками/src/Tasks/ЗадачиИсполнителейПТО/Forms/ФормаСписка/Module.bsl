#Область ОбработчикиСобытий

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)

	Если Врег(ИмяСобытия) = Врег("Запись_ЗадачиЗадачиИсполнителейПТО") Тогда 
		Элементы.Список.Обновить();
	КонецЕсли;

КонецПроцедуры

#КонецОбласти
