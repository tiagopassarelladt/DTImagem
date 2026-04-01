unit USeletor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Datasnap.DBClient, Vcl.DBCGrids, System.Math,
  Vcl.ExtCtrls, System.Net.HttpClient, Vcl.Imaging.jpeg, Vcl.Imaging.pngimage, Vcl.Imaging.GIFImg,
  System.Threading, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TFrmSeletor = class(TForm)
    dsIMG: TDataSource;
    ScrollBox1: TScrollBox;
    Shape1: TShape;
    cdsIMG: TFDMemTable;
    cdsIMGID: TIntegerField;
    cdsIMGURL: TStringField;
    procedure DBCtrlGrid1MouseEnter(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
  private
    FCarregando: Boolean;
    FUrlImagem: string;
    function DownloadImageToStream(const URL: string; AStream: TMemoryStream): Boolean;
    function LoadStreamToPicture(AStream: TMemoryStream; APicture: TPicture): Boolean;
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
  img: TImage;
  xPosicao: Integer;
  URLs: TArray<string>;
  Streams: TArray<TMemoryStream>;
  I, Count: Integer;
begin
  // Coletar todas as URLs
  Count := 0;
  cdsIMG.First;
  while not cdsIMG.Eof do
  begin
    Inc(Count);
    cdsIMG.Next;
  end;

  if Count = 0 then Exit;

  // Limitar a 15 imagens para não sobrecarregar
  if Count > 15 then
    Count := 15;

  // Criar arrays
  SetLength(URLs, Count);
  SetLength(Streams, Count);

  // Preencher URLs e criar streams
  cdsIMG.First;
  for I := 0 to Count - 1 do
  begin
    URLs[I] := cdsIMGURL.AsString;
    Streams[I] := TMemoryStream.Create;
    cdsIMG.Next;
  end;

  // Download paralelo usando TParallel.For
  TParallel.For(0, Count - 1,
    procedure(Index: Integer)
    begin
      DownloadImageToStream(URLs[Index], Streams[Index]);
    end
  );

  // Criar imagens na UI (thread principal)
  xPosicao := 1;
  cdsIMG.First;
  for I := 0 to Count - 1 do
  begin
    if Streams[I].Size > 100 then
    begin
      img := TImage.Create(Self);
      img.Name := 'img' + IntToStr(I + 1);
      img.Parent := ScrollBox1;
      img.AlignWithMargins := True;
      img.Left := 1;
      img.Top := xPosicao;
      img.Width := 180;
      img.Height := 106;
      img.Cursor := crHandPoint;
      img.Center := True;
      img.Proportional := True;
      img.AutoSize := False;
      img.Hint := URLs[I];
      img.OnDblClick := onClick;

      if LoadStreamToPicture(Streams[I], img.Picture) then
      begin
        if (img.Picture.Graphic <> nil) and (not img.Picture.Graphic.Empty) then
          xPosicao := xPosicao + 110
        else
          img.Free;
      end
      else
        img.Free;
    end;

    Streams[I].Free;
    cdsIMG.Next;
  end;
end;

function TFrmSeletor.DownloadImageToStream(const URL: string; AStream: TMemoryStream): Boolean;
var
  HTTPClient: THTTPClient;
begin
  Result := False;
  if (URL = '') or (Pos('http', URL) <> 1) then
    Exit;

  HTTPClient := THTTPClient.Create;
  try
    try
      HTTPClient.UserAgent := 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36';
      HTTPClient.CustomHeaders['Accept'] := 'image/*,*/*;q=0.8';
      HTTPClient.CustomHeaders['Referer'] := 'https://www.bing.com/';
      HTTPClient.HandleRedirects := True;
      HTTPClient.ConnectionTimeout := 5000;  // 5 segundos timeout
      HTTPClient.ResponseTimeout := 10000;   // 10 segundos timeout

      AStream.Clear;
      HTTPClient.Get(URL, AStream);
      Result := AStream.Size > 100;
    except
      Result := False;
    end;
  finally
    HTTPClient.Free;
  end;
end;

function TFrmSeletor.LoadStreamToPicture(AStream: TMemoryStream; APicture: TPicture): Boolean;
var
  Jpeg: TJPEGImage;
  Png: TPngImage;
  Gif: TGIFImage;
  Bmp: TBitmap;
  Header: array[0..7] of Byte;
  ImageType: string;
begin
  Result := False;

  if (AStream = nil) or (AStream.Size < 100) then
    Exit;

  try
    // Detectar tipo de imagem pelo header
    AStream.Position := 0;
    FillChar(Header, SizeOf(Header), 0);
    AStream.Read(Header, Min(AStream.Size, 8));
    AStream.Position := 0;

    // Identificar formato
    if (Header[0] = $FF) and (Header[1] = $D8) then
      ImageType := 'JPEG'
    else if (Header[0] = $89) and (Header[1] = $50) and (Header[2] = $4E) and (Header[3] = $47) then
      ImageType := 'PNG'
    else if (Header[0] = $47) and (Header[1] = $49) and (Header[2] = $46) then
      ImageType := 'GIF'
    else if (Header[0] = $42) and (Header[1] = $4D) then
      ImageType := 'BMP'
    else
      ImageType := 'JPEG';

    // Carregar conforme o tipo
    if ImageType = 'JPEG' then
    begin
      Jpeg := TJPEGImage.Create;
      try
        Jpeg.LoadFromStream(AStream);
        APicture.Assign(Jpeg);
        Result := True;
      finally
        Jpeg.Free;
      end;
    end
    else if ImageType = 'PNG' then
    begin
      Png := TPngImage.Create;
      try
        Png.LoadFromStream(AStream);
        APicture.Assign(Png);
        Result := True;
      finally
        Png.Free;
      end;
    end
    else if ImageType = 'GIF' then
    begin
      Gif := TGIFImage.Create;
      try
        Gif.LoadFromStream(AStream);
        APicture.Assign(Gif);
        Result := True;
      finally
        Gif.Free;
      end;
    end
    else if ImageType = 'BMP' then
    begin
      Bmp := TBitmap.Create;
      try
        Bmp.LoadFromStream(AStream);
        APicture.Assign(Bmp);
        Result := True;
      finally
        Bmp.Free;
      end;
    end;
  except
    Result := False;
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


