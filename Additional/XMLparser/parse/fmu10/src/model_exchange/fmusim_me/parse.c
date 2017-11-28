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
	XMLparsed->nv = 0;

	//Вычисление количества переменных
	for (k = 0; vars[k]; k++) {
		XMLparsed->nv = XMLparsed->nv + 1;
	} //for

	//Выделенеие памяти под массивы
	XMLparsed->pRecVar = (TRecVar*)calloc(XMLparsed->nv,sizeof(TRecVar));

	//Задание массива описаний переменных модели

	for (k = 0; vars[k]; k++) {
		ScalarVariable* sv = vars[k];
		
		TRecVar SetVar = { Real, 0, "" , None, fmiFalse };

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

		SetVar.ValueRef = getValueReference(sv);                 //Получение ссылки на переменнную

		switch (sv->typeSpec->type) {                            //Получение типа переменной
			case elm_Real:
				SetVar.VarType = Real;
				break;
			case elm_Integer:
				SetVar.VarType = Int;
				break;
			case elm_Boolean:
				SetVar.VarType = Bool;
				break;
			case elm_String:
				SetVar.VarType = Str;
				break;
		}
		(XMLparsed->pRecVar[k]) = SetVar;
	} //for
}

