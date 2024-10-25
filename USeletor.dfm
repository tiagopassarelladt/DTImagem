object FrmSeletor: TFrmSeletor
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Seletor de Imagens'
  ClientHeight = 338
  ClientWidth = 165
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  StyleElements = []
  OnMouseWheelDown = FormMouseWheelDown
  OnMouseWheelUp = FormMouseWheelUp
  OnShow = FormShow
  TextHeight = 13
  object ScrollBox1: TScrollBox
    Left = 0
    Top = 0
    Width = 165
    Height = 338
    Cursor = crHandPoint
    HorzScrollBar.Visible = False
    Align = alClient
    BevelInner = bvNone
    BevelOuter = bvNone
    BorderStyle = bsNone
    Color = clWhite
    ParentColor = False
    TabOrder = 0
    StyleElements = []
    object Shape1: TShape
      Left = 0
      Top = 0
      Width = 165
      Height = 338
      Cursor = crHandPoint
      Align = alClient
      Pen.Color = clWhite
      ExplicitLeft = 48
      ExplicitTop = 96
      ExplicitWidth = 65
      ExplicitHeight = 65
    end
  end
  object cdsIMG: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 48
    Top = 216
    object cdsIMGID: TIntegerField
      FieldName = 'ID'
    end
    object cdsIMGURL: TStringField
      FieldName = 'URL'
      Size = 1000
    end
  end
  object dsIMG: TDataSource
    DataSet = cdsIMG
    Left = 88
    Top = 216
  end
end
