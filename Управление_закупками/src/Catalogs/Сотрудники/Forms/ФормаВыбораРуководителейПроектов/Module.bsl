#Область ОбработчикиСобытийФорм

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка) 
	
	АвтоЗаголовок = Ложь;
	Заголовок = "Руководители проектов";

	Список.Параметры.УстановитьЗначениеПараметра("Дата", ТекущаяДатаСеанса());  
	Список.Параметры.УстановитьЗначениеПараметра("Должность", Справочники.Должности.РуководительПроектов);
	
КонецПроцедуры

#КонецОбласти
