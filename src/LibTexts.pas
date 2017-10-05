unit LibTexts;

interface

const

{$IFNDEF ENG}
  //Ошибки
  txt_FMUBlock_InputCount_err = 'FMI. Неверно задано количество входов. Необходимое количество входов для модели: ';
  txt_FMUBlock_OutputCount_err = 'FMI. Неверно задано количество выходов. Требуемое количество: ';
  txt_FMUBlock_Archive_err = 'FMI. Укажите <имя файла>.fmu';
  txt_FMUBlock_Instantiate_err = 'FMI. Ошибка создания образца модели';
  txt_FMUBlock_Init_err = 'FMI. Ошибка инициализации';
  txt_FMUBlock_Set_Time_err = 'FMI. Ошибка установки времени в модели';
  txt_FMUBlock_Run_err = 'FMI. Ошбика на шаге интегрирования в модели';

  //Рабочие
  txt_FMUBlock_Init = 'FMI. Проверка заданных параметров на этапе инициализации';
  txt_FMUBlock_Instantiate_good = 'FMI. Создан образец модели';
  txt_FMUBlock_Init_good = 'FMI. Модель инициализирована';
  txt_FMUBlock_State_init_good = 'FMI. Получены начальные значения модели';
  txt_FMUBlock_Der_Init_good = 'FMI. Получены начальные производные модели';
  txt_FMUBlock_Terminate_Simulation = 'FMI. Симуляция остановлена';
  txt_FMUBlock_Free_Model = 'FMI. Память модели освобождена';

{$ELSE}
  //Ошибки
  txt_FMUBlock_InputCount_err = 'FMI. Invalid input count. Required input count: ';
  txt_FMUBlock_OutputCount_err = 'FMI. Invalid output count. Required count: ';
  txt_FMUBlock_Archive_err = 'FMI. Select <filename>.fmu';
  txt_FMUBlock_Instantiate_err = 'FMI. Instantiate error';
  txt_FMUBlock_Init_err = 'FMI. Initialization error';
  txt_FMUBlock_Set_Time_err = 'FMI. Setting time error';
  txt_FMUBlock_Run_err = 'FMI. Integration step error';

  //Рабочие
  txt_FMUBlock_Init = 'FMI. Checking the specified parameters during the initialization phase';
  txt_FMUBlock_Instantiate_good = 'FMI. Unit instantiated';
  txt_FMUBlock_Init_good = 'FMI. Model initializated';
  txt_FMUBlock_State_init_good = 'FMI. Start states initialized';
  txt_FMUBlock_Der_Init_good = 'FMI. Start derivatives initialized';
  txt_FMUBlock_Terminate_Simulation = 'FMI. Simulation stoped';
  txt_FMUBlock_Free_Model = 'FMI. Model instance is now free';
{$ENDIF}

implementation

end.
