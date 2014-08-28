unit frmPrincipal;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db, sqldb, XMLConf, sqlite3conn, FileUtil, TADbSource,
  RTTICtrls, Forms, Controls, Graphics, Dialogs, Buttons, ExtCtrls, StdCtrls,
  Spin, ButtonPanel, ComCtrls, DBGrids, Menus,  EditBtn,
  DbCtrls, uDataModule, uSaldo, lazutf8sysutils,frmRelatorioPerPar, frmrelatoriocresaldo;

type

  { TformPrincipal }

  TformPrincipal = class(TForm)
    BtnTie: TBitBtn;
    btnBitWon: TBitBtn;
    btnBitLoss: TBitBtn;
    ckbAutoUpdate: TCheckBox;
    cmbEstrategias: TComboBox;
    dtEditDateSys: TDateEdit;
    DBGrid1: TDBGrid;
    ImageList1: TImageList;
    Label1: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label7: TLabel;
    lblConta: TLabel;
    lblTxAcerto: TLabel;
    lblQtdWon: TLabel;
    Label6: TLabel;
    lblQtdLoss: TLabel;
    lblBalanco: TLabel;
    lblSaldo: TLabel;
    Label3: TLabel;
    lblPayout: TLabel;
    lstPar: TListBox;
    MainMenu1: TMainMenu;
    mAbrir: TMenuItem;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    menTrocarTpConta: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    menFechar: TMenuItem;
    menuLimparBanco: TMenuItem;
    Panel1: TPanel;
    Panel2: TPanel;
    rbEdit: TRadioButton;
    SpinEdit1: TSpinEdit;
    spePercentual: TSpinEdit;
    StatusBar1: TStatusBar;
    Timer1: TTimer;
    vlEdit: TRadioButton;
    rb83: TRadioButton;
    rdgTempo: TRadioGroup;
    vl5: TRadioButton;
    vl10: TRadioButton;
    vl20: TRadioButton;
    vl50: TRadioButton;
    rb70: TRadioButton;
    rb65: TRadioButton;
    rb60: TRadioButton;
    RadioGroup1: TRadioGroup;
    RadioGroup2: TRadioGroup;
    TrayIcon1: TTrayIcon;
    procedure ApplicationProperties1Activate(Sender: TObject);
    procedure btnBitWonClick(Sender: TObject);
    procedure btnBitLossClick(Sender: TObject);
    procedure BtnTieClick(Sender: TObject);
    procedure Edit1EditingDone(Sender: TObject);
    procedure Edit1Enter(Sender: TObject);
    procedure Edit1KeyPress(Sender: TObject; var Key: char);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lblContaClick(Sender: TObject);
    procedure lblContaDblClick(Sender: TObject);
    procedure lblSaldoClick(Sender: TObject);
    procedure lstParClick(Sender: TObject);
    procedure mAbrirClick(Sender: TObject);
    procedure menFecharClick(Sender: TObject);
    procedure menTrocarTpContaClick(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure menuLimparBancoClick(Sender: TObject);
    procedure Panel1Click(Sender: TObject);
    procedure spePercentualEnter(Sender: TObject);
    procedure SpinEdit1Enter(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure vlEditChange(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpinEdit1Change(Sender: TObject);
    procedure SQLConnector1AfterConnect(Sender: TObject);
    procedure TrayIcon1Click(Sender: TObject);
    procedure vlChange(Sender: TObject);

  private
    procedure pintarPayout();
    procedure pintarSaldo();
    function getValor():integer;
    function getPerPayout():double;
    function getPayout():double;
    function getEstrategia():string;
    function getPar():string;
    function getHora():string;
    function getData():string;

  public
    { public declarations }
  end;

var
  formPrincipal: TformPrincipal;
  saldo: Double;
  saldoIni: Double;
  qtdWon:integer;
  qtdLoss:integer;
  tpContReal:boolean;
  lstParPercentual: TStringList;

implementation

{$R *.lfm}

{ TformPrincipal }

function TformPrincipal.getValor():integer;
begin

  if vl5.Checked = True then result:= 5;
  if vl10.Checked = True then result:= 10;
  if vl20.Checked = True then result:= 20;
  if vl50.Checked = True then result:= 50;
  if vlEdit.Checked then result:= SpinEdit1.Value;
end;

function TformPrincipal.getEstrategia():string;
begin
  if (cmbEstrategias.ItemIndex<0) then cmbEstrategias.ItemIndex:=0;
  result:=cmbEstrategias.Items[cmbEstrategias.ItemIndex];
end;
function TformPrincipal.getPar():string;
begin
  if (lstPar.ItemIndex<0) then lstPar.ItemIndex:=0;
  result:=lstPar.Items[lstPar.ItemIndex];
end;

function TformPrincipal.getPerPayout():double;
begin

  if rb70.Checked = True then result:= 0.70;
  if rb65.Checked = True then result:= 0.65;
  if rb60.Checked = True then result:= 0.60;
  if rb83.Checked = True then result:= 0.83;
  if rbEdit.Checked = True then result:= spePercentual.Value/100;

end;

function TformPrincipal.getHora():string;
begin
  result:=  rdgTempo.Items[rdgTempo.ItemIndex];
end;

function TformPrincipal.getData():string;
begin
  result:=  DateToStr(dtEditDateSys.Date);
end;

function TformPrincipal.getPayout():double;
begin

     result:= (getValor()*getPerPayout()) + getValor();

end;

procedure TformPrincipal.pintarPayout();
begin
  lblPayout.Caption:= FloatToStr(getPayout());
end;

procedure TformPrincipal.pintarSaldo;
var
  bal: Double;
  acerto: integer;
  erros: integer;

begin
  lblSaldo.Caption:= FloatToStr(dm.GetSaldo());
  bal:=dm.GetSaldo()-dm.GetSaldoInicial();
  lblBalanco.Caption:= Format('%2f', [bal]);
  if bal < 0 then lblBalanco.Font.Color:=clRed;
  if bal > 0 then lblBalanco.Font.Color:=clBlue;
  // percentual de acerto
  acerto:=dm.GetAcerto('won');
  erros:=dm.GetAcerto('loss');
  lblQtdWon.Caption:=IntToStr(acerto);
  lblQtdLoss.Caption:=IntToStr(erros);
  if (erros>0) and (acerto>0) then
  begin
    lblTxAcerto.Caption:= Format('%2f', [(100*(acerto/(erros+acerto)))]) + ' %';
  end;


end;

procedure TformPrincipal.SpinEdit1Change(Sender: TObject);
begin

end;

procedure TformPrincipal.SQLConnector1AfterConnect(Sender: TObject);
begin

end;

procedure TformPrincipal.TrayIcon1Click(Sender: TObject);
begin
if formPrincipal.WindowState = wsMinimized then
begin
  formPrincipal.SetFocus;
  formPrincipal.WindowState:= wsNormal;
end else begin
 formPrincipal.SetFocus;
 formPrincipal.WindowState:= wsMinimized;
end;

end;

procedure TformPrincipal.vlChange(Sender: TObject);
begin
  pintarPayout();
end;

procedure TformPrincipal.lstParClick(Sender: TObject);
begin
     spePercentual.Value:= StrToInt(lstParPercentual.Strings[lstPar.ItemIndex]);
     rbEdit.Checked:= True;
end;

procedure TformPrincipal.mAbrirClick(Sender: TObject);
begin
end;

procedure TformPrincipal.menFecharClick(Sender: TObject);
begin
  formPrincipal.Close;
end;

procedure TformPrincipal.menTrocarTpContaClick(Sender: TObject);
begin
    if (tpContReal=True) then
    begin
      tpContReal:=false;
      lblConta.Caption:= 'CONTA DEMO';
      lblConta.Font.Color:= clBlue;
    end else begin
     lblConta.Caption:= 'CONTA REAL';
     tpContReal:=True;
     lblConta.Font.Color:= clRed;
    end;
  dm.CarregarBanco(tpContReal);
  dm.reloadTable();
  pintarPayout();
  pintarSaldo();

end;

procedure TformPrincipal.MenuItem2Click(Sender: TObject);
begin
  frmSaldo.ShowModal;
  pintarSaldo();
end;

procedure TformPrincipal.MenuItem3Click(Sender: TObject);
begin

end;

procedure TformPrincipal.MenuItem4Click(Sender: TObject);
begin
  formPrincipal.FormStyle:= fsNormal;
  formRelatorioCresSaldo.ShowModal;
  formPrincipal.FormStyle:= fsSystemStayOnTop;
end;

procedure TformPrincipal.MenuItem5Click(Sender: TObject);
begin
  formPrincipal.FormStyle:= fsNormal;
  formRelatorioPerPar.ShowModal;
  formPrincipal.FormStyle:= fsSystemStayOnTop;
end;

procedure TformPrincipal.menuLimparBancoClick(Sender: TObject);
var
  r:integer;
begin
  r := MessageDlg('Aviso', 'Todos os dados serão excluidos?', Dialogs.mtInformation, mbYesNo, 7);
  if (r = 6) then
  begin
  //  ShowMessage(IntToStr(r));
      dm.LimparBanco();
      dm.AtualizaSaldo(250, 'inicio', DateToStr(NowUTC()));
      pintarSaldo();
      dm.reloadTable();
  end;
end;

procedure TformPrincipal.Panel1Click(Sender: TObject);
begin

end;

procedure TformPrincipal.spePercentualEnter(Sender: TObject);
begin
  rbEdit.Checked:= True;
end;

procedure TformPrincipal.SpinEdit1Enter(Sender: TObject);
begin
  vlEdit.Checked:= True;
end;

procedure TformPrincipal.Timer1Timer(Sender: TObject);
const
  qtd:Integer = 6;
  inc:Integer = 4;
var
  hora:integer;
begin
  hora:= StrToInt(FormatDateTime('hh', NowUTC()));
  if (ckbAutoUpdate.Checked = True) then
  begin
    if (hora>=0) and (hora<=3) then rdgTempo.ItemIndex:=0;
    if (hora>=4) and (hora<=7) then rdgTempo.ItemIndex:=1;
    if (hora>=8) and (hora<=11) then rdgTempo.ItemIndex:=2;
    if (hora>=12) and (hora<=15) then rdgTempo.ItemIndex:=3;
    if (hora>=16) and (hora<=19) then rdgTempo.ItemIndex:=4;
    if (hora>=20) and (hora<=23) then rdgTempo.ItemIndex:=5;
    dtEditDateSys.Date:=NowUTC();
  end;
  StatusBar1.Panels[0].Text := 'Hora UTC: ' + FormatDateTime('HH:MM:SS', NowUTC());
  StatusBar1.Panels[1].Text := 'Hora BRZ: ' + FormatDateTime('HH:MM:SS', Now());

end;

procedure TformPrincipal.vlEditChange(Sender: TObject);
begin

end;

procedure TformPrincipal.SpeedButton1Click(Sender: TObject);
begin
//  TMemLog.Lines.Delete(TMemLog.Lines.Count-1);
end;

procedure TformPrincipal.FormCreate(Sender: TObject);
begin
end;

procedure TformPrincipal.btnBitWonClick(Sender: TObject);
var
  linha:string;
begin
  dm.insertIntoOperacoes(getPar(),getValor(),getPayout(),'won', getHora(), getEstrategia(), getData());
  dm.reloadTable();
  pintarSaldo();
end;

procedure TformPrincipal.ApplicationProperties1Activate(Sender: TObject);
begin
end;

procedure TformPrincipal.btnBitLossClick(Sender: TObject);
var
  linha:string;
begin
 dm.insertIntoOperacoes(getPar(),getValor(),0,'loss', getHora(), getEstrategia(), getData());
 dm.reloadTable();
 pintarSaldo();
//    TMemLog.Lines.add(linha);
end;

procedure TformPrincipal.BtnTieClick(Sender: TObject);
begin
  dm.insertIntoOperacoes(getPar(),getValor(),getValor(),'tie', getHora(), getEstrategia(), getData());
  dm.reloadTable();
  pintarSaldo();
end;

procedure TformPrincipal.Edit1EditingDone(Sender: TObject);
begin

end;

procedure TformPrincipal.Edit1Enter(Sender: TObject);
begin
end;

procedure TformPrincipal.Edit1KeyPress(Sender: TObject; var Key: char);
begin

end;

procedure TformPrincipal.FormShow(Sender: TObject);
var
   FilePar: TextFile;
   FileEstrategia: TextFile;
   Str: String;
   strListTemp: TStringList;

begin
    pintarPayout();
    pintarSaldo();
    dm.reloadTable();
    strListTemp:= TStringList.Create;
    lstParPercentual:= TStringList.Create;
    // le o arquivo dos pares
    AssignFile(FilePar, 'pares.txt');
      {$I+}
      try
        Reset(FilePar);
        repeat
          Readln(FilePar, Str);
          // separa do arquivo PAR,PERCENTUAL o valor
          strListTemp.Delimiter:=',';
          strListTemp.DelimitedText:= Str;
          lstParPercentual.Add(strListTemp[1]);
          lstPar.Items.Add(strListTemp[0]);


        until(EOF(FilePar));
        CloseFile(FilePar);
      except
        on E: EInOutError do
        begin
         Writeln('File handling error occurred. Details: '+E.ClassName+'/'+E.Message);
        end;
      end;
    lstPar.ItemIndex:=0;

    // le o arquivo dos pares
    AssignFile(FileEstrategia, 'estrategias.txt');
      {$I+}
      try
        Reset(FileEstrategia);
        repeat
          Readln(FileEstrategia, Str);
          cmbEstrategias.Items.Add(Str);
        until(EOF(FileEstrategia));
        CloseFile(FileEstrategia);
      except
        on E: EInOutError do
        begin
         Writeln('File handling error occurred. Details: '+E.ClassName+'/'+E.Message);
        end;
      end;
    cmbEstrategias.ItemIndex:=0;

end;

procedure TformPrincipal.lblContaClick(Sender: TObject);
begin

end;

procedure TformPrincipal.lblContaDblClick(Sender: TObject);
begin


end;

procedure TformPrincipal.lblSaldoClick(Sender: TObject);
begin

end;

end.

