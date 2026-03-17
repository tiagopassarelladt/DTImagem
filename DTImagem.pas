unit DTImagem;

interface

uses
  System.SysUtils,
  System.Classes,
  Vcl.StdCtrls,
  MSHTML,
  net.HttpClient,
  Soap.EncdDecd,
  Winapi.UrlMon,
  System.NetEncoding,
  Vcl.Imaging.jpeg,
  USeletor,
  Vcl.Imaging.pngimage,
  Vcl.Imaging.gifimg,
  Vcl.Graphics,
  System.RegularExpressions,
  System.StrUtils;

// Tipo para configurar tamanho das imagens
type
  TTipoTamanhoImagem = (
    ttiThumbnails,    // Apenas miniaturas (padrão)
    ttiPequenas,      // Imagens pequenas
    ttiMedias,        // Imagens médias
    ttiGrandes,       // Imagens grandes
    ttiExtraGrandes,  // Imagens extra grandes
    ttiEnormes,       // Imagens enormes
    ttiTodosTamanhos  // Todos os tamanhos disponíveis
  );

type
  TDTImagem = class(TComponent)
  private
    FCaminhoImagem: string;
    FImagem: TPicture;
    FCosmos: Boolean;
    FHabilitaSeletor: boolean;
    FTipoImagem: string;
    FImgBase64: string;
    FTamanhoKB: Double;
    FMostrarBarraStatus: boolean;
    FTipoTamanhoImagem: TTipoTamanhoImagem;

    // PROPRIEDADES PARA REDIMENSIONAMENTO
    FRedimensionar: Boolean;          // Habilita/desabilita redimensionamento
    FLarguraRedimensionada: Integer;  // Largura desejada
    FAlturaRedimensionada: Integer;   // Altura desejada
    FManterAspecto: Boolean;          // Manter proporção original
    FQualidadeCompressao: Integer;    // Qualidade JPEG (1-100)

    procedure stCaminhoImagem(const Value: string);
    function GetValorCampoHtml(FHTML, FTag, FTagNome: string; FProximos: Integer=0; const FResultado: TStringList = nil): string;
    procedure setFImagem(const Value: TPicture);
    Function ConvertJPG_BMP(xFile: string):TMemoryStream;
    procedure setCosmos(const Value: Boolean);
    procedure SetHabilitaSeletor(const Value: boolean);
    function VerificarAssinaturaJPEG(xFile: string): Boolean;
    function RepararJPEG(xFile: string): Boolean;
    function IdentificarTipoImagem(const FileName: string): string;
    function ImageFileToBase64(const FilePath: string): string;
    procedure DownloadImage(const AURL, AFileName: string);
    function IsJPEGFile(const FileName: string): Boolean;
    function IsPNGFile(const FileName: string): Boolean;
    function IsGIFFile(const FileName: string): Boolean;
    function IsWebPFile(const FileName: string): Boolean;
    function LoadAnyImageAsJPEG(const FileName: string; Quality: Integer = 90): TMemoryStream;
    function DetectImageTypeFromFile(const FileName: string): string;

    // FUNÇÕES PARA BUSCA AVANÇADA
    procedure ExtrairImagensDoHTML(const HTML: string; ImageUrls: TStringList);
    procedure ExtrairImagensDoDuckDuckGo(const HTML: string; ImageUrls: TStringList);
    function DecodeURL(const EncodedURL: string): string;
    function DecodeURLEncoded(const EncodedURL: string): string;
    function GetParametrosTamanho: string;
    function GetDescricaoTamanho: string;
    procedure SetTipoTamanhoImagem(const Value: TTipoTamanhoImagem);

    // FUNÇÕES DE REDIMENSIONAMENTO
    procedure RedimensionarImagem(const CaminhoDaImagem: string);
    procedure RedimensionarImagemPersonalizada(const CaminhoDaImagem: string; Altura, Largura: Integer);
    procedure SetRedimensionar(const Value: Boolean);
    procedure SetLarguraRedimensionada(const Value: Integer);
    procedure SetAlturaRedimensionada(const Value: Integer);
    procedure SetManterAspecto(const Value: Boolean);
    procedure SetQualidadeCompressao(const Value: Integer);

  public
    procedure Buscar(Codigo:string;Descricao:string; NomeDaImagem : string = '');
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    // MÉTODOS PÚBLICOS PARA REDIMENSIONAMENTO
    procedure RedimensionarImagemManual(Largura, Altura: Integer);
    procedure RedimensionarImagemQuadrada(Tamanho: Integer);

  published
    property CaminhoDaImagem          : string                read FCaminhoImagem          write stCaminhoImagem;
    property Imagem                   : TPicture              read FImagem                 write setFImagem;
    property ConsultarNaCosmos        : Boolean               read FCosmos                 write setCosmos;
    property HabilitaSeletor          : boolean               read FHabilitaSeletor        write SetHabilitaSeletor;
    property TipoImagem               : string                read FTipoImagem             write FTipoImagem;
    property ImgBase64                : string                read FImgBase64              write FImgBase64;
    property TamanhoKB                : Double                read FTamanhoKB              write FTamanhoKB;
    property MostrarBarraStatus       : boolean               read FMostrarBarraStatus     write FMostrarBarraStatus;
    property TipoTamanhoImagem        : TTipoTamanhoImagem    read FTipoTamanhoImagem      write SetTipoTamanhoImagem;

    // PROPRIEDADES PARA REDIMENSIONAMENTO
    property Redimensionar            : Boolean               read FRedimensionar          write SetRedimensionar;
    property LarguraRedimensionada    : Integer               read FLarguraRedimensionada  write SetLarguraRedimensionada;
    property AlturaRedimensionada     : Integer               read FAlturaRedimensionada   write SetAlturaRedimensionada;
    property ManterAspecto            : Boolean               read FManterAspecto          write SetManterAspecto;
    property QualidadeCompressao      : Integer               read FQualidadeCompressao    write SetQualidadeCompressao;
end;

procedure Register;

implementation

uses
  Frm_StatusX, Vcl.Forms, IdSSLOpenSSL, System.Math, System.Types;

procedure Register;
begin
  RegisterComponents('DT Inovacao', [TDTImagem]);
end;

{ TDTImagem }

constructor TDTImagem.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FImagem := TPicture.create;
  FTipoTamanhoImagem := ttiThumbnails;

  // VALORES PADRÃO PARA REDIMENSIONAMENTO
  FRedimensionar := False;
  FLarguraRedimensionada := 150;
  FAlturaRedimensionada := 150;
  FManterAspecto := False;
  FQualidadeCompressao := 90;
end;

destructor TDTImagem.Destroy;
begin
  FreeAndNil(fimagem);
  inherited destroy;
end;

function TDTImagem.ImageFileToBase64(const FilePath: string): string;
var
  MemoryStream: TMemoryStream;
  Base64Stream: TStringStream;
  Picture: TPicture;
  FileExt: string;
  IsRealJPEG: Boolean;
begin
  Result := '';
  MemoryStream := TMemoryStream.Create;
  Base64Stream := TStringStream.Create;
  Picture := TPicture.Create;

  try
    try
      // Detecta o tipo real da imagem pelo conteúdo (não pela extensão)
      IsRealJPEG := IsJPEGFile(FilePath);

      try
        Picture.LoadFromFile(FilePath);
      except
        on E: Exception do
        begin
          FreeAndNil(Picture);
          Picture := TPicture.Create;
          try
            // Usa o tipo real detectado, não a extensão
            if IsRealJPEG then
            begin
              Picture.Graphic := TJPEGImage.Create;
              Picture.Graphic.LoadFromFile(FilePath);
            end
            else
            begin
              FileExt := LowerCase(ExtractFileExt(FilePath));
              if (FileExt = '.png') then
              begin
                Picture.Graphic := TPNGImage.Create;
                Picture.Graphic.LoadFromFile(FilePath);
              end
              else if (FileExt = '.gif') then
              begin
                Picture.Graphic := TGIFImage.Create;
                Picture.Graphic.LoadFromFile(FilePath);
              end
              else if (FileExt = '.bmp') then
              begin
                Picture.Graphic := TBitmap.Create;
                Picture.Graphic.LoadFromFile(FilePath);
              end
              else
              begin
                // Tenta como bitmap genérico
                Picture.Graphic := TBitmap.Create;
                Picture.Graphic.LoadFromFile(FilePath);
              end;
            end;
          except
            FreeAndNil(Picture);
            Result := ''; // Retorna uma string vazia para evitar falhas
            Exit;
          end;
        end;
      end;
      Picture.Graphic.SaveToStream(MemoryStream);
    finally
      Picture.Free;
    end;
    MemoryStream.Position := 0;

    FTamanhoKB := MemoryStream.Size / 1024;

    TNetEncoding.Base64.Encode(MemoryStream, Base64Stream);

    Result := Base64Stream.DataString;
  finally
    MemoryStream.Free;
    Base64Stream.Free;
  end;
end;

function TDTImagem.IsJPEGFile(const FileName: string): Boolean;
var
  FileStream: TFileStream;
  Buffer: array[0..2] of Byte;
begin
  Result := False;
  if not FileExists(FileName) then Exit;

  try
    FileStream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
    try
      if FileStream.Size >= 3 then
      begin
        FileStream.Read(Buffer, 3);
        Result := (Buffer[0] = $FF) and (Buffer[1] = $D8) and (Buffer[2] = $FF);
      end;
    finally
      FileStream.Free;
    end;
  except
    Result := False;
  end;
end;

function TDTImagem.IsPNGFile(const FileName: string): Boolean;
var
  FileStream: TFileStream;
  Buffer: array[0..7] of Byte;
begin
  Result := False;
  if not FileExists(FileName) then Exit;

  try
    FileStream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
    try
      if FileStream.Size >= 8 then
      begin
        FileStream.Read(Buffer, 8);
        // PNG signature: 89 50 4E 47 0D 0A 1A 0A
        Result := (Buffer[0] = $89) and (Buffer[1] = $50) and (Buffer[2] = $4E) and
                  (Buffer[3] = $47) and (Buffer[4] = $0D) and (Buffer[5] = $0A) and
                  (Buffer[6] = $1A) and (Buffer[7] = $0A);
      end;
    finally
      FileStream.Free;
    end;
  except
    Result := False;
  end;
end;

function TDTImagem.IsGIFFile(const FileName: string): Boolean;
var
  FileStream: TFileStream;
  Buffer: array[0..5] of Byte;
begin
  Result := False;
  if not FileExists(FileName) then Exit;

  try
    FileStream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
    try
      if FileStream.Size >= 6 then
      begin
        FileStream.Read(Buffer, 6);
        // GIF signature: GIF87a ou GIF89a
        Result := (Buffer[0] = $47) and (Buffer[1] = $49) and (Buffer[2] = $46) and
                  (Buffer[3] = $38) and ((Buffer[4] = $37) or (Buffer[4] = $39)) and
                  (Buffer[5] = $61);
      end;
    finally
      FileStream.Free;
    end;
  except
    Result := False;
  end;
end;

function TDTImagem.IsWebPFile(const FileName: string): Boolean;
var
  FileStream: TFileStream;
  Buffer: array[0..11] of Byte;
begin
  Result := False;
  if not FileExists(FileName) then Exit;

  try
    FileStream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
    try
      if FileStream.Size >= 12 then
      begin
        FileStream.Read(Buffer, 12);
        // WebP signature: RIFF....WEBP
        Result := (Buffer[0] = $52) and (Buffer[1] = $49) and (Buffer[2] = $46) and
                  (Buffer[3] = $46) and (Buffer[8] = $57) and (Buffer[9] = $45) and
                  (Buffer[10] = $42) and (Buffer[11] = $50);
      end;
    finally
      FileStream.Free;
    end;
  except
    Result := False;
  end;
end;

function TDTImagem.DetectImageTypeFromFile(const FileName: string): string;
begin
  if IsJPEGFile(FileName) then
    Result := 'jpeg'
  else if IsPNGFile(FileName) then
    Result := 'png'
  else if IsGIFFile(FileName) then
    Result := 'gif'
  else if IsWebPFile(FileName) then
    Result := 'webp'
  else
    Result := 'unknown';
end;

function TDTImagem.LoadAnyImageAsJPEG(const FileName: string; Quality: Integer = 90): TMemoryStream;
var
  BMP: TBitmap;
  JPG: TJPEGImage;
  PNG: TPNGImage;
  GIF: TGIFImage;
  ImageType: string;
  Loaded: Boolean;
begin
  Result := nil;
  if not FileExists(FileName) then Exit;

  BMP := TBitmap.Create;
  JPG := TJPEGImage.Create;
  PNG := nil;
  GIF := nil;
  Loaded := False;

  try
    // Detecta o tipo real pelo conteúdo
    ImageType := DetectImageTypeFromFile(FileName);

    try
      // Tenta carregar pelo tipo detectado
      if (ImageType = 'jpeg') and (not Loaded) then
      begin
        try
          JPG.LoadFromFile(FileName);
          BMP.Assign(JPG);
          Loaded := True;
        except
          Loaded := False;
        end;
      end;

      if (ImageType = 'png') and (not Loaded) then
      begin
        try
          PNG := TPNGImage.Create;
          PNG.LoadFromFile(FileName);
          BMP.Assign(PNG);
          Loaded := True;
        except
          Loaded := False;
          FreeAndNil(PNG);
        end;
      end;

      if (ImageType = 'gif') and (not Loaded) then
      begin
        try
          GIF := TGIFImage.Create;
          GIF.LoadFromFile(FileName);
          BMP.Assign(GIF);
          Loaded := True;
        except
          Loaded := False;
          FreeAndNil(GIF);
        end;
      end;

      // Se não carregou ainda (webp ou unknown), tenta todos os formatos
      if not Loaded then
      begin
        // Tenta como PNG primeiro (muito comum em downloads)
        try
          if not Assigned(PNG) then
            PNG := TPNGImage.Create;
          PNG.LoadFromFile(FileName);
          BMP.Assign(PNG);
          Loaded := True;
        except
          Loaded := False;
        end;
      end;

      if not Loaded then
      begin
        // Tenta como JPEG
        try
          JPG.LoadFromFile(FileName);
          BMP.Assign(JPG);
          Loaded := True;
        except
          Loaded := False;
        end;
      end;

      if not Loaded then
      begin
        // Tenta como GIF
        try
          if not Assigned(GIF) then
            GIF := TGIFImage.Create;
          GIF.LoadFromFile(FileName);
          BMP.Assign(GIF);
          Loaded := True;
        except
          Loaded := False;
        end;
      end;

      if not Loaded then
      begin
        // Tenta como BMP direto
        try
          BMP.LoadFromFile(FileName);
          Loaded := True;
        except
          Loaded := False;
        end;
      end;

      // Se conseguiu carregar, converte para JPEG
      if Loaded and (BMP.Width > 0) and (BMP.Height > 0) then
      begin
        JPG.Assign(BMP);
        JPG.CompressionQuality := Quality;

        Result := TMemoryStream.Create;
        JPG.SaveToStream(Result);
        Result.Position := 0;
      end;

    except
      on E: Exception do
      begin
        FreeAndNil(Result);
      end;
    end;
  finally
    BMP.Free;
    JPG.Free;
    if Assigned(PNG) then PNG.Free;
    if Assigned(GIF) then GIF.Free;
  end;
end;

procedure TDTImagem.RedimensionarImagem(const CaminhoDaImagem: string);
begin
  if FRedimensionar then
    RedimensionarImagemPersonalizada(CaminhoDaImagem, FAlturaRedimensionada, FLarguraRedimensionada);
end;

procedure TDTImagem.RedimensionarImagemPersonalizada(const CaminhoDaImagem: string; Altura, Largura: Integer);
var
  bmp, bmp1: TBitmap;
  jpg: TJPEGImage;
  png: TPNGImage;
  scaleX, scaleY, scale: Double;
  newWidth, newHeight: integer;
  srcRect, destRect: TRect;
  offsetX, offsetY: integer;
  TipoOriginal: string;
  CaminhoFinal: string;
begin
  if not FileExists(CaminhoDaImagem) then Exit;

  try
    jpg := TJPEGImage.Create;
    png := TPNGImage.Create;
    bmp1 := TBitmap.Create;

    try
      TipoOriginal := LowerCase(ExtractFileExt(CaminhoDaImagem));

      // Carrega a imagem baseado no tipo
      try
        if IsJPEGFile(CaminhoDaImagem) or (TipoOriginal = '.jpg') or (TipoOriginal = '.jpeg') then
        begin
          jpg.LoadFromFile(CaminhoDaImagem);
          TipoOriginal := '.jpg';
        end
        else if TipoOriginal = '.png' then
        begin
          png.LoadFromFile(CaminhoDaImagem);
          jpg.Assign(png);
          TipoOriginal := '.png';
        end
        else
        begin
          bmp1.LoadFromFile(CaminhoDaImagem);
          jpg.Assign(bmp1);
          TipoOriginal := '.jpg'; // Converte para JPG por padrão
        end;
      except
        // Fallback: tenta carregar como bitmap genérico
        try
          bmp1.LoadFromFile(CaminhoDaImagem);
          jpg.Assign(bmp1);
          TipoOriginal := '.jpg';
        except
          Exit; // Se não conseguir carregar, sai
        end;
      end;

      // Se ManterAspecto = True, calcula proporções
      if FManterAspecto then
      begin
        scaleX := Largura / jpg.Width;
        scaleY := Altura / jpg.Height;
        scale := Min(scaleX, scaleY); // Usa menor escala para manter dentro dos limites

        newWidth := Round(jpg.Width * scale);
        newHeight := Round(jpg.Height * scale);

        // Centraliza na área desejada
        offsetX := (Largura - newWidth) div 2;
        offsetY := (Altura - newHeight) div 2;

        bmp := TBitmap.Create;
        try
          bmp.SetSize(Largura, Altura);
          bmp.Canvas.Brush.Color := clWhite; // Fundo branco
          bmp.Canvas.FillRect(Rect(0, 0, Largura, Altura));

          // Desenha a imagem redimensionada e centralizada
          destRect := Rect(offsetX, offsetY, offsetX + newWidth, offsetY + newHeight);
          bmp.Canvas.StretchDraw(destRect, jpg);

          jpg.Assign(bmp);
        finally
          bmp.Free;
        end;
      end
      else
      begin
        // Redimensionamento com crop (método original otimizado)
        scaleX := Largura / jpg.Width;
        scaleY := Altura / jpg.Height;
        scale := Max(scaleX, scaleY); // Usa maior escala para preencher completamente

        newWidth := Round(jpg.Width * scale);
        newHeight := Round(jpg.Height * scale);

        offsetX := (newWidth - Largura) div 2;
        offsetY := (newHeight - Altura) div 2;

        bmp := TBitmap.Create;
        try
          bmp.SetSize(Largura, Altura);

          srcRect := Rect(0, 0, jpg.Width, jpg.Height);
          destRect := Rect(-offsetX, -offsetY, newWidth - offsetX, newHeight - offsetY);

          bmp.Canvas.StretchDraw(destRect, jpg);
          jpg.Assign(bmp);
        finally
          bmp.Free;
        end;
      end;

      // Configura qualidade de compressão
      jpg.CompressionQuality := FQualidadeCompressao;

      // Salva o arquivo
      try
        if FileExists(CaminhoDaImagem) then
          DeleteFile(CaminhoDaImagem);
      except
        // Ignora erro de delete
      end;

      // Define caminho final baseado no tipo original ou forçando JPEG
      if TipoOriginal = '.png' then
        CaminhoFinal := ChangeFileExt(CaminhoDaImagem, '.png')
      else
        CaminhoFinal := ChangeFileExt(CaminhoDaImagem, '.jpg');

      // Salva conforme o tipo
      if TipoOriginal = '.png' then
      begin
        png.Assign(jpg);
        png.SaveToFile(CaminhoFinal);
      end
      else
      begin
        jpg.SaveToFile(CaminhoFinal);
      end;

      // Atualiza o caminho se mudou a extensão
      if CaminhoFinal <> CaminhoDaImagem then
        FCaminhoImagem := CaminhoFinal;

    finally
      jpg.Free;
      png.Free;
      bmp1.Free;
    end;
  except
    on E: Exception do
    begin
      // Log do erro se necessário, mas não interrompe o fluxo
    end;
  end;
end;

procedure TDTImagem.RedimensionarImagemManual(Largura, Altura: Integer);
begin
  if FileExists(FCaminhoImagem) then
  begin
    RedimensionarImagemPersonalizada(FCaminhoImagem, Altura, Largura);

    // Recarrega a imagem redimensionada
    try
      FImagem.LoadFromFile(FCaminhoImagem);
      FImgBase64 := ImageFileToBase64(FCaminhoImagem);
    except
      // Ignora erro de recarregamento
    end;
  end;
end;

procedure TDTImagem.RedimensionarImagemQuadrada(Tamanho: Integer);
begin
  RedimensionarImagemManual(Tamanho, Tamanho);
end;

procedure TDTImagem.DownloadImage(const AURL, AFileName: string);
var
  HTTPClient: THTTPClient;
  MemStream: TMemoryStream;
  TempFile: string;
  JPEGStream: TMemoryStream;
  ImageType: string;
begin
  if (AURL = '') or (Pos('http', AURL) <> 1) then
    Exit;

  HTTPClient := THTTPClient.Create;
  MemStream := TMemoryStream.Create;
  try
    try
      HTTPClient.UserAgent := 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';
      // Não aceita WebP pois Delphi não tem suporte nativo
      HTTPClient.CustomHeaders['Accept'] := 'image/jpeg,image/png,image/gif,image/bmp,image/*;q=0.5';
      HTTPClient.CustomHeaders['Accept-Language'] := 'pt-BR,pt;q=0.9,en;q=0.8';
      HTTPClient.CustomHeaders['Referer'] := 'https://www.bing.com/';
      HTTPClient.HandleRedirects := True;

      HTTPClient.Get(AURL, MemStream);

      // Só salva se recebeu dados
      if MemStream.Size > 100 then
      begin
        MemStream.Position := 0;

        // Salva temporariamente para detectar o tipo real
        TempFile := ChangeFileExt(AFileName, '.tmp');
        MemStream.SaveToFile(TempFile);

        try
          // Detecta o tipo real da imagem pelo conteúdo
          ImageType := DetectImageTypeFromFile(TempFile);

          // Se for WebP, não salva (Delphi não suporta)
          if ImageType = 'webp' then
          begin
            if FileExists(TempFile) then
              DeleteFile(TempFile);
            Exit;
          end;

          // Se já é JPEG, apenas renomeia
          if ImageType = 'jpeg' then
          begin
            if FileExists(AFileName) then
              DeleteFile(AFileName);
            RenameFile(TempFile, AFileName);
          end
          else
          begin
            // Converte para JPEG real antes de salvar
            JPEGStream := LoadAnyImageAsJPEG(TempFile, FQualidadeCompressao);
            try
              if Assigned(JPEGStream) and (JPEGStream.Size > 0) then
              begin
                if FileExists(AFileName) then
                  DeleteFile(AFileName);
                JPEGStream.SaveToFile(AFileName);
              end;
              // Se conversão falhar, NÃO salva o arquivo (evita erro depois)
            finally
              if Assigned(JPEGStream) then
                JPEGStream.Free;
            end;

            // Remove arquivo temporário
            if FileExists(TempFile) then
              DeleteFile(TempFile);
          end;
        except
          // Em caso de erro, remove temporário e não salva nada
          if FileExists(TempFile) then
            DeleteFile(TempFile);
        end;
      end;
    except
      // Ignora erros de download
    end;
  finally
    MemStream.Free;
    HTTPClient.Free;
  end;
end;

function TDTImagem.GetParametrosTamanho: string;
begin
  case FTipoTamanhoImagem of
    ttiThumbnails:    Result := '&tbm=isch';
    ttiPequenas:      Result := '&tbm=isch&udm=2&tbs=isz:s';
    ttiMedias:        Result := '&tbm=isch&udm=2&tbs=isz:m';
    ttiGrandes:       Result := '&tbm=isch&udm=2&tbs=isz:l';
    ttiExtraGrandes:  Result := '&tbm=isch&udm=2&tbs=isz:xl';
    ttiEnormes:       Result := '&tbm=isch&udm=2&tbs=isz:xxl';
    ttiTodosTamanhos: Result := '&tbm=isch&udm=2';
  else
    Result := '&tbm=isch';
  end;
end;

function TDTImagem.GetDescricaoTamanho: string;
begin
  case FTipoTamanhoImagem of
    ttiThumbnails:    Result := 'Miniaturas (Thumbnails)';
    ttiPequenas:      Result := 'Imagens Pequenas';
    ttiMedias:        Result := 'Imagens Médias';
    ttiGrandes:       Result := 'Imagens Grandes';
    ttiExtraGrandes:  Result := 'Imagens Extra Grandes';
    ttiEnormes:       Result := 'Imagens Enormes';
    ttiTodosTamanhos: Result := 'Todos os Tamanhos';
  else
    Result := 'Miniaturas (Padrão)';
  end;
end;

procedure TDTImagem.SetTipoTamanhoImagem(const Value: TTipoTamanhoImagem);
begin
  FTipoTamanhoImagem := Value;
end;

procedure TDTImagem.SetRedimensionar(const Value: Boolean);
begin
  FRedimensionar := Value;
end;

procedure TDTImagem.SetLarguraRedimensionada(const Value: Integer);
begin
  if Value > 0 then
    FLarguraRedimensionada := Value
  else
    FLarguraRedimensionada := 150; // Valor mínimo
end;

procedure TDTImagem.SetAlturaRedimensionada(const Value: Integer);
begin
  if Value > 0 then
    FAlturaRedimensionada := Value
  else
    FAlturaRedimensionada := 150; // Valor mínimo
end;

procedure TDTImagem.SetManterAspecto(const Value: Boolean);
begin
  FManterAspecto := Value;
end;

procedure TDTImagem.SetQualidadeCompressao(const Value: Integer);
begin
  if (Value >= 1) and (Value <= 100) then
    FQualidadeCompressao := Value
  else if Value < 1 then
    FQualidadeCompressao := 1
  else
    FQualidadeCompressao := 100;
end;

procedure TDTImagem.ExtrairImagensDoHTML(const HTML: string; ImageUrls: TStringList);
var
  I, StartPos, EndPos: Integer;
  TempURL, CleanURL: string;
  URLs: TStringList;
  JsonData: string;
begin
  ImageUrls.Clear;
  URLs := TStringList.Create;
  try
    // BUSCA 1: URLs de alta resolução em dados JSON do Google
    I := 1;
    while I <= Length(HTML) do
    begin
      // Procurar por padrões como ["https://...",width,height]
      StartPos := PosEx('["https://', HTML, I);
      if StartPos = 0 then Break;

      StartPos := StartPos + 2; // Pula ["
      EndPos := StartPos;
      while (EndPos <= Length(HTML)) and (HTML[EndPos] <> '"') do
        Inc(EndPos);

      TempURL := Copy(HTML, StartPos, EndPos - StartPos);

      // Filtrar URLs de imagens válidas (não thumbnails)
      if (Length(TempURL) > 80) and
         (Pos('http', TempURL) = 1) and
         (Pos('gstatic.com', TempURL) = 0) and // Excluir thumbnails do Google
         (Pos('googlelogo', TempURL) = 0) and  // Excluir logos
         ((Pos('.jpg', LowerCase(TempURL)) > 0) or
          (Pos('.jpeg', LowerCase(TempURL)) > 0) or
          (Pos('.png', LowerCase(TempURL)) > 0) or
          (Pos('.webp', LowerCase(TempURL)) > 0)) then
      begin
        CleanURL := DecodeURL(TempURL);
        if URLs.IndexOf(CleanURL) = -1 then
          URLs.Add(CleanURL);
      end;

      I := EndPos;
    end;

    // BUSCA 2: URLs originais em atributos data-src ou similares
    I := 1;
    while I <= Length(HTML) do
    begin
      StartPos := PosEx('data-src="https://', HTML, I);
      if StartPos = 0 then Break;

      StartPos := StartPos + 10; // Pula 'data-src="'
      EndPos := StartPos;
      while (EndPos <= Length(HTML)) and (HTML[EndPos] <> '"') do
        Inc(EndPos);

      TempURL := Copy(HTML, StartPos, EndPos - StartPos);

      if (Length(TempURL) > 50) and
         (Pos('gstatic.com', TempURL) = 0) and
         ((Pos('.jpg', LowerCase(TempURL)) > 0) or
          (Pos('.jpeg', LowerCase(TempURL)) > 0) or
          (Pos('.png', LowerCase(TempURL)) > 0) or
          (Pos('.webp', LowerCase(TempURL)) > 0)) then
      begin
        CleanURL := DecodeURL(TempURL);
        if URLs.IndexOf(CleanURL) = -1 then
          URLs.Add(CleanURL);
      end;

      I := EndPos;
    end;

    // BUSCA 3: URLs em links /imgres?imgurl= (imagens originais)
    I := 1;
    while I <= Length(HTML) do
    begin
      StartPos := PosEx('/imgres?imgurl=', HTML, I);
      if StartPos = 0 then Break;

      StartPos := StartPos + 15; // Pula '/imgres?imgurl='
      EndPos := StartPos;
      while (EndPos <= Length(HTML)) and
            (HTML[EndPos] <> '&') and
            (HTML[EndPos] <> '"') and
            (HTML[EndPos] <> ' ') do
        Inc(EndPos);

      TempURL := Copy(HTML, StartPos, EndPos - StartPos);
      TempURL := StringReplace(TempURL, '%3A', ':', [rfReplaceAll]);
      TempURL := StringReplace(TempURL, '%2F', '/', [rfReplaceAll]);
      TempURL := StringReplace(TempURL, '%3F', '?', [rfReplaceAll]);
      TempURL := StringReplace(TempURL, '%3D', '=', [rfReplaceAll]);

      if (Length(TempURL) > 30) and (Pos('http', TempURL) = 1) then
      begin
        if URLs.IndexOf(TempURL) = -1 then
          URLs.Add(TempURL);
      end;

      I := EndPos;
    end;

    // BUSCA 4: URLs dentro de objetos JavaScript (dados de imagem)
    I := 1;
    while I <= Length(HTML) do
    begin
      StartPos := PosEx('"ou":"', HTML, I);
      if StartPos = 0 then Break;

      StartPos := StartPos + 6; // Pula '"ou":"'
      EndPos := StartPos;
      while (EndPos <= Length(HTML)) and (HTML[EndPos] <> '"') do
        Inc(EndPos);

      TempURL := Copy(HTML, StartPos, EndPos - StartPos);
      TempURL := StringReplace(TempURL, '\u003d', '=', [rfReplaceAll]);
      TempURL := StringReplace(TempURL, '\u0026', '&', [rfReplaceAll]);
      TempURL := StringReplace(TempURL, '\\', '', [rfReplaceAll]);

      if (Length(TempURL) > 50) and (Pos('http', TempURL) = 1) then
      begin
        CleanURL := DecodeURL(TempURL);
        if URLs.IndexOf(CleanURL) = -1 then
          URLs.Add(CleanURL);
      end;

      I := EndPos;
    end;

    // FALLBACK: Se não encontrou nada, usar método anterior
    if URLs.Count = 0 then
    begin
      I := 1;
      while I <= Length(HTML) do
      begin
        StartPos := PosEx('https://encrypted-tbn', HTML, I);
        if StartPos = 0 then Break;

        EndPos := StartPos;
        while (EndPos <= Length(HTML)) and
              (HTML[EndPos] <> '"') and
              (HTML[EndPos] <> '''') and
              (HTML[EndPos] <> ' ') and
              (HTML[EndPos] <> '>') do
          Inc(EndPos);

        TempURL := Copy(HTML, StartPos, EndPos - StartPos);

        if (Length(TempURL) > 50) and (Pos('gstatic.com', TempURL) > 0) then
        begin
          CleanURL := DecodeURL(TempURL);
          if URLs.IndexOf(CleanURL) = -1 then
            URLs.Add(CleanURL);
        end;

        I := EndPos;
      end;
    end;

    // Copiar URLs encontradas (priorizando as de alta resolução)
    for I := 0 to URLs.Count - 1 do
      ImageUrls.Add(URLs[I]);

  finally
    URLs.Free;
  end;
end;

function TDTImagem.DecodeURL(const EncodedURL: string): string;
begin
  Result := EncodedURL;
  Result := StringReplace(Result, '%3A', ':', [rfReplaceAll]);
  Result := StringReplace(Result, '%2F', '/', [rfReplaceAll]);
  Result := StringReplace(Result, '%3F', '?', [rfReplaceAll]);
  Result := StringReplace(Result, '%3D', '=', [rfReplaceAll]);
  Result := StringReplace(Result, '%26', '&', [rfReplaceAll]);
  Result := StringReplace(Result, '%20', ' ', [rfReplaceAll]);
  Result := StringReplace(Result, '\u003d', '=', [rfReplaceAll]);
  Result := StringReplace(Result, '\u0026', '&', [rfReplaceAll]);
  Result := StringReplace(Result, '\"', '"', [rfReplaceAll]);
  Result := StringReplace(Result, '\\', '\', [rfReplaceAll]);

  if Pos('&amp;', Result) > 0 then
    Result := Copy(Result, 1, Pos('&amp;', Result) - 1);
end;

function TDTImagem.DecodeURLEncoded(const EncodedURL: string): string;
begin
  Result := TNetEncoding.URL.Decode(EncodedURL);
end;

procedure TDTImagem.ExtrairImagensDoDuckDuckGo(const HTML: string; ImageUrls: TStringList);
var
  I, StartPos, EndPos: Integer;
  TempURL: string;
  URLs: TStringList;
  SearchPattern: string;
begin
  ImageUrls.Clear;
  URLs := TStringList.Create;
  try
    // MÉTODO PRINCIPAL: Extrair URLs do Bing Images (murl = media URL original)
    // No HTML do Bing, o JSON é codificado com &quot; em vez de "
    // Formato: &quot;murl&quot;:&quot;https://...&quot;
    SearchPattern := '&quot;murl&quot;:&quot;';
    I := 1;
    while I <= Length(HTML) do
    begin
      StartPos := PosEx(SearchPattern, HTML, I);
      if StartPos = 0 then Break;

      StartPos := StartPos + Length(SearchPattern);
      EndPos := PosEx('&quot;', HTML, StartPos);

      if EndPos > StartPos then
      begin
        TempURL := Copy(HTML, StartPos, EndPos - StartPos);

        // Decodificar caracteres de escape
        TempURL := StringReplace(TempURL, '\/', '/', [rfReplaceAll]);
        TempURL := StringReplace(TempURL, '&amp;', '&', [rfReplaceAll]);

        if (Pos('http', TempURL) = 1) and (Length(TempURL) > 20) then
        begin
          if URLs.IndexOf(TempURL) = -1 then
            URLs.Add(TempURL);
        end;

        I := EndPos + 1;
      end
      else
        Break;
    end;

    // MÉTODO 2: Tentar formato alternativo com aspas normais (caso o Bing mude)
    if URLs.Count = 0 then
    begin
      I := 1;
      while I <= Length(HTML) do
      begin
        StartPos := PosEx('"murl":"', HTML, I);
        if StartPos = 0 then Break;

        StartPos := StartPos + 8;
        EndPos := StartPos;

        while (EndPos <= Length(HTML)) and (HTML[EndPos] <> '"') do
          Inc(EndPos);

        TempURL := Copy(HTML, StartPos, EndPos - StartPos);
        TempURL := StringReplace(TempURL, '\/', '/', [rfReplaceAll]);

        if (Pos('http', TempURL) = 1) and (Length(TempURL) > 20) then
        begin
          if URLs.IndexOf(TempURL) = -1 then
            URLs.Add(TempURL);
        end;

        I := EndPos + 1;
      end;
    end;

    // MÉTODO 3: Extrair URLs de thumbnails do Bing (formato th?id=) como fallback
    if URLs.Count = 0 then
    begin
      I := 1;
      while I <= Length(HTML) do
      begin
        StartPos := PosEx('src="https://tse', HTML, I);
        if StartPos = 0 then Break;

        StartPos := StartPos + 5; // Pula 'src="'
        EndPos := StartPos;

        while (EndPos <= Length(HTML)) and (HTML[EndPos] <> '"') do
          Inc(EndPos);

        TempURL := Copy(HTML, StartPos, EndPos - StartPos);
        TempURL := StringReplace(TempURL, '&amp;', '&', [rfReplaceAll]);

        if (Pos('https://tse', TempURL) = 1) and (Length(TempURL) > 30) then
        begin
          if URLs.IndexOf(TempURL) = -1 then
            URLs.Add(TempURL);
        end;

        I := EndPos + 1;
      end;
    end;

    // Copiar URLs encontradas
    for I := 0 to URLs.Count - 1 do
      ImageUrls.Add(URLs[I]);

  finally
    URLs.Free;
  end;
end;

procedure TDTImagem.Buscar(Codigo: string; Descricao: string; NomeDaImagem: string = '');
var
  Pesquisa, Response, img64, memo2: string;
  Resultado: TStringList;
  HttpClient: THTTPClient;
  AStream: TMemoryStream;
  DownloadOK: Boolean;
  I, retorno: Integer;
  FrmStatus: TfrmStatusx;
  ResponseStream: TStringStream;
  Conteudo: string;
  Buffer: TBytes;
  ImageUrls: TStringList;
  URLCompleta: string;
begin
  try
    if FMostrarBarraStatus then
    begin
      FrmStatus := TfrmStatusx.Create(nil);
      FrmStatus.Show;
      FrmStatus.BringToFront;
      FrmStatus.lblStatus.Caption := 'Buscando imagens (' + GetDescricaoTamanho + ')';
    end;
    Application.ProcessMessages;

    HttpClient := THTTPClient.Create;
    ImageUrls := TStringList.Create;
    DownloadOK := False;

    if Length(NomeDaImagem) > 0 then
      FCaminhoImagem := IncludeTrailingPathDelimiter(FCaminhoImagem) + NomeDaImagem + '.jpg'
    else
      FCaminhoImagem := IncludeTrailingPathDelimiter(FCaminhoImagem) + Codigo + '.jpg';

    if not DirectoryExists(ExtractFilePath(FCaminhoImagem)) then
      ForceDirectories(ExtractFilePath(FCaminhoImagem));

    try
      if FileExists(FCaminhoImagem) then
        DeleteFile(FCaminhoImagem);

      // Tentativa 1: Cosmos
      if FCosmos then
      begin
        if FMostrarBarraStatus then
          FrmStatus.lblStatus.Caption := 'Tentando Cosmos';

        AStream := TMemoryStream.Create;
        try
          try
            HttpClient.Get('https://cdn-cosmos.bluesoft.com.br/products/' + Codigo, AStream);
            if AStream.Size > 0 then
            begin
              SetLength(Buffer, Min(AStream.Size, 512));
              AStream.Position := 0;
              AStream.ReadBuffer(Buffer[0], Length(Buffer));
              Conteudo := TEncoding.UTF8.GetString(Buffer);

              if (Pos('<html', LowerCase(Conteudo)) > 0) or (Pos('404', Conteudo) > 0) then
                retorno := -1
              else
                retorno := 0;

              if retorno = 0 then
              begin
                AStream.Position := 0;
                try
                  AStream.SaveToFile(FCaminhoImagem);
                  retorno := 0;
                except
                  on E: Exception do
                    retorno := -1;
                end;
              end;
            end
            else
              retorno := -1;
          except
            retorno := -1;
          end;

          if (retorno = 0) and FileExists(FCaminhoImagem) then
          begin
            // Redimensionar se necessário
            if FRedimensionar then
            begin
              if FMostrarBarraStatus then
                FrmStatus.lblStatus.Caption := 'Redimensionando imagem';
              RedimensionarImagem(FCaminhoImagem);
            end;

            // Preencher propriedades da imagem
            FTipoImagem := IdentificarTipoImagem(FCaminhoImagem);

            // Recarregar para obter tamanho correto (pode ter sido redimensionado)
            AStream.Clear;
            AStream.LoadFromFile(FCaminhoImagem);
            FTamanhoKB := AStream.Size / 1024;

            FImgBase64 := ImageFileToBase64(FCaminhoImagem);
            FImagem.LoadFromFile(FCaminhoImagem);
            DownloadOK := True;
          end;
        finally
          AStream.Free;
        end;
      end;
    except
      DownloadOK := False;
    end;

    // Tentativa 2: Bing Images (substitui Google/DuckDuckGo que agora requerem JavaScript)
    if not DownloadOK then
    begin
      if FMostrarBarraStatus then
        FrmStatus.lblStatus.Caption := 'Buscando no Bing Images (' + GetDescricaoTamanho + ')';

      Pesquisa := Trim(Codigo + ' ' + Descricao).Replace(' ', '+');
      Resultado := TStringList.Create;
      try
        // Configurar headers para simular navegador
        HttpClient.UserAgent := 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';
        HttpClient.CustomHeaders['Accept'] := 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8';
        HttpClient.CustomHeaders['Accept-Language'] := 'pt-BR,pt;q=0.9,en;q=0.8';

        ResponseStream := TStringStream.Create('', TEncoding.UTF8);

        try
          // URL do Bing Images
          URLCompleta := 'https://www.bing.com/images/search?q=' + Pesquisa + '&form=HDRSC2&first=1';

          HttpClient.Get(URLCompleta, ResponseStream);
          Response := ResponseStream.DataString;
        finally
          ResponseStream.Free;
        end;

        // Extrair imagens do HTML do Bing
        ExtrairImagensDoDuckDuckGo(Response, ImageUrls);

        if ImageUrls.Count > 0 then
        begin
          if FHabilitaSeletor then
          begin
            FrmSeletor := TFrmSeletor.Create(nil);
            try
              if FrmSeletor.cdsIMG.Active then
                FrmSeletor.cdsIMG.EmptyDataSet
              else
                FrmSeletor.cdsIMG.CreateDataSet;

              FrmSeletor.Carregando := True;
              for I := 0 to Pred(ImageUrls.Count) do
              begin
                if (Pos('http', ImageUrls[I]) > 0) then
                begin
                  FrmSeletor.cdsIMG.Append;
                  FrmSeletor.cdsIMGID.AsInteger := I + 1;
                  FrmSeletor.cdsIMGURL.AsString := ImageUrls[I];
                  FrmSeletor.cdsIMG.Post;
                end;
              end;

              FrmSeletor.ShowModal;
              img64 := FrmSeletor.UrlImagem;
            finally
              FrmSeletor.Free;
            end;
          end
          else
          begin
            // Tentar cada URL até encontrar uma que funcione
            img64 := '';
            for I := 0 to Pred(ImageUrls.Count) do
            begin
              if (Pos('http', ImageUrls[I]) > 0) then
              begin
                if FMostrarBarraStatus then
                  FrmStatus.lblStatus.Caption := 'Testando imagem ' + IntToStr(I + 1) + ' de ' + IntToStr(ImageUrls.Count);
                Application.ProcessMessages;

                // Tentar baixar a imagem
                DownloadImage(ImageUrls[I], FCaminhoImagem);

                // Verificar se baixou corretamente (arquivo existe e tem tamanho mínimo)
                if FileExists(FCaminhoImagem) then
                begin
                  try
                    AStream := TMemoryStream.Create;
                    try
                      AStream.LoadFromFile(FCaminhoImagem);
                      if AStream.Size > 500 then
                      begin
                        img64 := ImageUrls[I];
                        Break; // Encontrou uma imagem válida
                      end
                      else
                        DeleteFile(FCaminhoImagem); // Arquivo muito pequeno, deletar
                    finally
                      AStream.Free;
                    end;
                  except
                    if FileExists(FCaminhoImagem) then
                      DeleteFile(FCaminhoImagem);
                  end;
                end;
              end;
            end;
          end;
        end
        else
        begin
          // Fallback: Usar método anterior do Google para thumbnails base64
          if FMostrarBarraStatus then
            FrmStatus.lblStatus.Caption := 'Tentando Google (fallback)';

          URLCompleta := 'https://www.google.com/search?q=' + Pesquisa + GetParametrosTamanho;
          ResponseStream := TStringStream.Create('', TEncoding.ANSI);
          try
            HttpClient.Get(URLCompleta, ResponseStream);
            Response := ResponseStream.DataString;
          finally
            ResponseStream.Free;
          end;

          // Tentar extrair thumbnails base64 do Google
          GetValorCampoHtml(Response, 'IMG', '', 0, Resultado);
          if Resultado.Count > 1 then
            img64 := Resultado[1].Replace('data:image/jpeg;base64,', '');

          // Ou tentar extrair URLs de imagens
          if (img64 = '') or (Pos('http', img64) = 0) then
          begin
            ExtrairImagensDoHTML(Response, ImageUrls);
            if ImageUrls.Count > 0 then
              img64 := ImageUrls[0];
          end;
        end;

        if img64 <> '' then
        begin
          // Baixar a imagem selecionada (do seletor ou fallback)
          // Sempre baixa para garantir que a imagem correta seja salva
          if FMostrarBarraStatus then
            FrmStatus.lblStatus.Caption := 'Baixando imagem selecionada';

          // Deletar arquivo anterior se existir
          if FileExists(FCaminhoImagem) then
            DeleteFile(FCaminhoImagem);

          DownloadImage(img64, FCaminhoImagem);

          if FileExists(FCaminhoImagem) then
          begin
            // Redimensionar após download
            if FRedimensionar then
            begin
              if FMostrarBarraStatus then
                FrmStatus.lblStatus.Caption := 'Redimensionando imagem';
              RedimensionarImagem(FCaminhoImagem);
            end;

            // Preencher propriedades da imagem
            try
              // Tipo da imagem
              FTipoImagem := IdentificarTipoImagem(FCaminhoImagem);

              // Tamanho em KB
              AStream := TMemoryStream.Create;
              try
                AStream.LoadFromFile(FCaminhoImagem);
                FTamanhoKB := AStream.Size / 1024;
              finally
                AStream.Free;
              end;

              // Base64
              FImgBase64 := ImageFileToBase64(FCaminhoImagem);

              // Carregar imagem no TPicture
              FImagem.LoadFromFile(FCaminhoImagem);
            except
              // Ignora erros
            end;
          end;
        end;
      finally
        Resultado.Free;
        ImageUrls.Free;
      end;
    end;
  except
    on E: Exception do
    begin
      // Fallback
      memo2 := Copy(Response, Pos('src="https://', Response) + 5);
      memo2 := Copy(memo2, 1, Pos('"', memo2) - 1);
      retorno := URLDownloadToFile(nil, PChar(memo2), PChar(FCaminhoImagem), 0, nil);

      // Redimensionar também no fallback
      if (retorno = 0) and FileExists(FCaminhoImagem) and FRedimensionar then
        RedimensionarImagem(FCaminhoImagem);

      AStream := TMemoryStream.Create;
      try
        AStream.LoadFromStream(ConvertJPG_BMP(FCaminhoImagem));
        AStream.Position := 0;
        FImgBase64 := ImageFileToBase64(FCaminhoImagem);
      finally
        AStream.Free;
      end;
    end;
  end;

  HttpClient.Free;
  if FMostrarBarraStatus then
    FrmStatus.Free;
end;

function TDTImagem.VerificarAssinaturaJPEG(xFile: string): Boolean;
var
  FileStream: TFileStream;
  StartBytes: Word;
  EndBytes: Word;
begin
  Result := False;
  if not FileExists(xFile) then
    Exit;

  FileStream := TFileStream.Create(xFile, fmOpenRead or fmShareDenyNone);
  try
    // Verifica se o arquivo começa com a assinatura JPEG (FFD8)
    FileStream.Read(StartBytes, SizeOf(StartBytes));
    StartBytes := Swap(StartBytes); // Converte para o formato correto de leitura
    if StartBytes <> $FFD8 then
      Exit; // Não é um arquivo JPEG válido

    // Agora, verifica se o arquivo termina com a assinatura JPEG (FFD9)
    FileStream.Seek(-2, soEnd);  // Move para os últimos 2 bytes
    FileStream.Read(EndBytes, SizeOf(EndBytes));
    EndBytes := Swap(EndBytes); // Converte para o formato correto de leitura
    if EndBytes <> $FFD9 then
      Exit; // Não é um arquivo JPEG válido

    // Se as assinaturas inicial e final estão corretas, o arquivo é um JPEG válido
    Result := True;
  finally
    FileStream.Free;
  end;
end;

function TDTImagem.RepararJPEG(xFile: string): Boolean;
var
  JPG: TJPEGImage;
  FotoStream: TMemoryStream;
begin
  Result     := False;
  JPG        := TJPEGImage.Create;
  FotoStream := TMemoryStream.Create;
  try
    try
      JPG.LoadFromFile(xFile);
      JPG.SaveToFile(xFile);
      Result := True;
    except
      on E: Exception do
      begin
        // Erro silencioso
      end;
    end;
  finally
    JPG.Free;
    FotoStream.Free;
  end;
end;

function TDTImagem.ConvertJPG_BMP(xFile: string): TMemoryStream;
var
  BMP     : TBitmap;
  JPG     : TJPEGImage;
  PNG     : TPNGImage;
  GIF     : TGIFImage;
  Foto    : TMemoryStream;
  vPassou : Boolean;
  FileSize: Int64;
  F: TFileStream;
  ImageType: string;
begin
  Result  := nil;
  vPassou := false;

  // Verificar se o arquivo existe e tem tamanho mínimo
  if not FileExists(xFile) then
    Exit;

  try
    F := TFileStream.Create(xFile, fmOpenRead or fmShareDenyNone);
    try
      FileSize := F.Size;
    finally
      F.Free;
    end;
  except
    Exit;
  end;

  if FileSize < 100 then
    Exit;

  // Detecta o tipo real da imagem pelo conteúdo (não pela extensão)
  ImageType := DetectImageTypeFromFile(xFile);

  JPG := TJPEGImage.Create;
  BMP := TBitmap.Create;
  PNG := nil;
  GIF := nil;
  Foto := nil;

  try
    try
      // Carrega baseado no tipo real detectado
      case AnsiIndexStr(ImageType, ['jpeg', 'png', 'gif']) of
        0: // JPEG real
          begin
            JPG.LoadFromFile(xFile);
            BMP.Assign(JPG);
            vPassou := True;
          end;
        1: // PNG real (mesmo que extensão seja .jpg)
          begin
            PNG := TPNGImage.Create;
            PNG.LoadFromFile(xFile);
            BMP.Assign(PNG);
            JPG.Assign(BMP);
            vPassou := True;
          end;
        2: // GIF real
          begin
            GIF := TGIFImage.Create;
            GIF.LoadFromFile(xFile);
            BMP.Assign(GIF);
            JPG.Assign(BMP);
            vPassou := True;
          end;
      else
        // Tipo desconhecido - tenta como JPEG primeiro, depois PNG
        try
          JPG.LoadFromFile(xFile);
          BMP.Assign(JPG);
          vPassou := True;
        except
          try
            PNG := TPNGImage.Create;
            PNG.LoadFromFile(xFile);
            BMP.Assign(PNG);
            JPG.Assign(BMP);
            vPassou := True;
          except
            // Tentar reparar JPEG como último recurso
            if RepararJPEG(xFile) then
            begin
              JPG.LoadFromFile(xFile);
              BMP.Assign(JPG);
              vPassou := True;
            end;
          end;
        end;
      end;
    except
      vPassou := False;
    end;

    if vPassou then
    begin
      try
        Foto := TMemoryStream.Create;
        BMP.SaveToStream(Foto);
        Foto.Position := 0;
        Result := Foto;
        FImagem.Assign(JPG);
      except
        FreeAndNil(Foto);
        Result := nil;
      end;
    end;
  finally
    FreeAndNil(JPG);
    FreeAndNil(BMP);
    if Assigned(PNG) then FreeAndNil(PNG);
    if Assigned(GIF) then FreeAndNil(GIF);
  end;
end;

function TDTImagem.GetValorCampoHtml(FHTML, FTag, FTagNome: string;
  FProximos: Integer; const FResultado: TStringList): string;
var
  doc: OleVariant;
  el: OleVariant;
  i, j: Integer;
  HTML :string;
begin
  Result := '';
  doc    := coHTMLDocument.Create as IHTMLDocument2;
  doc.write(FHTML);
  doc.close;
  for i := 0 to doc.body.all.length - 1 do
  begin
    el := doc.body.all.item(i);
    if (el.tagName = FTag) then
    begin
          if Assigned(FResultado) then
            FResultado.Add(Trim(el.src))
          else
          begin
            Result := Result + Trim(el.src);
            exit;
          end;
    end;
  end;
end;

function TDTImagem.IdentificarTipoImagem(const FileName: string): string;
var
  FileStream: TFileStream;
  Buffer: array[0..7] of Byte; // Buffer para os primeiros bytes do arquivo
begin
  Result := 'Desconhecido'; // Valor padrão caso o tipo não seja identificado

  // Abrir o arquivo em modo leitura
  FileStream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    // Ler os primeiros 8 bytes (alguns formatos como PNG precisam de mais de 4)
    FileStream.ReadBuffer(Buffer, SizeOf(Buffer));

    // Verificar se é um arquivo JPEG (Assinatura: FF D8 FF)
    if (Buffer[0] = $FF) and (Buffer[1] = $D8) and (Buffer[2] = $FF) then
      Result := 'JPEG'

    // Verificar se é um arquivo PNG (Assinatura: 89 50 4E 47 0D 0A 1A 0A)
    else if (Buffer[0] = $89) and (Buffer[1] = $50) and (Buffer[2] = $4E) and
            (Buffer[3] = $47) and (Buffer[4] = $0D) and (Buffer[5] = $0A) and
            (Buffer[6] = $1A) and (Buffer[7] = $0A) then
      Result := 'PNG'

    // Verificar se é um arquivo GIF (Assinatura: GIF87a ou GIF89a)
    else if (Buffer[0] = $47) and (Buffer[1] = $49) and (Buffer[2] = $46) then
      Result := 'GIF'

    // Verificar se é um arquivo BMP (Assinatura: 42 4D)
    else if (Buffer[0] = $42) and (Buffer[1] = $4D) then
      Result := 'BMP';

  finally
    FileStream.Free; // Fechar o arquivo
  end;
end;

procedure TDTImagem.setCosmos(const Value: Boolean);
begin
  FCosmos := Value;
end;

procedure TDTImagem.setFImagem(const Value: TPicture);
begin
  FImagem := Value;
end;

procedure TDTImagem.SetHabilitaSeletor(const Value: boolean);
begin
  FHabilitaSeletor := Value;
end;

procedure TDTImagem.stCaminhoImagem(const Value: string);
begin
  FCaminhoImagem := Value;
end;

end.
