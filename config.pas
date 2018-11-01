unit config;

{$M+}

interface

  uses Windows, SysUtils, Classes, iniFiles;

type TConfiguration = class
     private
       Fic: TIniFile;
       FDestinationFolder: string;
       FFormatFileName: string;
       FDataBaseFolder: string;
       FStockNull: Boolean;
       procedure Read;
       procedure Write;
     public
       constructor Create(const FileName: string); reintroduce;
       destructor Destroy; override;
     published
       property DataBaseFolder: string read FDataBaseFolder write FDatabaseFolder;
       property DestinationFolder: string read FDestinationFolder write FDestinationFolder;
       property FormatFileName: string read FFormatFileName write FFormatFileName;
       property StockNull: Boolean read FStockNull write FStockNull;
     end;

     var v_config: TConfiguration = nil;

implementation

{ TConfiguration }

constructor TConfiguration.Create(const FileName: string);
begin
  inherited Create;
  Fic:= TIniFile.Create(FileName);
  Read;
end;

destructor TConfiguration.Destroy;
begin
  Write;
  FreeAndNil(Fic);
  inherited;
end;

procedure TConfiguration.Read;
begin
  FDataBaseFolder   := Fic.ReadString('config', 'database', '');
  FDestinationFolder:= Fic.ReadString('config', 'destination', '');
  FFormatFileName   := Fic.ReadString('config', 'formatfilename', 'products-%YYYYMMDD%-%HHNN%.csv');
  FStockNull        := Fic.ReadBool('config', 'stocknull', False);
end;

procedure TConfiguration.Write;
begin
  Fic.WriteString('config', 'database', FDataBaseFolder);
  Fic.WriteString('config', 'destination', FDestinationFolder);
  Fic.WriteString('config', 'formatfilename', FFormatFileName);
  Fic.WriteBool('config', 'stocknull', FStocknull);
end;

initialization

  v_config:= TConfiguration.Create(ChangeFileExt(ParamStr(0), '.config'));

finalization

  FreeAndnil(v_config);

end.
