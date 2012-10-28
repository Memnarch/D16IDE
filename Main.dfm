object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'D16IDE'
  ClientHeight = 635
  ClientWidth = 1184
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object SplitterLeft: TSplitter
    Left = 185
    Top = 26
    Height = 478
    ExplicitLeft = 480
    ExplicitTop = 296
    ExplicitHeight = 100
  end
  object SplitterRight: TSplitter
    Left = 996
    Top = 26
    Height = 478
    Align = alRight
    ExplicitLeft = 764
    ExplicitTop = 35
    ExplicitHeight = 606
  end
  object Splitter1: TSplitter
    Left = 0
    Top = 504
    Width = 1184
    Height = 3
    Cursor = crVSplit
    Align = alBottom
    ExplicitLeft = 185
    ExplicitTop = 29
    ExplicitWidth = 565
  end
  object plLeft: TPanel
    Left = 0
    Top = 26
    Width = 185
    Height = 478
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitTop = 57
    ExplicitHeight = 447
    object CodeTree: TVirtualStringTree
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 179
      Height = 472
      Align = alClient
      Header.AutoSizeIndex = 0
      Header.DefaultHeight = 17
      Header.Font.Charset = DEFAULT_CHARSET
      Header.Font.Color = clWindowText
      Header.Font.Height = -11
      Header.Font.Name = 'Tahoma'
      Header.Font.Style = []
      Header.MainColumn = -1
      TabOrder = 0
      OnDblClick = CodeTreeDblClick
      OnGetText = CodeTreeGetText
      ExplicitHeight = 441
      Columns = <>
    end
  end
  object plRight: TPanel
    Left = 999
    Top = 26
    Width = 185
    Height = 478
    Align = alRight
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitTop = 57
    ExplicitHeight = 447
    object ProjectTree: TVirtualStringTree
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 179
      Height = 472
      Align = alClient
      Header.AutoSizeIndex = 0
      Header.DefaultHeight = 17
      Header.Font.Charset = DEFAULT_CHARSET
      Header.Font.Color = clWindowText
      Header.Font.Height = -11
      Header.Font.Name = 'Tahoma'
      Header.Font.Style = []
      Header.MainColumn = -1
      TabOrder = 0
      TreeOptions.AutoOptions = [toAutoDropExpand, toAutoExpand, toAutoScrollOnExpand, toAutoTristateTracking, toAutoDeleteMovedNodes]
      TreeOptions.SelectionOptions = [toRightClickSelect]
      OnContextPopup = ProjectTreeContextPopup
      OnDblClick = ProjectTreeDblClick
      ExplicitHeight = 441
      Columns = <>
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 507
    Width = 1184
    Height = 128
    Align = alBottom
    BevelOuter = bvNone
    Caption = 'Panel1'
    TabOrder = 2
    object Log: TSynMemo
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 1178
      Height = 122
      Align = alClient
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Style = []
      TabOrder = 0
      Gutter.Font.Charset = DEFAULT_CHARSET
      Gutter.Font.Color = clWindowText
      Gutter.Font.Height = -11
      Gutter.Font.Name = 'Courier New'
      Gutter.Font.Style = []
      Options = [eoAutoIndent, eoDragDropEditing, eoEnhanceEndKey, eoGroupUndo, eoNoCaret, eoScrollPastEol, eoShowScrollHint, eoSmartTabDelete, eoSmartTabs, eoTabsToSpaces]
      ReadOnly = True
      RightEdgeColor = clWhite
      ScrollBars = ssVertical
      FontSmoothing = fsmNone
    end
  end
  object PageControl: TJvPageControl
    AlignWithMargins = True
    Left = 191
    Top = 29
    Width = 802
    Height = 472
    Align = alClient
    TabOrder = 3
    OnContextPopup = PageControlContextPopup
    ExplicitLeft = 188
    ExplicitTop = 57
    ExplicitWidth = 808
    ExplicitHeight = 447
  end
  object ControlBar: TControlBar
    Left = 0
    Top = 0
    Width = 1184
    Height = 26
    Align = alTop
    AutoSize = True
    BevelInner = bvNone
    BevelKind = bkNone
    DrawingStyle = dsGradient
    TabOrder = 4
    object tbRun: TToolBar
      Left = 12
      Top = 2
      Width = 69
      Height = 22
      Align = alNone
      Caption = 'ToolBar'
      DrawingStyle = dsGradient
      Images = IDEData.ToolBarImages
      TabOrder = 0
      object btnCompile: TToolButton
        Left = 0
        Top = 0
        Caption = 'Compile'
        ImageIndex = 0
      end
      object btnRun: TToolButton
        Left = 23
        Top = 0
        Caption = 'Run'
        ImageIndex = 1
      end
      object btnStop: TToolButton
        Left = 46
        Top = 0
        Caption = 'Stop'
        Enabled = False
        ImageIndex = 2
      end
    end
  end
  object MainMenu: TMainMenu
    Left = 216
    Top = 112
    object File1: TMenuItem
      Caption = 'File'
      object New1: TMenuItem
        Caption = 'New'
        object miNewUnit: TMenuItem
          Caption = 'New Unit'
        end
        object miNewProject: TMenuItem
          Caption = 'New Project'
        end
      end
      object miOpen: TMenuItem
        Caption = 'Open Project'
      end
      object miSave: TMenuItem
        Caption = 'Save'
        ShortCut = 16467
      end
      object miSaveAs: TMenuItem
        Caption = 'Save as'
      end
      object miSaveProjectAs: TMenuItem
        Caption = 'Save Project as'
      end
      object miSaveAll: TMenuItem
        Caption = 'Save all'
      end
      object miExit: TMenuItem
        Caption = 'Exit'
      end
    end
    object Edit1: TMenuItem
      Caption = 'Edit'
      object Undo1: TMenuItem
        Caption = 'Undo'
      end
      object Redo1: TMenuItem
        Caption = 'Redo'
      end
      object Cut1: TMenuItem
        Caption = 'Cut'
      end
      object Copy1: TMenuItem
        Caption = 'Copy'
      end
      object Paste1: TMenuItem
        Caption = 'Paste'
      end
    end
    object Search1: TMenuItem
      Caption = 'Search'
      object Find1: TMenuItem
        Caption = 'Find'
      end
      object Replace1: TMenuItem
        Caption = 'Replace'
      end
    end
    object Project1: TMenuItem
      Caption = 'Project'
      object miCompile: TMenuItem
        Caption = 'Compile'
        ImageIndex = 0
        ShortCut = 16504
      end
      object miRun: TMenuItem
        Caption = 'Run'
        ImageIndex = 1
        ShortCut = 120
      end
      object miStop: TMenuItem
        Caption = 'Stop'
        Enabled = False
        ImageIndex = 2
        ShortCut = 16497
      end
      object miOptions: TMenuItem
        Caption = 'Options'
      end
    end
    object Help1: TMenuItem
      Caption = 'Help'
      object About1: TMenuItem
        Caption = 'About'
      end
    end
  end
  object SynCompletionProposal: TSynCompletionProposal
    Options = [scoLimitToMatchedText, scoUseInsertList, scoUsePrettyText, scoUseBuiltInTimer, scoEndCharCompletion, scoCompleteWithTab, scoCompleteWithEnter]
    Width = 480
    EndOfTokenChr = '()[]. '
    TriggerChars = '.'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = []
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clBtnText
    TitleFont.Height = -11
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = [fsBold]
    Columns = <
      item
        BiggestWord = 'CONSTRUCTOR'
      end
      item
        BiggestWord = 'CONSTRUCTOR'
      end>
    OnExecute = SynCompletionProposalExecute
    ShortCut = 16416
    TimerInterval = 250
    Left = 368
    Top = 304
  end
end
