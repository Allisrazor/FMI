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
} TInputFlag;                  //����, ������� ���������� �������� �� ���������� ������/������� ��� ���

typedef struct {               //���, � ������� ����������� ���������� ���� fmiReal
	fmiBoolean IsParameter;
	const char* Name;
	TInputFlag InputFlag;                    
} TRecVar;

typedef struct {
	const char* MI;              //ModelIdentifier
	const char* ModelGUID;       //GUID
	int nx;                      //NumberOfStates
	int nz;                      //NumberOfEventIndicators
	int nr;                      //���������� �������� ������������ ����������
	int ni;                      //���������� �������� ������������ ����������
	int nb;                      //���������� �������� ������������ ����������
	int ns;                      //���������� �������� ������������ ����������
	TRecVar* pRecRealVar;        //������ �������� ���������� ���� fmiReal
	TRecVar* pRecIntVar;         //������ �������� ���������� ���� fmiInteger
	TRecVar* pRecBoolVar;       //������ �������� ���������� ���� fmiBoolean
	TRecVar* pRecStringVar;      //������ �������� ���������� ���� fmiString
} XMLInfo;

DllExport void XMLParse(XMLInfo* XMLparsed, const char* xmlPath);
DllExport void FreeM(void * ptrmem);


