/* -------------------------------------------------------------------------
 * fmi_me.h
 * Function types for all function of the "FMI for Model Exchange 1.0"
 * and a struct with the corresponding function pointers.
 * Copyright QTronic GmbH. All rights reserved.
 * -------------------------------------------------------------------------*/

#include <stdlib.h>
#include "fmiModelTypes.h"
#include "xml_parser.h"

typedef enum {
	Input,
	Output,
	None
} TInputFlag;                  //����, ������� ���������� �������� �� ���������� ������/������� ��� ���

typedef enum {
	Real,
	Int,
	Bool,
	Str
} TVarTypeFlag;                //����, ������� ���������� ��� ����������

typedef struct {               //���, � ������� ����������� ���������� ���� fmiReal
	TVarTypeFlag VarType;
    fmiValueReference ValueRef;
	fmiBoolean IsParameter;
	const wchar_t* Name;
	TInputFlag InputFlag;                    
} TRecVar;

typedef struct {
	const wchar_t* MI;              //ModelIdentifier
	const wchar_t* ModelGUID;       //GUID
	int nx;                         //NumberOfStates
	int nz;                         //NumberOfEventIndicators
	int nv;                         //���������� �������� ����������
	TRecVar* pRecVar;               //��������� �� ������ �������� ���������� 
} XMLInfo;

void XMLParse(void** MD, XMLInfo* XMLparsed, const char* xmlPath);

void XMLFree(void** MD, XMLInfo* XMLparsed);

