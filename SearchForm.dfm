object SimpleSearchForm: TSimpleSearchForm
  Left = 0
  Top = 0
  Width = 519
  Height = 36
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  ParentBackground = False
  ParentColor = False
  ParentFont = False
  TabOrder = 0
  object edFind: TEdit
    Left = 8
    Top = 8
    Width = 233
    Height = 21
    TabOrder = 0
    OnKeyPress = edFindKeyPress
  end
  object btnPrevious: TButton
    Left = 247
    Top = 6
    Width = 26
    Height = 25
    Caption = 'P'
    TabOrder = 1
    OnClick = btnPreviousClick
  end
  object btnNext: TButton
    Left = 279
    Top = 6
    Width = 26
    Height = 25
    Caption = 'N'
    TabOrder = 2
    OnClick = btnNextClick
  end
end
