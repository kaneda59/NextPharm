program Next;

uses
  Vcl.Forms,
  main in 'main.pas' {ForMainM2COMM},
  Vcl.Themes,
  Vcl.Styles,
  config in 'config.pas',
  fScript in 'fScript.pas' {ForScript},
  mdData in 'mdData.pas' {Module: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.ShowMainForm := False;
  TStyleManager.TrySetStyle('Smokey Quartz Kamri');
  Application.CreateForm(TModule, Module);
  Application.CreateForm(TForMainM2COMM, ForMainM2COMM);
  Application.Run;
end.
