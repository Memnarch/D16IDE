object ProjectView: TProjectView
  Left = 0
  Top = 0
  Caption = 'ProjectView'
  ClientHeight = 290
  ClientWidth = 244
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object ProjectTree: TVirtualStringTree
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 238
    Height = 284
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
  object ProjectPopup: TPopupMenu
    Left = 32
    Top = 232
    object NewUnit2: TMenuItem
      Caption = 'New Unit'
    end
    object AddUnit2: TMenuItem
      Caption = 'Add Existing Unit'
    end
    object Options3: TMenuItem
      Caption = 'Options'
    end
  end
  object UnitPopup: TPopupMenu
    Left = 32
    Top = 176
    object NewUnit1: TMenuItem
      Caption = 'New Unit'
    end
    object AddUnit1: TMenuItem
      Caption = 'Add Existing Unit'
    end
    object RemoveUnit1: TMenuItem
      Caption = 'Remove Unit'
    end
    object Options2: TMenuItem
      Caption = 'Options'
    end
  end
  object ActionList: TActionList
    Left = 120
    Top = 152
    object actRemoveSelectedUnit: TAction
      Caption = 'Remove from Project'
      OnExecute = actRemoveSelectedUnitExecute
    end
  end
end
