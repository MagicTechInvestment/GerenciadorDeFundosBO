program project1;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, tachartlazaruspkg, runtimetypeinfocontrols, 
frmPrincipal, uDataModule, uSaldo,
  frmRelatorioPerPar, frmrelatoriocresaldo;

{$R *.res}

begin
  Application.Title:='GerenciadorDeFundos';
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TformPrincipal, formPrincipal);
  Application.CreateForm(Tdm, dm);
  Application.CreateForm(TfrmSaldo, frmSaldo);
  Application.CreateForm(TformRelatorioPerPar, formRelatorioPerPar);
  Application.CreateForm(TformRelatorioCresSaldo, formRelatorioCresSaldo);
  Application.Run;
end.

