unit main;

{$WARN UNIT_PLATFORM OFF}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Data.DB, Data.Win.ADODB,
  Vcl.Grids, Vcl.DBGrids, Vcl.ExtCtrls, Vcl.fileCtrl, System.UITypes,
  Vcl.Samples.Gauges, Vcl.Buttons, Vcl.ImgList, Vcl.Menus;

const CNX_STRING : string = 'Provider=PCSoft.HFSQL;Initial Catalog=%s;Password="";Extended Properties="Language=ISO-8859-1"';

type
  TForMainM2COMM = class(TForm)
    Panel1: TPanel;
    Database1: TADOConnection;
    btnGenerate: TButton;
    Panel2: TPanel;
    Gauge1: TGauge;
    edFormatFileName: TEdit;
    Label1: TLabel;
    LblPos: TLabel;
    edDestination: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    edDataBase: TEdit;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    btnPause: TButton;
    cbStockNull: TCheckBox;
    TrayIcon1: TTrayIcon;
    ImageList1: TImageList;
    PopupMenu1: TPopupMenu;
    MnuGenerate: TMenuItem;
    MnuPause: TMenuItem;
    N1: TMenuItem;
    MnuClose: TMenuItem;
    btnPrixWeb: TButton;
    MnuPrixWeb: TMenuItem;
    btnQuery: TButton;
    cbTakeOldRef: TCheckBox;
    btnHistorisation: TButton;
    Gauge2: TGauge;
    procedure btnGenerateClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure edDataBaseChange(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnPauseClick(Sender: TObject);
    procedure TrayIcon1DblClick(Sender: TObject);
    procedure MnuCloseClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnPrixWebClick(Sender: TObject);
    procedure btnQueryClick(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnHistorisationClick(Sender: TObject);
  private
    { Déclarations privées }
    Pause: Boolean;
    file_auto: Boolean;
    web_auto : Boolean;
  public
    { Déclarations publiques }
  end;

var
  ForMainM2COMM: TForMainM2COMM;

implementation

{$R *.dfm}

  uses Config, fScript, mdData;

    function BoolToStr(const cond: Boolean; const sTrue, sFalse: string): string;
    begin
      if cond then result:= sTrue
              else result:= sFalse;
    end;

    function complete(const value: string; const endcar: char): string;
    begin
      result:= value;
      if result<>'' then
      if result[length(value)]<>endcar then
        result:= result + endcar;
    end;

//procedure ConvertFile(const FileName: string);
//var
//  LBuffer: TBytes;
//  LByteOrderMark: TBytes;
//  LFileStream: TFileStream;
//  LOffset: Integer;
//  LEncoding, DestEncoding: TEncoding;
//  FileText: string;
//  ucs4Text: UCS4String;
//  wideStringText: WideString;
//begin
//  LEncoding:= nil;
//
//  LFileStream := TFileStream.Create(FileName, fmOpenRead);
//  try
//    SetLength(LBuffer, LFileStream.Size);
//    LFileStream.ReadBuffer(Pointer(LBuffer)^, Length(LBuffer));
//    LOffset := TEncoding.GetBufferEncoding(LBuffer, LEncoding);
//  finally
//    LFileStream.Free;
//  end;
//
//  RenameFile(FileName, ChangeFileExt(FileName, '.bak'));
//
//  DestEncoding := TEncoding.Unicode;
//  LBuffer := LEncoding.Convert(LEncoding, DestEncoding, LBuffer,
//    LOffset, Length(LBuffer) - LOffset);
//  LOffset := TEncoding.GetBufferEncoding(LBuffer, DestEncoding);
//  FileText := DestEncoding.GetString(LBuffer, LOffset, Length(LBuffer) - LOffset);
//  ucs4Text := UnicodeStringToUCS4String(FileText);
//  wideStringText := UCS4StringToWideString(ucs4Text);
//  //ShowMessage(wideStringText);
//
//  LFileStream := TFileStream.Create(FileName, fmCreate);
//  try
//    LByteOrderMark := DestEncoding.GetPreamble;
//    LFileStream.Write(LByteOrderMark[0], Length(LByteOrderMark));
//    LFileStream.Write(wideStringText[1], Length(wideStringText) * SizeOf(Char));
//  finally
//    LFileStream.Free;
//  end;
//end;

procedure TForMainM2COMM.btnGenerateClick(Sender: TObject);
var Fichier: TStringList;
    FileName: string;
    FormatEtiquette: string;

    PrixRemise: double;

    function DecimalStr(const value: string): string;
    begin
      result:= value;
      result:= StringReplace(result, ',', '.', [rfReplaceall]);
    end;

begin
  if file_auto or (MessageDLG('Voulez-vous générer le fichier des étiquettes ?', mtConfirmation, [mbYes, mbNo], 0)=mrYes) then
  begin
    Pause:= False;
    btnPause.Enabled:= True;
    MnuPause.Enabled:= True;
    btnGenerate.Enabled:= False;
    MnuGenerate.Enabled:= False;
    MnuClose.Enabled:= False;
    Fichier:= TStringList.Create;
    with TAdoQuery.Create(nil) do
    try
      Database1.Close;
      DataBase1.ConnectionString:= Format(CNX_STRING, [edDatabase.Text]);
      Connection:= Database1;
      SQL.Add('SELECT t.CNK as code,LibF,PrixPublic,PrixPublic-((PrixPublic*RemisePC)/100) as remisePCT,');
      SQL.Add('       (PrixPublic-RemisePC) as RemisePx, TypeRemise, st.StkRayon, st.stkCave, g.CodeBarre, RemisePC');
      SQL.Add('FROM tarSpe t LEFT OUTER JOIN AutresCodesBarresSpe g on g.cnk=t.cnk LEFT OUTER JOIN stock st');
      SQL.Add('ON st.cnk=t.cnk');
      SQL.Add('WHERE PrixPublic>0');
      Open;
      Gauge1.MaxValue:= RecordCount;
      Gauge1.MinValue:= 0;
      Gauge1.Progress:= 0;
      while (not Eof) and (not Pause) do
      begin
        if (FieldByName('stkRayon').AsInteger>0) or (cbStockNull.Checked) or
           (cbTakeOldRef.Checked and Module.FindMedication(FieldByName('Code').AsInteger)) then
        begin
          formatEtiquette:= '0';
          if FieldByName('TypeRemise').AsInteger=3 then
          begin
            if FieldByName('remisePC').AsFloat<>0 then
            begin
              if FieldByName('remisePC').AsFloat>10 then
                formatEtiquette:= '3';
              if FieldByName('remisePC').AsFloat<=10 then
                formatEtiquette:= '4';
            end;
          end
          else if FieldByName('TypeRemise').AsInteger=5 then
                 formatEtiquette:= '3';

          if FieldByName('TypeRemise').AsInteger=3 then
            PrixRemise:= FieldByName('remisePCT').AsFloat
          else
          if FieldByName('TypeRemise').AsInteger=5 then
            PrixRemise:= FieldByName('RemisePx').AsFloat
          else PrixRemise:= 0;

          if FieldByName('CodeBarre').AsString<>'' then
          Fichier.Add('M,' +  FieldByName('code').AsString + ',' +
                              FieldByName('codeBarre').AsString + ',' +
                              formatEtiquette + ',' +
                              StringReplace(FieldByName('LibF').AsString, ',', '.', [rfReplaceAll]) + ',' + FieldByName('StkCave').AsString + ',1,' +
                              DecimalStr(FormatFloat('0.00', FieldByName('PrixPublic').AsFloat)) + ',' +
                              BoolToStr((PrixRemise=0) or
                                        (FieldByName('PrixPublic').AsFloat=PrixRemise), '', DecimalStr(FormatFloat('0.00', PrixRemise))) + ',' +
                              FieldByName('StkRayon').AsString);
          Fichier.Add('M,' +  FieldByName('code').AsString + ',' +
                              FieldByName('code').AsString + ',' +
                              formatEtiquette + ',' +
                              StringReplace(FieldByName('LibF').AsString, ',', '.', [rfReplaceAll]) + ',' + FieldByName('StkCave').AsString + ',1,' +
                              DecimalStr(FormatFloat('0.00', FieldByName('PrixPublic').AsFloat)) + ',' +
                              BoolToStr((PrixRemise=0) or
                                        (FieldByName('PrixPublic').AsFloat=PrixRemise), '', DecimalStr(FormatFloat('0.00', PrixRemise))) + ',' +
                              FieldByName('StkRayon').AsString);

          Module.AddMedication(FieldByName('code').AsInteger,
                               FieldByName('LibF').AsString);
        end;
        Gauge1.Progress:= Gauge1.Progress + 1;
        LblPos.Caption:= intToStr(RecNo) + '/' + intToStr(RecordCount);
        Application.ProcessMessages;
        Next;
      end;
      Close;
      FileName:= edFormatFileName.Text;
      FileName:= StringReplace(FileName, '%YYYYMMDD%', FormatDateTime('YYYYMMDD', Date),[rfReplaceAll]);
      FileName:= StringReplace(FileName, '%HHNN%', FormatDateTime('HHNN', Time), [RfReplaceAll]);
      FileName:= complete(edDestination.Text, '\') + FileName;
      if not FileExists(FileName) or (MessageDLG('le fichier existe déjà, voulez-vous continuer ? le fichier précédent sera écrasé', mtConfirmation, [mbYes, mbNo], 0)=mrYes) then
      begin
        Fichier.SaveToFile(FileName, TEncoding.ASCII);
        Fichier.Clear;
        if not file_auto then Fichier.SaveToFile(FileName + '.done');
        if not file_auto then ShowMessage('Fichier créé avec succès');
      end
      else if not file_auto then ShowMessage('Abandon');
    finally
      Free;
      FreeAndNil(Fichier);
      btnGenerate.Enabled:= True;
      MnuGenerate.Enabled:= True;
      MnuClose.Enabled:= True;
      BtnPause.Enabled:= False;
      MnuPause.Enabled:= False;
    end;
  end;
  if file_auto and (not web_auto) then Application.Terminate;
end;

procedure TForMainM2COMM.btnHistorisationClick(Sender: TObject);
var i: integer;
begin
  with TOpenDialog.Create(nil) do
  try
    Filter:= 'CSV Files (*.csv)|*.csv|All files (*.*)|*.*';
    Options:= Options + [ofAllowMultiSelect];
    InitialDir:= edDestination.Text;
    if Execute then
    if MessageDLG('Voulez-vous importer les références non connues de ce(s) fichier(s) ?',
                  mtConfirmation, [mbYes, mbNo], 0)=mrYes then
    Gauge1.MinValue:= 0;
    Gauge1.MaxValue:= Files.Count;
    Gauge1.Progress:= 0;
    for i := 0 to Files.Count-1 do
    begin
      Module.ImportCSVFile(Files[i], Gauge2);
      Gauge1.Progress:= Gauge1.Progress + 1;
      Application.ProcessMessages;
    end;
    ShowMessage('importation terminée');
    Gauge1.Progress:= 0;
  finally
    Free;
  end;
end;

procedure TForMainM2COMM.btnPauseClick(Sender: TObject);
begin
  if MessageDLG('Voulez-vous stopper la génération du fichier ?', mtConfirmation, [mbYes, mbNo], 0)=mrYes then
  begin
    Pause:= True;
    btnGenerate.Enabled:= True;
    MnuGenerate.Enabled:= True;
  end;
end;

procedure TForMainM2COMM.btnPrixWebClick(Sender: TObject);
begin
  with TAdoQuery.Create(nil) do
  try
    Database1.Close;
    DataBase1.ConnectionString:= Format(CNX_STRING, [edDatabase.Text]);
    Connection:= Database1;
    SQL.Add('UPDATE tarSpe SET PrixWeb=Round(PrixPublic-((PrixPublic*RemisePC)/100), 2)');
    SQL.Add('WHERE RemisePC>0');
    try
      ExecSQL;
      if not web_auto then MessageDLG('Les prix Web ont été mis à jour', mtConfirmation, [mbYes], 0);
    except
      on E: Exception do
        if not web_auto then MessageDLG('Impossible de mettre à jour les prix Web : ' + e.Message,
                   mtError, [mbYes], 0);
    end;
  finally
    Free;
  end;
  if web_auto then Application.Terminate;
end;

procedure TForMainM2COMM.btnQueryClick(Sender: TObject);
begin
  TForScript.Execute;
end;

procedure TForMainM2COMM.edDataBaseChange(Sender: TObject);
begin
  btnGenerate.Enabled:= (edFormatFileName.Text<>'') and
                        (edDestination.Text<>'') and
                        (edDataBase.Text<>'');
  MnuGenerate.Enabled:= btnGenerate.Enabled;
  btnQuery.Enabled:= btnGenerate.Enabled;
end;

procedure TForMainM2COMM.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  v_config.DataBaseFolder:= edDataBase.Text;
  v_config.DestinationFolder:= edDestination.Text;
  v_config.FormatFileName:= edFormatFileName.Text;
  v_config.StockNull:= cbStockNull.Checked;
end;

procedure TForMainM2COMM.FormCreate(Sender: TObject);
begin
  edDataBase.Text      := v_config.DataBaseFolder;
  edDestination.Text   := v_config.DestinationFolder;
  edFormatFileName.Text:= v_config.FormatFileName;
  cbStockNull.Checked  := v_config.StockNull;

  file_auto:= ParamStr(1)='/file';
  web_auto := ParamStr(2)='/web';

  if file_auto and (edDataBase.Text<>'') and (edDestination.Text<>'') then btnGenerate.Click;
  if web_auto  and (edDataBase.Text<>'') and (edDestination.Text<>'') then  btnPrixWeb.Click;

  if not Module.PrepareConnection then
    MessageDLG('impossible de se connecter à la base de données locale d''historisation', mtError, [mbOk], 0);
end;

procedure TForMainM2COMM.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if (ssAlt in Shift) and (ssCTRL in Shift) then
    cbStockNull.Visible:= True;
end;

procedure TForMainM2COMM.FormShow(Sender: TObject);
begin
  Left := Screen.Width - Width - 5;
  Top  := Screen.Height - Height - 32;
end;

procedure TForMainM2COMM.MnuCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TForMainM2COMM.SpeedButton1Click(Sender: TObject);
var Dossier: string;
begin
  if SelectDirectory('Choisir le chemin d''accès de la base de données', 'Dossier', Dossier) then
    edDataBase.Text:= Dossier;
end;

procedure TForMainM2COMM.SpeedButton2Click(Sender: TObject);
var Dossier: string;
begin
  if SelectDirectory('Choisir le chemin de destination', 'Dossier', Dossier) then
    edDestination.Text:= Dossier;
end;

procedure TForMainM2COMM.TrayIcon1DblClick(Sender: TObject);
begin
  if not Self.Showing then Show
                      else Hide;
end;

end.
