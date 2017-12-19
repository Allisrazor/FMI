unit parserXML;

interface

uses
Windows, FMITypes;

procedure XMLParse(XMLInfo : TpXMLInfo;
<<<<<<< HEAD
                  xmlPath : fmiString); cdecl; external 'FMI_Parser_XML' name ('XMLParse');
=======
                  xmlPath : fmiString); cdecl; external 'parserXML' name ('XMLParse');
>>>>>>> ba6c29a64a26bc41d74572f9a5bb904dcc343a87

implementation

end.
