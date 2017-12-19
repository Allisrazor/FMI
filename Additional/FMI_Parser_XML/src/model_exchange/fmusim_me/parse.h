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
} TInputFlag;                  //Флаг, который показывает является ли переменная входом/выходом или нет

typedef enum {
	Real,
	Int,
	Bool,
	Str
} TVarTypeFlag;                //Флаг, который показывает тип переменной

typedef struct {               //Тип, в котором описывается переменная типа fmiReal
	TVarTypeFlag VarType;
    fmiValueReference ValueRef;
	fmiBoolean IsParameter;
	const char* Name;
	TInputFlag InputFlag;                    
} TRecVar;

typedef struct {
	const char* MI;              //ModelIdentifier
	const char* ModelGUID;       //GUID
	int nx;                      //NumberOfStates
	int nz;                      //NumberOfEventIndicators
	int nv;                      //Количество описаний переменных
	TRecVar* pRecVar;            //Указатель на массив описаний переменных 
} XMLInfo;

DllExport void XMLParse(XMLInfo* XMLparsed, const char* xmlPath);

