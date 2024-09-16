unit DLD.frmMain;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.Controls.Presentation,
  FMX.StdCtrls,
  Winapi.Messages;

type
  TfrmDisableLaptopDisplay = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);
  private
    FSWbemLocator: OLEVariant;
    FWMIService: OLEVariant;
    FPreviousWbemObject: OLEVariant;
    FPreviousBrightness: Byte;
  private
    procedure MoveToSecondaryDisplay;
  public
    procedure ChangeBrightness;
    procedure ReturnBrightness;
  end;

var
  frmDisableLaptopDisplay: TfrmDisableLaptopDisplay;

implementation

uses
  Winapi.ActiveX,
  Win.ComObj;

{$R *.fmx}

procedure TfrmDisableLaptopDisplay.FormCreate(Sender: TObject);
begin
  MoveToSecondaryDisplay;
  FSWbemLocator := CreateOleObject('WbemScripting.SWbemLocator');
  FWMIService := FSWbemLocator.ConnectServer('localhost', 'root\WMI', '', '');
  ChangeBrightness;
end;

procedure TfrmDisableLaptopDisplay.FormDestroy(Sender: TObject);
begin
  ReturnBrightness;
end;

procedure TfrmDisableLaptopDisplay.FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkEscape then
    Application.Terminate;
end;

procedure TfrmDisableLaptopDisplay.MoveToSecondaryDisplay;
begin
  Left := Screen.Displays[0].PhysicalWorkarea.Left;
  Top := Screen.Displays[0].PhysicalWorkarea.Top;
end;

procedure TfrmDisableLaptopDisplay.ChangeBrightness;
var
  LWbemObjectSet: OLEVariant;
  LEnum: IEnumvariant;
  LWbemObject: OLEVariant;
  LValue: LongWord;
begin
  ReturnBrightness;
  { find and store current brightness }
  LWbemObjectSet := FWMIService.ExecQuery('SELECT * FROM WmiMonitorBrightness Where Active=True', 'WQL', $00000020);
  LEnum := IUnknown(LWbemObjectSet._NewEnum) as IEnumvariant;
  while LEnum.Next(1, LWbemObject, LValue) = 0 do
  begin
    FPreviousBrightness := Byte(LWbemObject.CurrentBrightness);
    LWbemObject := Unassigned;
  end;
  { update current brightness to 0 }
  LWbemObjectSet := FWMIService.ExecQuery('SELECT * FROM WmiMonitorBrightnessMethods Where Active=True', 'WQL', $00000020);
  LEnum := IUnknown(LWbemObjectSet._NewEnum) as IEnumvariant;
  while LEnum.Next(1, LWbemObject, LValue) = 0 do
  begin
    LWbemObject.WmiSetBrightness(0, 0);
    FPreviousWbemObject := LWbemObject;
    LWbemObject := Unassigned;
  end;
end;

procedure TfrmDisableLaptopDisplay.ReturnBrightness;
begin
  if VarCompareValue(FPreviousWbemObject, Unassigned) <> TVariantRelationship.vrEqual then
  begin
    FPreviousWbemObject.WmiSetBrightness(0, FPreviousBrightness);
    FPreviousWbemObject := Unassigned;
  end;
end;

end.
