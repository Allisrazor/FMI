
 //**************************************************************************//
 // ������ �������� ��� �������� ��������� ������ ������� ����-4             //
 // �����������:        �������� �.�.                                        //
 //**************************************************************************//

unit parserXML;

 //**************************************************************************//
 //                  ���� ��� ������� ������� ������� XML                    //
 //                                                                          //
 //**************************************************************************//

interface

uses
Windows, FMITypes;

type
TMD = pointer;  //��� ��������� �� ��������� (��� ������������ ������ ���������
TpMD = ^TMD;    //ModelDescription � �� ������������)

procedure XMLParse(MD : TpMD;
                   XMLInfo : TpXMLInfo;
                   xmlPath : pAnsiChar); cdecl; external 'FMI_Parser_XML' name ('XMLParse');

procedure XMLFree(MD : TpMD;
                  XMLInfo : TpXMLInfo); cdecl; external 'FMI_Parser_XML' name ('XMLFree');

implementation

end.
