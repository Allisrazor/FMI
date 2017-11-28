unit parserXML;

interface

uses
Windows, FMITypes;

procedure XMLParse(XMLInfo : TpXMLInfo;
                  xmlPath : fmiString); cdecl; external 'parserXML' name ('XMLParse');

implementation

end.
