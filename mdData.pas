unit mdData;

interface

uses
  System.SysUtils, System.Classes, Data.DB, Data.Win.ADODB;

type
  TModule = class(TDataModule)
    cnxSQL: TADOConnection;
  private
    { Déclarations privées }
    procedure PrepareDataBase;
    procedure PrepareData;
    function TableExists(const TableName: string): Boolean;
    function ColumnExists(const TableName, ColumnName: string): Boolean;
    procedure CheckField(const TableName, FieldName, script: string);
    procedure CreateTable(const TableName: string);
    function FindField(const TableName_, FieldName_: string): Boolean;
  public
    { Déclarations publiques }
    function PrepareConnection: Boolean;
    function AddSQLQuery: TADoQuery;
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
  result:= False;
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
  result:= False;
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

procedure TModule.CreateTable(const TableName: string);
begin
  try
    q.ExecSQL;
  except
    on E: Exception do
      EcrireLogFile('Erreur lors de la création de la table ' + TableName + ' : ' + E.Message);
  end;
end;

procedure TModule.CheckField(const TableName, FieldName: string; const script: string);
begin
  if not FindField(TableName, FieldName) then
  begin
    q.SQL.Clear;
    q.SQL.Add('alter table "' + TableName + '"');
    q.SQL.Add(script);
    try
      q.ExecSQL;
    except
      on E: Exception do
        EcrireLogFile('erreur lors de la mise à jour de la table ' + TableName + ' sur le champ ' + FieldName + ' : ' + e.Message);
    end;
  end;
end;

procedure TModule.PrepareDataBase;
begin
  if not TableExists('sessions') then
  begin
    q.SQL.Add('CREATE TABLE "sessions" (');
    q.SQL.Add('"id"          INTEGER PRIMARY KEY NOT NULL,');
    q.SQL.Add('"date_open"   DATETIME,');
    q.SQL.Add('"date_close"  DATETIME,');
    q.SQL.Add('"NIUSER"      INTEGER,');
    q.SQL.Add('"MATRICULE"   VARCHAR(125)');
    q.SQL.Add(')');
    CreateTable('sessions');
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
  DataPath:= ExtractFilePath(ParamStr(0)) + 'data\';
  ForceDirectories(DataPath);
  FileDataBase:= DataPath + 'next.sqlite';
  if not FileExists(FileDataBase) then
  with TStringList.Create do
  try
    SaveToFile(FileDataBase);
    PrepareDataBase;
  finally
    Free;
  end;
  cnx_string:= 'Provider=MSDASQL.1;Persist Security Info=False;Extended Properties="Driver={SQLite3 ODBC Driver};' +
               'Database=[filename];UTF8Encoding=1;StepAPI=0;SyncPragma=NORMAL;NoTXN=0;Timeout=;ShortNames=1;' +
               'LongNames=1;NoCreat=0;NoWCHAR=0;FKSupport=0;JournalMode=;LoadExt=;"';
  cnx_string:= StringReplace(cnx_string, '[filename]', FileDataBase);
  cnxSQL.Close;
  cnxSQL.ConnectionString:= cnx_string;
  try
    cnxSQL.Open();
  except
    on E: Exception do
    begin

    end;
  end;
end;

procedure TModule.PrepareData;
begin

end;

end.
