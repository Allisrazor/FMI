 //**************************************************************************//
 // Данный исходный код является составной частью системы МВТУ-4             //
 // Программист:        Тимофеев К.А.                                        //
 //**************************************************************************//


library FMI_lib;

  //**************************************************************************//
  //                   Тестовая библиотека блоков                             //
  //     Автор:                                                               //
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

  //Эта функция возвращает адрес структуры DllInfo
function  GetEntry:Pointer;
begin
  Result:=@DllInfo;
end;

exports
  GetEntry name 'GetEntry',         //Функция получения адреса структуры DllInfo
  CreateObject name 'CreateObject'; //Функция создания объекта

begin
end.
