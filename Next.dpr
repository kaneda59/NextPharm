program Next;



{$R 'Elevation.res' 'Elevation.rc'}

uses
  Winapi.Windows,
  Vcl.Forms,
  Vcl.Dialogs,
  main in 'main.pas' {ForMainM2COMM},
  Vcl.Themes,
  Vcl.Styles,
  Messages,
  Classes,
  SysUtils,
  System.UITypes,
  config in 'config.pas',
  fScript in 'fScript.pas' {ForScript},
  mdData in 'mdData.pas' {Module: TDataModule},
  ukill in 'ukill.pas',
  uLogs in 'uLogs.pas',
  fSupplierRules in 'fSupplierRules.pas' {ForListSupplierRules},
  fsSupplierRule in 'fsSupplierRule.pas' {ForSaiSupplierRule};

{$R *.res}

var HandleApp: THandle = 0;
    file_auto: Boolean = False;
    web_auto : Boolean = False;

    procedure ShowAllReadyApplication(const HandleApp: THandle);
    begin
      try
        SendMessage(HandleApp, WM_SETPARAMETERS, Integer(file_auto), integer(web_auto));
      except
        on E: Exception do
          WriteToLog('erreur sendmessage already running program : ' + e.Message);
      end;
    end;

begin
  Application.Initialize;
  SetLastError(0);
  CreateMutex(nil, False, '{B009B142-0947-44A4-8901-8E5B122C5924}');
  if GetLastError = ERROR_ALREADY_EXISTS then
  begin
   HandleApp:= FindWindow('TForMainM2COMM', nil);
   file_auto:= ParamStr(1)='/file';
   web_auto := ParamStr(2)='/web';
   if file_auto or web_auto then
        ShowAllReadyApplication(HandleApp)
   else MessageDLG('this program is already running', mtWarning, [mbOk], 0);
  end
  else
  begin
    Application.MainFormOnTaskbar := True;
    Application.ShowMainForm := True;
    TStyleManager.TrySetStyle('Charcoal Dark Slate');
    Application.CreateForm(TModule, Module);
  Application.CreateForm(TForMainM2COMM, ForMainM2COMM);
  Application.Run;
  end;
end.
