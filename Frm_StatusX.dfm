object frmStatusX: TfrmStatusX
  Left = 231
  Top = 166
  BorderIcons = []
  BorderStyle = bsNone
  Caption = 'Status'
  ClientHeight = 45
  ClientWidth = 462
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poMainFormCenter
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 462
    Height = 45
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 2
    Color = clWhite
    ParentBackground = False
    TabOrder = 0
    StyleElements = [seBorder]
    object lbl1: TLabel
      Left = 2
      Top = 2
      Width = 458
      Height = 17
      Align = alTop
      AutoSize = False
      Caption = 'Aguarde'
      Color = 10455853
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      Transparent = False
      Layout = tlCenter
      StyleElements = [seBorder]
      ExplicitWidth = 477
    end
    object lblStatus: TLabel
      Left = 2
      Top = 19
      Width = 458
      Height = 24
      Align = alClient
      Caption = 'Pesquisando imagem do produto'
      Color = clGray
      ParentColor = False
      Layout = tlCenter
      StyleElements = [seBorder]
      ExplicitWidth = 155
      ExplicitHeight = 13
    end
  end
end