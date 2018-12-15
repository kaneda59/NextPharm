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
       FDestinationFolderWeb: string;
       FFmtZeroDisc: string;
       FFmtLTenDisc: string;
       FFmtMTenDisc: string;
       FMajPxWeb: Boolean;
       procedure Read;
       procedure Write;
     public
       constructor Create(const FileName: string); reintroduce;
       destructor Destroy; override;
     published
       property DataBaseFolder: string read FDataBaseFolder write FDatabaseFolder;
       property DestinationFolder: string read FDestinationFolder write FDestinationFolder;
       property DestinationFolderWeb: string read FDestinationFolderWeb write FDestinationFolderWeb;
       property FormatFileName: string read FFormatFileName write FFormatFileName;
       property StockNull: Boolean read FStockNull write FStockNull;
       property MajPxWeb: Boolean  read FMajPxWeb  write FMajPxWeb;
       property FmtZeroDisc: string read FFmtZeroDisc write FFmtZeroDisc;
       property FmtLTenDisc: string read FFmtLTenDisc write FFmtLTenDisc;
       property FmtMTenDisc: string read FFmtMTenDisc write FFmtMTenDisc;
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
  FDestinationFolderWeb:= Fic.ReadString('config', 'destinationWeb', '');
  FFormatFileName   := Fic.ReadString('config', 'formatfilename', 'products-%YYYYMMDD%-%HHNN%.csv');
  FStockNull        := Fic.ReadBool('config', 'stocknull', False);
  FMajPxWeb         := Fic.ReadBool('config', 'majpxweb', False);
  FFmtZeroDisc      := Fic.ReadString('config', 'FmtZeroDisc', '0');
  FFmtLTenDisc      := Fic.ReadString('config', 'FmtLTenDisc', '4');
  FFmtMTenDisc      := Fic.ReadString('config', 'FmtMTenDisc', '6');
end;

procedure TConfiguration.Write;
begin
  Fic.WriteString('config', 'database',       FDataBaseFolder);
  Fic.WriteString('config', 'destination',    FDestinationFolder);
  Fic.WriteString('config', 'destinationWeb', FDestinationFolderWeb);
  Fic.WriteString('config', 'formatfilename', FFormatFileName);
  Fic.WriteBool  ('config', 'stocknull',      FStocknull);
  Fic.WriteBool  ('config', 'majpxweb',       FMajPxWeb);
  Fic.WriteString('config', 'FmtZeroDisc', FFmtZeroDisc);
  Fic.WriteString('config', 'FmtLTenDisc', FFmtLTenDisc);
  Fic.WriteString('config', 'FmtMTenDisc', FFmtMTenDisc);
end;

initialization

  v_config:= TConfiguration.Create(ChangeFileExt(ParamStr(0), '.config'));

finalization

  FreeAndnil(v_config);

end.
