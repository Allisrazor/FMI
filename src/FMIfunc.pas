unit FMIfunc;

interface

uses
Windows, SysUtils;

const
//������� ������� ��� FMU
  fmiTrue = True;
  fmiFalse = False;

type
 //����������� ���� ������ � fmiModelTypes
  fmiComponent = pointer;
  fmiValueReference = Cardinal;
  fmiReal = Double;
  fmiInteger = Integer;
  fmiBoolean = Boolean;
  fmiString = pAnsiChar;
  fmiPBoolean = ^fmiBoolean; //��������� �� fmiBoolean
  size_t = Cardinal;         //����������� ��� �� c++

//����������� ���� ������ � fmiModelFunctions
  fmiStatus = (fmiOk, fmiWarning, fmiDiscard, fmiError, fmiFatal);
  fmiCallbackLogger = procedure (c : fmiComponent;
                                 instanceName : fmiString;
                                 status : fmiStatus;
                                 category : fmiString;
                                 Logmessage : fmiString);  cdecl; //�������� � message

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

  // --- ����� ���������� �� xml ---
  TInputFlag = (Input, Output, None);         //����, ������� ���������� �������� �� ���������� ������/������� ��� ���

  TRecVar = record                            //���, � ������� ����������� ���������� ���� fmiReal
    IsParameter : boolean;
    Name : pAnsiChar;
    InputFlag : TInputFlag;
  end;
  TpRecVar = ^TRecVar;

  TXMLInfo = record                           //�������� ���, ������� �������� ������ �� .xml
    ModelIdentifier : pAnsiChar;              //������������� ������
    GUID : pAnsiChar;                         //GUID ������
    NumberOfStates : fmiInteger;              //���������� ���������� ���������
    NumberOfEventIndicators : fmiInteger;     //���������� ����������� �������
    RealArrayLen : integer;                   //���������� ��������� � ������� �������� ������������ ����������
    IntArrayLen : integer;                    //���������� ��������� � ������� �������� ����� ����������
    BoolArrayLen : integer;                   //���������� ��������� � ������� �������� ��������� ����������
    StringArrayLen : integer;                 //���������� ��������� � ������� �������� ��������� ����������
    RealArray : TpRecVar;                     //��������� �� ������ ���������� ���� fmiReal
    IntArray : TpRecVar;                      //��������� �� ������ ���������� ���� fmiInteger
    BoolArray : TpRecVar;                     //��������� �� ������ ���������� ���� fmiBoolean
    StringArray : TpRecVar;                   //��������� �� ������ ���������� ���� fmiString
  end;
  TpXMLInfo = ^TXMLInfo;

  TArrRecVar = array of TpRecVar;             //��� - ������������ ������ ������� � ����������
  // --- ����� ���������� �� xml ---

  // --- �����  ���������� ������ FMU ---
  TFMU = packed record
    dll_Handle : THandle;                     //����� ��� .dll ������ FMU
    xmlPath : AnsiString;                     //���� � .xml
    p_xmlPath : pAnsiChar;                    //��������� �� ���� � .xml
    CallbackFunctions : fmiCallbackFunctions; //�������� ���������� CallbackFunctions
    model_instance : fmiComponent;            //��������� �� ������� ������
    loggingOn : fmiBoolean;                   //fmiTrue, ���� ���������� ������� log
    fmuFlag : fmiStatus;                      //����, ������������ ��������� FMI
    InputCount : integer;                     //���������� ������
    OutputCount : integer;                    //���������� �������

    nx : size_t;                              //���������� ���������� ��������� (� �. �. ��� ���������� �����������) - �� .xml
    x : array of fmiReal;                     //������ ���������� ��������� ������
    der_x : array of fmiReal;                 //������ ����������� ������
    nz : size_t;                              //���������� ����������� ������� - �� .xml
    z : array of fmiReal;                     //������ ������� ����������� �������
    pre_z : array of fmiReal;                 //������ ���������� ����������� �������

    vr : array of fmiValueReference;          //��������� ���� ������������ ���������� ������
    r : array of fmiReal;                     //������ ���� ������������ ���������� ������
    nr : size_t;                              //���������� ������������ ���� ���������� ������

    vb : array of fmiValueReference;          //��������� ���� ��������� ���������� ������
    b : array of fmiBoolean;                  //������ ���� ��������� ���������� ������
    nb : size_t;                              //���������� ��������� ���� ���������� ������

    vi : array of fmiValueReference;          //��������� ���� ����� ���������� ������
    i : array of fmiInteger;                  //������ ���� ����� ���������� ������
    ni : size_t;                              //���������� ����� ���� ���������� ������

    vs : array of fmiValueReference;          //��������� ���� ��������� ���������� ������
    s : array of fmiString;                   //������ ���� ��������� ���������� ������
    ns : size_t;                              //���������� ��������� ���� ���������� ������

    Tstart : fmiReal;                         //��������� ����� �������������� - �� .xml, ���� ��� ����
    Tend : fmiReal;                           //�������� ����� �������������� - �� .xml, ���� ��� ����
    toleranceControlled : fmiBoolean;         //True, ���� ����� �������������� ��� ��������������
    inst_name : AnsiString;                   //��� ������ - �� .xml
    GUID : AnsiString;                        //����������������� ����� - �� .xml
    p_inst_name : pAnsiChar;                  //��������� �� ��� ������
    p_GUID : pAnsiChar;                       //��������� �� ����������������� �����
    eventInfo : fmiEventInfo;                 //������ �������� �������� �������
    TimeEvent : fmiBoolean;
    StepEvent : fmiBoolean;
    StateEvent : fmiBoolean;
    XMLInfo : TXMLInfo;                       //������ �������� ������ �� .xml
    RealArray : TArrRecVar;                   //������ �������� ������������ �����
    IntArray : TArrRecVar;                    //������ �������� ����� �����
    BoolArray : TArrRecVar;                   //������ �������� ��������� �����
    StringArray : TArrRecVar;                 //������ �������� ��������� �����
  end;
  // --- �����  ���������� ������ FMU ---

  // --- ����� ������� FMU ---

  //����������� ������� � fmiModelFunctions -- ����� ����������, ����� ��������� ���������� (var), � ����� ���
  TfmiGetModelTypesPlatform = function() : fmiString; cdecl;

  TfmiGetVersion = function() : fmiString; cdecl;

  //������� ��� �������� � ����������� ���������� ������
  TfmiInstantiateModel = function(instanceName : fmiString;
                                  GUID : fmiString;
                                  functions : fmiCallbackFunctions;
                                  loggingOn: fmiBoolean) : fmiComponent; cdecl;

  TfmiFreeModelInstance = procedure(c : fmiComponent); cdecl;

  TfmiSetDebugLogging = function(c : fmiComponent;
                                 loggingOn: fmiBoolean) : fmiStatus; cdecl;

  //������� ����������� ����������� ���������� � �����������
  TfmiSetTime = function(c : fmiComponent;
                         time : fmiReal) : fmiStatus; cdecl;

  TfmiSetContinuousStates = function(c : fmiComponent;
                                     � : array of fmiReal;
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

  //�������, ����������� ������� �������� ��������� ������

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

  //��� - ������� FMU (��� �������� �� .dll)
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
  // --- ����� ������� FMU ---


//���������� ������� callback � ������ ����������� (???� ���������� ����� ��������)
procedure CallbackLogger(c : fmiComponent;
                         instanceName : fmiString;
                         status : fmiStatus;
                         category : fmiString;
                         Logmessage : fmiString); cdecl;

function Fcalloc(nobj : size_t; size : size_t) : pointer; cdecl;

procedure freeM(obj : pointer); cdecl;

//���������� ������� �������� ������� ���� fmiStatus � ������
function fmiStatusToString (Status : fmiStatus) : fmiString; cdecl;

//���������� ������� ��������� �������� ��� �������� �������
Function GetOutputValue(FMU : TFMU;
                        FMUfunc : TFMUfunc;
                        OutputName : string;
                        var value : double) : fmiStatus;

//��������� ������� ��������� �������� ��� ������
Function SetInputValue(var FMU : TFMU;
                       FMUfunc : TFMUfunc;
                       value : array of double) : fmiStatus;

implementation

//�������� ������� callback � ������ ����������� (� ���������� ����� ��������)
procedure CallbackLogger      (c : fmiComponent;
                               instanceName : fmiString;
                               status : fmiStatus;
                               category : fmiString;
                               Logmessage : fmiString);  cdecl; //�������� � message
  begin
    Logmessage := Logmessage;   //??? ���-�� ����� ��������� � ��������
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

procedure freeM (obj : pointer); cdecl;   //??? ��� �� ��������, ���� � �������� ��������� ������������ ���� � ��� �� ��������� �� ������ ���
begin
    if (not (obj = nil)) and (obj <> @DummyData) then
    begin
      FreeMem(obj);
    end;
end;

//�������� ������� �������� ������� ���� fmiStatus � ������
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

//�������� ������� ��������� �������� ��� �������� �������
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
        Result := fmiWarning;  //���� ����� �� ������� -  ��� ��������������, �� ��� ���������, ������ ������ � ����� ����� ������
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
          Result := fmiError;  //���� ����� �� ������� -  ��� ������, �� �������� � �������� �� ModelInstance
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
          Result := fmiError;  //���� ����� �� ������� -  ��� ������, �� �������� � �������� �� ModelInstance
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
          Result := fmiError;  //���� ����� �� ������� -  ��� ������, �� �������� � �������� �� ModelInstance
          exit;
        end;
        if BoolVal[0] then value := 1
        else value := 0;
      end; //bool
    end; //case

    Result := fmiOk;

  end;//GetOutputValue

//�������� ������� ��������� �������� ��� ������
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
          Result := fmiError;  //���� ����� �� ������� -  ��� ������, �� �������� � �������� �� ModelInstance
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
          Result := fmiError;  //���� ����� �� ������� -  ��� ������, �� �������� � �������� �� ModelInstance
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
          Result := fmiError;  //���� ����� �� ������� -  ��� ������, �� �������� � �������� �� ModelInstance
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
