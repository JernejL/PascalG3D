program rendergdx;

{$mode objfpc}{$H+}

uses
	{$IFDEF UNIX}{$IFDEF UseCThreads}
	cthreads,
	{$ENDIF}{$ENDIF}
	Interfaces, // this includes the LCL widgetset
	Forms, u_rendergdx, G3D_model, simplegamegenerics
	{ you can add units after this };

{$R *.res}

begin
	RequireDerivedFormResource:=True;
	Application.Scaled:=True;
	Application.Initialize;
        Application.CreateForm(TForm1, Form1);
	Application.Run;
end.

