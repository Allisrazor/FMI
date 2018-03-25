
 //**************************************************************************//
 // Данный исходный код является составной частью системы МВТУ-4             //
 // Программист:        Тимофеев К.А.                                        //
 //**************************************************************************//

unit FMIfunc;

 //***************************************************************************//
 //               Функции FMI                                                 //
 //***************************************************************************//

interface

uses
Windows, SysUtils, FMITypes;

const
//Задание костант для FMI
  fmiTrue = True;
  fmiFalse = False;

type
  // --- Набор функций FMI ---

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


//Объявление функций callback
procedure CallbackLogger(c : fmiComponent;
                         instanceName : fmiString;
                         status : fmiStatus;
                         category : fmiString;
                         Logmessage : fmiString); cdecl;

function Fcalloc(nobj : size_t; size : size_t) : pointer; cdecl;

procedure freeM(obj : pointer); cdecl;

//Объявление Функции перевода статуса типа fmiStatus в строку
function fmiStatusToString (Status : fmiStatus) : fmiString; cdecl;

//Объявление функции получения значений для выходов
Function GetOutputValue(var FMU : TFMU;
                        FMUfunc : TFMUfunc;
                        var value : array of double) : fmiStatus;

//Объявление функции получения значений для заданных свойств
Function GetPropValue(var FMU : TFMU;
                        FMUfunc : TFMUfunc;
                        PropName : String;
                        var value : double) : fmiStatus;

//Объяление функции установки значений для входов
Function SetInputValue(var FMU : TFMU;
                       FMUfunc : TFMUfunc;
                       value : array of double) : fmiStatus;

implementation

//Описание функций callback
procedure CallbackLogger      (c : fmiComponent;
                               instanceName : fmiString;
                               status : fmiStatus;
                               category : fmiString;
                               Logmessage : fmiString);  cdecl;
  begin
    Logmessage := Logmessage;
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

procedure freeM (obj : pointer); cdecl;
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

//Описание функции получения значений для выходов
Function GetOutputValue(var FMU : TFMU;
                        FMUfunc : TFMUfunc;
                        var value : array of double) : fmiStatus;
var
VR : array of fmiValueReference;
RealVal : array of fmiReal;
IntVal : array of fmiInteger;
BoolVal : array of fmiBoolean;
i, j : integer;
status : fmiStatus;
begin
  j := 0;
  if (FMU.OutputCount > 0) then
  begin
    For i := 0 to (FMU.XMLInfo.VarArrayLen - 1) do
    begin
      if FMU.VarArray[i]^.InputFlag = Output then
      begin
        case FMU.VarArray[i]^.VarType of
          Real: begin
            SetLength(RealVal, 2);
            SetLength(VR, 2);
            VR[0] := FMU.VarArray[i]^.ValueRef;
            Status := FMUfunc.fmiGetReal(FMU.model_instance, VR, RealVal);
            if (Status <> fmiOk) then
            begin
              Result := fmiError;  //если выход из функции -  это ошибка, то проблема с импортом из ModelInstance
              exit;
            end;
            Value[j] := RealVal[0];
            inc(j);
          end;  //Real
          Int: begin
            SetLength(IntVal, 2);
            SetLength(VR, 2);
            VR[0] := FMU.VarArray[i]^.ValueRef;
            Status := FMUfunc.fmiGetInteger(FMU.model_instance, VR, IntVal);
            if (Status <> fmiOk) then
            begin
              Result := fmiError;  //если выход из функции -  это ошибка, то проблема с импортом из ModelInstance
              exit;
            end;
            Value[j] := IntVal[0];
            inc(j);
          end;  //Int
          Bool: begin
            SetLength(BoolVal, 2);
            SetLength(VR, 2);
            VR[0] := FMU.VarArray[i]^.ValueRef;
            Status := FMUfunc.fmiGetBoolean(FMU.model_instance, VR, BoolVal);
            if (Status <> fmiOk) then
            begin
              Result := fmiError;  //если выход из функции -  это ошибка, то проблема с импортом из ModelInstance
              exit;
            end;
            if (BoolVal[0]) then Value[j] := 1
            else Value[j] := 0;
            inc(j);
          end;  //Bool
        end;  //case
      end;  //if
    end; //for
  end; //If

  Result := fmiOk;

end;//GetOutputValue

//Описание функции установки значений для входов
Function SetInputValue(var FMU : TFMU;
                       FMUfunc : TFMUfunc;
                       value : array of double) : fmiStatus;
var
VR : array of fmiValueReference;
RealVal : array of fmiReal;
IntVal : array of fmiInteger;
BoolVal : array of fmiBoolean;
i, j : integer;
status : fmiStatus;
begin
  j := 0;
  if (FMU.InputCount > 0) then
  begin
    For i := 0 to (FMU.XMLInfo.VarArrayLen - 1) do
    begin
      if FMU.VarArray[i]^.InputFlag = Input then
      begin
        case FMU.VarArray[i]^.VarType of
          Real: begin
            SetLength(RealVal, 2);
            SetLength(VR, 2);
            RealVal[0] := Value[j];
            VR[0] := FMU.VarArray[i]^.ValueRef;
            Status := FMUfunc.fmiSetReal(FMU.model_instance, VR, RealVal);
            if (Status <> fmiOk) then
            begin
              Result := fmiError;  //если выход из функции -  это ошибка, то проблема с импортом из ModelInstance
              exit;
            end;
            inc(j);
          end;  //Real
          Int: begin
            SetLength(IntVal, 2);
            SetLength(VR, 2);
            IntVal[0] := round(Value[j]);
            VR[0] := FMU.VarArray[i]^.ValueRef;
            Status := FMUfunc.fmiSetInteger(FMU.model_instance, VR, IntVal);
            if (Status <> fmiOk) then
            begin
              Result := fmiError;  //если выход из функции -  это ошибка, то проблема с импортом из ModelInstance
              exit;
            end;
            inc(j);
          end;  //Int
          Bool: begin
            SetLength(BoolVal, 2);
            SetLength(VR, 2);
            VR[0] := FMU.VarArray[i]^.ValueRef;
            if (Value[j] >= 0.6) then BoolVal[0] := True
            else BoolVal[0] := false;
            Status := FMUfunc.fmiSetBoolean(FMU.model_instance, VR, BoolVal);
            if (Status <> fmiOk) then
            begin
              Result := fmiError;  //если выход из функции -  это ошибка, то проблема с импортом из ModelInstance
              exit;
            end;
            inc(j);
          end;  //Bool
        end;  //case
      end;  //if
    end; //for
  end; //If

  Result := fmiOk;

end;//SetInputValue

//Описание функции получения значений для заданных свойств
Function GetPropValue(var FMU : TFMU;
                        FMUfunc : TFMUfunc;
                        PropName : String;
                        var value : double) : fmiStatus;
var
VR : array of fmiValueReference;
RealVal : array of fmiReal;
IntVal : array of fmiInteger;
BoolVal : array of fmiBoolean;
i : integer;
status : fmiStatus;
begin
  Status := fmiWarning;
  For i := 0 to (FMU.XMLInfo.VarArrayLen - 1) do
  begin
    if FMU.VarArray[i]^.Name = PropName then
    begin
      case FMU.VarArray[i]^.VarType of
        Real: begin
          SetLength(RealVal, 2);
          SetLength(VR, 2);
          VR[0] := FMU.VarArray[i]^.ValueRef;
          Status := FMUfunc.fmiGetReal(FMU.model_instance, VR, RealVal);
          if (Status <> fmiOk) then
          begin
            Result := fmiError;  //если выход из функции -  это ошибка, то проблема с импортом из ModelInstance
            exit;
          end;
          Value := RealVal[0];
          Result := fmiOk;
          exit;
        end;  //Real
        Int: begin
          SetLength(IntVal, 2);
          SetLength(VR, 2);
          VR[0] := FMU.VarArray[i]^.ValueRef;
          Status := FMUfunc.fmiGetInteger(FMU.model_instance, VR, IntVal);
          if (Status <> fmiOk) then
          begin
            Result := fmiError;  //если выход из функции -  это ошибка, то проблема с импортом из ModelInstance
            exit;
          end;
          Value := IntVal[0];
          Result := fmiOk;
          exit;
        end;  //Int
        Bool: begin
          SetLength(BoolVal, 2);
          SetLength(VR, 2);
          VR[0] := FMU.VarArray[i]^.ValueRef;
          Status := FMUfunc.fmiGetBoolean(FMU.model_instance, VR, BoolVal);
          if (Status <> fmiOk) then
          begin
            Result := fmiError;  //если выход из функции -  это ошибка, то проблема с импортом из ModelInstance
            exit;
          end;
          if (BoolVal[0]) then Value := 1
          else Value := 0;
          Result := fmiOk;
          exit;
        end;  //Bool
      end;  //case
    end;  //if
  end; //for

  if not (Status = fmiOk) then Result := fmiWarning
  else Result := fmiOk;

end;  //GetOutputValue

initialization
 FillChar(DummyData,SizeOf(DummyData),byte(0));
end.
