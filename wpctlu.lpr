program wpctlu;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, wpctlunit
  { you can add units after this };

begin
  RequireDerivedFormResource:=True;
  Application.Title:='wpctlu';
  Application.Initialize;
  Application.CreateForm(Twpctl, wpctl);
  Application.Run;
end.

