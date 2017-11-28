
 //**************************************************************************//
 // Данный исходный код является составной частью системы МВТУ-4             //
 // Программист:        Тимофеев К.А.                                        //
 //**************************************************************************//


unit Blocks;

 //***************************************************************************//
 //               Блоки для импорта данных по интерфейсу FMI               //
 //***************************************************************************//

interface

uses Windows, Classes, MBTYArrays, DataTypes, SysUtils, RunObjts, SyncObjs, IntArrays,
Math, LibTexts, FMIfunc, sevenzip, parserXML;

type

{*******************************************************************************
                              Класс блок
*******************************************************************************}
  TFMUBlock = class(TRunObject)
  public
    constructor    Create(Owner: TObject); override;
    destructor     Destroy; override;
    function       InfoFunc(Action: Integer):NativeInt; override;
    function       RunFunc(var at,h : RealType; Action:Integer):NativeInt; override;
    function       GetParamID(const ParamName:string; var DataType:TDataType; var IsConst: boolean):NativeInt; override;
    function       GetOutParamID(const ParamName:string;var DataType:TDataType;var IsConst: boolean):NativeInt;override;
    function       ReadParam(ID: NativeInt;ParamType:TDataType;DestData: Pointer;DestDataType: TDataType;MoveData:TMoveProc):boolean;override;
  private
    // --- Задаваемые свойства блока ---
    FMUAdress: string;
    InputCount: Integer;
    OutputCount: Integer;
    PropName1: string;
    PropName2: string;
    PropName3: string;
    PropName4: string;
    PropName5: string;
    // --- Параметры блока ---

    // --- Переменная для FMU ---
    FMU : TFMU;

    // --- Переменная для функций ---
    FMUfunc : TFMUfunc;

    // --- Внутренние свойства блока ---
    function Init: int8;
    function Start: int8;
    function Run(var at,h : RealType): int8;
    function Stop: int8;

  end;

implementation

{Класс блок}


{ public }
constructor TFMUBlock.Create;
begin
  inherited;
end;

destructor TFMUBlock.Destroy;
begin
  inherited;
end;

function TFMUBlock.InfoFunc(Action: Integer):NativeInt;
var
i : integer;
begin
  Result:=0;
  case Action of
    i_GetInit: Result := r_Success;
    //i_GetPropErr: Result := Init;
    i_GetCount: begin
      for i := 0 to (FMU.InputCount - 1) do 
      begin
        cU[i] := 1;
      end;
      for i := 0 to (FMU.OutputCount - 1) do 
      begin
        cY[i] := 1;
      end;
    end;
  else
    Result := inherited InfoFunc(Action);
  end
end; //InfoFunc

function TFMUBlock.RunFunc;
begin
  Result:=0;
  case Action of
    f_InitObjects: try
                     Result := Init;
                   except
                     Result := r_Fail;
                   end;
    f_Stop:        try
                     Result := Stop;
                   except
                     Result := r_Fail;
                   end;
    f_InitState,
    f_GoodStep:    try
                     Result := Run(at,h);
                   except
                     Result := r_Fail;
                   end;
  end
end; //RunFunc

function TFMUBlock.GetParamID;
begin
  Result:=inherited GetParamId(ParamName,DataType,IsConst);
  if Result = -1 then begin
    if StrEqu(ParamName,'FMUAdress') then begin
      Result := NativeInt(@FMUAdress);
      DataType := dtFileName;
      Exit;
    end;
    if StrEqu(ParamName,'InputCount') then begin
      Result := NativeInt(@InputCount);
      DataType := dtInteger;
      Exit;
    end;
    if StrEqu(ParamName,'OutputCount') then begin
      Result := NativeInt(@OutputCount);
      DataType := dtInteger;
      Exit;
    end;
    if StrEqu(ParamName,'PropName1') then begin
      Result := NativeInt(@PropName1);
      DataType := dtString;
      Exit;
    end;
    if StrEqu(ParamName,'PropName2') then begin
      Result := NativeInt(@PropName2);
      DataType := dtString;
      Exit;
    end;
    if StrEqu(ParamName,'PropName3') then begin
      Result := NativeInt(@PropName3);
      DataType := dtString;
      Exit;
    end;
    if StrEqu(ParamName,'PropName4') then begin
      Result := NativeInt(@PropName4);
      DataType := dtString;
      Exit;
    end;
    if StrEqu(ParamName,'PropName5') then begin
      Result := NativeInt(@PropName5);
      DataType := dtString;
      Exit;
    end;
  end;
end; //GetParamID

function TFMUBlock.GetOutParamID(const ParamName:string; var DataType:TDataType; var IsConst: boolean):NativeInt;
begin
  Result:=inherited GetOutParamID(ParamName, DataType, IsConst);
end;  //GetOutParamID

function TFMUBlock.ReadParam(ID: NativeInt; ParamType:TDataType; DestData:Pointer; DestDataType:TDataType; MoveData:TMoveProc):boolean;
begin
  Result:=inherited ReadParam(ID,ParamType,DestData,DestDataType,MoveData);
end;  //ReadParam

{ private }
function TFMUBlock.Init: int8;
var
ArchNameBuffer, ArchExtBuffer : string;
i : integer;
p : TpRecVar;
FileExistBool1, FileExistBool2 : boolean;
begin
  Result := r_Success;
  FMU.InputCount := 0;   //Инициализация количества входов
  FMU.OutputCount := 0;   //Инициализация количества выходов

  // Распаковывает файлы
  if length (FMUAdress)>4 then
  begin
    ArchExtBuffer := ExtractFileExt(FMUAdress);
    //??? уберем с помощью .xml
    ArchNameBuffer := ExtractFileName(FMUAdress);
    setlength(ArchNameBuffer, (length(ArchNameBuffer)-4));
    //??? уберем с помощью .xml
  end;

  FileExistBool1 := FileExists(GetCurrentDir + '\' + ArchNameBuffer + '\' + ArchNameBuffer + '.dll');
  FileExistBool2 := FileExists(GetCurrentDir + '\' + ArchNameBuffer + '\binaries\win32\' + ArchNameBuffer + '.dll');

  if not (FileExistBool1 or FileExistBool2) then
  begin
    if (ArchExtBuffer = '.fmu') and FileExists(FMUAdress) then
    begin
      with CreateInArchive(CLSID_CFormatZip) do
      begin
        OpenFile(FMUAdress);
        ExtractTo(GetCurrentDir + '\' + ArchNameBuffer);
        Close;
      end;
    end else
    begin
      ErrorEvent(txt_FMUBlock_Archive_err, msError, VisualObject);
      Result := r_Fail;
      Exit;
    end;
  end;

  FMU.xmlPath := (GetCurrentDir + '\' + ArchNameBuffer + '\modelDescription.xml');
  FMU.p_xmlPath := pansichar(FMU.xmlPath);
  XMLParse(@FMU.XMLInfo, FMU.p_xmlPath);

  //Запись данных о вещественных переменных
  SetLength(FMU.RealArray, FMU.XMLInfo.RealArrayLen);
  p := FMU.XMLInfo.RealArray;
  for I := 0 to FMU.XMLInfo.RealArrayLen -1 do
    begin
      FMU.RealArray[i] := p;
      if (FMU.RealArray[i]^.InputFlag = input) then inc(FMU.InputCount);
      if (StrPas(FMU.RealArray[i]^.Name) = PropName1) then inc(FMU.OutputCount);
      if (StrPas(FMU.RealArray[i]^.Name) = PropName2) then inc(FMU.OutputCount);
      if (StrPas(FMU.RealArray[i]^.Name) = PropName3) then inc(FMU.OutputCount);
      if (StrPas(FMU.RealArray[i]^.Name) = PropName4) then inc(FMU.OutputCount);
      if (StrPas(FMU.RealArray[i]^.Name) = PropName5) then inc(FMU.OutputCount);
      inc(p);
    end;

  //Запись данных о целых переменных
  SetLength(FMU.IntArray, FMU.XMLInfo.IntArrayLen);
  p := FMU.XMLInfo.IntArray;
  for I := 0 to FMU.XMLInfo.IntArrayLen -1 do
    begin
      FMU.IntArray[i] := p;
      if (FMU.IntArray[i]^.InputFlag = input) then inc(FMU.InputCount);
      if (StrPas(FMU.IntArray[i]^.Name) = PropName1) then inc(FMU.OutputCount);
      if (StrPas(FMU.IntArray[i]^.Name) = PropName2) then inc(FMU.OutputCount);
      if (StrPas(FMU.IntArray[i]^.Name) = PropName3) then inc(FMU.OutputCount);
      if (StrPas(FMU.IntArray[i]^.Name) = PropName4) then inc(FMU.OutputCount);
      if (StrPas(FMU.IntArray[i]^.Name) = PropName5) then inc(FMU.OutputCount);
      inc(p);
    end;

  //Запись данных о булевских переменных
  SetLength(FMU.BoolArray, FMU.XMLInfo.BoolArrayLen);
  p := FMU.XMLInfo.BoolArray;
  for I := 0 to FMU.XMLInfo.BoolArrayLen -1 do
    begin
      FMU.BoolArray[i] := p;
      if (FMU.BoolArray[i]^.InputFlag = input) then inc(FMU.InputCount);
      if (StrPas(FMU.BoolArray[i]^.Name) = PropName1) then inc(FMU.OutputCount);
      if (StrPas(FMU.BoolArray[i]^.Name) = PropName2) then inc(FMU.OutputCount);
      if (StrPas(FMU.BoolArray[i]^.Name) = PropName3) then inc(FMU.OutputCount);
      if (StrPas(FMU.BoolArray[i]^.Name) = PropName4) then inc(FMU.OutputCount);
      if (StrPas(FMU.BoolArray[i]^.Name) = PropName5) then inc(FMU.OutputCount);
      inc(p);
    end;

  //Запись данных о строковых переменных
  SetLength(FMU.StringArray, FMU.XMLInfo.StringArrayLen);
  p := FMU.XMLInfo.StringArray;
  for I := 0 to FMU.XMLInfo.StringArrayLen -1 do
    begin
      FMU.StringArray[i] := p;
      inc(p);
    end;

  //Проверка соответствия количества входов
  if not (FMU.InputCount = InputCount) then
  begin
    ErrorEvent((txt_FMUBlock_InputCount_err + IntToStr(FMU.InputCount)),
      msError, VisualObject);
    Result := r_Fail;
    Exit;
  end;

  //Проверка соответствия количества выходов
  if not (FMU.OutputCount = OutputCount) then
  begin
    ErrorEvent((txt_FMUBlock_OutputCount_err + ' Необходимо ' + IntToStr(FMU.OutputCount) + ' выходов, или верно указать имена переменных в Имя переменной выхода №'),
      msError, VisualObject);
    Result := r_Fail;
    Exit;
  end;
  
  //Инициализация параметров FMU
  FMU.loggingOn := fmiTrue;                      //fmiTrue, если необходимо ведения log
  FMU.nx := FMU.XMLInfo.NumberOfStates;          //Количество переменных состояний (для вычисления производных) - из .xml
  FMU.nz := FMU.XMLInfo.NumberOfEventIndicators; //Количество индикаторов события - из .xml
  FMU.Tstart := 0;                               //??? Начальное время интегрирования - из .xml, если там есть
  FMU.Tend := 7;                                 //??? Конечное время интегрирования - из .xml, если там есть
  FMU.toleranceControlled := fmiFalse;
  FMU.p_inst_name := FMU.XMLInfo.ModelIdentifier;
  FMU.p_GUID := FMU.XMLInfo.GUID;
  Setlength(FMU.x,FMU.nx);
  Setlength(FMU.der_x,FMU.nx);
  Setlength(FMU.z,FMU.nz);
  Setlength(FMU.pre_z,FMU.nz);
  for i := 0 to (FMU.nz - 1) do FMU.z[i] := 0;

  //Созздание массива всех параметров модели
  FMU.nr := 6;
  SetLength(FMU.vr,(FMU.nr+1));
  for i := 0 to FMU.nr - 1 do FMU.vr[i] := i;


  //Присвоение Callback функциям значений из Delphi
  FMU.CallbackFunctions.logger := CallbackLogger;
  FMU.CallbackFunctions.allocateMemory := Fcalloc;
  FMU.CallbackFunctions.freeMemory := freeM;

  //Инициализация функций FMU
  FMUfunc.fmu_name := ArchNameBuffer;  //??? Из .xml файла
  if FileExists(GetCurrentDir + '\' + ArchNameBuffer + '\' + ArchNameBuffer + '.dll') then
  begin
    FMU.dll_Handle := Loadlibrary(pchar(GetCurrentDir + '\' + FMUfunc.fmu_name + '\' + FMUfunc.fmu_name + '.dll'));
  end else
  begin
    FMU.dll_Handle := Loadlibrary(pchar(GetCurrentDir + '\' + FMUfunc.fmu_name + '\binaries\win32\' + FMUfunc.fmu_name + '.dll'));
  end;
  if (FMU.dll_Handle >= 32) then
  begin
    @FMUfunc.fmiGetModelTypesPlatform :=      GetProcAddress(FMU.dll_Handle,pchar(FMUfunc.fmu_name+'_fmiGetModelTypesPlatform'));
    @FMUfunc.fmiGetVersion :=                 GetProcAddress(FMU.dll_Handle,pchar(FMUfunc.fmu_name+'_fmiGetVersion'));
    @FMUfunc.fmiInstantiateModel :=           GetProcAddress(FMU.dll_Handle,pchar(FMUfunc.fmu_name+'_fmiInstantiateModel'));
    @FMUfunc.fmiFreeModelInstance :=          GetProcAddress(FMU.dll_Handle,pchar(FMUfunc.fmu_name+'_fmiFreeModelInstance'));
    @FMUfunc.fmiSetDebugLogging :=            GetProcAddress(FMU.dll_Handle,pchar(FMUfunc.fmu_name+'_fmiSetDebugLogging'));
    @FMUfunc.fmiSetTime :=                    GetProcAddress(FMU.dll_Handle,pchar(FMUfunc.fmu_name+'_fmiSetTime'));
    @FMUfunc.fmiSetContinuousStates :=        GetProcAddress(FMU.dll_Handle,pchar(FMUfunc.fmu_name+'_fmiSetContinuousStates'));
    @FMUfunc.fmiCompletedIntegratorStep :=    GetProcAddress(FMU.dll_Handle,pchar(FMUfunc.fmu_name+'_fmiCompletedIntegratorStep'));
    @FMUfunc.fmiSetReal :=                    GetProcAddress(FMU.dll_Handle,pchar(FMUfunc.fmu_name+'_fmiSetReal'));
    @FMUfunc.fmiSetInteger :=                 GetProcAddress(FMU.dll_Handle,pchar(FMUfunc.fmu_name+'_fmiSetInteger'));
    @FMUfunc.fmiSetBoolean :=                 GetProcAddress(FMU.dll_Handle,pchar(FMUfunc.fmu_name+'_fmiSetBoolean'));
    @FMUfunc.fmiSetString :=                  GetProcAddress(FMU.dll_Handle,pchar(FMUfunc.fmu_name+'_fmiSetString'));
    @FMUfunc.fmiInitialize :=                 GetProcAddress(FMU.dll_Handle,pchar(FMUfunc.fmu_name+'_fmiInitialize'));
    @FMUfunc.fmiGetDerivatives :=             GetProcAddress(FMU.dll_Handle,pchar(FMUfunc.fmu_name+'_fmiGetDerivatives'));
    @FMUfunc.fmiGetEventIndicators :=         GetProcAddress(FMU.dll_Handle,pchar(FMUfunc.fmu_name+'_fmiGetEventIndicators'));
    @FMUfunc.fmiGetReal :=                    GetProcAddress(FMU.dll_Handle,pchar(FMUfunc.fmu_name+'_fmiGetReal'));
    @FMUfunc.fmiGetInteger :=                 GetProcAddress(FMU.dll_Handle,pchar(FMUfunc.fmu_name+'_fmiGetInteger'));
    @FMUfunc.fmiGetBoolean :=                 GetProcAddress(FMU.dll_Handle,pchar(FMUfunc.fmu_name+'_fmiGetBoolean'));
    @FMUfunc.fmiGetString :=                  GetProcAddress(FMU.dll_Handle,pchar(FMUfunc.fmu_name+'_fmiGetString'));
    @FMUfunc.fmiEventUpdate :=                GetProcAddress(FMU.dll_Handle,pchar(FMUfunc.fmu_name+'_fmiEventUpdate'));
    @FMUfunc.fmiGetContinuousStates :=        GetProcAddress(FMU.dll_Handle,pchar(FMUfunc.fmu_name+'_fmiGetContinuousStates'));
    @FMUfunc.fmiGetNominalContinuousStates := GetProcAddress(FMU.dll_Handle,pchar(FMUfunc.fmu_name+'_fmiGetNominalContinuousStates'));
    @FMUfunc.fmiGetStateValueReferences :=    GetProcAddress(FMU.dll_Handle,pchar(FMUfunc.fmu_name+'_fmiGetStateValueReferences'));
    @FMUfunc.fmiTerminate :=                  GetProcAddress(FMU.dll_Handle,pchar(FMUfunc.fmu_name+'_fmiTerminate'));
  end; //end if
  
  //Создание образца модели в памяти
  FMU.model_instance := FMUfunc.fmiInstantiateModel(FMU.p_inst_name, FMU.p_GUID, FMU.CallbackFunctions, FMU.loggingOn);
  if (FMU.model_instance = Nil) then
  begin
    ErrorEvent(txt_FMUBlock_Instantiate_err, msError, VisualObject);
    Result := r_Fail;
    Exit;
  end else
  begin
    ErrorEvent(txt_FMUBlock_Instantiate_good, msInfo, VisualObject);
  end;

  //Установка начального времени интегрирования
  FMU.fmuFlag := FMUfunc.fmiSetTime(FMU.model_instance, FMU.Tstart);
  if (FMU.fmuFlag <> fmiOk) then
  begin
    ErrorEvent(txt_FMUBlock_Init_err, msError, VisualObject);
    Result := r_Fail;
    Exit;
  end;

  //Инициализация модели
  FMU.fmuFlag := FMUfunc.fmiInitialize(FMU.model_instance, FMU.toleranceControlled, 0.0,
  FMU.eventInfo);
  if (FMU.fmuFlag <> fmiOk) then
  begin
    ErrorEvent(txt_FMUBlock_Init_err, msError, VisualObject);
    Result := r_Fail;
    Exit;
  end else
  begin
    ErrorEvent(txt_FMUBlock_Init_good, msInfo, VisualObject);
  end;

  //Установка начальных значений переменных модели после инициализации
  Setlength(FMU.x,(FMU.nx+1));
  FMU.fmuFlag := FMUfunc.fmiGetContinuousStates(FMU.model_instance, FMU.x, FMU.nx);
  if (FMU.fmuFlag <> fmiOk) then
  begin
    ErrorEvent(txt_FMUBlock_Init_err, msError, VisualObject);
    Result := r_Fail;
    Exit;
  end else
  begin
    Setlength(FMU.x,FMU.nx);
    ErrorEvent(txt_FMUBlock_State_init_good, msInfo, VisualObject);
  end;

  //Установка начальных значений производных переменных модели после инициализации
  Setlength(FMU.der_x,(FMU.nx+1));
  FMU.fmuFlag := FMUfunc.fmiGetDerivatives(FMU.model_instance, FMU.der_x, FMU.nx);
  if (FMU.fmuFlag <> fmiOk) then
  begin
    ErrorEvent(txt_FMUBlock_Init_err, msError, VisualObject);
    Result := r_Fail;
    Exit;
  end else
  begin
    Setlength(FMU.der_x,FMU.nx);
    ErrorEvent(txt_FMUBlock_Der_Init_good, msInfo, VisualObject);
  end;

  //Установка начальных значений индикаторов события модели после инициализации
  if (FMU.nz > 0) then
  begin
    Setlength(FMU.z,(FMU.nz+1));
    FMU.fmuFlag := FMUfunc.fmiGetEventIndicators (FMU.model_instance, FMU.z, FMU.nz);
    if (FMU.fmuFlag <> fmiOk) then
    begin
      ErrorEvent(txt_FMUBlock_Init_err, msError, VisualObject);
      Result := r_Fail;
      Exit;
    end;
  end;

end;  //Init

function TFMUBlock.Start: int8;
begin
  ErrorEvent(txt_FMUBlock_Init, msInfo, VisualObject);
  Result := r_Success;
end;  //Start

function TFMUBlock.Run (var at,h : RealType) : int8;
var
  InputValue : array of fmiReal;
  OutputValue : fmiReal;
  i, j : Integer;
begin

  //Задание значений входов
  SetLength(InputValue,FMU.InputCount);
  for i := 0 to (FMU.InputCount - 1) do InputValue[i] := U[i].Arr^[0];
  SetInputValue(FMU, FMUfunc, InputValue);

  //Установка текущего времени интегрирования
  FMU.fmuFlag := FMUfunc.fmiSetTime(FMU.model_instance, at);
  if (FMU.fmuFlag <> fmiOk) then
  begin
    ErrorEvent(txt_FMUBlock_Set_Time_err, msError, VisualObject);
    Result := r_Fail;
    Exit;
  end;

  //Один шаг интегрирования эйлеровским методом
  if at>0 then
  begin

    //Проверка наступления события по времени
    FMU.TimeEvent := FMU.eventInfo.upcomingTimeEvent and (FMU.eventInfo.nextEventTime < at);
    if FMU.TimeEvent then at := FMU.eventInfo.nextEventTime;

  
    //Установка значений переменных модели на шаге интегрирования
    Setlength(FMU.x,(FMU.nx+1));
    FMU.fmuFlag := FMUfunc.fmiGetContinuousStates(FMU.model_instance, FMU.x, FMU.nx);
    if (FMU.fmuFlag <> fmiOk) then
    begin
      ErrorEvent(txt_FMUBlock_Run_err, msError, VisualObject);
      Result := r_Fail;
      Exit;
    end else
    begin
      Setlength(FMU.x,FMU.nx);
    end;

    //Установка значений производных переменных модели на шаге интегрирования
    Setlength(FMU.der_x,(FMU.nx+1));
    FMU.fmuFlag := FMUfunc.fmiGetDerivatives(FMU.model_instance, FMU.der_x, FMU.nx);
    if (FMU.fmuFlag <> fmiOk) then
    begin
      ErrorEvent(txt_FMUBlock_Run_err, msError, VisualObject);
      Result := r_Fail;
      Exit;
    end else
    begin
      Setlength(FMU.der_x,FMU.nx);
    end;

    //Расчет переменных интегрированием по Эйлеру
    for i := 0 to (FMU.nx-1) do
    begin
      FMU.x[i] := FMU.x[i] + h * FMU.der_x[i]
    end;

    //Запись новых значений переменных в образец модели FMU
    Setlength(FMU.x,(FMU.nx+1));
    FMU.fmuFlag := FMUfunc.fmiSetContinuousStates(FMU.model_instance, FMU.x, FMU.nx);
    if (FMU.fmuFlag <> fmiOk) then
    begin
      ErrorEvent(txt_FMUBlock_Run_err, msError, VisualObject);
      Result := r_Fail;
      Exit;
    end else
      Setlength(FMU.x,FMU.nx);

    //Получение индикаторов события
    if (FMU.nz > 0) then
    begin
      for i := 0 to (FMU.nz-1) do FMU.pre_z[i] := FMU.z[i];
      Setlength(FMU.z,(FMU.nz+1));
      FMU.fmuFlag := FMUfunc.fmiGetEventIndicators(FMU.model_instance, FMU.z, FMU.nz);
      if (FMU.fmuFlag <> fmiOk) then
      begin
        ErrorEvent(txt_FMUBlock_Run_err, msError, VisualObject);
        Result := r_Fail;
        Exit;
      end else
      begin
        Setlength(FMU.z,FMU.nz);
    end;
    end;

    //Функция окончания шага интегрирования
    FMU.fmuFlag := FMUfunc.fmiCompletedIntegratorStep(FMU.model_instance, FMU.StepEvent);
    if (FMU.fmuFlag <> fmiOk) then
    begin
      ErrorEvent(txt_FMUBlock_Run_err, msError, VisualObject);
      Result := r_Fail;
      Exit;
    end;

    //Событие, при выполнения условия индикатора события
    if (FMU.nz > 0) then
    begin
      FMU.StateEvent := False;
      FMU.StateEvent := (FMU.StateEvent or ((FMU.z[0]*FMU.pre_z[0]) < 0));
      if FMU.StateEvent then
      begin
        FMU.StateEvent := not FMU.StateEvent;
        FMU.fmuFlag := FMUfunc.fmiEventUpdate(FMU.model_instance, FMU.StateEvent, FMU.eventInfo);
        if (FMU.fmuFlag <> fmiOk) then
        begin
          ErrorEvent(txt_FMUBlock_Run_err, msError, VisualObject);
          Result := r_Fail;
          Exit;
        end;
      end;
    end;

    //Событие, при выполнении условия времени
    if FMU.TimeEvent then
    begin
      FMU.fmuFlag := FMUfunc.fmiEventUpdate(FMU.model_instance, FMU.StateEvent, FMU.eventInfo);
      if (FMU.fmuFlag <> fmiOk) then
      begin
        ErrorEvent(txt_FMUBlock_Run_err, msError, VisualObject);
        Result := r_Fail;
        Exit;
      end;
    end;               


    //Проверка окончания симуляции
    if FMU.eventInfo.terminateSimulation then
    begin
      Result := r_Success;
      exit;
    end;
    
      
  end;  //if at>0

  if (FMU.OutputCount > 0) then
  begin
    j := 0;
    for i := 1 to 5 do
    begin
      case i of
        1: begin  
          if (GetOutputValue(FMU, FMUfunc, PropName1, OutputValue) = fmiOk) then
          begin
            Y[j].Arr^[0] := OutputValue;
            j := j + 1;
          end;
        end;
        2: begin  
          if (GetOutputValue(FMU, FMUfunc, PropName2, OutputValue) = fmiOk) then
          begin
            Y[j].Arr^[0] := OutputValue;
            j := j + 1;
          end;
        end;
        3: begin  
          if (GetOutputValue(FMU, FMUfunc, PropName3, OutputValue) = fmiOk) then
          begin
            Y[j].Arr^[0] := OutputValue;
            j := j + 1;
          end;
        end;
        4: begin  
          if (GetOutputValue(FMU, FMUfunc, PropName4, OutputValue) = fmiOk) then
          begin
            Y[j].Arr^[0] := OutputValue;
            j := j + 1;
          end;
        end;
        5: begin  
          if (GetOutputValue(FMU, FMUfunc, PropName5, OutputValue) = fmiOk) then
          begin
            Y[j].Arr^[0] := OutputValue;
            j := j + 1;
          end;
        end;
      end; //case
    end; //for
  end; // if (FMU.OutputCount > 0)

  Result := r_Success;
end;  //Run

function TFMUBlock.Stop: int8;
begin
  FMU.fmuFlag := FMUfunc.fmiTerminate(FMU.model_instance);
  if (FMU.fmuFlag = fmiOk) then ErrorEvent(txt_FMUBlock_Terminate_Simulation, msInfo, VisualObject);
  FMUfunc.fmiFreeModelInstance(FMU.model_instance);
  //ErrorEvent(txt_FMUBlock_Free_Model, msInfo, VisualObject);
  Result := r_Success;
end;  //Stop

end.

// xxx

