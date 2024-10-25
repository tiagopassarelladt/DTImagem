unit DTImagem;

interface

uses
  System.SysUtils,
  System.Classes,
  Vcl.StdCtrls,
  IdHTTP,
  MSHTML,
  Soap.EncdDecd,
  Winapi.UrlMon,
  System.NetEncoding,
  Vcl.Imaging.jpeg,
  USeletor,
  Vcl.Imaging.pngimage,
  Vcl.Imaging.gifimg,
  Vcl.Graphics;

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

  public
    procedure Buscar(Codigo:string;Descricao:string);
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property CaminhoDaImagem    : string     read FCaminhoImagem      write stCaminhoImagem;
    property Imagem             : TPicture   read FImagem             write setFImagem;
    property ConsultarNaCosmos  : Boolean    read FCosmos             write setCosmos;
    property HabilitaSeletor    : boolean    read FHabilitaSeletor    write SetHabilitaSeletor;
    property TipoImagem         : string     read FTipoImagem         write FTipoImagem;
    property ImgBase64          : string     read FImgBase64          write FImgBase64;
    property TamanhoKB          : Double     read FTamanhoKB          write FTamanhoKB;
    property MostrarBarraStatus : boolean    read FMostrarBarraStatus write FMostrarBarraStatus;
end;

procedure Register;

implementation

uses
  Frm_StatusX, Vcl.Forms;

procedure Register;
begin
  RegisterComponents('DT Inovacao', [TDTImagem]);
end;

{ TDTImagem }

function TDTImagem.ImageFileToBase64(const FilePath: string): string;
var
  MemoryStream: TMemoryStream;
  Base64Stream: TStringStream;
  Graphic: TGraphic;
  FileExt: string;
begin
  Result       := '';
  MemoryStream := TMemoryStream.Create;
  Base64Stream := TStringStream.Create;
  Graphic      := nil;

  try
    FileExt := LowerCase(ExtractFileExt(FilePath));

    if FileExt = '.bmp' then
      Graphic := TBitmap.Create
    else if (FileExt = '.jpg') or (FileExt = '.jpeg') then
      Graphic := TJPEGImage.Create
    else if FileExt = '.png' then
      Graphic := TPngImage.Create
    else
      raise Exception.Create('Formato de imagem não suportado.');

    Graphic.LoadFromFile(FilePath);

    Graphic.SaveToStream(MemoryStream);
    MemoryStream.Position := 0;

    FTamanhoKB            := MemoryStream.Size / 1024;

    TNetEncoding.Base64.Encode(MemoryStream, Base64Stream);

    Result                := Base64Stream.DataString;
  finally
    MemoryStream.Free;
    Base64Stream.Free;
    Graphic.Free;
  end;
end;

procedure TDTImagem.Buscar(Codigo:string;Descricao:string);
var
Memo1,Memo2    : string;
Pesquisa       : string;
Resultado      : TStringList;
IdHTTP1        : TIdHTTP;
img64,Response : string;
ImgStream      : TArray<Byte>;
retorno        : integer;
AStream        : TMemoryStream;
DownloadOK     : Boolean;
I              : Integer;
FrmStatus      : TfrmStatusx;
begin
  try
      try
              if FMostrarBarraStatus then
              begin
                FrmStatus      := TfrmStatusx.Create(nil);
                FrmStatus.Show;
                FrmStatus.BringToFront;
              end;
              application.ProcessMessages;
              IdHTTP1        := TIdHTTP.Create(nil);
              DownloadOK     := False;
              FCaminhoImagem := FCaminhoImagem + '\' + Codigo + '.jpg';

              if not DirectoryExists(ExtractFilePath(FCaminhoImagem)) then
                 ForceDirectories(ExtractFilePath(FCaminhoImagem));

              try
                    if FileExists( FCaminhoImagem ) then
                        DeleteFile( FCaminhoImagem );

                    if FCosmos then
                    begin
                        retorno := URLDownloadToFile(nil, PChar('https://cdn-cosmos.bluesoft.com.br/products/'+ Codigo), PChar(FCaminhoImagem), 0, nil);
                        if retorno = 0 then
                        begin
                             try
                               if FileExists(FCaminhoImagem) then
                               begin
                                    AStream := TMemoryStream.Create;
                                    AStream.LoadFromFile((FCaminhoImagem));
                                    AStream.Position := 0;

                                    FImagem.LoadFromStream(AStream);

                                    FImgBase64 := ImageFileToBase64(FCaminhoImagem);

                                    if Assigned(AStream) then
                                     FreeAndNil(AStream);
                                    DownloadOK := True;
                               end;
                             except
                                    DownloadOK := False;
                             end;
                        end;
                    end;
              Except
                    DownloadOK := False;
              end;

              if not DownloadOK then
              begin
                    Pesquisa  := Trim(codigo + ' + ' + Descricao);
                    Pesquisa  := Pesquisa.Replace(' ','+');
                    Memo1     := '';
                    Resultado := TStringList.create;
                    Response  := IdHTTP1.Get('https://www.google.com/search?q='+ Pesquisa +'&tbm=isch');
                    memo1     := (Response);
                    GetValorCampoHtml(memo1,'IMG','',0,Resultado);
                    memo2     := Resultado[1].Replace('data:image/jpeg;base64,','imagem: ');
                    img64     := Resultado[1].Replace('data:image/jpeg;base64,','');

                    if FHabilitaSeletor then
                    begin
                          FrmSeletor := TFrmSeletor.Create(nil);
                          if FrmSeletor.cdsIMG.Active then
                          begin
                               FrmSeletor.cdsIMG.EmptyDataSet;
                          end else begin
                               FrmSeletor.cdsIMG.CreateDataSet;
                          end;
                          FrmSeletor.Carregando := True;

                          // CRIAR OPÇÃO DE SELECIONAR A IMAGEM DESEJADA
                          for I := 0 to Pred( Resultado.Count ) do
                          begin
                              if Pos( 'http', Resultado[i] ) > 0 then
                              begin
                                 FrmSeletor.cdsIMG.Append;
                                 FrmSeletor.cdsIMGID.AsInteger := i+1;
                                 FrmSeletor.cdsIMGURL.AsString := Resultado[i];
                                 FrmSeletor.cdsIMG.Post;
                              end;
                          end;

                          FrmSeletor.ShowModal;
                          img64 := FrmSeletor.UrlImagem;
                          FreeAndNil( FrmSeletor );

                          if FMostrarBarraStatus then
                          FrmStatus.Close;
                    end;
                    Resultado.Free;

                    try
                        retorno := URLDownloadToFile(nil, PChar(img64), PChar(FCaminhoImagem), 0, nil);
                        if retorno=0 then
                        begin
                             try
                               if FileExists(FCaminhoImagem) then
                               begin
                                    if ConvertJPG_BMP(FCaminhoImagem) <> nil then
                                    begin
                                        AStream          := TMemoryStream.Create;
                                        AStream.LoadFromStream(ConvertJPG_BMP(FCaminhoImagem));
                                        AStream.Position := 0;
                                        FImgBase64       := ImageFileToBase64(FCaminhoImagem);
                                    end else begin
                                        FTipoImagem := IdentificarTipoImagem(FCaminhoImagem);
                                        FImagem.LoadFromFile(FCaminhoImagem);
                                        FImgBase64  := ImageFileToBase64(FCaminhoImagem);
                                    end;

                                    if Assigned(AStream) then
                                     FreeAndNil(AStream);
                               end;
                             except
                                  FTipoImagem := IdentificarTipoImagem(FCaminhoImagem);
                                  FImagem.LoadFromFile(FCaminhoImagem);
                                  FImgBase64  := ImageFileToBase64(FCaminhoImagem);

                                  if Assigned(AStream) then
                                   FreeAndNil(AStream);
                             end;
                        end;
                    finally
                    end;
              end;
      except on e:Exception do
      begin
              memo2            := '';
              memo2            := Copy(memo1 ,Pos('src="https://',Memo1 )+5);
              memo2            := Copy(Memo2 ,1,Pos('"',Memo2 )-1);
              retorno          := URLDownloadToFile(nil, PChar( memo2 ), PChar(FCaminhoImagem), 0, nil);

              AStream          := TMemoryStream.Create;

              AStream.LoadFromStream(ConvertJPG_BMP(FCaminhoImagem));
              AStream.Position := 0;
              FImgBase64       := ImageFileToBase64(FCaminhoImagem);

              if Assigned(AStream) then
               FreeAndNil(AStream);
      end;

      end;
  finally
      FreeAndNil(IdHTTP1);
      if FMostrarBarraStatus then
      FreeAndNil(FrmStatus);
  end;
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
  Foto    : TMemoryStream;
  vPassou : Boolean;
begin
  Result  := nil;
  vPassou := false;
                //or (not VerificarAssinaturaJPEG(xFile))
  if (ExtractFileExt(xFile) <> '.jpg')  then
  begin
        JPG := TJPEGImage.Create;
        try

          try
              try
                JPG.LoadFromFile(xFile);
                vPassou := True;
              except

              end;
          finally
              try
                 if RepararJPEG(xFile) then
                     JPG.LoadFromFile(xFile);
                 vPassou := True;
              except

              end;
          end;

          try
            if vPassou then
            begin
                BMP           := TBitmap.Create;
                BMP.Assign(JPG);
                Foto          := TMemoryStream.Create;
                BMP.SaveToStream(Foto);
                Foto.Position := 0;
                Result        := Foto;
                FImagem.Assign(JPG);
            end;
          finally
            FreeAndNil(BMP);
          end;
        finally
          FreeAndNil(JPG);
        end;
  end;
end;

constructor TDTImagem.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FImagem := TPicture.create;
end;

destructor TDTImagem.Destroy;
begin
  FreeAndNil(fimagem);
  inherited destroy;
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
