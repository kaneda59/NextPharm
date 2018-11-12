unit mdData;

interface

uses
  Forms, Windows, System.SysUtils, System.Classes, Data.DB, Data.Win.ADODB,
  vcl.Samples.Gauges;

type
  TProductInfo = record
    cnk: string;
    libf: string;
  end;

  TModule = class(TDataModule)
    cnxSQL: TADOConnection;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    { Déclarations privées }
    FProd: TStringList;
    procedure PrepareDataBase;
    procedure CheckField(const TableName, FieldName, script: string);
    procedure CreateTable(q: TAdoQuery; const TableName: string);
    function FindField(const TableName_, FieldName_: string): Boolean;
    function getProductInformation(const value: string): TProductInfo;
  public
    { Déclarations publiques }
    function TableExists(const TableName: string): Boolean;
    function ColumnExists(const TableName, ColumnName: string): Boolean;
    function PrepareConnection: Boolean;
    function AddSQLQuery: TADoQuery;
    function FindMedication(const cnk: integer): Boolean;
    function AddMedication(const cnk: integer; const libF: string): Boolean;
    function ImportCSVFile(const FileName: string; const gg: TGauge = nil): Boolean;
  end;

var
  Module: TModule;
  DataPath: string = '';

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ TModule }

function TModule.ColumnExists(const TableName, ColumnName: string): Boolean;
var qr: TAdoQuery;
begin
  //result:= False;
  qr:= AddSQLQuery;
  try
    qr.SQL.Add('select sql from sqlite_master where name= :name');
    qr.Parameters.ParamByName('name').Value:= TableName;
    qr.Open;
    result:= pos(UpperCase(ColumnName), UpperCase(qr.FieldByName('sql').AsString))>0;
    qr.Close;
  finally
    FreeAndNil(qr);
  end;
end;

function TModule.TableExists(const TableName: string): Boolean;
var q: TAdoQuery;
begin
  //result:= False;
  q:= AddSQLQuery;
  try
    q.SQL.Add('SELECT name FROM sqlite_master WHERE type=' + QuotedStr('table') + ' AND name=' + QuotedStr(tablename));
    q.Open;
    result:= UpperCase(q.FieldByName('name').AsString) = UpperCase(TableName);
    q.Close;
  finally
    FreeAndnil(q);
  end;
end;

function TModule.FindField(const TableName_, FieldName_: string): Boolean;
begin
  with AddSQLQuery do
  try
    SQL.clear;
    SQL.Add('select * from ' + TableName_ + ' where 1=2');
    Open;
    result:= Assigned(FindField(FieldName_));
    Close;
  finally
    Free;
  end;
end;

function TModule.FindMedication(const cnk: integer): Boolean;
begin
  //result:= False;
  with AddSQLQuery do
  try
    SQL.Add('SELECT * FROM histostock WHERE cnk=' + intToStr(cnk));
    Open;
    result:= FieldByName('cnk').AsInteger=cnk;
    Close;
  finally
    Free;
  end;
end;

function TModule.getProductInformation(const value: string): TProductInfo;
//var i: integer;
begin
  FillChar(result, SizeOf(result), 0);
  FProd.DelimitedText:= Value;
  if FProd.Count>0 then
  begin
    if FProd.Count>1 then result.cnk:= FProd[1];
    if FProd.Count>4 then result.libf:= FProd[4];
  end;
end;

function TModule.ImportCSVFile(const FileName: string; const gg: TGauge = nil): Boolean;
var i: integer;
    cnks: TStringList;
    pf: TProductInfo;
    nb: integer;
begin
  result:= False;
  if FileExists(FileName) then
  begin
    cnks:= TStringList.Create;
    with TStringList.Create do
    try
      LoadFromFile(FileName);
      for i := 0 to Count-1 do
      begin
        pf:= getProductInformation(Strings[i]);
        if (pf.cnk<>'') and (cnks.IndexOfName(pf.cnk)<0) then
          cnks.Add(pf.cnk + '=' + pf.libf);
      end;
      nb:= 0;
      if assigned(gg) then
      begin
        gg.MinValue:= 0;
        gg.MaxValue:= cnks.Count;
        gg.Progress:= 0;
      end;
      for i := 0 to cnks.Count-1 do
      begin
        if not AddMedication(strToInt(cnks.Names[i]), cnks.Values[cnks.Names[i]]) then
        begin
          if assigned(gg) then gg.Progress:= gg.Progress + 1;
          Application.processMessages;

          continue;
        end
        else Inc(nb);
        if assigned(gg) then gg.Progress:= gg.Progress + 1;
        Application.processMessages;
      end;
      if assigned(gg) then gg.Progress:= 0;
    finally
      Free;
      FreeAndNil(cnks);
    end;
    result:= nb>0;
  end;
end;

procedure TModule.CreateTable(q: TAdoQuery; const TableName: string);
begin
  try
    q.ExecSQL;
  except
    on E: Exception do
      outputdebugstring(Pchar('Erreur lors de la création de la table ' + TableName + ' : ' + E.Message));
  end;
end;

procedure TModule.DataModuleCreate(Sender: TObject);
begin
  FProd:= TStringList.create;
  FProd.StrictDelimiter:= True;
  FProd.Delimiter:= ',';
end;

procedure TModule.DataModuleDestroy(Sender: TObject);
begin
  FreeAndNil(FProd);
end;

procedure TModule.CheckField(const TableName, FieldName: string; const script: string);
begin
  if not FindField(TableName, FieldName) then
  with AddSQLQuery do
  try
    SQL.Clear;
    SQL.Add('alter table "' + TableName + '"');
    SQL.Add(script);
    try
      ExecSQL;
    except
      on E: Exception do
        outputdebugstring(pchar('erreur lors de la mise à jour de la table ' + TableName + ' sur le champ ' + FieldName + ' : ' + e.Message));
    end;
  finally
    Free;
  end;
end;

procedure TModule.PrepareDataBase;
var q: TAdoQuery;
begin
  q:= AddSQLQuery;
  try
  if not TableExists('histoStock') then
  begin

    q.SQL.Add('CREATE TABLE "histostock" (');
    q.SQL.Add('"cnk"         INTEGER PRIMARY KEY NOT NULL,');
    q.SQL.Add('"LibF"        VARCHAR(255)');
    q.SQL.Add(')');

    CreateTable(q, 'histostock');
  end;
  CheckField('histostock', 'LibF', 'ADD "LibF" VARCHAR(255)');
  finally
    FreeAndNil(q);
  end;
end;

function TModule.AddMedication(const cnk: integer; const libF: string): Boolean;
var Lb: string;
begin
  result:= False;
  if not FindMedication(cnk) then
  with AddSQLQuery do
  try
    lb:= LibF;
    if Length(lb)>255 then
      lb:= Copy(LibF,1,255);
    SQL.Add('INSERT INTO histostock');
    SQL.Add('(cnk, libF)');
    SQL.Add('VALUES');
    SQL.Add('(' + intToStr(cnk) + ', ' + QuotedStr(Lb) + ')');
    try
      ExecSQL;
      Result:= True;
    except
      on E: Exception do
        outputdebugstring(pchar('erreur lors de l''ajout : ' + intToStr(cnk) + ' = ' + e.Message));
    end;
  finally
    Free;
  end;
end;

function TModule.AddSQLQuery: TADoQuery;
begin
  result:= TAdoQuery.Create(nil);
  result.Connection:= cnxSQL;
  result.SQL.Clear;
end;

function TModule.PrepareConnection: Boolean;
var cnx_string: string;
    FileDataBase: string;
begin
  Result:= False;
  DataPath:= ExtractFilePath(ParamStr(0)) + 'data\';
  ForceDirectories(DataPath);
  FileDataBase:= DataPath + 'next.sqlite';
  if not FileExists(FileDataBase) then
  with TStringList.Create do
  try
    SaveToFile(FileDataBase);
  finally
    Free;
  end;
  cnx_string:= 'Provider=MSDASQL.1;Persist Security Info=False;Extended Properties="Driver={SQLite3 ODBC Driver};' +
               'Database=[filename];UTF8Encoding=1;StepAPI=0;SyncPragma=NORMAL;NoTXN=0;Timeout=;ShortNames=0;' +
               'LongNames=0;NoCreat=0;NoWCHAR=0;FKSupport=0;JournalMode=;LoadExt=;"';
  cnx_string:= StringReplace(cnx_string, '[filename]', FileDataBase, [rfReplaceAll]);
  cnxSQL.Close;
  cnxSQL.ConnectionString:= cnx_string;
  try
    cnxSQL.Open();
    result:= cnxSQL.Connected;
    if result then
      PrepareDataBase;
  except
    on E: Exception do
    begin
      outputdebugstring(pchar('erreur connexion : ' + e.Message));
    end;
  end;
end;

end.
