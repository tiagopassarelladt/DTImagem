object Form5: TForm5
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Demo - DTImagem'
  ClientHeight = 520
  ClientWidth = 800
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  TextHeight = 13
  object Shape1: TShape
    Left = 7
    Top = 7
    Width = 181
    Height = 148
    Cursor = crHandPoint
    Pen.Color = clGray
  end
  object Image1: TImage
    Left = 8
    Top = 8
    Width = 179
    Height = 145
    Cursor = crHandPoint
    Center = True
    Proportional = True
    Stretch = True
  end
  object Label1: TLabel
    Left = 197
    Top = 5
    Width = 33
    Height = 13
    Caption = 'C'#243'digo'
  end
  object Label2: TLabel
    Left = 301
    Top = 5
    Width = 46
    Height = 13
    Caption = 'Descri'#231#227'o'
  end
  object Label10: TLabel
    Left = 8
    Top = 161
    Width = 180
    Height = 13
    Alignment = taCenter
    AutoSize = False
    Caption = 'Pr'#233'-visualiza'#231#227'o da Imagem'
    Color = clBtnFace
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
  end
  object edtCodigo: TEdit
    Left = 197
    Top = 21
    Width = 98
    Height = 21
    TabOrder = 0
    Text = '7894900019155'
  end
  object edtDescricao: TEdit
    Left = 301
    Top = 21
    Width = 234
    Height = 21
    BevelOuter = bvRaised
    CharCase = ecUpperCase
    TabOrder = 1
    Text = 'COCA COLA PET'
  end
  object Button1: TButton
    Left = 541
    Top = 19
    Width = 90
    Height = 25
    Cursor = crHandPoint
    Caption = 'Buscar Imagem'
    TabOrder = 2
    OnClick = Button1Click
  end
  object Panel1: TPanel
    Left = 197
    Top = 447
    Width = 595
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
      Width = 530
      Height = 21
      TabOrder = 0
    end
  end
  object GroupBox1: TGroupBox
    Left = 197
    Top = 50
    Width = 595
    Height = 33
    Caption = ' Op'#231#245'es Gerais '
    TabOrder = 4
    object CheckBox1: TCheckBox
      Left = 10
      Top = 12
      Width = 130
      Height = 17
      Cursor = crHandPoint
      Caption = 'Consultar na Cosmos'
      TabOrder = 0
    end
    object CheckBox2: TCheckBox
      Left = 143
      Top = 12
      Width = 162
      Height = 17
      Cursor = crHandPoint
      Caption = 'Mostrar seletor de imagens'
      TabOrder = 1
    end
    object CheckBox3: TCheckBox
      Left = 309
      Top = 12
      Width = 109
      Height = 17
      Cursor = crHandPoint
      Caption = 'Mostrar Status'
      Checked = True
      State = cbChecked
      TabOrder = 2
    end
  end
  object GroupBox2: TGroupBox
    Left = 197
    Top = 89
    Width = 595
    Height = 89
    Caption = ' Tamanho das Imagens Google '
    TabOrder = 5
    object rbThumbnails: TRadioButton
      Left = 10
      Top = 18
      Width = 97
      Height = 17
      Caption = 'Thumbnails'
      Checked = True
      TabOrder = 0
      TabStop = True
    end
    object rbPequenas: TRadioButton
      Left = 113
      Top = 18
      Width = 97
      Height = 17
      Caption = 'Pequenas'
      TabOrder = 1
    end
    object rbMedias: TRadioButton
      Left = 216
      Top = 18
      Width = 97
      Height = 17
      Caption = 'M'#233'dias'
      TabOrder = 2
    end
    object rbGrandes: TRadioButton
      Left = 319
      Top = 18
      Width = 97
      Height = 17
      Caption = 'Grandes'
      TabOrder = 3
    end
    object rbExtraGrandes: TRadioButton
      Left = 422
      Top = 18
      Width = 97
      Height = 17
      Caption = 'Extra Grandes'
      TabOrder = 4
    end
    object rbEnormes: TRadioButton
      Left = 10
      Top = 41
      Width = 97
      Height = 17
      Caption = 'Enormes'
      TabOrder = 5
    end
    object rbTodosTamanhos: TRadioButton
      Left = 113
      Top = 41
      Width = 130
      Height = 17
      Caption = 'Todos os Tamanhos'
      TabOrder = 6
    end
  end
  object GroupBox3: TGroupBox
    Left = 197
    Top = 184
    Width = 595
    Height = 257
    Caption = ' Redimensionamento '
    TabOrder = 6
    object Label7: TLabel
      Left = 15
      Top = 45
      Width = 41
      Height = 13
      Caption = 'Largura:'
      Enabled = False
    end
    object Label8: TLabel
      Left = 15
      Top = 72
      Width = 33
      Height = 13
      Caption = 'Altura:'
      Enabled = False
    end
    object Label9: TLabel
      Left = 15
      Top = 126
      Width = 114
      Height = 13
      Caption = 'Qualidade Compress'#227'o:'
      Enabled = False
    end
    object chkRedimensionar: TCheckBox
      Left = 15
      Top = 20
      Width = 162
      Height = 17
      Caption = 'Habilitar Redimensionamento'
      TabOrder = 0
      OnClick = chkRedimensionarClick
    end
    object spnLargura: TSpinEdit
      Left = 60
      Top = 42
      Width = 65
      Height = 22
      Enabled = False
      MaxValue = 2000
      MinValue = 50
      TabOrder = 1
      Value = 150
    end
    object spnAltura: TSpinEdit
      Left = 60
      Top = 69
      Width = 65
      Height = 22
      Enabled = False
      MaxValue = 2000
      MinValue = 50
      TabOrder = 2
      Value = 150
    end
    object chkManterAspecto: TCheckBox
      Left = 15
      Top = 99
      Width = 201
      Height = 17
      Caption = 'Manter Aspecto (adiciona bordas)'
      Enabled = False
      TabOrder = 3
    end
    object spnQualidade: TSpinEdit
      Left = 134
      Top = 123
      Width = 65
      Height = 22
      Enabled = False
      MaxValue = 100
      MinValue = 1
      TabOrder = 4
      Value = 90
    end
    object btnRedimensionar150: TButton
      Left = 15
      Top = 160
      Width = 120
      Height = 35
      Caption = 'Redimensionar'#13#10'150x150'
      Enabled = False
      TabOrder = 5
      OnClick = btnRedimensionar150Click
    end
    object btnRedimensionar250: TButton
      Left = 141
      Top = 160
      Width = 120
      Height = 35
      Caption = 'Redimensionar'#13#10'250x250'
      Enabled = False
      TabOrder = 6
      OnClick = btnRedimensionar250Click
    end
    object btnRedimensionarCustom: TButton
      Left = 15
      Top = 201
      Width = 246
      Height = 35
      Caption = 'Redimensionar com Valores Personalizados'
      Enabled = False
      TabOrder = 7
      OnClick = btnRedimensionarCustomClick
    end
  end
  object DTImagem1: TDTImagem
    ConsultarNaCosmos = False
    HabilitaSeletor = False
    MostrarBarraStatus = False
    TipoTamanhoImagem = ttiThumbnails
    Redimensionar = False
    LarguraRedimensionada = 150
    AlturaRedimensionada = 150
    ManterAspecto = False
    QualidadeCompressao = 90
    Left = 80
    Top = 48
  end
end
