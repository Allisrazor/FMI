unit FMITypes;

interface

uses Windows;

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
  TVarTypeFlag = (Real, Int, Bool, Str);      //����, ������� ���������� ��� ����������

  TRecVar = record                            //���, � ������� ����������� ���������� ���� fmiReal
    VarType : TVarTypeFlag;
    ValueRef : fmiValueReference;
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
    VarArrayLen : integer;                    //���������� ��������� � ������� �������� ����������
    VarArray : TpRecVar;                      //��������� �� ������ ����������
  end;
  TpXMLInfo = ^TXMLInfo;

  TArrRecVar = array of TpRecVar;             //��� - ������������ ������ ������� � ����������
  // --- ����� ���������� �� xml ---

  // --- �����  ���������� ������ FMU ---
  TFMU = packed record
    dll_Handle : THandle;                     //����� ��� .dll ������ FMU
    IsStarted : boolean;                      //����, ������������ �������� ������ �� ������ ��� ���
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
    xmlPath : AnsiString;                     //���� � .xml
    p_xmlPath : pAnsiChar;                    //��������� �� ���� � .xml
    XMLInfo : TXMLInfo;                       //������ �������� ������ �� .xml
    VarArray : TArrRecVar;                    //������ �������� ����������
  end;
  // --- �����  ���������� ������ FMU ---

implementation

end.
