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
  Position = poMainFormCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object SplitterLeft: TSplitter
    Left = 185
    Top = 26
    Height = 478
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
    object LogTree: TVirtualStringTree
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 1178
      Height = 122
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
      OnDblClick = LogTreeDblClick
      Columns = <>
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
      Left = 291
      Top = 2
      Width = 69
      Height = 22
      Align = alNone
      Caption = 'ToolBar'
      DisabledImages = IDEData.ToolBarDisabledImages
      DrawingStyle = dsGradient
      Images = IDEData.ToolBarImages
      TabOrder = 0
      object btnRun: TToolButton
        Left = 0
        Top = 0
        Action = IDEActions.actRun
      end
      object btnPause: TToolButton
        Left = 23
        Top = 0
        Action = IDEActions.actPause
      end
      object btnStop: TToolButton
        Left = 46
        Top = 0
        Action = IDEActions.actStop
      end
    end
    object tbDebug: TToolBar
      Left = 373
      Top = 2
      Width = 69
      Height = 22
      AutoSize = True
      Caption = 'tbDebug'
      DisabledImages = IDEData.ToolBarDisabledImages
      DrawingStyle = dsGradient
      Images = IDEData.ToolBarImages
      TabOrder = 1
      object btnStep: TToolButton
        Left = 0
        Top = 0
        Action = IDEActions.actStep
      end
      object btnStepOver: TToolButton
        Left = 23
        Top = 0
        Action = IDEActions.actStepOver
      end
      object btnStepUntilReturn: TToolButton
        Left = 46
        Top = 0
        Action = IDEActions.actStepUntilReturn
      end
    end
    object tbFile: TToolBar
      Left = 11
      Top = 2
      Width = 69
      Height = 22
      Caption = 'tbFile'
      DisabledImages = IDEData.ToolBarDisabledImages
      DrawingStyle = dsGradient
      Images = IDEData.ToolBarImages
      TabOrder = 2
      object btnNewUnit: TToolButton
        Left = 0
        Top = 0
        Action = IDEActions.actNewUnit
      end
      object btnSave: TToolButton
        Left = 23
        Top = 0
        Action = IDEActions.actSaveActive
      end
      object btnSaveAll: TToolButton
        Left = 46
        Top = 0
        Action = IDEActions.actSaveAll
      end
    end
    object tbEdit: TToolBar
      Left = 93
      Top = 2
      Width = 124
      Height = 22
      AutoSize = True
      Caption = 'tbEdit'
      DisabledImages = IDEData.ToolBarDisabledImages
      DrawingStyle = dsGradient
      Images = IDEData.ToolBarImages
      TabOrder = 3
      object ToolButton1: TToolButton
        Left = 0
        Top = 0
        Action = IDEActions.actUndo
      end
      object ToolButton2: TToolButton
        Left = 23
        Top = 0
        Action = IDEActions.actRedo
      end
      object ToolButton3: TToolButton
        Left = 46
        Top = 0
        Width = 8
        Caption = 'ToolButton3'
        ImageIndex = 12
        Style = tbsSeparator
      end
      object btnCopy: TToolButton
        Left = 54
        Top = 0
        Action = IDEActions.actCopy
      end
      object btnCut: TToolButton
        Left = 77
        Top = 0
        Action = IDEActions.actCut
      end
      object btnPaste: TToolButton
        Left = 100
        Top = 0
        Action = IDEActions.actPaste
      end
    end
    object tbSearch: TToolBar
      Left = 230
      Top = 2
      Width = 48
      Height = 22
      Caption = 'tbSearch'
      DisabledImages = IDEData.ToolBarDisabledImages
      DrawingStyle = dsGradient
      Images = IDEData.ToolBarImages
      TabOrder = 4
      object ToolButton4: TToolButton
        Left = 0
        Top = 0
        Action = IDEActions.actFind
      end
      object ToolButton5: TToolButton
        Left = 23
        Top = 0
        Action = IDEActions.actReplace
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
          Action = IDEActions.actNewUnit
        end
        object miNewProject: TMenuItem
          Action = IDEActions.actNewProject
        end
      end
      object miOpen: TMenuItem
        Action = IDEActions.actOpenProject
      end
      object miSave: TMenuItem
        Action = IDEActions.actSaveActive
      end
      object miSaveAs: TMenuItem
        Action = IDEActions.actSaveActiveAs
      end
      object miSaveProjectAs: TMenuItem
        Action = IDEActions.actSaveProjectAs
      end
      object miSaveAll: TMenuItem
        Action = IDEActions.actSaveAll
      end
      object miExit: TMenuItem
        Action = IDEActions.actExit
      end
    end
    object Edit1: TMenuItem
      Caption = 'Edit'
      object Undo1: TMenuItem
        Action = IDEActions.actUndo
      end
      object Redo1: TMenuItem
        Action = IDEActions.actRedo
      end
      object Cut1: TMenuItem
        Action = IDEActions.actCut
      end
      object Copy1: TMenuItem
        Action = IDEActions.actCopy
      end
      object Paste1: TMenuItem
        Action = IDEActions.actPaste
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
        Action = IDEActions.actCompile
      end
      object miRun: TMenuItem
        Action = IDEActions.actRun
      end
      object miStop: TMenuItem
        Action = IDEActions.actStop
      end
      object miOptions: TMenuItem
        Action = IDEActions.actProjectOptions
      end
    end
    object Help1: TMenuItem
      Caption = 'Help'
      object About1: TMenuItem
        Action = IDEActions.actAbout
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
