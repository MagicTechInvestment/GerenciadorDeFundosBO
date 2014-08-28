unit frmrelatoriocresaldo;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, TAGraph, TASeries, TASources, TAStyles,
  TARadialSeries, TAMultiSeries, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, EditBtn, Buttons, Menus, uDataModule, dateutils, lazutf8sysutils;

type

  { TformRelatorioCresSaldo }

  TformRelatorioCresSaldo = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Chart1: TChart;
    Chart1AreaSeries1: TAreaSeries;
    Chart1BarSeries1: TBarSeries;
    ChartStyles1: TChartStyles;
    dEdtFim: TDateEdit;
    dEdtIni: TDateEdit;
    ListChartSource1: TListChartSource;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    Panel1: TPanel;
    Panel2: TPanel;
    PopupMenu1: TPopupMenu;
    SaveDialog1: TSaveDialog;
    SpeedButton1: TSpeedButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Chart1DblClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
  private
    { private declarations }
  public
    procedure RecarregarChart();
  end;

var
  formRelatorioCresSaldo: TformRelatorioCresSaldo;

implementation

{$R *.lfm}

procedure TformRelatorioCresSaldo.FormShow(Sender: TObject);
begin
     dEdtIni.Date:=Now-10;
     dEdtFim.Date:=Now;
     RecarregarChart();
end;

procedure TformRelatorioCresSaldo.MenuItem1Click(Sender: TObject);
begin
  SaveDialog1.Execute;
  if SaveDialog1.FileName<>'' then
  begin
       Chart1.SaveToFile(TJPEGImage, SaveDialog1.FileName);
  end;
end;

procedure TformRelatorioCresSaldo.MenuItem2Click(Sender: TObject);
begin
    if Chart1AreaSeries1.ConnectType = ctStepYX then
  begin
    Chart1AreaSeries1.ConnectType:= ctLine;
  end else begin
    Chart1AreaSeries1.ConnectType:= ctStepYX;
  end;
end;

procedure TformRelatorioCresSaldo.Button3Click(Sender: TObject);
begin
  dEdtIni.Date:=Now;
  dEdtFim.Date:=Now;
  RecarregarChart();

end;

procedure TformRelatorioCresSaldo.Chart1DblClick(Sender: TObject);
begin

end;

procedure TformRelatorioCresSaldo.Button1Click(Sender: TObject);
begin
  dEdtIni.Date:= StartOfAMonth(YearOf(Now), MonthOf(Now));
  dEdtFim.Date:=Now;
  RecarregarChart();
end;

procedure TformRelatorioCresSaldo.Button2Click(Sender: TObject);
begin
  dEdtIni.Date:= StartOfAWeek (YearOf(Now), WeekOf(Now));
  dEdtFim.Date:=Now;
  RecarregarChart();
end;

procedure TformRelatorioCresSaldo.RecarregarChart();
var
  i, index:integer;
begin
  dm.RelatorioSaldo(dEdtIni.Date,dEdtFim.Date);
  dm.SqlExterno.First;
  ListChartSource1.Clear;
  for i:= 0 To dm.SqlExterno.RecordCount-1 do
  begin
    index:= ListChartSource1.Add(i,dm.SqlExterno.FieldByName('SALDO').AsFloat, dm.SqlExterno['DATA']);
    if i > 4 then
    begin
      ListChartSource1.SetColor(index, $8000FF);
    end else begin
      Chart1AreaSeries1.SetColor(index, $80FFFF);
    end;
    dm.SqlExterno.Next;
  end;
//  for
end;
end.

