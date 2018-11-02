object Module: TModule
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 150
  Width = 215
  object cnxSQL: TADOConnection
    ConnectionString = 
      'Provider=MSDASQL.1;Persist Security Info=False;Extended Properti' +
      'es="Driver={SQLite3 ODBC Driver};Database=D:\Application\NextPha' +
      'rm\Win64\Debug\data\next.sqlite;UTF8Encoding=1;StepAPI=0;SyncPra' +
      'gma=NORMAL;NoTXN=0;Timeout=;ShortNames=0;LongNames=0;NoCreat=0;N' +
      'oWCHAR=0;FKSupport=0;JournalMode=;LoadExt=;"'
    LoginPrompt = False
    Provider = 'MSDASQL.1'
    Left = 80
    Top = 40
  end
end
