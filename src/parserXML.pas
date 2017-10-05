unit parserXML;

interface

uses
Windows, FMIfunc;

procedure XMLParse(XMLInfo : TpXMLInfo;
                  xmlPath : fmiString); cdecl; external 'parserXML' name ('XMLParse');

//procedure FreeM (obj : pointer); cdecl; external 'parserXML' name ('FreeM');

implementation

end.
