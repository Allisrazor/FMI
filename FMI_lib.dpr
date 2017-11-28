 //**************************************************************************//
 // ������ �������� ��� �������� ��������� ������ ������� ����-4             //
 // �����������:        �������� �.�.                                        //
 //**************************************************************************//


library FMI_lib;

  //**************************************************************************//
  //                   �������� ���������� ������                             //
  //     �����:                                                               //
  //**************************************************************************//

uses
  SimpleShareMem,
  Classes,
  Blocks in 'src\Blocks.pas',
  FMIfunc in 'src\FMIfunc.pas',
  FMITypes in 'src\FMITypes.pas',
  Info in 'src\Info.pas',
  LibTexts in 'src\LibTexts.pas',
  parserXML in 'src\parserXML.pas',
  sevenzip in 'src\sevenzip.pas';

{$R *.res}

  //��� ������� ���������� ����� ��������� DllInfo
function  GetEntry:Pointer;
begin
  Result:=@DllInfo;
end;

exports
  GetEntry name 'GetEntry',         //������� ��������� ������ ��������� DllInfo
  CreateObject name 'CreateObject'; //������� �������� �������

begin
end.
