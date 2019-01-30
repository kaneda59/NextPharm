object ForScript: TForScript
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = 'HF-SQL Editor'
  ClientHeight = 582
  ClientWidth = 734
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 169
    Width = 734
    Height = 3
    Cursor = crVSplit
    Align = alTop
    ExplicitTop = 130
    ExplicitWidth = 351
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 734
    Height = 41
    Align = alTop
    BevelInner = bvLowered
    TabOrder = 0
    object Button1: TButton
      Tag = 100
      Left = 8
      Top = 8
      Width = 75
      Height = 25
      Cursor = crHandPoint
      Caption = 'New'
      TabOrder = 0
      OnClick = ActionClick
    end
    object Button2: TButton
      Tag = 101
      Left = 88
      Top = 8
      Width = 75
      Height = 25
      Cursor = crHandPoint
      Caption = 'Open'
      TabOrder = 1
      OnClick = ActionClick
    end
    object Button3: TButton
      Tag = 102
      Left = 168
      Top = 8
      Width = 75
      Height = 25
      Cursor = crHandPoint
      Caption = 'Save'
      TabOrder = 2
      OnClick = ActionClick
    end
    object Button4: TButton
      Tag = 103
      Left = 248
      Top = 8
      Width = 75
      Height = 25
      Cursor = crHandPoint
      Caption = 'Execute'
      TabOrder = 3
      OnClick = ActionClick
    end
  end
  object Script: TMemo
    Left = 0
    Top = 41
    Width = 734
    Height = 128
    Align = alTop
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
  end
  object DBGrid1: TDBGrid
    Left = 0
    Top = 172
    Width = 734
    Height = 391
    Align = alClient
    DataSource = dsQuery
    TabOrder = 2
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 563
    Width = 734
    Height = 19
    Panels = <>
  end
  object dsQuery: TDataSource
    DataSet = qryScript
    Left = 328
    Top = 232
  end
  object qryScript: TADOQuery
    Connection = ForMainM2COMM.Database1
    Parameters = <>
    Left = 264
    Top = 304
  end
end
