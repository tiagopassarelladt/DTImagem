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
  System.StrUtils,
  System.IOUtils;

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
    procedure setFImagem(const Value: TPicture);
    procedure setCosmos(const Value: Boolean);
    procedure SetHabilitaSeletor(const Value: boolean);
    function IdentificarTipoImagem(const FileName: string): string;
    function ImageFileToBase64(const FilePath: string): string;
    function IsJPEGFile(const FileName: string): Boolean;

    // FUNÇÕES PARA BUSCA AVANÇADA
    procedure ExtrairImagensDoDuckDuckGo(const HTML: string; ImageUrls: TStringList);
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
  HttpClient: THTTPClient;
  ResponseStream: TMemoryStream;
  Response: string;
  URLCompleta: string;
  Pesquisa: string;
  ImageUrls: TStringList;
  Resultado: TStringList;
  DownloadOK: Boolean;
  I: Integer;
  FrmStatus: TfrmStatusx;
  imgSelecionada: string;
begin
  DownloadOK := False;
  ImageUrls := TStringList.Create;
  Resultado := TStringList.Create;
  FrmStatus := nil;

  try
    // STATUS UI
    if FMostrarBarraStatus then
    begin
      FrmStatus := TfrmStatusx.Create(nil);
      FrmStatus.Show;
      FrmStatus.BringToFront;
      FrmStatus.lblStatus.Caption := 'Iniciando busca...';
      Application.ProcessMessages;
    end;

    // CAMINHO
    if Length(NomeDaImagem) > 0 then
      FCaminhoImagem := IncludeTrailingPathDelimiter(FCaminhoImagem) + NomeDaImagem + '.jpg'
    else
      FCaminhoImagem := IncludeTrailingPathDelimiter(FCaminhoImagem) + Codigo + '.jpg';

    if not DirectoryExists(ExtractFilePath(FCaminhoImagem)) then
      ForceDirectories(ExtractFilePath(FCaminhoImagem));

    if FileExists(FCaminhoImagem) then
      DeleteFile(FCaminhoImagem);

    // COSMOS
    if FCosmos then
    begin
      if Assigned(FrmStatus) then
        FrmStatus.lblStatus.Caption := 'Tentando Cosmos...';

      HttpClient := THTTPClient.Create;
      ResponseStream := TMemoryStream.Create;
      try
        try
          HttpClient.Get('https://cdn-cosmos.bluesoft.com.br/products/' + Codigo, ResponseStream);

          if ResponseStream.Size > 0 then
          begin
            ResponseStream.Position := 0;
            ResponseStream.SaveToFile(FCaminhoImagem);

            if FileExists(FCaminhoImagem) then
              DownloadOK := True;
          end;
        except
          DownloadOK := False;
        end;
      finally
        ResponseStream.Free;
        HttpClient.Free;
      end;
    end;

    // BING
    if not DownloadOK then
    begin
      if Assigned(FrmStatus) then
        FrmStatus.lblStatus.Caption := 'Buscando no Bing...';

      Pesquisa := Trim(Codigo + ' ' + Descricao).Replace(' ', '+');

      HttpClient := THTTPClient.Create;
      ResponseStream := TMemoryStream.Create;
      try
        HttpClient.UserAgent := 'Mozilla/5.0';
        URLCompleta := 'https://www.bing.com/images/search?q=' + Pesquisa;

        HttpClient.Get(URLCompleta, ResponseStream);

        if ResponseStream.Size = 0 then
          Exit;

        SetString(Response, PAnsiChar(ResponseStream.Memory), ResponseStream.Size);
      finally
        ResponseStream.Free;
        HttpClient.Free;
      end;

      ExtrairImagensDoDuckDuckGo(Response, ImageUrls);

      // SELETOR
      if (ImageUrls.Count > 0) and FHabilitaSeletor then
      begin
        if Assigned(FrmStatus) then
          FrmStatus.lblStatus.Caption := 'Selecione uma imagem...';

        FrmSeletor := TFrmSeletor.Create(nil);
        try
          FrmSeletor.Carregando := True;

          if not FrmSeletor.cdsIMG.Active then
            FrmSeletor.cdsIMG.CreateDataSet
          else
            FrmSeletor.cdsIMG.EmptyDataSet;

          for I := 0 to Pred(ImageUrls.Count) do
          begin
            if Pos('http', ImageUrls[I]) > 0 then
            begin
              FrmSeletor.cdsIMG.Append;
              FrmSeletor.cdsIMGID.AsInteger := I + 1;
              FrmSeletor.cdsIMGURL.AsString := ImageUrls[I];
              FrmSeletor.cdsIMG.Post;
            end;
          end;

          FrmSeletor.ShowModal;
          imgSelecionada := FrmSeletor.UrlImagem;
        finally
          FrmSeletor.Free;
        end;
      end
        else
      if ImageUrls.Count > 0 then
        begin
          // automático - busca imagem válida com preferência por JPEG
          imgSelecionada := '';
          
          // PRIMEIRA TENTATIVA: Procurar especificamente por JPEG válido
          for I := 0 to Pred(ImageUrls.Count) do
          begin
            if Assigned(FrmStatus) then
            begin
              FrmStatus.lblStatus.Caption := 'Buscando JPEG válido ' + IntToStr(I + 1) + '/' + IntToStr(ImageUrls.Count);
              Application.ProcessMessages;
            end;

            try
              HttpClient := THTTPClient.Create;
              ResponseStream := TMemoryStream.Create;
              try
                HttpClient.Get(ImageUrls[I], ResponseStream);

                if ResponseStream.Size > 500 then
                begin
                  ResponseStream.Position := 0;
                  ResponseStream.SaveToFile(FCaminhoImagem);
                  
                  // Validar se é JPEG válido
                  if IsJPEGFile(FCaminhoImagem) then
                  begin
                    // Tentar carregar a imagem para garantir que é válida
                    try
                      var TempPic := TPicture.Create;
                      try
                        TempPic.LoadFromFile(FCaminhoImagem);
                        
                        // Sucesso! Imagem JPEG válida encontrada
                        imgSelecionada := ImageUrls[I];
                        DownloadOK := True;
                        Break;
                      finally
                        TempPic.Free;
                      end;
                    except
                      // Imagem corrompida, continuar procurando
                      if FileExists(FCaminhoImagem) then
                        DeleteFile(FCaminhoImagem);
                    end;
                  end
                  else
                  begin
                    // Não é JPEG, deletar e continuar procurando
                    if FileExists(FCaminhoImagem) then
                      DeleteFile(FCaminhoImagem);
                  end;
                end;
              finally
                ResponseStream.Free;
                HttpClient.Free;
              end;
            except
              // Erro no download, continuar
            end;
          end;
          
          // SEGUNDA TENTATIVA: Se não encontrou JPEG, aceitar qualquer formato válido
          if not DownloadOK then
          begin
            for I := 0 to Pred(ImageUrls.Count) do
            begin
              if Assigned(FrmStatus) then
              begin
                FrmStatus.lblStatus.Caption := 'Buscando imagem válida ' + IntToStr(I + 1) + '/' + IntToStr(ImageUrls.Count);
                Application.ProcessMessages;
              end;

              try
                HttpClient := THTTPClient.Create;
                ResponseStream := TMemoryStream.Create;
                try
                  HttpClient.Get(ImageUrls[I], ResponseStream);

                  if ResponseStream.Size > 500 then
                  begin
                    ResponseStream.Position := 0;
                    ResponseStream.SaveToFile(FCaminhoImagem);
                    
                    // Tentar carregar a imagem para garantir que é válida
                    try
                      var TempPic := TPicture.Create;
                      try
                        TempPic.LoadFromFile(FCaminhoImagem);
                        
                        // Sucesso! Imagem válida encontrada (qualquer formato)
                        imgSelecionada := ImageUrls[I];
                        DownloadOK := True;
                        Break;
                      finally
                        TempPic.Free;
                      end;
                    except
                      // Imagem corrompida, continuar procurando
                      if FileExists(FCaminhoImagem) then
                        DeleteFile(FCaminhoImagem);
                    end;
                  end;
                finally
                  ResponseStream.Free;
                  HttpClient.Free;
                end;
              except
                // Erro no download, continuar
              end;
            end;
          end;
        end;

      // baixar selecionada manualmente
      if (not DownloadOK) and (imgSelecionada <> '') then
      begin
        if Assigned(FrmStatus) then
          FrmStatus.lblStatus.Caption := 'Baixando imagem selecionada...';

        HttpClient := THTTPClient.Create;
        ResponseStream := TMemoryStream.Create;
        try
          HttpClient.Get(imgSelecionada, ResponseStream);

          if ResponseStream.Size > 0 then
          begin
            ResponseStream.Position := 0;
            ResponseStream.SaveToFile(FCaminhoImagem);
            DownloadOK := True;
          end;
        finally
          ResponseStream.Free;
          HttpClient.Free;
        end;
      end;
    end;

    // FINAL
    if DownloadOK and FileExists(FCaminhoImagem) then
    begin
      if Assigned(FrmStatus) then
        FrmStatus.lblStatus.Caption := 'Processando imagem...';

      try
        if FRedimensionar then
          RedimensionarImagem(FCaminhoImagem);

        FTipoImagem := IdentificarTipoImagem(FCaminhoImagem);
        FTamanhoKB := TFile.GetSize(FCaminhoImagem) / 1024;

        FImgBase64 := ImageFileToBase64(FCaminhoImagem);
        FImagem.LoadFromFile(FCaminhoImagem);
      except
      end;
    end;

  finally
    ImageUrls.Free;
    Resultado.Free;

    if Assigned(FrmStatus) then
      FrmStatus.Free;
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
