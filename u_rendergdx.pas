unit u_rendergdx;

{$mode objfpc}{$H+}

interface

uses
	Classes, windows, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, dglOpenGL,
	G3D_model;

type

	{ TForm1 }

 TForm1 = class(TForm)
		log: TMemo;
		procedure FormCreate(Sender: TObject);
	private

	public

	end;

var
	Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
var
	MyDC: HDC;
	MyRC: HGLRC;
begin

	InitOpenGL();
	ReadExtensions;

	MyDC := GetDC(form1.handle);
	MyRC := CreateRenderingContext(MyDC, [opDoubleBuffered], 32 {ColorBits}, 24 {ZBits}, 0, 0, 0, 0);
	ActivateRenderingContext(MyDC, MyRC);

end;

end.

