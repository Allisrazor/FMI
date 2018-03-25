
 //**************************************************************************//
 // Данный исходный код является составной частью системы МВТУ-4             //
 // Программист:        Тимофеев К.А.                                        //
 //**************************************************************************//

unit parserXML;

 //**************************************************************************//
 //                  Блок для импорта функций парсера XML                    //
 //                                                                          //
 //**************************************************************************//

interface

uses
Windows, FMITypes;

type
TMD = pointer;  //тип указатель на указатель (для вытаскивания адреса структуры
TpMD = ^TMD;    //ModelDescription и ее освобождения)

procedure XMLParse(MD : TpMD;
                   XMLInfo : TpXMLInfo;
                   xmlPath : pAnsiChar); cdecl; external 'FMI_Parser_XML' name ('XMLParse');

procedure XMLFree(MD : TpMD;
                  XMLInfo : TpXMLInfo); cdecl; external 'FMI_Parser_XML' name ('XMLFree');

implementation

end.
