inherited ioViewModel1: TioViewModel1
  inherited Commands: TActionList
    object acHello: TAction
      Caption = 'acHello'
      OnExecute = acHelloExecute
    end
    object acEnableDisable: TAction
      Caption = 'acEnableDisable'
      OnExecute = acEnableDisableExecute
    end
  end
  object FDQuery1: TFDQuery
    Left = 96
    Top = 88
  end
end
