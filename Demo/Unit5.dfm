object Form5: TForm5
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Demo - DTImagem'
  ClientHeight = 167
  ClientWidth = 591
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  TextHeight = 13
  object Shape1: TShape
    Left = 7
    Top = 7
    Width = 131
    Height = 148
    Cursor = crHandPoint
    Pen.Color = clGray
  end
  object Image1: TImage
    Left = 8
    Top = 8
    Width = 129
    Height = 145
    Proportional = True
    Stretch = True
  end
  object Label1: TLabel
    Left = 147
    Top = 5
    Width = 33
    Height = 13
    Caption = 'Codigo'
  end
  object Label2: TLabel
    Left = 251
    Top = 2
    Width = 46
    Height = 13
    Caption = 'Descri'#231#227'o'
  end
  object edtCodigo: TEdit
    Left = 147
    Top = 21
    Width = 98
    Height = 21
    TabOrder = 0
    Text = '7894900019155'
  end
  object edtDescricao: TEdit
    Left = 251
    Top = 21
    Width = 234
    Height = 21
    BevelOuter = bvRaised
    CharCase = ecUpperCase
    TabOrder = 1
    Text = 'COCA COLA PET'
  end
  object Button1: TButton
    Left = 491
    Top = 19
    Width = 90
    Height = 25
    Cursor = crHandPoint
    Caption = 'Buscar Imagem'
    TabOrder = 2
    OnClick = Button1Click
  end
  object Panel1: TPanel
    Left = 147
    Top = 89
    Width = 434
    Height = 66
    BevelInner = bvLowered
    TabOrder = 3
    object Label3: TLabel
      Left = 10
      Top = 7
      Width = 99
      Height = 13
      Caption = 'Caminho da imagem:'
    end
    object Label4: TLabel
      Left = 320
      Top = 7
      Width = 78
      Height = 13
      Caption = 'Tipo da imagem:'
    end
    object Label5: TLabel
      Left = 10
      Top = 43
      Width = 39
      Height = 13
      Caption = 'Base64:'
    end
    object lblCaminho: TLabel
      Left = 115
      Top = 7
      Width = 196
      Height = 13
      AutoSize = False
    end
    object lblTipo: TLabel
      Left = 402
      Top = 7
      Width = 23
      Height = 13
      AutoSize = False
    end
    object Label6: TLabel
      Left = 10
      Top = 23
      Width = 102
      Height = 13
      Caption = 'Tamanho da imagem:'
    end
    object lblTamanho: TLabel
      Left = 117
      Top = 23
      Width = 61
      Height = 13
      AutoSize = False
    end
    object edtBase64: TEdit
      Left = 55
      Top = 40
      Width = 370
      Height = 21
      TabOrder = 0
    end
  end
  object GroupBox1: TGroupBox
    Left = 147
    Top = 50
    Width = 434
    Height = 33
    TabOrder = 4
    object CheckBox1: TCheckBox
      Left = 10
      Top = 9
      Width = 130
      Height = 17
      Cursor = crHandPoint
      Caption = 'Consultar na cosmos'
      TabOrder = 0
    end
    object CheckBox2: TCheckBox
      Left = 143
      Top = 9
      Width = 162
      Height = 17
      Cursor = crHandPoint
      Caption = 'Mostrar seletor de imagens'
      TabOrder = 1
    end
    object CheckBox3: TCheckBox
      Left = 309
      Top = 9
      Width = 109
      Height = 17
      Cursor = crHandPoint
      Caption = 'Mostrar Status'
      Checked = True
      State = cbChecked
      TabOrder = 2
    end
  end
  object DTImagem1: TDTImagem
    ConsultarNaCosmos = False
    HabilitaSeletor = False
    MostrarBarraStatus = False
    Left = 64
    Top = 48
  end
end
