inherited ioViewModel1: TioViewModel1
  inherited Commands: TActionList
    object acHello: TAction
      Caption = 'Hello'
      OnExecute = acHelloExecute
    end
    object acEnableDisable: TAction
      Caption = 'On/Off'
      OnExecute = acEnableDisableExecute
    end
  end
  object FDQuery1: TFDQuery
    Left = 96
    Top = 88
  end
end
