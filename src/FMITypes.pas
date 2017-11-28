unit FMITypes;

interface

uses Windows;

type
  //Стандартные типы данных в fmiModelTypes
  fmiComponent = pointer;
  fmiValueReference = Cardinal;
  fmiReal = Double;
  fmiInteger = Integer;
  fmiBoolean = Boolean;
  fmiString = pAnsiChar;
  fmiPBoolean = ^fmiBoolean; //указатель на fmiBoolean
  size_t = Cardinal;         //Стандартный тип из c++

  //Стандартные типы данных в fmiModelFunctions
  fmiStatus = (fmiOk, fmiWarning, fmiDiscard, fmiError, fmiFatal);
  fmiCallbackLogger = procedure (c : fmiComponent;
                                 instanceName : fmiString;
                                 status : fmiStatus;
                                 category : fmiString;
                                 Logmessage : fmiString);  cdecl; //изменено с message

  fmiCallbackAllocateMemory = function (nobj : size_t; size : size_t) : pointer; cdecl;

  fmiCallbackFreeMemory = procedure (obj : pointer); cdecl;

  fmiCallbackFunctions = record
    logger : fmiCallbackLogger;
    allocateMemory : fmiCallbackAllocateMemory;
    freeMemory : fmiCallbackFreeMemory;
  end;

  fmiEventInfo = record
    iterationConverged : fmiBoolean;
    stateValueReferencesChanged : fmiBoolean;
    stateValuesChanged : fmiBoolean;
    terminateSimulation : fmiBoolean;
    upcomingTimeEvent : fmiBoolean;
    nextEventTime : fmiReal;
  end;

  // --- Набор параметров из xml ---
  TInputFlag = (Input, Output, None);         //Флаг, который показывает является ли переменная входом/выходом или нет
  TVarTypeFlag = (Real, Int, Bool, Str);      //Флаг, который показывает тип переменной

  TRecVar = record                            //Тип, в котором описывается переменная типа fmiReal
    VarType : TVarTypeFlag;
    ValueRef : fmiValueReference;
    IsParameter : boolean;
    Name : pAnsiChar;
    InputFlag : TInputFlag;
  end;
  TpRecVar = ^TRecVar;

  TXMLInfo = record                           //Основной тип, который содержит данные из .xml
    ModelIdentifier : pAnsiChar;              //Идентификатор модели
    GUID : pAnsiChar;                         //GUID модели
    NumberOfStates : fmiInteger;              //Количество переменных состояния
    NumberOfEventIndicators : fmiInteger;     //Количество индикаторов события
    VarArrayLen : integer;                    //Количество элементов в массиве описаний переменных
    VarArray : TpRecVar;                      //Указатель на массив переменных
  end;
  TpXMLInfo = ^TXMLInfo;

  TArrRecVar = array of TpRecVar;             //Тип - динамический массив записей о переменных
  // --- Набор параметров из xml ---

  // --- Набор  параметров модели FMU ---
  TFMU = packed record
    dll_Handle : THandle;                     //Хэндл для .dll модели FMU
    IsStarted : boolean;                      //Флаг, показывающий запущена модель на расчет или нет
    CallbackFunctions : fmiCallbackFunctions; //Создание переменной CallbackFunctions
    model_instance : fmiComponent;            //Указатель на образец модели
    loggingOn : fmiBoolean;                   //fmiTrue, если необходимо ведения log
    fmuFlag : fmiStatus;                      //Флаг, возвращаемый функциями FMI
    InputCount : integer;                     //Количество входов
    OutputCount : integer;                    //Количество выходов

    nx : size_t;                              //Количество переменных состояний (в т. ч. для вычисления производных) - из .xml
    x : array of fmiReal;                     //Массив переменных состояния модели
    der_x : array of fmiReal;                 //Массив производных модели
    nz : size_t;                              //Количество индикаторов события - из .xml
    z : array of fmiReal;                     //Массив текущих индикаторов события
    pre_z : array of fmiReal;                 //Массив предыдущих индикаторов события

    Tstart : fmiReal;                         //Начальное время интегрирования - из .xml, если там есть
    Tend : fmiReal;                           //Конечное время интегрирования - из .xml, если там есть
    toleranceControlled : fmiBoolean;         //True, если нужно контролировать шаг интегрирования
    inst_name : AnsiString;                   //Имя модели - из .xml
    GUID : AnsiString;                        //Идентификационный номер - из .xml
    p_inst_name : pAnsiChar;                  //Указатель на имя модели
    p_GUID : pAnsiChar;                       //Указатель на идентификационный номер
    eventInfo : fmiEventInfo;                 //Запись значения текущего события
    TimeEvent : fmiBoolean;
    StepEvent : fmiBoolean;
    StateEvent : fmiBoolean;
    xmlPath : AnsiString;                     //Путь к .xml
    p_xmlPath : pAnsiChar;                    //Указатель на путь к .xml
    XMLInfo : TXMLInfo;                       //Запись основных данных из .xml
    VarArray : TArrRecVar;                    //Массив описаний переменных
  end;
  // --- Набор  параметров модели FMU ---

implementation

end.
