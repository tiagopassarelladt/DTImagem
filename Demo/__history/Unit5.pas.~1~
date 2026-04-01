unit Unit5;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, DTImagem,
  Vcl.Samples.Spin;

type
  TForm5 = class(TForm)
    Image1: TImage;
    edtCodigo: TEdit;
    edtDescricao: TEdit;
    Button1: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Shape1: TShape;
    DTImagem1: TDTImagem;
    Panel1: TPanel;
    GroupBox1: TGroupBox;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    Label3: TLabel;
    Label4: TLabel;
    edtBase64: TEdit;
    Label5: TLabel;
    lblCaminho: TLabel;
    lblTipo: TLabel;
    Label6: TLabel;
    lblTamanho: TLabel;
    CheckBox3: TCheckBox;

    // NOVOS CONTROLES PARA CONFIGURAÇÃO DE TAMANHO
    GroupBox2: TGroupBox;
    rbThumbnails: TRadioButton;
    rbPequenas: TRadioButton;
    rbMedias: TRadioButton;
    rbGrandes: TRadioButton;
    rbExtraGrandes: TRadioButton;
    rbEnormes: TRadioButton;
    rbTodosTamanhos: TRadioButton;

    // NOVOS CONTROLES PARA REDIMENSIONAMENTO
    GroupBox3: TGroupBox;
    chkRedimensionar: TCheckBox;
    Label7: TLabel;
    Label8: TLabel;
    spnLargura: TSpinEdit;
    spnAltura: TSpinEdit;
    chkManterAspecto: TCheckBox;
    Label9: TLabel;
    spnQualidade: TSpinEdit;
    btnRedimensionar250: TButton;
    btnRedimensionar150: TButton;
    btnRedimensionarCustom: TButton;
    Label10: TLabel;

    procedure Button1Click(Sender: TObject);
    procedure chkRedimensionarClick(Sender: TObject);
    procedure btnRedimensionar250Click(Sender: TObject);
    procedure btnRedimensionar150Click(Sender: TObject);
    procedure btnRedimensionarCustomClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  private
    procedure AtualizarInterface;
    procedure ConfigurarTamanhoImagem;
    procedure ConfigurarRedimensionamento;
    function GetTipoTamanhoSelecionado: TTipoTamanhoImagem;

  public
    { Public declarations }
  end;

var
  Form5: TForm5;

implementation

{$R *.dfm}

procedure TForm5.FormCreate(Sender: TObject);
begin
  // Configurações iniciais
  rbThumbnails.Checked := True; // Padrão
  chkRedimensionar.Checked := False;
  spnLargura.Value := 150;
  spnAltura.Value := 150;
  spnQualidade.Value := 90;
  chkManterAspecto.Checked := False;

  // Desabilitar controles de redimensionamento inicialmente
  chkRedimensionarClick(nil);
end;

function TForm5.GetTipoTamanhoSelecionado: TTipoTamanhoImagem;
begin
  if rbThumbnails.Checked then Result := ttiThumbnails
  else if rbPequenas.Checked then Result := ttiPequenas
  else if rbMedias.Checked then Result := ttiMedias
  else if rbGrandes.Checked then Result := ttiGrandes
  else if rbExtraGrandes.Checked then Result := ttiExtraGrandes
  else if rbEnormes.Checked then Result := ttiEnormes
  else if rbTodosTamanhos.Checked then Result := ttiTodosTamanhos
  else Result := ttiThumbnails; // Fallback
end;

procedure TForm5.ConfigurarTamanhoImagem;
begin
  DTImagem1.TipoTamanhoImagem := GetTipoTamanhoSelecionado;
end;

procedure TForm5.ConfigurarRedimensionamento;
begin
  DTImagem1.Redimensionar := chkRedimensionar.Checked;
  DTImagem1.LarguraRedimensionada := spnLargura.Value;
  DTImagem1.AlturaRedimensionada := spnAltura.Value;
  DTImagem1.ManterAspecto := chkManterAspecto.Checked;
  DTImagem1.QualidadeCompressao := spnQualidade.Value;
end;

procedure TForm5.chkRedimensionarClick(Sender: TObject);
begin
  // Habilitar/desabilitar controles de redimensionamento
  spnLargura.Enabled := chkRedimensionar.Checked;
  spnAltura.Enabled := chkRedimensionar.Checked;
  chkManterAspecto.Enabled := chkRedimensionar.Checked;
  spnQualidade.Enabled := chkRedimensionar.Checked;
  btnRedimensionar150.Enabled := chkRedimensionar.Checked;
  btnRedimensionar250.Enabled := chkRedimensionar.Checked;
  btnRedimensionarCustom.Enabled := chkRedimensionar.Checked;

  Label7.Enabled := chkRedimensionar.Checked;
  Label8.Enabled := chkRedimensionar.Checked;
  Label9.Enabled := chkRedimensionar.Checked;
end;

procedure TForm5.Button1Click(Sender: TObject);
var
  TipoDesc: string;
begin
  try
    // Limpar interface
    lblCaminho.Caption := '';
    lblTipo.Caption    := '';
    edtBase64.Text     := '';
    Image1.Picture     := nil;

    // Configurar componente
    DTImagem1.MostrarBarraStatus := CheckBox3.Checked;
    DTImagem1.CaminhoDaImagem    := 'c:\temp';
    DTImagem1.HabilitaSeletor    := CheckBox2.Checked;
    DTImagem1.ConsultarNaCosmos  := CheckBox1.Checked;

    // Configurar tipo de tamanho
    ConfigurarTamanhoImagem;

    // Configurar redimensionamento
    ConfigurarRedimensionamento;

    // Buscar imagem
    DTImagem1.Buscar(edtCodigo.Text, edtDescricao.Text);

    // Atualizar interface
    AtualizarInterface;

  except
    on E: Exception do
      ShowMessage('Erro ao buscar imagem: ' + E.Message);
  end;
end;

procedure TForm5.AtualizarInterface;
var
  TipoDesc: string;
begin
  if FileExists(DTImagem1.CaminhoDaImagem) then
  begin
    // Carregar imagem
    if Assigned(DTImagem1.Imagem) then
      Image1.Picture.Assign(DTImagem1.Imagem)
    else
      Image1.Picture.LoadFromFile(DTImagem1.CaminhoDaImagem);

    // Atualizar labels
    lblCaminho.Caption := DTImagem1.CaminhoDaImagem;
    lblTipo.Caption := DTImagem1.TipoImagem;
    lblTamanho.Caption := Format('%.2f KB', [DTImagem1.TamanhoKB]);
    edtBase64.Text := Copy(DTImagem1.ImgBase64, 1, 100) + '...'; // Truncar para exibição

    // Mostrar informações de configuração
    case DTImagem1.TipoTamanhoImagem of
      ttiThumbnails: TipoDesc := 'Thumbnails';
      ttiPequenas: TipoDesc := 'Pequenas';
      ttiMedias: TipoDesc := 'Médias';
      ttiGrandes: TipoDesc := 'Grandes';
      ttiExtraGrandes: TipoDesc := 'Extra Grandes';
      ttiEnormes: TipoDesc := 'Enormes';
      ttiTodosTamanhos: TipoDesc := 'Todos os Tamanhos';
    end;

    if DTImagem1.Redimensionar then
      TipoDesc := TipoDesc + Format(' | Redim: %dx%d', [DTImagem1.LarguraRedimensionada, DTImagem1.AlturaRedimensionada]);

    Caption := Format('Demo - DTImagem [%s] - Sucesso!', [TipoDesc]);
  end
  else
  begin
    Caption := 'Demo - DTImagem - Nenhuma imagem encontrada';
    ShowMessage('Nenhuma imagem foi encontrada para os critérios especificados.');
  end;
end;

procedure TForm5.btnRedimensionar150Click(Sender: TObject);
begin
  if FileExists(DTImagem1.CaminhoDaImagem) then
  begin
    DTImagem1.RedimensionarImagemQuadrada(150);
    AtualizarInterface;
    ShowMessage('Imagem redimensionada para 150x150px!');
  end
  else
    ShowMessage('Primeiro busque uma imagem!');
end;

procedure TForm5.btnRedimensionar250Click(Sender: TObject);
begin
  if FileExists(DTImagem1.CaminhoDaImagem) then
  begin
    DTImagem1.RedimensionarImagemQuadrada(250);
    AtualizarInterface;
    ShowMessage('Imagem redimensionada para 250x250px!');
  end
  else
    ShowMessage('Primeiro busque uma imagem!');
end;

procedure TForm5.btnRedimensionarCustomClick(Sender: TObject);
begin
  if FileExists(DTImagem1.CaminhoDaImagem) then
  begin
    DTImagem1.RedimensionarImagemManual(spnLargura.Value, spnAltura.Value);
    AtualizarInterface;
    ShowMessage(Format('Imagem redimensionada para %dx%dpx!', [spnLargura.Value, spnAltura.Value]));
  end
  else
    ShowMessage('Primeiro busque uma imagem!');
end;

end.
