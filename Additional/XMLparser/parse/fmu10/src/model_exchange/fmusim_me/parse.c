/* ------------------------------------------------------------------------- 
 * main.c
 * Implements simulation of a single FMU instance using the forward Euler
 * method for numerical integration.
 * Command syntax: see printHelp()
 * Simulates the given FMU from t = 0 .. tEnd with fixed step size h and
 * writes the computed solution to file 'result.csv'.
 * The CSV file (comma-separated values) may e.g. be plotted using
 * OpenOffice Calc or Microsoft Excel.
 * This program demonstrates basic use of an FMU.
 * Real applications may use advanced numerical solvers instead, means to 
 * exactly locate state events in time, graphical plotting utilities, support
 * for co-execution of many FMUs, stepping and debug support, user control
 * of parameter and start values etc. 
 * All this is missing here.
 *
 * Revision history
 *  07.02.2010 initial version released in FMU SDK 1.0
 *  05.03.2010 bug fix: removed strerror(GetLastError()) from error messages
 *  11.06.2010 bug fix: replaced win32 API call to OpenFile in getFmuPath
 *    which restricted path length to FMU to 128 chars. New limit is MAX_PATH.
 *  15.07.2010 fixed wrong label in xml parser: deault instead of default
 *  13.12.2010 added check for undefined 'declared type' to xml parser
 *  31.07.2011 bug fix: added missing freeModelInstance(c)
 *  31.07.2011 bug fix: added missing terminate(c)
 *  30.08.2012 fixed access violation in xmlParser after reporting unknown attribute name
 *
 * Free libraries and tools used to implement this simulator:
 *  - header files from the FMU specification
 *  - eXpat 2.0.1 XML parser, see http://expat.sourceforge.net
 *  - 7z.exe 4.57 zip and unzip tool, see http://www.7-zip.org
 * Author: Jakob Mauss
 * Copyright QTronic GmbH. All rights reserved.
 * -------------------------------------------------------------------------*/

#include <stdlib.h>
#include <stdio.h>
#include <string.h> //strerror()
#include "parse.h"

void __iob_func(void) {}

ModelDescription* md;

DllExport void XMLParse(XMLInfo* XMLparsed, const char* xmlPath)
{
	md = parse(xmlPath);
	ScalarVariable** vars = md->modelVariables;
	XMLparsed->MI = getModelIdentifier(md);
	XMLparsed->ModelGUID = getString(md, att_guid);
	XMLparsed->nx = getNumberOfStates(md);
	XMLparsed->nz = getNumberOfEventIndicators(md);

	int k = 0;
	XMLparsed->nr = 0;
	XMLparsed->ni = 0;
	XMLparsed->nb = 0;
	XMLparsed->ns = 0;

	//Вычисление количества переменных (сколько вещественных, целых, булевских, строковых)
	for (k = 0; vars[k]; k++) {
		ScalarVariable* sv = vars[k];
		switch (sv->typeSpec->type) {
			case elm_Real:
				XMLparsed->nr = XMLparsed->nr + 1;
				break;
			case elm_Integer:
				XMLparsed->ni = XMLparsed->ni + 1;
				break;
			case elm_Boolean:
				XMLparsed->nb = XMLparsed->nb + 1;
				break;
			case elm_String:
				XMLparsed->ns = XMLparsed->ns + 1;
		}
	} //for

	//Выделенеие памяти под массивы
	XMLparsed->pRecRealVar = (TRecVar*)calloc(XMLparsed->nr,sizeof(TRecVar));
	XMLparsed->pRecIntVar  = (TRecVar*)calloc(XMLparsed->ni, sizeof(TRecVar));
	XMLparsed->pRecBoolVar = (TRecVar*)calloc(XMLparsed->nb, sizeof(TRecVar));
	XMLparsed->pRecStringVar = (TRecVar*)calloc(XMLparsed->ns, sizeof(TRecVar));

	//Задание массива описаний переменных модели
	int r = 0;
	int i = 0;
	int b = 0;
	int s = 0;

	for (k = 0; vars[k]; k++) {
		ScalarVariable* sv = vars[k];
		
		TRecVar SetVar = { "" , None, fmiFalse };

		SetVar.Name = getName(sv);                               //Получение имени переменной

		if (getCausality(sv) != enu_input) {                     //Проверка вход/выход или нет
			if (getCausality(sv) != enu_output) {
				SetVar.InputFlag = None;
			}
			else
				SetVar.InputFlag = Output;
		}
		else SetVar.InputFlag = Input;                           //Проверка параметр или нет

		SetVar.IsParameter = fmiFalse;
		if (getVariability(sv) == enu_parameter) {
			SetVar.IsParameter = fmiTrue;
		}

		switch (sv->typeSpec->type) {
			case elm_Real:
				(XMLparsed->pRecRealVar[r]) = SetVar;
				r = r + 1;
				break;
			case elm_Integer:
				(XMLparsed->pRecIntVar[i]) = SetVar;
				i = i + 1;
				break;
			case elm_Boolean:
				(XMLparsed->pRecBoolVar[b]) = SetVar;
				b = b + 1;
				break;
			case elm_String:
				(XMLparsed->pRecStringVar[s]) = SetVar;
				s = s + 1;
		}
	} //for
}

DllExport void FreeM(void* ptrmem)
{
	free(ptrmem);
}
