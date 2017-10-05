
 //**************************************************************************//
 // ������ �������� ��� �������� ��������� ������ ������� ����-4             //
 // �����������:        �������� �.�.                                        //
 //**************************************************************************//


unit Info;

  //**************************************************************************//
  //         ����� ��������� ������ �������� � ������� ��� �� ��������        //
  //**************************************************************************//

interface

uses Classes, InterfaceUnit, DataTypes, DataObjts, RunObjts;

  //������������� ����������
function  Init:boolean;
  //��������� �������� �������
function  CreateObject(Owner:Pointer;const Name: string):Pointer;
  //����������� ����������
procedure Release;

  //������� ������������� ������ ����������
  //��� �������� ������ �� ��������� �������������, ���������� ����������
  //� ������� �������� ��������
const
  DllInfo: TDllInfo =
  (
    Init:         Init;
    Release:      Release;
    CreateObject: CreateObject;
  );

implementation

uses Blocks;

function  Init:boolean;
begin
  //���� ���������� ���������������� ���������, �� ������� ������ ������� True
  Result:=True;
  //����������� ����� � �������� ����������� ���� ������ ���������
  DBRoot:=DllInfo.Main.DataBasePath^;

  //����� ����� ���������� ����������� �������������� ������� ��������������
  //��� ������ ������� DllInfo.Main.RegisterFuncs
  //��� ���� ����� ���������� ������� � �������� ���� ������ ���������� � ������ �������� ������������ ���������.

end;


type
  TClassRecord = packed record
    Name:     string;
    RunClass: TRunClass;
  end;

  //**************************************************************************//
  //    ������� ������� ��������� � ����������� ���������� ������ ����        //
  //    � ������������ � ���� �������� ��������� �������������� run-�������   //
  //**************************************************************************//
const
  ClassTable:array[0..0] of TClassRecord =
  (
    (Name:'FMUBlock';   RunClass:TFMUBlock)
  );

  //��� ��������� �������� ��������
  //��� ���������� ��������� �� ������-������
function  CreateObject(Owner:Pointer;const Name: string):Pointer;
 var i: integer;
begin
  Result:=nil;
  for i:=0 to High(ClassTable) do if StrEqu(Name,ClassTable[i].Name) then begin
    Result:=ClassTable[i].RunClass.Create(Owner);
    exit;
  end;
end;

procedure Release;
begin

end;

end.
