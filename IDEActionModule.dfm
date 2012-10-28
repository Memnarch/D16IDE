object IDEActions: TIDEActions
  OldCreateOrder = False
  Height = 98
  Width = 130
  object ActionList: TActionList
    Left = 24
    Top = 14
    object actNewUnit: TAction
      Caption = 'New Unit'
      OnExecute = actNewUnitExecute
    end
    object actCloseUnitByTab: TAction
      Caption = 'Close'
      OnExecute = actCloseUnitByTabExecute
    end
    object actSaveActive: TAction
      Caption = 'Save'
      ShortCut = 16467
      OnExecute = actSaveActiveExecute
    end
    object actSaveActiveAs: TAction
      Caption = 'Save as'
      OnExecute = actSaveActiveAsExecute
    end
    object actSaveAll: TAction
      Caption = 'Save all'
      OnExecute = actSaveAllExecute
    end
    object actSaveProjectAs: TAction
      Caption = 'Save Project as'
      OnExecute = actSaveProjectAsExecute
    end
    object actNewProject: TAction
      Caption = 'New Project'
      OnExecute = actNewProjectExecute
    end
    object actCompile: TAction
      Caption = 'Compile'
      ImageIndex = 0
      ShortCut = 16504
      OnExecute = actCompileExecute
    end
    object actOpenProject: TAction
      Caption = 'Open Project'
      OnExecute = actOpenProjectExecute
    end
    object actAddExistingUnit: TAction
      Caption = 'Add Existing Unit'
      OnExecute = actAddExistingUnitExecute
    end
    object actProjectOptions: TAction
      Caption = 'Options'
      OnExecute = actProjectOptionsExecute
    end
    object actPeekCompile: TAction
      Caption = 'Peek Compile'
      OnExecute = actPeekCompileExecute
    end
    object actRun: TAction
      Caption = 'Run'
      ImageIndex = 1
      ShortCut = 120
      OnExecute = actRunExecute
    end
    object actStop: TAction
      Caption = 'Stop'
      Enabled = False
      ImageIndex = 2
      ShortCut = 16497
      OnExecute = actStopExecute
    end
    object actExit: TAction
      Caption = 'Exit'
      OnExecute = actExitExecute
    end
  end
end
