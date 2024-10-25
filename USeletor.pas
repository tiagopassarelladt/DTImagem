unit USeletor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Datasnap.DBClient, Vcl.DBCGrids,
  Vcl.ExtCtrls, IdHTTP,Vcl.Imaging.jpeg;

type
  TFrmSeletor = class(TForm)
    cdsIMG: TClientDataSet;
    cdsIMGID: TIntegerField;
    cdsIMGURL: TStringField;
    dsIMG: TDataSource;
    ScrollBox1: TScrollBox;
    Shape1: TShape;
    procedure DBCtrlGrid1MouseEnter(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
  private
    FCarregando: Boolean;
    FUrlImagem: string;
   procedure GetImageByUrl(URL: string; APicture: TPicture);
    procedure SetCarregando(const Value: Boolean);
    procedure SetUrlImagem(const Value: string);
    procedure onClick(Sender : TObject);
  public
    property Carregando:Boolean read FCarregando write SetCarregando;
    property UrlImagem:string read FUrlImagem write SetUrlImagem;
  end;

var
  FrmSeletor: TFrmSeletor;


implementation

{$R *.dfm}

{ TFrmSeletor }

procedure TFrmSeletor.DBCtrlGrid1MouseEnter(Sender: TObject);
begin
     FCarregando := False;
end;

procedure TFrmSeletor.FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
       ScrollBox1.SetFocus;
       ScrollBox1.VertScrollBar.Position := ScrollBox1.VertScrollBar.Position + 10;
end;

procedure TFrmSeletor.FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
       ScrollBox1.SetFocus;
       ScrollBox1.VertScrollBar.Position := ScrollBox1.VertScrollBar.Position - 10;
end;

procedure TFrmSeletor.FormShow(Sender: TObject);
var
img      : TImage;
xPosicao : integer;
begin
  cdsIMG.First;

  xPosicao := 1;

  while not cdsIMG.Eof do
  begin
          img                  := TImage.Create(Self);
          img.Name             := 'img' + cdsIMGID.AsString;
          img.Parent           := ScrollBox1;
          img.AlignWithMargins := True;
          img.Left             := 1;
          img.Top              := xPosicao;
          img.Width            := 180;
          img.Height           := 106;
          img.Cursor           := crHandPoint;
          img.Center           := True;
          img.Proportional     := True;
          img.AutoSize         := False;
          img.Hint             := cdsIMGURL.AsString;
          img.OnDblClick       := onClick;

          GetImageByUrl(cdsIMGURL.AsString, img.Picture);

          xPosicao := xPosicao + 110;

      cdsIMG.Next;
  end;
end;

procedure TFrmSeletor.GetImageByUrl(URL: string; APicture: TPicture);
var
  Jpeg: TJPEGImage;
  Strm: TMemoryStream;
  vIdHTTP : TIdHTTP;
begin
      try
         try
            Jpeg := TJPEGImage.Create;
            Strm := TMemoryStream.Create;
            vIdHTTP := TIdHTTP.Create(nil);
            try
              vIdHTTP.Get(URL, Strm);
              if (Strm.Size > 0) then
              begin
                Strm.Position := 0;
                Jpeg.LoadFromStream(Strm);
                APicture.Assign(Jpeg);
              end;
            finally
              Strm.Free;
              Jpeg.Free;
              vIdHTTP.Free;
            end;
         Except

         end;
      finally

      end;
end;

procedure TFrmSeletor.onClick(Sender: TObject);
begin
     FUrlImagem := TImage( Sender ).Hint;
     close;
end;

procedure TFrmSeletor.SetCarregando(const Value: Boolean);
begin
  FCarregando := Value;
end;

procedure TFrmSeletor.SetUrlImagem(const Value: string);
begin
  FUrlImagem := Value;
end;

end.

