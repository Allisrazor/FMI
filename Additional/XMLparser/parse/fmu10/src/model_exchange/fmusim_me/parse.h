/* -------------------------------------------------------------------------
 * fmi_me.h
 * Function types for all function of the "FMI for Model Exchange 1.0"
 * and a struct with the corresponding function pointers.
 * Copyright QTronic GmbH. All rights reserved.
 * -------------------------------------------------------------------------*/

#include <stdlib.h>
#include "fmiModelTypes.h"
#include "xml_parser.h"

#ifdef _MSC_VER
#define DllExport __declspec( dllexport )
#else
#define DllExport
#endif

typedef enum {
	Input,
	Output,
	None
} TInputFlag;                  //‘лаг, который показывает €вл€етс€ ли переменна€ входом/выходом или нет

typedef struct {               //“ип, в котором описываетс€ переменна€ типа fmiReal
	fmiBoolean IsParameter;
	const char* Name;
	TInputFlag InputFlag;                    
} TRecVar;

typedef struct {
	const char* MI;              //ModelIdentifier
	const char* ModelGUID;       //GUID
	int nx;                      //NumberOfStates
	int nz;                      //NumberOfEventIndicators
	int nr;                      // оличество описаний вещественных переменных
	int ni;                      // оличество описаний вещественных переменных
	int nb;                      // оличество описаний вещественных переменных
	int ns;                      // оличество описаний вещественных переменных
	TRecVar* pRecRealVar;        //ћассив описаний переменных типа fmiReal
	TRecVar* pRecIntVar;         //ћассив описаний переменных типа fmiInteger
	TRecVar* pRecBoolVar;       //ћассив описаний переменных типа fmiBoolean
	TRecVar* pRecStringVar;      //ћассив описаний переменных типа fmiString
} XMLInfo;

DllExport void XMLParse(XMLInfo* XMLparsed, const char* xmlPath);
DllExport void FreeM(void * ptrmem);


