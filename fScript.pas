unit fScript;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.StdCtrls, Vcl.ComCtrls,
  Vcl.Grids, Vcl.DBGrids, Vcl.ExtCtrls, Data.Win.ADODB;

type
  TForScript = class(TForm)
    Panel1: TPanel;
    Script: TMemo;
    DBGrid1: TDBGrid;
    StatusBar1: TStatusBar;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    dsQuery: TDataSource;
    Button4: TButton;
    Splitter1: TSplitter;
    qryScript: TADOQuery;
    procedure ActionClick(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
    class procedure Execute;
  end;

implementation

{$R *.dfm}

  uses config, main, System.UITypes;

{ TForScript }

procedure TForScript.ActionClick(Sender: TObject);
begin
  case TButton(Sender).Tag of
     100 : if (Script.Text='') or (MessageDLG('Would you write a new script ?', mtConfirmation, [mbYes, mbNo], 0)=mrYes) then
             Script.Text:= '';
     101 : with TOpenDialog.Create(nil) do
           try
             Title:= 'select an sql file';
             Filter:= 'SQL File (*.sql)|*.sql|All files (*.*|*.*';
             if Execute then
               Script.Lines.LoadFromFile(FileName);
           finally
             Free;
           end;
     102 : if Script.Text<>'' then
           with TSaveDialog.Create(nil) do
           try
             Title:= 'select an sql file';
             Filter:= 'SQL File (*.sql)|*.sql|All files (*.*|*.*';
             DefaultExt:= '.sql';
             if Execute then
               Script.Lines.SaveToFile(FileName);
           finally
             Free;
           end
           else ShowMessage('No text file will be saved');
     103 : begin
             qryScript.Close;
             qryScript.SQL.Text:= Script.Text;
             try
               qryScript.Open;
             except
               on E: Exception do
                 MessageDLG('Error on execute your script : ' + e.Message, mtWarning, [mbOk], 0);
             end;
           end;
  end;
end;

class procedure TForScript.Execute;
var ForScript: TForScript;
begin
  Application.CreateForm(TForScript, ForScript);
  try
    Application.MainForm.FormStyle:= fsNormal;
    ForScript.ShowModal;
    Application.MainForm.FormStyle:= fsStayOnTop;
  finally
    FreeAndNil(ForScript);
  end;
end;

end.
