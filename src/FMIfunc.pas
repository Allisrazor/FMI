unit FMIfunc;

interface

uses
Windows, SysUtils;

const
//Задание костант для FMU
  fmiTrue = True;
  fmiFalse = False;

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

  TRecVar = record                            //Тип, в котором описывается переменная типа fmiReal
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
    RealArrayLen : integer;                   //Количество элементов в массиве описаний вещественных переменных
    IntArrayLen : integer;                    //Количество элементов в массиве описаний целых переменных
    BoolArrayLen : integer;                   //Количество элементов в массиве описаний булевских переменных
    StringArrayLen : integer;                 //Количество элементов в массиве описаний строковых переменных
    RealArray : TpRecVar;                     //Указатель на массив переменных типа fmiReal
    IntArray : TpRecVar;                      //Указатель на массив переменных типа fmiInteger
    BoolArray : TpRecVar;                     //Указатель на массив переменных типа fmiBoolean
    StringArray : TpRecVar;                   //Указатель на массив переменных типа fmiString
  end;
  TpXMLInfo = ^TXMLInfo;

  TArrRecVar = array of TpRecVar;             //Тип - динамический массив записей о переменных
  // --- Набор параметров из xml ---

  // --- Набор  параметров модели FMU ---
  TFMU = packed record
    dll_Handle : THandle;                     //Хэндл для .dll модели FMU
    xmlPath : AnsiString;                     //Путь к .xml
    p_xmlPath : pAnsiChar;                    //Указатель на путь к .xml
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

    vr : array of fmiValueReference;          //Указатели всех вещественных параметров модели
    r : array of fmiReal;                     //Массив всех вещественных параметров модели
    nr : size_t;                              //Количество вещественных всех параметров модели

    vb : array of fmiValueReference;          //Указатели всех булевских параметров модели
    b : array of fmiBoolean;                  //Массив всех булевских параметров модели
    nb : size_t;                              //Количество булевских всех параметров модели

    vi : array of fmiValueReference;          //Указатели всех целых параметров модели
    i : array of fmiInteger;                  //Массив всех целых параметров модели
    ni : size_t;                              //Количество целых всех параметров модели

    vs : array of fmiValueReference;          //Указатели всех строковых параметров модели
    s : array of fmiString;                   //Массив всех строковых параметров модели
    ns : size_t;                              //Количество строковых всех параметров модели

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
    XMLInfo : TXMLInfo;                       //Запись основных данных из .xml
    RealArray : TArrRecVar;                   //Массив описаний вещественных чисел
    IntArray : TArrRecVar;                    //Массив описаний целых чисел
    BoolArray : TArrRecVar;                   //Массив описаний булевских чисел
    StringArray : TArrRecVar;                 //Массив описаний строковых чисел
  end;
  // --- Набор  параметров модели FMU ---

  // --- Набор функций FMU ---

  //Стандартные функции в fmiModelFunctions -- нужно посмотреть, какие параметры изменяются (var), а какие нет
  TfmiGetModelTypesPlatform = function() : fmiString; cdecl;

  TfmiGetVersion = function() : fmiString; cdecl;

  //Функции для создания и уничтожения экземпляра модели
  TfmiInstantiateModel = function(instanceName : fmiString;
                                  GUID : fmiString;
                                  functions : fmiCallbackFunctions;
                                  loggingOn: fmiBoolean) : fmiComponent; cdecl;

  TfmiFreeModelInstance = procedure(c : fmiComponent); cdecl;

  TfmiSetDebugLogging = function(c : fmiComponent;
                                 loggingOn: fmiBoolean) : fmiStatus; cdecl;

  //Функции обеспечения независимых переменных и кэширования
  TfmiSetTime = function(c : fmiComponent;
                         time : fmiReal) : fmiStatus; cdecl;

  TfmiSetContinuousStates = function(c : fmiComponent;
                                     х : array of fmiReal;
                                     nx : size_t) : fmiStatus; cdecl;

  TfmiCompletedIntegratorStep = function(c : fmiComponent;
                                         var callEventUpdate : fmiBoolean) : fmiStatus; cdecl;

  TfmiSetReal = function(c : fmiComponent;
                         vr : array of fmiValueReference;
                         //nvr : size_t;
                         value : array of fmiReal) : fmiStatus; cdecl;

  TfmiSetInteger = function(c : fmiComponent;
                            vr : array of fmiValueReference;
                            //nvr : size_t;
                            value : array of fmiInteger) : fmiStatus; cdecl;

  TfmiSetBoolean = function(c : fmiComponent;
                            vr : array of fmiValueReference;
                            //nvr : size_t;
                            value : array of fmiBoolean) : fmiStatus; cdecl;

  TfmiSetString = function(c : fmiComponent;
                           vr : array of fmiValueReference;
                           //nvr : size_t;
                           value : array of fmiString) : fmiStatus; cdecl;

  //Функции, реализующие решение основных уравнений модели

  TfmiInitialize = function(c : fmiComponent;
                            toleranceControlled : fmiBoolean;
                            relativeTolerance : fmiReal;
                            var eventInfo : fmiEventInfo) : fmiStatus; cdecl;

  TfmiGetDerivatives = function(c : fmiComponent;
                                var derivatives : array of fmiReal;
                                var nx : size_t) : fmiStatus; cdecl;

  TfmiGetEventIndicators = function(c : fmiComponent;
                                    var eventIndicators : array of fmiReal;
                                    var ni : size_t) : fmiStatus; cdecl;

  TfmiGetReal = function(c : fmiComponent;
                         vr : array of fmiValueReference;
                         //nvr : size_t;
                         var value : array of fmiReal) : fmiStatus; cdecl;

  TfmiGetInteger = function(c : fmiComponent;
                            vr : array of fmiValueReference;
                            //nvr : size_t;
                            var value : array of fmiInteger) : fmiStatus; cdecl;

  TfmiGetBoolean = function(c : fmiComponent;
                            vr : array of fmiValueReference;
                            //nvr : size_t;
                            var value : array of fmiBoolean) : fmiStatus; cdecl;

  TfmiGetString = function(c : fmiComponent;
                           vr : array of fmiValueReference;
                           //nvr : size_t;
                           var value : array of fmiString) : fmiStatus; cdecl;

  TfmiEventUpdate = function(c : fmiComponent;
                             var intermediateResults : fmiBoolean;
                             var eventInfo : fmiEventInfo) : fmiStatus; cdecl;

  TfmiGetContinuousStates = function(c : fmiComponent;
                                     var states : array of fmiReal;
                                     var nx : size_t) : fmiStatus; cdecl;

  TfmiGetNominalContinuousStates = function(c : fmiComponent;
                                            var x_nominal : array of fmiReal;
                                            var nx : size_t) : fmiStatus; cdecl;

  TfmiGetStateValueReferences = function(c : fmiComponent;
                                         var vrx : array of fmiValueReference;
                                         var nx : size_t) : fmiStatus; cdecl;

  TfmiTerminate = function(c : fmiComponent) : fmiStatus; cdecl;

  //Тип - функции FMU (для экспорта из .dll)
  TFMUfunc = record
    fmu_name : string;
    fmiGetModelTypesPlatform : TfmiGetModelTypesPlatform;
    fmiGetVersion : TfmiGetVersion;
    fmiInstantiateModel : TfmiInstantiateModel;
    fmiFreeModelInstance : TfmiFreeModelInstance;
    fmiSetDebugLogging : TfmiSetDebugLogging;
    fmiSetTime : TfmiSetTime;
    fmiSetContinuousStates : TfmiSetContinuousStates;
    fmiCompletedIntegratorStep : TfmiCompletedIntegratorStep;
    fmiSetReal : TfmiSetReal;
    fmiSetInteger : TfmiSetInteger;
    fmiSetBoolean : TfmiSetBoolean;
    fmiSetString : TfmiSetString;
    fmiInitialize : TfmiInitialize;
    fmiGetDerivatives : TfmiGetDerivatives;
    fmiGetEventIndicators : TfmiGetEventIndicators;
    fmiGetReal : TfmiGetReal;
    fmiGetInteger : TfmiGetInteger;
    fmiGetBoolean : TfmiGetBoolean;
    fmiGetString : TfmiGetString;
    fmiEventUpdate : TfmiEventUpdate;
    fmiGetContinuousStates : TfmiGetContinuousStates;
    fmiGetNominalContinuousStates : TfmiGetNominalContinuousStates;
    fmiGetStateValueReferences : TfmiGetStateValueReferences;
    fmiTerminate : TfmiTerminate;
  end;//end record
  // --- Набор функций FMU ---


//Объявление функций callback в первом приближении (???в дальнейшем можно заменить)
procedure CallbackLogger(c : fmiComponent;
                         instanceName : fmiString;
                         status : fmiStatus;
                         category : fmiString;
                         Logmessage : fmiString); cdecl;

function Fcalloc(nobj : size_t; size : size_t) : pointer; cdecl;

procedure freeM(obj : pointer); cdecl;

//Объявление Функции перевода статуса типа fmiStatus в строку
function fmiStatusToString (Status : fmiStatus) : fmiString; cdecl;

//Объявление функции получения значений для заданных выходов
Function GetOutputValue(FMU : TFMU;
                        FMUfunc : TFMUfunc;
                        OutputName : string;
                        var value : double) : fmiStatus;

//Объяление функции установки значений для входов
Function SetInputValue(var FMU : TFMU;
                       FMUfunc : TFMUfunc;
                       value : array of double) : fmiStatus;

implementation

//Описание функций callback в первом приближении (в дальнейшем можно заменить)
procedure CallbackLogger      (c : fmiComponent;
                               instanceName : fmiString;
                               status : fmiStatus;
                               category : fmiString;
                               Logmessage : fmiString);  cdecl; //изменено с message
  begin
    Logmessage := Logmessage;   //??? Что-то нужно придумать с логгером
  end;


var DummyData: array[0..512] of byte;

function Fcalloc (nobj : size_t; size : size_t) : pointer; cdecl;
begin
    Result:=nil;
    if (nobj * size) > 0 then begin
      GetMem(Result, nobj * size);
      FillChar(Result^, nobj * size, byte(0));
    end
    else
      Result := @DummyData;
end;

procedure freeM (obj : pointer); cdecl;   //??? Она не работает, если в качестве параметра используется один и тот же указатель во второй раз
begin
    if (not (obj = nil)) and (obj <> @DummyData) then
    begin
      FreeMem(obj);
    end;
end;

//Описание Функции перевода статуса типа fmiStatus в строку
function fmiStatusToString (Status : fmiStatus) : fmiString; cdecl;
  begin
    case status of
      fmiOk: Result := 'Ok';
      fmiWarning: Result := 'Warning';
      fmiDiscard: Result := 'Discard';
      fmiError: Result := 'Error';
      fmiFatal: Result := 'Fatal';
    end;
  end;

//Описание функции получения значений для заданных выходов
Function GetOutputValue(FMU : TFMU;
                        FMUfunc : TFMUfunc;
                        OutputName : string;
                        var value : double) : fmiStatus;
Type
TValueFlag = (real, int, bool, none);
var
vr : array of fmiValueReference;
RealVal : array of fmiReal;
IntVal : array of fmiInteger;
BoolVal : array of fmiBoolean;
Eqv : boolean;
i : integer;
status : fmiStatus;
VF : TValueFlag;
  begin
    Eqv := false;
    VF := none;

    while not Eqv do
    begin
      For i := 0 to (FMU.XMLInfo.RealArrayLen -1) do
      begin
        if FMU.RealArray[i]^.name = OutputName then
        begin
          Eqv := true;
          VF := real;
          SetLength(vr,1);
          vr[0] := i;
          break;
        end;
      end;

      For i := 0 to (FMU.XMLInfo.IntArrayLen -1) do
      begin
        if FMU.IntArray[i]^.name = OutputName then
        begin
          Eqv := true;
          VF := int;
          SetLength(vr,1);
          vr[0] := i;
          break;
        end;
      end;

      For i := 0 to (FMU.XMLInfo.BoolArrayLen -1) do
      begin
        if FMU.BoolArray[i]^.name = OutputName then
        begin
          Eqv := true;
          VF := bool;
          SetLength(vr,1);
          vr[0] := i;
          break;
        end;
      end;

      if (not Eqv) then
      begin
        Result := fmiWarning;  //если выход из функции -  это предупреждение, то все нормально, просто ошибка в вводе имени выхода
        exit;
      end;
    end; //while

    case VF of
      real: begin
        SetLength(RealVal, 2);
        SetLength(vr, (length(vr) + 1));
        Status := FMUfunc.fmiGetReal(FMU.model_instance, vr, RealVal);
        if (Status <> fmiOk) then
        begin
          Result := fmiError;  //если выход из функции -  это ошибка, то проблема с импортом из ModelInstance
          exit;
        end;
        value := RealVal[0];
      end; //real
      int: begin
        SetLength(IntVal, 2);
        SetLength(vr, (length(vr) + 1));
        Status := FMUfunc.fmiGetInteger(FMU.model_instance, vr, IntVal);
        if (Status <> fmiOk) then
        begin
          Result := fmiError;  //если выход из функции -  это ошибка, то проблема с импортом из ModelInstance
          exit;
        end;
        value := IntVal[0];
      end; //int
      bool: begin
        SetLength(BoolVal, 2);
        SetLength(vr, (length(vr) + 1));
        Status := FMUfunc.fmiGetBoolean(FMU.model_instance, vr, BoolVal);
        if (Status <> fmiOk) then
        begin
          Result := fmiError;  //если выход из функции -  это ошибка, то проблема с импортом из ModelInstance
          exit;
        end;
        if BoolVal[0] then value := 1
        else value := 0;
      end; //bool
    end; //case

    Result := fmiOk;

  end;//GetOutputValue

//Описание функции установки значений для входов
Function SetInputValue(var FMU : TFMU;
                       FMUfunc : TFMUfunc;
                       value : array of double) : fmiStatus;
var
RealVR : array of fmiValueReference;
IntVR : array of fmiValueReference;
BoolVR : array of fmiValueReference;
RealVal : array of fmiReal;
IntVal : array of fmiInteger;
BoolVal : array of fmiBoolean;
i, j : integer;
status : fmiStatus;
  begin
  j := 0;
  if (FMU.InputCount > 0) then
  begin
    For i := 0 to (FMU.XMLInfo.RealArrayLen -1) do
    begin
      if FMU.RealArray[i]^.InputFlag = Input then
      begin
        SetLength(RealVal, 2);
        SetLength(RealVR, 2);
        RealVal[0] := Value[j];
        Status := FMUfunc.fmiSetReal(FMU.model_instance, RealVR, RealVal);
        if (Status <> fmiOk) then
        begin
          Result := fmiError;  //если выход из функции -  это ошибка, то проблема с импортом из ModelInstance
          exit;
        end;
        inc(j);
      end;
    end; //for

    For i := 0 to (FMU.XMLInfo.IntArrayLen -1) do
    begin
      if FMU.IntArray[i]^.InputFlag = Input then
      begin
        SetLength(IntVal, 2);
        SetLength(IntVR, 2);
        IntVal[0] := round(Value[j]);
        Status := FMUfunc.fmiSetInteger(FMU.model_instance, IntVR, IntVal);
        if (Status <> fmiOk) then
        begin
          Result := fmiError;  //если выход из функции -  это ошибка, то проблема с импортом из ModelInstance
          exit;
        end;
        inc(j);
      end;
    end; //for

    For i := 0 to (FMU.XMLInfo.BoolArrayLen -1) do
    begin
      if FMU.BoolArray[i]^.InputFlag = Input then
      begin
        SetLength(BoolVal, 2);
        SetLength(BoolVR, 2);
        if (Value[j] >= 0.6) then BoolVal[0] := True
        else BoolVal[0] := false;
        Status := FMUfunc.fmiSetBoolean(FMU.model_instance, BoolVR, BoolVal);
        if (Status <> fmiOk) then
        begin
          Result := fmiError;  //если выход из функции -  это ошибка, то проблема с импортом из ModelInstance
          exit;
        end;
        inc(j);
      end;
    end;
  end; //If

    Result := fmiOk;

  end;//SetInputValue


initialization
 FillChar(DummyData,SizeOf(DummyData),byte(0));
end.
