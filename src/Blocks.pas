
 //**************************************************************************//
 // Данный исходный код является составной частью системы МВТУ-4             //
 // Программист:        Тимофеев К.А.                                        //
 //**************************************************************************//


unit Blocks;

 //***************************************************************************//
 //               Блоки для импорта данных по интерфейсу FMI               //
 //***************************************************************************//

interface

uses Windows, Classes, MBTYArrays, DataTypes, DataObjts, SysUtils, RunObjts, SyncObjs, IntArrays,
Math, LibTexts, FMITypes, FMIfunc, sevenzip, parserXML;

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
    function       WriteParam(ID: NativeInt;Src: Pointer;SrcType: TDataType;destType: TDataType):boolean;override;
    procedure      EditFunc(Props:TList;
                            SetPortCount:TSetPortCount;
                            SetCondPortCount:TSetCondPortCount;
                            ExecutePropScript:TExecutePropScript
                            );override;
  private
    // --- Задаваемые свойства блока ---
    FMUAdress: string;
    ParameterNames: string;
    InputNames: string;
    OutputNames: string;
    PropCount: integer;
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
    function EditProp: int8;
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

procedure TFMUBlock.EditFunc;
var
Data : TEvalData;
StringBuf : string;
begin
  inherited;
  //Переписывается количество и имена входов
  Data := TEvalData(FindVar(Props,'InputCount'));
  if (Data <> nil) and not (StrToInt(Data.StrValue) = FMU.InputCount)  then
  begin
    SetPortCount(VisualObject,0);
    Data.StrValue := IntToStr(FMU.InputCount);
    ExecutePropScript(VisualObject,Data);
  end;

  //Переписывается количество и имена выходов
  Data := TEvalData(FindVar(Props,'OutputCount'));
  if (Data <> nil) and not (StrToInt(Data.StrValue) = FMU.OutputCount)  then
  begin
    Data.StrValue := IntToStr(FMU.OutputCount);
    ExecutePropScript(VisualObject,Data);
  end;

end;

function TFMUBlock.InfoFunc(Action: Integer):NativeInt;
var
i : integer;
begin
  Result:=0;
  case Action of
    i_GetInit: Result := r_Success;
    i_HaveSpetialEditor: Result := EditProp;
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
    if StrEqu(ParamName,'ParameterNames') then begin
      Result := 22;
      DataType := dtString;
      Exit;
    end;
    if StrEqu(ParamName,'InputNames') then begin
      Result := 23;
      DataType := dtString;
      Exit;
    end;
    if StrEqu(ParamName,'OutputNames') then begin
      Result := 24;
      DataType := dtString;
      Exit;
    end;
    if StrEqu(ParamName,'PropCount') then begin
      Result := NativeInt(@PropCount);
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

function TFMUBlock.WriteParam;
begin
  case ID of
    22: begin
         if SrcType = dtString then begin
         if not (PString(src)^ = ParameterNames) then PString(src)^ := ParameterNames;
           Result:=True;
         end;
       end;
    23: begin
         if SrcType = dtString then begin
         if not (PString(src)^ = InputNames) then PString(src)^ := InputNames;
           Result:=True;
         end;
       end;
    24: begin
         if SrcType = dtString then begin
         if not (PString(src)^ = OutputNames) then PString(src)^ := OutputNames;
           Result:=True;
         end;
       end;
  else
    Result:=inherited WriteParam(ID,Src,SrcType,destType);
  end;
end; //WriteParam

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
NameBuffer, DirBuffer : string;
i : integer;
p : TpRecVar;
FileExistBool1, FileExistBool2 : boolean;
begin
  Result := r_Success;

  if not ((ExtractFileExt(FMUAdress) = '.dll') or (ExtractFileExt(FMUAdress) = '.fmu')) then
  begin
    ErrorEvent((txt_FMUBlock_ChoseRight_err), msError, VisualObject);
    Result := r_Fail;
    Exit;
  end;  //if not (.dll or .fmu)

  if (ExtractFileExt(FMUAdress) = '.dll') then
  begin
    NameBuffer := ExtractFileName(FMUAdress);
    setlength(NameBuffer, (length(NameBuffer)-4));
    if not FileExists(GetCurrentDir + '\' + NameBuffer + '\binaries\win32\' +
      NameBuffer + '.dll') then
    begin
      DirBuffer := GetCurrentDir + '\' + NameBuffer + '\binaries\win32\';
      ErrorEvent((ExtractFileName(FMUAdress) + txt_FMUBlock_File_exists_err +
        DirBuffer + '. ' + txt_FMUBlock_ChoseRight_err), msError, VisualObject);
      Result := r_Fail;
      Exit;
    end;  //if not FileExists(.dll)
    if not FileExists(GetCurrentDir + '\' + NameBuffer + '\modelDescription.xml') then
    begin
      DirBuffer := GetCurrentDir + '\' + NameBuffer + '\';
      ErrorEvent(('modelDescription.xml' + txt_FMUBlock_File_exists_err +
        DirBuffer + '. ' + txt_FMUBlock_ChoseRight_err), msError, VisualObject);
      Result := r_Fail;
      Exit;
    end;  //if not FileExists(.xml)
    FMUfunc.fmu_name := NameBuffer;
  end;  //if (ExtractFileExt(FMUAdress) = '.dll')

  if (ExtractFileExt(FMUAdress) = '.fmu') then
  begin
    if not FileExists(FMUAdress) then
    begin
      ErrorEvent((ExtractFileName(FMUAdress) + txt_FMUBlock_File_exists_err +
        ExtractFilePath(FMUAdress) + '. ' + txt_FMUBlock_ChoseRight_err), msError, VisualObject);
      Result := r_Fail;
      Exit;
    end;  //if not FileExists(FMUAdress)
    NameBuffer := ExtractFileName(FMUAdress);
    setlength(NameBuffer, (length(NameBuffer)-4));
    FMUfunc.fmu_name := NameBuffer;
  end;  //(ExtractFileExt(FMUAdress) = '.fmu')

  if not (FMU.xmlPath = (GetCurrentDir + '\' + FMUfunc.fmu_name + '\modelDescription.xml')) then
  begin
    ErrorEvent(txt_FMUBlock_ChoseRight_err, msError, VisualObject);
    Result := r_Fail;
    Exit;
  end;

  Result := r_Success;
  FMU.IsStarted := false;
  
  //Инициализация параметров FMU
  FMU.loggingOn := fmiTrue;                      //fmiTrue, если необходимо ведения log
  FMU.nx := FMU.XMLInfo.NumberOfStates;          //Количество переменных состояний (для вычисления производных) - из .xml
  FMU.nz := FMU.XMLInfo.NumberOfEventIndicators; //Количество индикаторов события - из .xml
  FMU.Tstart := 0;                               //??? Начальное время интегрирования - из .xml, если там есть
  FMU.toleranceControlled := fmiFalse;
  FMU.p_inst_name := FMU.XMLInfo.ModelIdentifier;
  FMU.p_GUID := FMU.XMLInfo.GUID;
  Setlength(FMU.x,FMU.nx);
  Setlength(FMU.der_x,FMU.nx);
  Setlength(FMU.z,FMU.nz);
  Setlength(FMU.pre_z,FMU.nz);
  for i := 0 to (FMU.nz - 1) do FMU.z[i] := 0;


  //Присвоение Callback функциям значений из Delphi
  FMU.CallbackFunctions.logger := CallbackLogger;
  FMU.CallbackFunctions.allocateMemory := Fcalloc;
  FMU.CallbackFunctions.freeMemory := freeM;

  //Инициализация функций FMU
  if FileExists(GetCurrentDir + '\' + FMUfunc.fmu_name + '\' + FMUfunc.fmu_name + '.dll') then
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
  Result := r_Success;
end;  //Start

function TFMUBlock.EditProp: int8;
var
NameBuffer, DirBuffer : string;
i : integer;
p : TpRecVar;
FileExistBool1, FileExistBool2 : boolean;
begin
  Result := r_Success;

  if not ((ExtractFileExt(FMUAdress) = '.dll') or (ExtractFileExt(FMUAdress) = '.fmu')) then
  begin
    Result := r_Fail;
    Exit;
  end;  //if not (.dll or .fmu)

  if (ExtractFileExt(FMUAdress) = '.dll') then
  begin
    NameBuffer := ExtractFileName(FMUAdress);
    setlength(NameBuffer, (length(NameBuffer)-4));
    if not FileExists(GetCurrentDir + '\' + NameBuffer + '\binaries\win32\' +
      NameBuffer + '.dll') then
    begin
      Result := r_Fail;
      Exit;
    end;  //if not FileExists(.dll)
    if not FileExists(GetCurrentDir + '\' + NameBuffer + '\modelDescription.xml') then
    begin
      Result := r_Fail;
      Exit;
    end;  //if not FileExists(.xml)
    FMUfunc.fmu_name := NameBuffer;
  end;  //if (ExtractFileExt(FMUAdress) = '.dll')

  if (ExtractFileExt(FMUAdress) = '.fmu') then
  begin
    if not FileExists(FMUAdress) then
    begin
      Result := r_Fail;
      Exit;
    end;  //if not FileExists(FMUAdress)
    NameBuffer := ExtractFileName(FMUAdress);
    setlength(NameBuffer, (length(NameBuffer)-4));
    FileExistBool1 := FileExists(GetCurrentDir + '\' + NameBuffer + '\modelDescription.xml');
    FileExistBool2 := FileExists(GetCurrentDir + '\' + NameBuffer + '\binaries\win32\' +
      NameBuffer + '.dll');
    if not (FileExistBool1 and FileExistBool2) then
    begin
      with CreateInArchive(CLSID_CFormatZip) do
      begin
        OpenFile(FMUAdress);
        ExtractTo(GetCurrentDir + '\' + NameBuffer);
        Close;
      end;
    end;  //распаковка архива
    FMUfunc.fmu_name := NameBuffer;
  end;  //(ExtractFileExt(FMUAdress) = '.fmu')

  if not (FMU.xmlPath = (GetCurrentDir + '\' + NameBuffer + '\modelDescription.xml')) then
  begin
    FMU.xmlPath := (GetCurrentDir + '\' + NameBuffer + '\modelDescription.xml');
    FMU.p_xmlPath := pansichar(FMU.xmlPath);
    XMLParse(@FMU.XMLInfo, FMU.p_xmlPath);

    //Запись данных о переменных
    SetLength(FMU.VarArray, FMU.XMLInfo.VarArrayLen);
    p := FMU.XMLInfo.VarArray;
    for i := 0 to FMU.XMLInfo.VarArrayLen -1 do
      begin
        FMU.VarArray[i] := p;
        inc(p);
      end;

    FMU.InputCount := 0;
    FMU.OutputCount := 0;
    InputNames := '';
    OutputNames := '';
    for i := 0 to (Length(FMU.VarArray) - 1) do
    begin
      if (FMU.VarArray[i].InputFlag = input) and (FMU.VarArray[i].VarType <> Str) then
      begin
        FMU.InputCount := FMU.InputCount + 1;
        InputNames := InputNames + FMU.VarArray[i].Name + ', ';
      end;
      if (FMU.VarArray[i].InputFlag = output) and (FMU.VarArray[i].VarType <> Str) then
      begin
        FMU.OutputCount := FMU.OutputCount + 1;
        OutputNames := OutputNames + FMU.VarArray[i].Name + ', ';
      end;
    end; //for
    if InputNames > '' then SetLength(InputNames,(Length(InputNames))-2);
    if OutputNames > '' then SetLength(OutputNames,(Length(OutputNames))-2);

    ParameterNames := '';
    for i := 0 to (Length(FMU.VarArray) - 1) do
      if FMU.VarArray[i].IsParameter then ParameterNames := ParameterNames + (FMU.VarArray[i].Name) + ', ';
    if ParameterNames > '' then SetLength(ParameterNames,(Length(ParameterNames))-2);
  end; // if not FMU.xmlPath
end;  //EditBlock

function TFMUBlock.Run (var at,h : RealType) : int8;
var
  InputValue, OutputValue : array of fmiReal;
  Value : fmiReal;
  PropNames: array of String;
  i: Integer;
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

    if not FMU.IsStarted then ErrorEvent(txt_FMUBlock_Start, msInfo, VisualObject);
    FMU.IsStarted := true;

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

  SetLength(OutputValue,FMU.OutputCount);
  GetOutputValue(FMU, FMUfunc, OutputValue);
  for i := 0 to (FMU.OutputCount - 1) do Y[i].Arr^[0] := OutputValue[i];

  if (PropCount > 0) then
  begin
    SetLength(PropNames,5);
    PropNames[0] := PropName1;
    PropNames[1] := PropName2;
    PropNames[2] := PropName3;
    PropNames[3] := PropName4;
    PropNames[4] := PropName5;
    SetLength(PropNames,PropCount);
    for i := 0 to (PropCount - 1) do
      if (GetPropValue(FMU, FMUfunc, PropNames[i], Value) = fmiOk) then
            Y[FMU.OutputCount + i].Arr^[0] := Value
      else begin
        ErrorEvent((txt_FMUBlock_WrongPropName_err + PropNames[i]), msError, VisualObject);
        Result := r_Fail;
        Exit;
      end;
  end; //(PropCount > 0)

  Result := r_Success;
end;  //Run

function TFMUBlock.Stop: int8;
begin
  FMU.IsStarted := false;
  FMU.fmuFlag := FMUfunc.fmiTerminate(FMU.model_instance);
  if (FMU.fmuFlag = fmiOk) then ErrorEvent(txt_FMUBlock_Terminate_Simulation, msInfo, VisualObject);
  FMUfunc.fmiFreeModelInstance(FMU.model_instance);
  //ErrorEvent(txt_FMUBlock_Free_Model, msInfo, VisualObject);
  Result := r_Success;
end;  //Stop

end.

