object ProjectOption: TProjectOption
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'ProjectOption'
  ClientHeight = 172
  ClientWidth = 328
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object cbOptimize: TCheckBox
    Left = 8
    Top = 8
    Width = 97
    Height = 17
    Caption = 'Optimize'
    TabOrder = 0
  end
  object cbAssemble: TCheckBox
    Left = 8
    Top = 31
    Width = 97
    Height = 17
    Caption = 'Assemble'
    TabOrder = 1
  end
  object cbBuildModule: TCheckBox
    Left = 8
    Top = 54
    Width = 97
    Height = 17
    Caption = 'Build Module'
    TabOrder = 2
  end
  object cbUseBigEndian: TCheckBox
    Left = 8
    Top = 77
    Width = 97
    Height = 17
    Caption = 'Use BigEndian'
    TabOrder = 3
  end
  object Button1: TButton
    Left = 245
    Top = 139
    Width = 75
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 4
  end
  object Button2: TButton
    Left = 164
    Top = 139
    Width = 75
    Height = 25
    Caption = 'Ok'
    ModalResult = 1
    TabOrder = 5
  end
end
