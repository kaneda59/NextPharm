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
    LblPos: TLabel;
    btnPause: TButton;
    TrayIcon1: TTrayIcon;
    ImageList1: TImageList;
    PopupMenu1: TPopupMenu;
    MnuGenerate: TMenuItem;
    MnuPause: TMenuItem;
    N1: TMenuItem;
    MnuClose: TMenuItem;
    btnPrixWeb: TButton;
    MnuPrixWeb: TMenuItem;
    pnl1: TPanel;
    btnQuery: TButton;
    chkMajPxWeb: TCheckBox;
    cbStockNull: TCheckBox;
    btnHistorisation: TButton;
    cbTakeOldRef: TCheckBox;
    Gauge2: TGauge;
    edDestPrixWeb: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    edDestination: TEdit;
    Label1: TLabel;
    edFormatFileName: TEdit;
    edDataBase: TEdit;
    Label4: TLabel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    spbDestPrixWeb: TSpeedButton;
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
    procedure spbDestPrixWebClick(Sender: TObject);
    procedure Panel1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
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
    FichierWeb: TStringList;
    FileName: string;
    FileNameWeb: string;
    FormatEtiquette: string;

    PrixRemise: double;

    function DecimalStr(const value: string): string;
    begin
      result:= value;
      result:= StringReplace(result, ',', '.', [rfReplaceall]);
    end;

    procedure AddWebInfo(const value: string);
    begin
      if chkMajPxWeb.Checked then
         FichierWeb.Add(value);
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
    if chkMajPxWeb.checked then
      FichierWeb:= TStringList.Create;
    with TAdoQuery.Create(nil) do
    try
      Database1.Close;
      DataBase1.ConnectionString:= Format(CNX_STRING, [edDatabase.Text]);
      Connection:= Database1;
      SQL.Add('SELECT t.CNK as code,LibF,LibN,PrixPublic,PrixPublic-((PrixPublic*RemisePC)/100) as remisePCT,');
      SQL.Add('       (PrixPublic-RemisePC) as RemisePx, PrixAchat, TypeRemise, st.StkRayon, st.stkCave, g.CodeBarre, RemisePC,');
      SQL.Add('       t.catAPBProd, t.Legislation, t.TempConservation, t.CodeLabo, t.pcTVA, t.Usage,');
      SQL.Add('       pe.DateDébutPromo, pe.DateFinPromo, pe.QtTotalePromo, pe.QtRestantePromo,');
      SQL.Add('       PrixPublic-((PrixPublic*pe.PCPromo)/100) as PromoPCT, pe.MontantPromo');
      SQL.Add('FROM tarSpe t LEFT OUTER JOIN AutresCodesBarresSpe g on g.cnk=t.cnk');
      SQL.Add('              LEFT OUTER JOIN stock st ON st.cnk=t.cnk');
      SQL.Add('              LEFT OUTER JOIN PromoDetail pd ON pd.valeur=t.cnk');
      SQL.Add('              LEFt OUTER JOIN PromoEntete pe ON pe.idPromoEntete=pd.idPromoEntete');
      SQL.Add('WHERE PrixPublic>0');
//      SQL.Add('SELECT t.CNK as code,LibF,PrixPublic,PrixPublic-((PrixPublic*RemisePC)/100) as remisePCT,');
//      SQL.Add('       (PrixPublic-RemisePC) as RemisePx, TypeRemise, st.StkRayon, st.stkCave, g.CodeBarre, RemisePC,');
//      SQL.Add('       t.catAPBProd, t.Legislation, t.TempConservation, t.CodeLabo, t.pcTVA, t.Usage, ');
//      SQL.Add('FROM tarSpe t LEFT OUTER JOIN AutresCodesBarresSpe g on g.cnk=t.cnk');
//      SQL.Add('              LEFT OUTER JOIN stock st');
//      SQL.Add('ON st.cnk=t.cnk');
//      SQL.Add('WHERE PrixPublic>0');
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

          begin
            if FieldByName('TypeRemise').AsInteger=3 then
              PrixRemise:= FieldByName('remisePCT').AsFloat
            else
            if FieldByName('TypeRemise').AsInteger=5 then
              PrixRemise:= FieldByName('RemisePx').AsFloat
            else PrixRemise:= 0;
          end;

          if  ( // test de la date de promo
               varIsNull(FieldByName('DateDébutPromo').Value) or
               (
                (FieldByName('DateDébutPromo').AsDateTime>=Date) and
                (FieldByName('DateFinPromo').AsDateTime<=Date)
               )
              ) or
              ( // test des qtés min/max
                (FieldByName('QtRestantePromo').AsInteger>0)
              )
          then
          begin
            OutputDebugString(pchar('on test si promo : ' + FieldByName('Code').AsString));
            if FieldByName('PromoPCT').AsFloat<>0 then
            begin
              OutputDebugString(pchar('promo en %'));
              PrixRemise:= FieldByName('PromoPCT').AsFloat;
              if FieldByName('PromoPCT').AsFloat>10 then
                formatEtiquette:= '3';
              if FieldByName('PromoPCT').AsFloat<=10 then
                formatEtiquette:= '4';
            end
            else
            if FieldByName('MontantPromo').AsFloat<>0 then
            begin
              OutputDebugString(pchar('promo en montant'));
              PrixRemise:= FieldByName('MontantPromo').AsFloat;
  //            if FieldByName('PromoPCT').AsFloat<>0 then
  //            begin
  //              if FieldByName('PromoPCT').AsFloat>10 then
  //                formatEtiquette:= '3';
  //              if FieldByName('PromoPCT').AsFloat<=10 then
  //                formatEtiquette:= '4';
  //            end;
            end
            else outputdebugstring('aucune promo pour ce produit');
          end;

          (*  Fichier MAJ WEB
          Cnk ; libellé F ; libellé N ; Catégorie APB ; Code législation ; Prix public (TvaC)
          ; Prix Achat (Htva) ; Code T° de conservation ; Code Labo ; Nom labo
          ; % TVA ; Code de ventilation ; Code Usage ; Produit avec Label APB
          ; produit Retiré du marché <RC>
          *)

          AddWebInfo(
                     FieldByName('code').AsString + ';' +
                     StringReplace(FieldByName('LibF').AsString, ',', '.', [rfReplaceAll]) + ';' +
                     StringReplace(FieldByName('LibN').AsString, ',', '.', [rfReplaceAll]) + ';' +
                     FieldByName('catAPBProd').AsString + ';' +
                     FieldByName('Legislation').AsString + ';' +
                     BoolToStr((PrixRemise=0) or
                               (FieldByName('PrixPublic').AsFloat=PrixRemise), '', DecimalStr(FormatFloat('0.00', PrixRemise))) + ';' +
                     DecimalStr(FormatFloat('0.00', FieldByName('PrixAchat').AsFloat)) + ';' +
                     FieldByName('TempConservation').AsString + ';' +
                     FieldByName('CodeLabo').AsString + ';;' +
                     DecimalStr(FormatFloat('0.00', FieldByName('PcTVA').AsFloat)) + ';' +
                     '0;' + FieldByName('Usage').AsString + ';;;'
                    );

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
      if chkMajPxWeb.checked then
      begin
        FileNameWeb:= ExtractFilePath(Complete(edDestPrixWeb.Text, '\'));
        FileNameWeb:= FileNameWeb + 'MajSiteWeb_' + FormatDateTime('YYYYMMDD', Date) + '.txt';
      end;
      if not FileExists(FileName) or (MessageDLG('le fichier existe déjà, voulez-vous continuer ? le fichier précédent sera écrasé', mtConfirmation, [mbYes, mbNo], 0)=mrYes) then
      begin
        Fichier.SaveToFile(FileName, TEncoding.ASCII);
        Fichier.Clear;
        if chkMajPxWeb.checked then
          FichierWeb.SaveToFile(FileNameWeb, TEncoding.ASCII);
        if not file_auto then Fichier.SaveToFile(FileName + '.done');
        if not file_auto then ShowMessage('Fichier créé avec succès');
      end
      else if not file_auto then ShowMessage('Abandon');
    finally
      Free;
      FreeAndNil(Fichier);
      if chkMajPxWeb.checked then
        FreeAndNil(FichierWeb);
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
  chkMajPxWeb.Checked:= True;
//  with TAdoQuery.Create(nil) do
//  try
//    Database1.Close;
//    DataBase1.ConnectionString:= Format(CNX_STRING, [edDatabase.Text]);
//    Connection:= Database1;
//    SQL.Add('UPDATE tarSpe SET PrixWeb=Round(PrixPublic-((PrixPublic*RemisePC)/100), 2)');
//    SQL.Add('WHERE RemisePC>0');
//    try
//      ExecSQL;
//      if not web_auto then MessageDLG('Les prix Web ont été mis à jour', mtConfirmation, [mbYes], 0);
//    except
//      on E: Exception do
//        if not web_auto then MessageDLG('Impossible de mettre à jour les prix Web : ' + e.Message,
//                   mtError, [mbYes], 0);
//    end;
//  finally
//    Free;
//  end;
//  if web_auto then Application.Terminate;
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
  v_config.DestinationFolderWeb:= edDestPrixWeb.Text;
  v_config.StockNull:= cbStockNull.Checked;
end;

procedure TForMainM2COMM.FormCreate(Sender: TObject);
begin
  Height:= 90;
  edDataBase.Text      := v_config.DataBaseFolder;
  edDestination.Text   := v_config.DestinationFolder;
  edDestPrixWeb.Text   := v_config.DestinationFolderWeb;
  if edDestPrixWeb.Text='' then
    edDestPrixWeb.Text:= edDestination.Text;
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

procedure TForMainM2COMM.Panel1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if ssCtrl in SHIFT then
  begin
    pnl1.Visible:= True;
    Height:= 291;
    Top   := Screen.Height - Height - 32;
  end;
end;

procedure TForMainM2COMM.spbDestPrixWebClick(Sender: TObject);
var Dossier: string;
begin
  if SelectDirectory('Choisir le chemin de destination', 'Dossier', Dossier) then
    edDestPrixWeb.Text:= Dossier;
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
