unit LibTexts;

interface

const

{$IFNDEF ENG}
  //������
  txt_FMUBlock_InputCount_err = 'FMI. ������� ������ ���������� ������. ����������� ���������� ������ ��� ������: ';
  txt_FMUBlock_OutputCount_err = 'FMI. ������� ������ ���������� �������. ��������� ����������: ';
  txt_FMUBlock_Archive_err = 'FMI. ������� <��� �����>.fmu';
  txt_FMUBlock_Instantiate_err = 'FMI. ������ �������� ������� ������';
  txt_FMUBlock_Init_err = 'FMI. ������ �������������';
  txt_FMUBlock_Set_Time_err = 'FMI. ������ ��������� ������� � ������';
  txt_FMUBlock_Run_err = 'FMI. ������ �� ���� �������������� � ������';

  //�������
  txt_FMUBlock_Init = 'FMI. �������� �������� ���������� �� ����� �������������';
  txt_FMUBlock_Instantiate_good = 'FMI. ������ ������� ������';
  txt_FMUBlock_Init_good = 'FMI. ������ ����������������';
  txt_FMUBlock_State_init_good = 'FMI. �������� ��������� �������� ������';
  txt_FMUBlock_Der_Init_good = 'FMI. �������� ��������� ����������� ������';
  txt_FMUBlock_Terminate_Simulation = 'FMI. ��������� �����������';
  txt_FMUBlock_Free_Model = 'FMI. ������ ������ �����������';

{$ELSE}
  //������
  txt_FMUBlock_InputCount_err = 'FMI. Invalid input count. Required input count: ';
  txt_FMUBlock_OutputCount_err = 'FMI. Invalid output count. Required count: ';
  txt_FMUBlock_Archive_err = 'FMI. Select <filename>.fmu';
  txt_FMUBlock_Instantiate_err = 'FMI. Instantiate error';
  txt_FMUBlock_Init_err = 'FMI. Initialization error';
  txt_FMUBlock_Set_Time_err = 'FMI. Setting time error';
  txt_FMUBlock_Run_err = 'FMI. Integration step error';

  //�������
  txt_FMUBlock_Init = 'FMI. Checking the specified parameters during the initialization phase';
  txt_FMUBlock_Instantiate_good = 'FMI. Unit instantiated';
  txt_FMUBlock_Init_good = 'FMI. Model initializated';
  txt_FMUBlock_State_init_good = 'FMI. Start states initialized';
  txt_FMUBlock_Der_Init_good = 'FMI. Start derivatives initialized';
  txt_FMUBlock_Terminate_Simulation = 'FMI. Simulation stoped';
  txt_FMUBlock_Free_Model = 'FMI. Model instance is now free';
{$ENDIF}

implementation

end.
