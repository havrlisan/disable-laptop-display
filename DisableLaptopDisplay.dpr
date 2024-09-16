program DisableLaptopDisplay;

uses
  System.StartUpCopy,
  FMX.Forms,
  DLD.frmMain in 'source\DLD.frmMain.pas' {frmDisableLaptopDisplay};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmDisableLaptopDisplay, frmDisableLaptopDisplay);
  Application.Run;
end.
