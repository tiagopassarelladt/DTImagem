unit Unit5;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, DTImagem;

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

    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form5: TForm5;

implementation

{$R *.dfm}

procedure TForm5.Button1Click(Sender: TObject);
begin
      lblCaminho.Caption           := '';
      lblTipo.Caption              := '';
      edtBase64.Text               := '';
      DTImagem1.MostrarBarraStatus := CheckBox3.Checked;
      DTImagem1.CaminhoDaImagem    := 'c:\temp';

      if CheckBox2.Checked then
       DTImagem1.HabilitaSeletor := True
      else
       DTImagem1.HabilitaSeletor := false;

      if CheckBox1.Checked then
      begin
        DTImagem1.ConsultarNaCosmos := true;
      end else begin
        DTImagem1.ConsultarNaCosmos := False;
      end;

      DTImagem1.Buscar(edtCodigo.Text,edtDescricao.Text);

      if FileExists( DTImagem1.CaminhoDaImagem ) then
      begin
          if Assigned( DTImagem1.Imagem ) then
            Image1.Picture.assign( DTImagem1.Imagem )
          else
            Image1.Picture.LoadFromFile( DTImagem1.CaminhoDaImagem );

          lblCaminho.Caption := DTImagem1.CaminhoDaImagem;
          lblTipo.Caption    := DTImagem1.TipoImagem;
          lblTamanho.Caption := Format('%.2f KB', [DTImagem1.TamanhoKB]);
          edtBase64.Text     := DTImagem1.ImgBase64;
      end;
end;

end.
