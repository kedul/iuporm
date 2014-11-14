object frm2: Tfrm2
  Left = 0
  Top = 0
  Caption = 'frm2'
  ClientHeight = 397
  ClientWidth = 852
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 176
    Top = 80
    Width = 337
    Height = 129
    Caption = 'Panel1'
    TabOrder = 0
    object Button1: TButton
      Left = 24
      Top = 24
      Width = 137
      Height = 25
      Action = DataModule2.acCiao
      TabOrder = 0
    end
  end
end
