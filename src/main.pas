unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, ShellApi, Dos, INIFiles;

type

  { TMainForm }

  TMainForm = class(TForm)
    btnmount: TButton;
    btnunmount: TButton;
    btnexit: TButton;
    imgjbsnewmedia: TImage;
    imgveracloud: TImage;
    lblccontainer: TLabel;
    lblcstatus: TLabel;
    lblcdrive: TLabel;
    lblccomputer: TLabel;
    lblcversion: TLabel;
    lblversion: TLabel;
    lblstatus: TLabel;
    lblcontainer: TLabel;
    lbldrive: TLabel;
    lblpc: TLabel;
    memini: TMemo;
    Runner: TTimer;
    SystrayIcon: TTrayIcon;
    procedure btnmountClick(Sender: TObject);
    procedure btnunmountClick(Sender: TObject);
    procedure btnexitClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormWindowStateChange(Sender: TObject);
    procedure imgjbsnewmediaClick(Sender: TObject);
    procedure imgveracloudClick(Sender: TObject);
    procedure RunnerCore(Sender: TObject);
    procedure SystrayIconClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    procedure GoRun();
    procedure CreateLockFile();
    procedure LoadLockFile();
    procedure RemoveLockFile();
  end;

var
  MainForm: TMainForm;
  programm: String;
  container: String;
  drive: String;
  currentdir: String;
  lockfile: String;
  drivefile: String;
  pc: String;
  cpc: String;

implementation

{$R *.lfm}

{ TMainForm }

procedure TMainForm.FormActivate(Sender: TObject);
begin
  currentdir:=GetCurrentDir;
  pc:=GetEnvironmentVariable('COMPUTERNAME');
  Runner.Enabled:=true;
  SystrayIcon.Show;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  INI:TINIFile;
begin
  INI:=TINIFile.Create('veracloud.ini');
  try
    programm:=INI.ReadString('GENERAL','program','');
    container:=INI.ReadString('GENERAL','container','');
    drive:=INI.ReadString('GENERAL','drive','');
  finally
    INI.Free;
  end;
  SystrayIcon.Hint:='VeraCloud ['+ExtractFileName(container)+']';
  MainForm.Caption:='VeraCloud ['+ExtractFileName(container)+']';
end;

procedure TMainForm.FormWindowStateChange(Sender: TObject);
begin
  if MainForm.WindowState = wsMinimized then begin
    MainForm.WindowState := wsNormal;
    MainForm.Hide;
    MainForm.ShowInTaskBar := stNever;
  end;
end;

procedure TMainForm.btnmountClick(Sender: TObject);
begin
  ShellExecute(0, 'open', Pchar(programm), Pchar('/l '+drive+' /w /q preferences /c n /h n /v "'+container+'"'), nil, 0);
end;

procedure TMainForm.btnunmountClick(Sender: TObject);
begin
  ShellExecute(0, 'open', Pchar(programm), Pchar('/d '+drive+' /s /w'), nil, 0);
end;

procedure TMainForm.btnexitClick(Sender: TObject);
begin
  MainForm.Close;
end;

procedure TMainForm.imgjbsnewmediaClick(Sender: TObject);
begin
  ShellExecuteW(0, 'open', PWideChar('https://jbs-newmedia.de'), nil, nil, 0);
end;

procedure TMainForm.imgveracloudClick(Sender: TObject);
begin
    ShellExecuteW(0, 'open', PWideChar('https://github.com/jbs-newmedia/VeraCloud'), nil, nil, 0);
end;

procedure TMainForm.RunnerCore(Sender: TObject);
begin
  GoRun();
end;

procedure TMainForm.SystrayIconClick(Sender: TObject);
begin
  Show();
  WindowState := wsNormal;
  Application.BringToFront();
end;

procedure TMainForm.GoRun();
begin
  lockfile:=ExtractFilePath(container)+ExtractFileName(container)+'.lock';
  drivefile:=drive+':\vc.lock';

  LoadLockFile();

  if (FileExists(container)) then begin
    if (FileExists(drivefile)) then begin
      if (cpc<>pc) then begin
         CreateLockFile();
      end;
      lblstatus.Caption:='mounted ['+cpc+']';
      btnmount.Enabled:=false;
      btnunmount.Enabled:=true;
    end else begin
      if (cpc=pc) then begin
         RemoveLockFile();
         LoadLockFile();
      end;
      if (cpc<>'') then begin
        lblstatus.Caption:='mounted ['+cpc+']';
        btnmount.Enabled:=false;
        btnunmount.Enabled:=false;
      end else begin
        lblstatus.Caption:='unmounted';
        btnmount.Enabled:=true;
        btnunmount.Enabled:=false;
      end;
    end;
  end else begin
    lblstatus.Caption:='container doesn''t exists';
    btnmount.Enabled:=false;
    btnunmount.Enabled:=false;
  end;

  lblcontainer.Caption:=container;
  lbldrive.Caption:=drive+':\';
  lblpc.Caption:=pc;
  MainForm.Refresh;
end;

procedure TMainForm.CreateLockFile();
begin
  memini.Lines.Clear;
  memini.Lines.Add(pc);
  memini.Lines.SaveToFile(lockfile);
end;

procedure TMainForm.LoadLockFile();
begin
  cpc:='';
  if (FileExists(lockfile)) then begin
    memini.Lines.Clear;
    memini.Lines.LoadFromFile(lockfile);
    cpc:=memini.Lines[0];
  end;
end;

procedure TMainForm.RemoveLockFile();
begin
  deleteFile(lockfile);
end;

end.
