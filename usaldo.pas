unit uSaldo;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, ButtonPanel, uDataModule, lazutf8sysutils;

type

  { TfrmSaldo }

  TfrmSaldo = class(TForm)
    ButtonPanel1: TButtonPanel;
    Edit1: TEdit;
    Label1: TLabel;
    Panel1: TPanel;
    procedure ButtonPanel1Click(Sender: TObject);
    procedure OKButtonClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmSaldo: TfrmSaldo;

implementation

{$R *.lfm}

{ TfrmSaldo }

procedure TfrmSaldo.ButtonPanel1Click(Sender: TObject);
begin

end;

procedure TfrmSaldo.OKButtonClick(Sender: TObject);
begin
  dm.AtualizaSaldo(StrToFloat(Edit1.Text), 'balanco-ajuste', DateToStr(NowUTC()));
end;

end.

