object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'frmMain'
  ClientHeight = 397
  ClientWidth = 852
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 16
    Top = 8
    Width = 209
    Height = 25
    Action = DataModule2.acCiao
    TabOrder = 0
  end
  object Button2: TButton
    Left = 240
    Top = 8
    Width = 209
    Height = 25
    Caption = 'Enable/Disable'
    TabOrder = 1
  end
  object Button3: TButton
    Left = 16
    Top = 56
    Width = 209
    Height = 25
    Caption = 'acHelloDM1 (command)'
    TabOrder = 2
  end
  object Button4: TButton
    Left = 240
    Top = 56
    Width = 209
    Height = 25
    Caption = 'Connect/Disconnect'
    TabOrder = 3
  end
  object Button5: TButton
    Left = 464
    Top = 8
    Width = 89
    Height = 25
    Caption = 'Create 1'
    TabOrder = 4
    OnClick = Button5Click
  end
  object Button6: TButton
    Left = 559
    Top = 8
    Width = 89
    Height = 25
    Caption = 'Create 2'
    TabOrder = 5
    OnClick = Button6Click
  end
  object Button7: TButton
    Left = 16
    Top = 136
    Width = 209
    Height = 25
    Caption = 'Create form 2'
    TabOrder = 6
    OnClick = Button7Click
  end
  object Button8: TButton
    Left = 16
    Top = 216
    Width = 209
    Height = 25
    Caption = 'Get interface type data'
    TabOrder = 7
    OnClick = Button8Click
  end
  object Button9: TButton
    Left = 240
    Top = 216
    Width = 209
    Height = 25
    Caption = 'Get interface variable data'
    TabOrder = 8
    OnClick = Button9Click
  end
  object Button10: TButton
    Left = 16
    Top = 280
    Width = 209
    Height = 25
    Caption = 'DI abbaia'
    TabOrder = 9
    OnClick = Button10Click
  end
  object Button11: TButton
    Left = 712
    Top = 8
    Width = 137
    Height = 25
    Caption = 'Acquire critical section'
    TabOrder = 10
    OnClick = Button11Click
  end
  object Button12: TButton
    Left = 712
    Top = 39
    Width = 137
    Height = 25
    Caption = 'Release critical section'
    TabOrder = 11
    OnClick = Button12Click
  end
  object ButtonHello: TButton
    Left = 712
    Top = 142
    Width = 137
    Height = 25
    Caption = 'Hello (ViewModel)'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 12
  end
  object ButtonHelloEnableDisable: TButton
    Left = 712
    Top = 173
    Width = 137
    Height = 25
    Caption = 'Hello (Enable/Disable)'
    TabOrder = 13
  end
  object Button13: TButton
    Left = 478
    Top = 280
    Width = 147
    Height = 25
    Caption = 'Persist a dog'
    TabOrder = 14
    OnClick = Button13Click
  end
  object Button14: TButton
    Left = 631
    Top = 280
    Width = 147
    Height = 25
    Caption = 'Load a dog'
    TabOrder = 15
    OnClick = Button14Click
  end
  object ioPrototypeBindSource1: TioPrototypeBindSource
    AutoActivate = True
    AutoPost = False
    FieldDefs = <>
    ScopeMappings = <>
    ioAutoRefreshOnNotification = arEnabledNoReload
    ioViewModelInterface = 'IioViewModel'
    Left = 608
    Top = 192
  end
end
