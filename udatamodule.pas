unit uDataModule;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db, sqldb, FileUtil, lazutf8sysutils, Dialogs;

type

  { Tdm }

  Tdm = class(TDataModule)
    DataSource1: TDataSource;
    DataSource2: TDataSource;
    sqlConnector: TSQLConnector;
    SQLQuery: TSQLQuery;
    SqlExterno: TSQLQuery;
    SQLQuerySaldo: TSQLQuery;
    SQLQueryTable: TSQLQuery;
    SQLTransaction1: TSQLTransaction;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    { private declarations }
  public
    procedure LimparBanco();
    procedure CarregarBanco(contaReal:boolean);
    procedure AtualizaSaldo(saldo:double; tipo:string; data:string; qtdWin:integer=0; qtdloss:integer=0);
    procedure reloadTable();
    procedure insertIntoOperacoes(ativo:String; investimento:double; payout:double; resultado:string; hora:string; estrategia:string; data:string);
    function  GetSaldo():double;
    function  GetSaldoInicial():double;
    function  GetAcerto(tipo:string):integer;
    procedure RelatorioPerPar(dataini:TDate; datafinal:TDate);
    procedure RelatorioSaldo(dataini:TDate; datafinal:TDate);

  end;

var
  dm: Tdm;

implementation

{$R *.lfm}

{ Tdm }

procedure Tdm.RelatorioPerPar(dataini:TDate; datafinal:TDate);
begin
       SqlExterno.Close;
       SqlExterno.SQL.Text:= 'SELECT sum(vlPayout-vlInvestimento) as TOTAL, ' +
         'nmAtivo as ATIVO from Operacoes WHERE dtAtualizacao >= :DATAINI AND dtAtualizacao <= :DATAFIM GROUP BY nmAtivo;';
       SqlExterno.params.parambyname('DATAINI').AsString:= DateToStr(dataini);
       SqlExterno.params.parambyname('DATAFIM').AsString:= DateToStr(datafinal);
       SqlExterno.Open;
end;


procedure Tdm.RelatorioSaldo(dataini:TDate; datafinal:TDate);
begin
       SqlExterno.Close;
       SqlExterno.SQL.Text:= 'SELECT MAX(id) AS lastid, dtAtualizacao AS DATA, vlSaldo AS SALDO FROM saldo ' +
        ' WHERE dtAtualizacao >= :DATAINI AND dtAtualizacao <= :DATAFIM GROUP BY dtAtualizacao;';
       SqlExterno.params.parambyname('DATAINI').AsString:= DateToStr(dataini);
       SqlExterno.params.parambyname('DATAFIM').AsString:= DateToStr(datafinal);
       SqlExterno.Open;
end;

procedure Tdm.CarregarBanco(contaReal:boolean);
begin
     if sqlConnector.Connected then
     begin
          sqlConnector.Close;
     end;
     if contaReal then
     begin
          sqlConnector.DatabaseName:= GetCurrentDir() + '\database.real.db';
     end else begin
          sqlConnector.DatabaseName:= GetCurrentDir() + '\database.demo.db';
     end;

     sqlConnector.Open;

end;

procedure Tdm.DataModuleCreate(Sender: TObject);
begin
     CarregarBanco(False);
end;

procedure Tdm.LimparBanco();
begin
       SQLQuery.SQL.text := 'delete from Operacoes';
       SQLQuery.ExecSQL;
       SQLTransaction1.Commit;
       SQLQuery.SQL.text := 'delete from Saldo';
       SQLQuery.ExecSQL;
       SQLTransaction1.Commit;

end;

function Tdm.GetAcerto(tipo:string):integer;
var
   resultado:integer;
begin
       SQLQuery.Close;
       if tipo = 'won' then
       begin
         SQLQuery.SQL.Text:= 'SELECT count(*) as valor FROM operacoes where tpResultado = 1 and dtAtualizacao = "' + DateToStr(NowUTC()) +'"';
       end else begin
         SQLQuery.SQL.Text:= 'SELECT count(*) as valor FROM operacoes where tpResultado = -1 and dtAtualizacao = "' + DateToStr(NowUTC()) +'"';
       end;
       SQLQuery.Open;
       SQLQuery.First;
       resultado:=SQLQuery['valor'];
       SQLQuery.Close;
       result:= resultado;
end;


function Tdm.GetSaldoInicial():double;
var
   tempSaldo:double;
begin
       SQLQuerySaldo.Close;
       SQLQuerySaldo.SQL.Text:= 'SELECT * FROM Saldo where (tpOpe = "inicio" OR tpOpe = "balanco-ajuste") AND'
       + ' dtAtualizacao ="'+DateToStr(NowUTC())+'" ORDER BY id Desc ';
       SQLQuerySaldo.Open;
       SQLQuerySaldo.First;
       if (SQLQuerySaldo.EOF) then
       begin
            AtualizaSaldo(GetSaldo(), 'inicio', DateToStr(NowUTC()));
            tempSaldo:= GetSaldo();
       end else begin
              tempSaldo:=SQLQuerySaldo['vlSaldo'];
       end;
       SQLQuerySaldo.Close;
       result:=tempSaldo;
end;

function Tdm.GetSaldo():double;
var
   tempSaldo:double;
begin
     SQLQuerySaldo.Close;
     SQLQuerySaldo.SQL.Text:= 'SELECT * FROM Saldo ORDER BY id Desc ';
     SQLQuerySaldo.Open;
     SQLQuerySaldo.First;
     tempSaldo:=SQLQuerySaldo['vlSaldo'];
     SQLQuerySaldo.Close;
     result:=tempSaldo;
end;

procedure Tdm.AtualizaSaldo(saldo:double; tipo:string; data:string; qtdWin:integer=0; qtdLoss:integer=0);
var
   acerto, erros:integer;
begin
     acerto:= GetAcerto('won');
     erros:= GetAcerto('loss');
     SQLQuery.SQL.text := 'insert into Saldo (vlSaldo, tpOpe, dtAtualizacao, qtdWinAtDay, qtdLossAtDay) ' +
'values (:SALDO,:TIPO, :DATA, :WIN, :LOSS)';
     SQLQuery.Params.ParamByName('TIPO').AsString := tipo;
     SQLQuery.Params.ParamByName('WIN').AsInteger:= acerto;
     SQLQuery.Params.ParamByName('LOSS').AsInteger := erros;
     SQLQuery.Params.ParamByName('DATA').AsString := data;
        if tipo='operacoes' then
        begin
             SQLQuery.Params.ParamByName('SALDO').AsFloat := GetSaldo() + saldo;
        end else begin
                SQLQuery.Params.ParamByName('SALDO').AsFloat := saldo;
        end;
        SQLQuery.ExecSQL;
        SQLTransaction1.Commit;
end;

procedure Tdm.insertIntoOperacoes(ativo:String; investimento:double; payout:double; resultado:string; hora:string; estrategia:string; data:string);
begin
     SQLQuery.SQL.text := 'insert into Operacoes ' +
'(nmAtivo,nmEstrategia, vlInvestimento, vlPayout, tpOperacao, tpResultado, dtHoraOperacao, dtAtualizacao)' +
'values (:ATIVO,:ESTRATEGIA, :INVEST, :PAY, :OP, :R, :HORA, :DT)';
        SQLQuery.Params.ParamByName('ATIVO').AsString := ativo;
        SQLQuery.Params.ParamByName('ESTRATEGIA').AsString :=  estrategia;
        SQLQuery.Params.ParamByName('INVEST').AsFloat := investimento;
        SQLQuery.Params.ParamByName('PAY').AsFloat := payout;
        SQLQuery.Params.ParamByName('HORA').AsString := hora;
        SQLQuery.Params.ParamByName('DT').AsString := data;
        case resultado of
        'won': SQLQuery.Params.ParamByName('R').AsInteger := 1;
        'tie': SQLQuery.Params.ParamByName('R').AsInteger := 0;
        else
          SQLQuery.Params.ParamByName('R').AsInteger := -1;
        end;
        SQLQuery.ExecSQL;
        SQLTransaction1.Commit;
        AtualizaSaldo(payout-investimento, 'operacoes', data);
end;

procedure Tdm.reloadTable();
begin
     SQLQueryTable.Close;
     SQLQueryTable.SQL.Text:= 'SELECT cast(nmAtivo as varchar) as ATIVO, '
     + ' cast(nmEstrategia as varchar) as ESTRATEGIA, vlInvestimento as INVESTIDO,'
     + 'vlPayout as PAYOUT, tpResultado, cast(dtAtualizacao as varchar) as DATA FROM Operacoes order by id desc';
     SQLQueryTable.Open;
end;

procedure Tdm.DataModuleDestroy(Sender: TObject);
begin
       sqlConnector.Close;
end;

end.

