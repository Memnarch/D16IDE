object CPUView: TCPUView
  AlignWithMargins = True
  Left = 0
  Top = 0
  BorderStyle = bsSizeToolWin
  Caption = 'CPUView'
  ClientHeight = 306
  ClientWidth = 174
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object RegisterList: TValueListEditor
    Left = 0
    Top = 0
    Width = 174
    Height = 257
    Align = alTop
    Strings.Strings = (
      'A='
      'B='
      'C='
      'X='
      'Y='
      'Z='
      'I='
      'J='
      'EX='
      'SP='
      'PC='
      'IA=')
    TabOrder = 0
    TitleCaptions.Strings = (
      'Register'
      'Value')
    ExplicitWidth = 165
    ColWidths = (
      69
      99)
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 257
    Width = 174
    Height = 40
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitTop = 265
    ExplicitWidth = 296
    object Label3: TLabel
      Left = 6
      Top = 6
      Width = 36
      Height = 13
      Caption = 'Queue:'
    end
    object lbQueue: TLabel
      Left = 62
      Top = 6
      Width = 41
      Height = 13
      AutoSize = False
      Caption = '0'
    end
    object Label4: TLabel
      Left = 6
      Top = 25
      Width = 35
      Height = 13
      Caption = 'Cycles:'
    end
    object lbCycles: TLabel
      Left = 62
      Top = 25
      Width = 41
      Height = 13
      AutoSize = False
      Caption = '0'
    end
  end
end
