unit frmRelatorioPerPar;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, TAStyles, TATools, TADbSource, TAGraph,
  TASources, TARadialSeries, TASeries, RTTIGrids, Forms, Controls, Graphics,
  Dialogs, BarChart, ButtonPanel, ExtCtrls, StdCtrls, ComCtrls, EditBtn,
  Buttons, Menus, uDataModule, dateutils;

type

  { TformRelatorioPerPar }

  TformRelatorioPerPar = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Chart1: TChart;
    Chart1BarSeries1: TBarSeries;
    dEdtIni: TDateEdit;
    dEdtFim: TDateEdit;
    ListChartSource1: TListChartSource;
    MenuItem1: TMenuItem;
    Panel1: TPanel;
    Panel2: TPanel;
    PopupMenu1: TPopupMenu;
    SaveDialog1: TSaveDialog;
    SpeedButton1: TSpeedButton;
    StatusBar1: TStatusBar;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    { private declarations }
  public
    procedure RecarregarChart();
  end;

var
  formRelatorioPerPar: TformRelatorioPerPar;

implementation

{$R *.lfm}

{ TformRelatorioPerPar }
procedure TformRelatorioPerPar.RecarregarChart();
var
  i, index:integer;
begin
  dm.RelatorioPerPar(dEdtIni.Date,dEdtFim.Date);
  dm.SqlExterno.First;
  ListChartSource1.Clear;
  for i:= 0 To dm.SqlExterno.RecordCount-1 do
  begin
    index:=ListChartSource1.Add(i,dm.SqlExterno.FieldByName('TOTAL').AsFloat, dm.SqlExterno['ATIVO']);
    if dm.SqlExterno.FieldByName('TOTAL').AsInteger > 0 then
    begin
         ListChartSource1.SetColor(index, clBlue);
    end else begin
         ListChartSource1.SetColor(index, clRed);

    end;
    dm.SqlExterno.Next;
  end;
//  for
end;



procedure TformRelatorioPerPar.Button1Click(Sender: TObject);
begin
  dEdtIni.Date:= StartOfAMonth(YearOf(Now), MonthOf(Now));
  dEdtFim.Date:=Now;
  RecarregarChart();
end;

procedure TformRelatorioPerPar.Button2Click(Sender: TObject);
begin
  dEdtIni.Date:= StartOfAWeek (YearOf(Now), WeekOf(Now));
  dEdtFim.Date:=Now;
  RecarregarChart();

end;

procedure TformRelatorioPerPar.Button3Click(Sender: TObject);
begin
  dEdtIni.Date:=Now-1;
  dEdtFim.Date:=Now;
  RecarregarChart();
end;

procedure TformRelatorioPerPar.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  dm.SqlExterno.Close;
end;

procedure TformRelatorioPerPar.FormShow(Sender: TObject);
begin
     dEdtIni.Date:=Now-10;
     dEdtFim.Date:=Now;
     RecarregarChart();
end;

procedure TformRelatorioPerPar.MenuItem1Click(Sender: TObject);
begin
  SaveDialog1.Execute;
  if SaveDialog1.FileName<>'' then
  begin
       Chart1.SaveToFile(TJPEGImage, SaveDialog1.FileName);
  end;
end;

procedure TformRelatorioPerPar.SpeedButton1Click(Sender: TObject);
begin
  RecarregarChart();
end;

end.

