object CPUView: TCPUView
  AlignWithMargins = True
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'CPUView'
  ClientHeight = 686
  ClientWidth = 312
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 0
    Top = 177
    Width = 312
    Height = 13
    Align = alTop
    Caption = 'Assembler:'
    ExplicitWidth = 53
  end
  object RegisterList: TValueListEditor
    Left = 0
    Top = 0
    Width = 312
    Height = 177
    Align = alTop
    Strings.Strings = (
      'A='
      'B='
      'C='
      'X='
      'Y='
      'Z='
      'I='
      'J=')
    TabOrder = 0
    TitleCaptions.Strings = (
      'Register'
      'Value')
    ColWidths = (
      150
      156)
  end
  object ASMView: TListBox
    Left = 0
    Top = 190
    Width = 312
    Height = 410
    Align = alClient
    BevelInner = bvNone
    BevelOuter = bvNone
    ItemHeight = 13
    TabOrder = 1
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 600
    Width = 312
    Height = 86
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    ExplicitLeft = 8
    ExplicitTop = 606
    object Label7: TLabel
      Left = 16
      Top = 6
      Width = 17
      Height = 13
      Caption = 'PC:'
    end
    object Label2: TLabel
      Left = 16
      Top = 25
      Width = 15
      Height = 13
      Caption = 'IA:'
    end
    object Label3: TLabel
      Left = 86
      Top = 6
      Width = 36
      Height = 13
      Caption = 'Queue:'
    end
    object lbPC: TLabel
      Left = 39
      Top = 6
      Width = 41
      Height = 13
      AutoSize = False
      Caption = '0'
    end
    object lbIA: TLabel
      Left = 39
      Top = 25
      Width = 41
      Height = 13
      AutoSize = False
      Caption = '0'
    end
    object lbQueue: TLabel
      Left = 142
      Top = 6
      Width = 41
      Height = 13
      AutoSize = False
      Caption = '0'
    end
    object Label4: TLabel
      Left = 86
      Top = 25
      Width = 35
      Height = 13
      Caption = 'Cycles:'
    end
    object lbCycles: TLabel
      Left = 142
      Top = 25
      Width = 41
      Height = 13
      AutoSize = False
      Caption = '0'
    end
  end
end
