unit wpctlunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Menus, Process, RegExpr, LazLogger;

type
  TSink = object
    id: integer;
    active: Boolean;
    name: string;
  end;

type
  TSinkButton = class(TButton)
    private
      Sink: TSink;
    public
      constructor Create(Sender: TWinControl; ASink: TSink; SinkButtonClick: TNotifyEvent); overload;
      procedure Activate();
      procedure Deactivate();
end;

type
  { Twpctl }
  Twpctl = class(TForm)
    procedure SinkButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ListDevices(Sender: TObject);
  private
    Buttons: array of TSinkButton;
    procedure FindSinks(wpctlOutput: TStringList);

  public

  end;

var
  wpctl: Twpctl;
  Sinks: array of TSink;

implementation

{$R *.lfm}

constructor TSinkButton.Create(Sender: TWinControl; ASink: TSink; SinkButtonClick: TNotifyEvent);
begin
  inherited Create(Sender);
  Sink := ASink;
  if ASink.active then Color := clSkyBlue;
  Caption := Sink.name;
  Parent := Sender;
  AutoSize := True;
  Left := 20;
  OnClick := SinkButtonClick;
end;

procedure TSinkButton.Activate();
var
  AProcess: TProcess;
begin

  AProcess := TProcess.Create(nil);
  try
    AProcess.Executable := '/usr/bin/wpctl';
    AProcess.Parameters.Add('set-default');
    AProcess.Parameters.Add(IntToStr(Sink.id));
    AProcess.Options := AProcess.Options + [poWaitOnExit, poUsePipes];
    AProcess.Execute;
    Sink.active := True;
    Color := clSkyBlue;
  finally
    AProcess.free;
  end;
end;

procedure TSinkButton.Deactivate();
begin
  Sink.active := False;
  Color := clDefault;
end;

procedure Twpctl.FindSinks(wpctlOutput: TStringList);
var
  i, siPos: integer;
  collect: Boolean;
  sinkFinder: TRegExpr;
begin
  collect   := False;
  sinkFinder := TRegExpr.Create('^ │\s+(\*)?\s+(\d+)\. ([\w\s\d\.]+)');
  for i := wpctlOutput.IndexOf('Audio') to wpctlOutput.IndexOf('Video') -1 do
  begin
       if pos('Sinks', wpctlOutput[i]) > 0 then collect := True;
       if collect then
       begin

         if sinkFinder.Exec(wpctlOutput[i]) then
         begin
            siPos := Length(Sinks);
            setLength(Sinks, siPos+1);
            Sinks[siPos].active := sinkFinder.Match[1] = '*';
            Sinks[siPos].id     := StrToInt(sinkFinder.Match[2]);
            Sinks[siPos].name   := TrimRight(sinkFinder.Match[3]);
         end;
       end;
       if (wpctlOutput[i] = ' │  ') or (wpctlOutput[i] = '') then collect := False;
  end;
end;


{ Twpctl }
procedure Twpctl.ListDevices(Sender: TObject);
var
  i,maxw: integer;
begin
    maxw := 0;
    setLength(Buttons, Length(Sinks));
    for i := 0 to Length(Sinks)-1 do
    begin
      Buttons[i] := TSinkButton.Create(Self, Sinks[i], @SinkButtonClick);
      Buttons[i].Top := 5 + (Buttons[i].height + 5) * i;

      Canvas.Font := Buttons[i].Font;
      Buttons[i].Width := Canvas.TextWidth(Buttons[i].Caption) + 20;

      if Buttons[i].Width > maxw then maxw := Buttons[i].Width;
    end;
    if Length(Buttons) > 0 then
       Height := 5 + (Buttons[0].height +5) * Length(Sinks);
       Width  := maxw + 40;

end;

procedure Twpctl.FormCreate(Sender: TObject);
var
  AProcess: TProcess;
  AStringList: TStringList;
begin
  // RUN PROCESS
  AProcess := TProcess.Create(nil);
  AProcess.Executable := '/usr/bin/wpctl';
  AProcess.Parameters.Add('status');
  AProcess.Parameters.Add('-k');

  // Wait for the Process
  AProcess.Options := AProcess.Options + [poWaitOnExit, poUsePipes];
  AProcess.Execute;

  // doesn't work and i don't know why
  if AProcess.ExitCode > 0 then
  begin
    AProcess.Free;
    exit;
  end;

  // READ STDPOUT
  AStringList := TStringList.Create;
  AStringList.LoadFromStream(AProcess.Output);

  FindSinks(AStringList);
  AStringList.Free;

  // STOP PROCESS
  AProcess.Free;

  ListDevices(Self);
end;

procedure Twpctl.SinkButtonClick(Sender: TObject);
var
  i: integer;
  Btn: TSinkButton;
begin
  Btn := Sender as TSinkButton;
     for i := 0 to Length(Buttons) -1 do
         Buttons[i].Deactivate;
     Btn.Activate;
  Application.Terminate;
end;

end.

