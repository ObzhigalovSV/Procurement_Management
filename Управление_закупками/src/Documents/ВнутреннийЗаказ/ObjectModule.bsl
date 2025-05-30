#Область ОбработчикиСобытий

Процедура ОбработкаЗаполнения(ДанныеЗаполнения, ТекстЗаполнения, СтандартнаяОбработка)
	
	Если ЭтоНовый() Тогда  
		
		Ответственный = КадрыСервер.ТекущийСотрудник();
		ДатаСоздания = ТекущаяДатаСеанса(); 
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, Режим) 
	
	Если Товары.Количество() = 0 Тогда
		
		ТекстСообщения = "Документ не проведен. Табличная часть документа не может быть пустой.";
		ОбщегоНазначения.СообщитьПользователю(ТекстСообщения,,,,Отказ);
		Возврат;
		
	КонецЕсли;  
	
	Если  Не ТабличнаяЧастьТоварыЗаполненаВерно() Тогда
		
		ТекстСообщения = "Ошибка. Текущий внутренний заказ не правильно заполнен.
			|Откройте заказ, исправьте ошибки и заново проведите документ.";
		
		ОбщегоНазначения.СообщитьПользователю(ТекстСообщения,,,,Отказ);
		Возврат;
                      
	КонецЕсли;
			
	//Проверка на отрицательную потребность
	Если КорректировкиФормируютОтрицательнуюПотребность() Тогда 
		Отказ = Истина;  
	КонецЕсли;
	
	
	Если Отказ Тогда 
		Возврат;
	КонецЕсли;
		
	Если ЗаказОтправленВОМТС Тогда 
		
		// регистр ОстатокПотребностиПоВнутреннимЗаказам Приход 
		ЗаписатьДвиженияВРегистрОстатокПотребностиПоВнутреннимЗаказам(Отказ);
			
	КонецЕсли;
		
КонецПроцедуры 

Процедура ОбработкаУдаленияПроведения(Отказ) 
	
	Если ЗаказОтправленВОМТС Тогда
		ТекстСообщения = СтрШаблон("Документ %1 от %2 не может быть удален, так как он уже передан в работу ОМТС",Номер, Дата);
		ОбщегоНазначения.СообщитьПользователю(ТекстСообщения,,,,Отказ);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти   


#Область СлужебныеПроцедурыИФункции

Функция ТабличнаяЧастьТоварыЗаполненаВерно()
	
	// Проверить на наличие/отсутствие ссылок на внутренний заказ, к которым должна примениться отрицательная корректировка.
	
	ТабличнаяЧастьТоварыЗаполненаВерно = Истина; 
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ВнутреннийЗаказТовары.Номенклатура КАК Номенклатура
		|ИЗ
		|	Документ.ВнутреннийЗаказ.Товары КАК ВнутреннийЗаказТовары
		|ГДЕ
		|	ВнутреннийЗаказТовары.Ссылка = &Ссылка
		|	И ВнутреннийЗаказТовары.Количество < 0
		|	И ВнутреннийЗаказТовары.ЗаказДляКорректировки = ЗНАЧЕНИЕ(Документ.ВнутреннийЗаказ.ПустаяСсылка)";
			
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	РезультатЗапроса = Запрос.Выполнить();  
	
	Если Не РезультатЗапроса.Пустой() Тогда
		
		ТабличнаяЧастьТоварыЗаполненаВерно = Ложь;
		
	КонецЕсли;  
	
	
	// Проверить ссылки на внутренний заказ, на принадлежность к базовому проекту и части проекта.
	// Корректировка должна ссылаться на одноименные рабочий документ и часть проекта.
	Запрос.Текст =
		"ВЫБРАТЬ
		|	ВнутреннийЗаказТовары.ЗаказДляКорректировки КАК ЗаказДляКорректировки
		|ИЗ
		|	Документ.ВнутреннийЗаказ.Товары КАК ВнутреннийЗаказТовары
		|ГДЕ
		|	ВнутреннийЗаказТовары.Количество < 0
		|	И ВнутреннийЗаказТовары.ЗаказДляКорректировки.РабочаяДокументация.БазовыйДокумент <> &БазовыйДокумент
		|	И ВнутреннийЗаказТовары.ЗаказДляКорректировки.РабочаяДокументация.РазделПроекта <> &РазделПроекта
		|	И ВнутреннийЗаказТовары.Ссылка = &Ссылка
		|	И ВнутреннийЗаказТовары.ЗаказДляКорректировки <> ЗНАЧЕНИЕ(Документ.ВнутреннийЗаказ.ПустаяСсылка)";
	
	
	БазовыйДокументИРазделПроекта = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(РабочаяДокументация,"БазовыйДокумент,РазделПроекта"); 
	
	Запрос.УстановитьПараметр("БазовыйДокумент", БазовыйДокументИРазделПроекта.БазовыйДокумент); 
	Запрос.УстановитьПараметр("РазделПроекта", БазовыйДокументИРазделПроекта.РазделПроекта); 
    Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	РезультатЗапроса = Запрос.Выполнить();  
	
	Если Не РезультатЗапроса.Пустой() Тогда
		
		ТабличнаяЧастьТоварыЗаполненаВерно = Ложь;
		
	КонецЕсли;
		
	Возврат ТабличнаяЧастьТоварыЗаполненаВерно;  
	
	
	
КонецФункции

Функция ПолучитьМассивКорректирующихЗаказов()
	
	МассивКорректирующихЗаказов = Новый Массив;
	
	Для Каждого СтрокаТабличнойЧасти Из Товары Цикл
		
		Если СтрокаТабличнойЧасти.Количество < 0 
			И СтрокаТабличнойЧасти.ЗаказДляКорректировки <> Документы.ВнутреннийЗаказ.ПустаяСсылка() Тогда 
			
			МассивКорректирующихЗаказов.Добавить(СтрокаТабличнойЧасти.ЗаказДляКорректировки);
			
		КонецЕсли;
		
	КонецЦикла;    
	
	МассивКорректирующихЗаказов.Добавить(Ссылка);
	
	Возврат МассивКорректирующихЗаказов;
	
КонецФункции

Функция КорректировкиФормируютОтрицательнуюПотребность()
	
	КорректировкиФормируютОтрицательнуюПотребность = Ложь;
	//Проверка на отрицательную потребность    
	
	
	МассивКорректирующихЗаказов = ПолучитьМассивКорректирующихЗаказов(); 
	
	
	Запрос = Новый Запрос; 
	Запрос.Текст =  "ВЫБРАТЬ
	                |	ВнутреннийЗаказТовары.Ссылка КАК ВнутреннийЗаказ,
	                |	ВнутреннийЗаказТовары.Номенклатура КАК Номенклатура,
	                |	ВнутреннийЗаказТовары.ДополнительныеХарактеристикиНоменклатуры КАК ДополнительныеХарактеристикиНоменклатуры,
	                |	ВнутреннийЗаказТовары.ЕдиницаИзмеренияЗаказа КАК ЕдиницаИзмеренияЗаказа,
	                |	ВнутреннийЗаказТовары.Количество КАК Количество
	                |ПОМЕСТИТЬ ВТТовары
	                |ИЗ
	                |	Документ.ВнутреннийЗаказ.Товары КАК ВнутреннийЗаказТовары
	                |ГДЕ
	                |	ВнутреннийЗаказТовары.Количество > 0
	                |	И ВнутреннийЗаказТовары.Ссылка В(&МассивКорректирующихЗаказов)
	                |	И ВнутреннийЗаказТовары.Ссылка.Проведен
	                |
	                |ОБЪЕДИНИТЬ ВСЕ
	                |
	                |ВЫБРАТЬ
	                |	ВнутреннийЗаказТовары.ЗаказДляКорректировки,
	                |	ВнутреннийЗаказТовары.Номенклатура,
	                |	ВнутреннийЗаказТовары.ДополнительныеХарактеристикиНоменклатуры,
	                |	ВнутреннийЗаказТовары.ЕдиницаИзмеренияЗаказа,
	                |	ВнутреннийЗаказТовары.Количество
	                |ИЗ
	                |	Документ.ВнутреннийЗаказ.Товары КАК ВнутреннийЗаказТовары
	                |ГДЕ
	                |	ВнутреннийЗаказТовары.Количество < 0
	                |	И ВнутреннийЗаказТовары.ЗаказДляКорректировки В(&МассивКорректирующихЗаказов)
	                |	И ВнутреннийЗаказТовары.Ссылка.Проведен
	                |;
	                |
	                |////////////////////////////////////////////////////////////////////////////////
	                |ВЫБРАТЬ
	                |	ВТТовары.ВнутреннийЗаказ КАК ВнутреннийЗаказ,
	                |	ВТТовары.Номенклатура КАК Номенклатура,
	                |	ВТТовары.ДополнительныеХарактеристикиНоменклатуры КАК ДополнительныеХарактеристикиНоменклатуры,
	                |	ВТТовары.ЕдиницаИзмеренияЗаказа КАК ЕдиницаИзмеренияЗаказа,
	                |	СУММА(ВТТовары.Количество) КАК Количество
	                |ПОМЕСТИТЬ ВТТоварыСвернутые
	                |ИЗ
	                |	ВТТовары КАК ВТТовары
	                |
	                |СГРУППИРОВАТЬ ПО
	                |	ВТТовары.Номенклатура,
	                |	ВТТовары.ВнутреннийЗаказ,
	                |	ВТТовары.ЕдиницаИзмеренияЗаказа,
	                |	ВТТовары.ДополнительныеХарактеристикиНоменклатуры
	                |;
	                |
	                |////////////////////////////////////////////////////////////////////////////////
	                |ВЫБРАТЬ
	                |	ВТТоварыСвернутые.ВнутреннийЗаказ.Номер КАК ВнутреннийЗаказНомер,
	                |	ВТТоварыСвернутые.Номенклатура.Представление КАК НоменклатураПредставление,
	                |	ВТТоварыСвернутые.ЕдиницаИзмеренияЗаказа.Представление КАК ЕдиницаИзмеренияЗаказаПредставление,
	                |	ВТТоварыСвернутые.Количество КАК Количество
	                |ИЗ
	                |	ВТТоварыСвернутые КАК ВТТоварыСвернутые
	                |ГДЕ
	                |	ВТТоварыСвернутые.Количество < 0";
	  
		
	Запрос.УстановитьПараметр("МассивКорректирующихЗаказов", МассивКорректирующихЗаказов);
	
	РезультатЗапроса = Запрос.Выполнить();
	Если Не РезультатЗапроса.Пустой() Тогда
		
		КорректировкиФормируютОтрицательнуюПотребность = Истина;
		
		Выборка = РезультатЗапроса.Выбрать();
		
		Пока Выборка.Следующий() Цикл
			
			ТекстСообщения = СтрШаблон("В заказе №%1, в строке с номенклатурой 
			| %2 %3 %4
			|формируется отрицательная потребность в количестве %5.",Выборка.ВнутреннийЗаказНомер,
			Выборка.НоменклатураПредставление, Выборка.КоличествоПоЗаявке, Выборка.ЕдиницаИзмеренияПредставление, Выборка.КоличествоПотребности);
			
			ОбщегоНазначения.СообщитьПользователю(ТекстСообщения);
			
		КонецЦикла; 
				
	КонецЕсли; 
	
	Возврат КорректировкиФормируютОтрицательнуюПотребность;
	
КонецФункции

Процедура ЗаписатьДвиженияВРегистрОстатокПотребностиПоВнутреннимЗаказам(Отказ)
	
	// Если поставка за заказчиком, движения проводить не надо.
	// В случае перепроведения - удалить старые записи
	
	Движения.ОстатокПотребностиПоВнутреннимЗаказам.Записывать = Истина;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ВнутреннийЗаказТовары.Номенклатура КАК Номенклатура,
	|	ВнутреннийЗаказТовары.ЕдиницаИзмеренияЗаказа КАК ЕдиницаИзмеренияЗаказа,
	|	СУММА(ВнутреннийЗаказТовары.Количество) КАК Количество,
	|	ВнутреннийЗаказТовары.ЗаказДляКорректировки КАК ЗаказДляКорректировки,
	|	ЕСТЬNULL(ВнутреннийЗаказТовары.ДополнительныеХарактеристикиНоменклатуры, ЗНАЧЕНИЕ(Документ.ВнутреннийЗаказ.ПустаяСсылка)) КАК ДополнительныеХарактеристикиНоменклатуры
	|ИЗ
	|	Документ.ВнутреннийЗаказ.Товары КАК ВнутреннийЗаказТовары
	|ГДЕ
	|	ВнутреннийЗаказТовары.Ссылка = &Ссылка
	|
	|СГРУППИРОВАТЬ ПО
	|	ВнутреннийЗаказТовары.Номенклатура,
	|	ВнутреннийЗаказТовары.ЕдиницаИзмеренияЗаказа,
	|	ВнутреннийЗаказТовары.ЗаказДляКорректировки,
	|	ВнутреннийЗаказТовары.ДополнительныеХарактеристикиНоменклатуры";
	
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	РезультатЗапроса =  Запрос.Выполнить();
	Выборка = РезультатЗапроса.Выбрать();
	
	//Результат не может быть пустой. Ранее была проверка на заполнение табличной части. 
	
	Движения.ОстатокПотребностиПоВнутреннимЗаказам.Записывать = Истина;
	
	Пока Выборка.Следующий() Цикл
		
		Движение = Движения.ОстатокПотребностиПоВнутреннимЗаказам.Добавить(); 
		
		Если Выборка.Количество >= 0 Тогда
			
			Движение.ВидДвижения = ВидДвиженияНакопления.Приход;			
			Движение.ВнутреннийЗаказ = Ссылка; 
			Движение.Количество = Выборка.Количество;
			
		Иначе      
			
			Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
			Движение.ВнутреннийЗаказ = Выборка.ЗаказДляКорректировки;
			Движение.Количество = - Выборка.Количество;   
			
		КонецЕсли;
		
		Движение.Период = Дата; 
		Движение.Номенклатура = Выборка.Номенклатура;
		Движение.ДополнительныеХарактеристикиНоменклатуры = Выборка.ДополнительныеХарактеристикиНоменклатуры;
		Движение.ЕдиницаИзмерения = Выборка.ЕдиницаИзмеренияЗаказа;

	КонецЦикла;
	
	Движения.Записать();
	
	ТекстСообщения = "Номенклатура из данного заказа успешно сохранена в список потребности для ОМТС.";		
	ОбщегоНазначения.СообщитьПользователю(ТекстСообщения,,Товары);
	
КонецПроцедуры

#КонецОбласти

