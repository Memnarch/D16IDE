object IDEActions: TIDEActions
  OldCreateOrder = False
  Height = 98
  Width = 130
  object ActionList: TActionList
    Images = IDEData.ToolBarImages
    Left = 24
    Top = 14
    object actNewUnit: TAction
      Category = 'File'
      Caption = 'New Unit'
      ImageIndex = 6
      OnExecute = actNewUnitExecute
    end
    object actCloseUnitByTab: TAction
      Caption = 'Close'
      OnExecute = actCloseUnitByTabExecute
    end
    object actSaveActive: TAction
      Category = 'File'
      Caption = 'Save'
      ImageIndex = 7
      ShortCut = 16467
      OnExecute = actSaveActiveExecute
    end
    object actSaveActiveAs: TAction
      Category = 'File'
      Caption = 'Save as'
      OnExecute = actSaveActiveAsExecute
    end
    object actSaveAll: TAction
      Category = 'File'
      Caption = 'Save all'
      ImageIndex = 8
      OnExecute = actSaveAllExecute
    end
    object actSaveProjectAs: TAction
      Category = 'File'
      Caption = 'Save Project as'
      OnExecute = actSaveProjectAsExecute
    end
    object actNewProject: TAction
      Category = 'File'
      Caption = 'New Project'
      OnExecute = actNewProjectExecute
    end
    object actCompile: TAction
      Caption = 'Compile'
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
      ImageIndex = 0
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
    object actPause: TAction
      Caption = 'Pause'
      Enabled = False
      ImageIndex = 1
      OnExecute = actPauseExecute
    end
    object actStep: TAction
      Caption = 'actStep'
      Enabled = False
      ImageIndex = 3
      ShortCut = 118
      OnExecute = actStepExecute
    end
    object actStepOver: TAction
      Caption = 'actStepOver'
      Enabled = False
      ImageIndex = 4
      ShortCut = 119
      OnExecute = actStepOverExecute
    end
    object actStepUntilReturn: TAction
      Caption = 'actStepUntilReturn'
      Enabled = False
      ImageIndex = 5
      ShortCut = 8311
      OnExecute = actStepUntilReturnExecute
    end
    object actCopy: TAction
      Caption = 'Copy'
      ImageIndex = 9
      OnExecute = actCopyExecute
    end
    object actCut: TAction
      Caption = 'Cut'
      ImageIndex = 10
      OnExecute = actCutExecute
    end
    object actPaste: TAction
      Caption = 'Paste'
      ImageIndex = 11
      OnExecute = actPasteExecute
    end
    object actUndo: TAction
      Caption = 'Undo'
      ImageIndex = 12
      OnExecute = actUndoExecute
    end
    object actRedo: TAction
      Caption = 'Redo'
      ImageIndex = 13
      OnExecute = actRedoExecute
    end
    object actFind: TAction
      Caption = 'Find'
      ImageIndex = 14
      ShortCut = 16454
      OnExecute = actFindExecute
    end
    object actReplace: TAction
      Caption = 'Replace'
      ImageIndex = 15
    end
    object actFindNext: TAction
      Caption = 'actFindNext'
      ShortCut = 114
      OnExecute = actFindNextExecute
    end
    object actFindPrevious: TAction
      Caption = 'actFindPrevious'
      ShortCut = 8306
      OnExecute = actFindPreviousExecute
    end
    object actAbout: TAction
      Caption = 'About'
      OnExecute = actAboutExecute
    end
    object actRemoveUnitFromProject: TAction
      Caption = 'Remove Unit'
      OnExecute = actRemoveUnitFromProjectExecute
    end
    object actCheckForUpdates: TAction
      Caption = 'Check for updates...'
      OnExecute = actCheckForUpdatesExecute
    end
  end
end
