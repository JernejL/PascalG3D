unit SimpleGameMath;

{$mode delphi}

interface

uses
	Classes, SysUtils;

type

	{ TQuaternion }

  TQuaternion = packed record

  		function Normalize(): TQuaternion;

    	case integer of
    		0: (pointer_to: single);
            1: (x, y, z, w: single;);
    		2: (arr: array[0..3] of single);

	end;
	PQuaternion = ^TQuaternion;

	{ Vector2 }

 Vector2 = packed record
	case boolean of
		True: (componens: array[0..1] of single);
		False: (x, y: single);
	end;

	{ Vector }

    Vector = packed record
       function IsNullVector(): boolean; inline;

       class function Make(const mx, my, mz: single): Vector; inline; static;

       class Operator = (A : Vector; B : Vector) : boolean;
       class Operator <> (A : Vector; B : Vector) : boolean;
       class Operator * (A : Vector; B : Single) : Vector;
       class Operator * (A : Vector; B : Vector) : Vector;
       class Operator - (A : Vector; B : Vector) : Vector;
       class Operator + (A : Vector; B : Vector) : Vector;
       class Operator / (A : Vector; B : Single) : Vector;

   	case integer of
           1: (x, y, z: single);
   		2: (components: array[0..2] of single);
   		0: (pointer_to: single);
   	end;
   	Pvector = ^Vector;

	{ TVector4f }

    TVector4f = packed record

       	class function Make(const mx, my, mz, mw: single): TVector4f; inline; static;

           class Operator * (A : TVector4f; B : Single) : TVector4f;
           class Operator - (A : TVector4f; B : TVector4f) : TVector4f;
    		class Operator + (A : TVector4f; B : TVector4f) : TVector4f;

           case integer of
				1: (x, y, z, w: single);
				2: (components: array[0..3] of single);
				0: (pointer_to: single);

	end;

  { TMatrix4f }

  TMatrix4f = packed record
          procedure SetIdentity; inline;
          procedure CreateFromQuaternion(ppvQuaternion: TQuaternion);
          procedure MakeTranslateMatrix(const tx, ty, tz: single);
          procedure ScaleGL(const x, y, z: single);

          function TransformVector(const vec: Vector): Vector;

          class Operator * (matrixa : TMatrix4f; matrixb : TMatrix4f) : TMatrix4f;

          function MatrixInverseV2(): boolean; inline; // used by opengl for camera

  		case integer of
  			0: (
  	        	pointer_to: single
  	        	);
  			1: (
  				vectors: array [0..3] of TVector4f // front up right position
  			);
  			2: (
  				arr: array[0..3, 0..3] of single
  			);
              8: (
  				RawComponents: array[0..3, 0..3] of single // for bero code
  			);
  			4: (
  				front: Vector;		pada: single;
  				up: Vector;			padb: single;
  				right: Vector;		padc: single;
  				position: Vector;		padd: single;
  			);
              5: (
  				front4: TVector4f;
  				up4: TVector4f;
  				right4: TVector4f;
  				position4: TVector4f;
              );
              7: (
  				LinArr: array[0..15] of single
  			);
      end;

  	Pmatrix4f = ^TMatrix4f;

const

  nullvector: Vector = (x:0; y:0; z:0);
  Zvector: Vector = (x:0; y:0; z:1);

  Nullmatrix: TMatrix4f = (
      vectors: (
  	    (x: 1;y: 0;z: 0;w: 0),
  		(x: 0;y: 0;z: 0;w: 0),
  		(x: 0;y: 0;z: 0;w: 0),
  		(x: 0;y: 0;z: 0;w: 0)
      )
  );

  IdentityVal: TMatrix4f = (
      vectors: (
  	    (x:1;y: 0;z: 0;w: 0),
  		(x:0;y: 1;z: 0;w: 0),
  		(x:0;y: 0;z: 1;w: 0),
  		(x:0;y: 0;z: 0;w: 1)
      )
  );

  function Distance1D(const a, b: single): single;  inline;
  function fabs(const x: single): single; inline;
  function MatrixTransformVector(vec: Vector; m: Tmatrix4f): Vector; overload;

implementation

function Distance1D(const a, b: single): single;
begin

	if (a > b) then
		result:= fabs(a - b)
	else
		result:= fabs(b - a);

end;

function fabs(const x: single): single;
begin

	result:= abs(x); // <- don't oprimize, FPC can use floating point instructions really good here.

end;

function MatrixTransformVector(vec: Vector; m: Tmatrix4f): Vector; overload; // tested, works.
begin

	Result.x := vec.x * m.vectors[0].components[0] + vec.y * m.vectors[1].components[0] + vec.z * m.vectors[2].components[0] + m.vectors[3].components[0];
	Result.y := vec.x * m.vectors[0].components[1] + vec.y * m.vectors[1].components[1] + vec.z * m.vectors[2].components[1] + m.vectors[3].components[1];
	Result.z := vec.x * m.vectors[0].components[2] + vec.y * m.vectors[1].components[2] + vec.z * m.vectors[2].components[2] + m.vectors[3].components[2];

{

  Result := MatrixRotateVector(vec, m);

  Result.x := Result.x + m[3, 0];
  Result.y := Result.y + m[3, 1];
  Result.z := Result.z + m[3, 2];
}
end;

{ TQuaternion }

function TQuaternion.Normalize(): TQuaternion;
var Factor: single;
begin

	Factor:=sqrt(sqr(x)+sqr(y)+sqr(z)+sqr(w));

	if Factor<>0.0 then begin
		Factor:=1.0/Factor;
		result.x:=x*Factor;
		result.y:=y*Factor;
		result.z:=z*Factor;
		result.w:=w*Factor;
	end else begin
		result.x:=0.0;
		result.y:=0.0;
		result.z:=0.0;
		result.w:=0.0;
	end;

end;

{ Vector }

function Vector.IsNullVector(): boolean;
begin

end;

class function Vector.Make(const mx, my, mz: single): Vector;
begin

end;

class operator Vector.=(A: Vector; B: Vector): boolean;
begin

end;

class operator Vector.<>(A: Vector; B: Vector): boolean;
begin

end;

class operator Vector.*(A: Vector; B: Single): Vector;
begin

end;

class operator Vector.*(A: Vector; B: Vector): Vector;
begin

end;

class operator Vector.-(A: Vector; B: Vector): Vector;
begin

end;

class operator Vector.+(A: Vector; B: Vector): Vector;
begin

end;

class operator Vector./(A: Vector; B: Single): Vector;
begin

end;

{ TVector4f }

class function TVector4f.Make(const mx, my, mz, mw: single): TVector4f;
begin

end;

class operator TVector4f.*(A: TVector4f; B: Single): TVector4f;
begin

end;

class operator TVector4f.-(A: TVector4f; B: TVector4f): TVector4f;
begin

end;

class operator TVector4f.+(A: TVector4f; B: TVector4f): TVector4f;
begin

end;

{ TMatrix4f }

procedure TMatrix4f.SetIdentity;
begin

  	self.vectors:= identityVal.vectors;

end;

procedure TMatrix4f.CreateFromQuaternion(ppvQuaternion: TQuaternion);
var
    qx2,qy2,qz2,qxqx2,qxqy2,qxqz2,qxqw2,qyqy2,qyqz2,qyqw2,qzqz2,qzqw2: single;
begin
ppvQuaternion:=ppvQuaternion.Normalize;
qx2:=ppvQuaternion.x+ppvQuaternion.x;
qy2:=ppvQuaternion.y+ppvQuaternion.y;
qz2:=ppvQuaternion.z+ppvQuaternion.z;
qxqx2:=ppvQuaternion.x*qx2;
qxqy2:=ppvQuaternion.x*qy2;
qxqz2:=ppvQuaternion.x*qz2;
qxqw2:=ppvQuaternion.w*qx2;
qyqy2:=ppvQuaternion.y*qy2;
qyqz2:=ppvQuaternion.y*qz2;
qyqw2:=ppvQuaternion.w*qy2;
qzqz2:=ppvQuaternion.z*qz2;
qzqw2:=ppvQuaternion.w*qz2;
RawComponents[0,0]:=1.0-(qyqy2+qzqz2);
RawComponents[0,1]:=qxqy2+qzqw2;
RawComponents[0,2]:=qxqz2-qyqw2;
RawComponents[0,3]:=0.0;
RawComponents[1,0]:=qxqy2-qzqw2;
RawComponents[1,1]:=1.0-(qxqx2+qzqz2);
RawComponents[1,2]:=qyqz2+qxqw2;
RawComponents[1,3]:=0.0;
RawComponents[2,0]:=qxqz2+qyqw2;
RawComponents[2,1]:=qyqz2-qxqw2;
RawComponents[2,2]:=1.0-(qxqx2+qyqy2);
RawComponents[2,3]:=0.0;
RawComponents[3,0]:=0.0;
RawComponents[3,1]:=0.0;
RawComponents[3,2]:=0.0;
RawComponents[3,3]:=1.0;

end;

procedure TMatrix4f.MakeTranslateMatrix(const tx, ty, tz: single);
begin

    arr[0,0]:= 1.0;
    arr[0,1]:= 0.0;
    arr[0,2]:= 0.0;
    arr[0,3]:= 0.0;

    arr[1,0]:= 0.0;
    arr[1,1]:= 1.0;
    arr[1,2]:= 0.0;
    arr[1,3]:= 0.0;

    arr[2,0]:= 0.0;
    arr[2,1]:= 0.0;
    arr[2,2]:= 1.0;
    arr[2,3]:= 0.0;

    arr[3,0]:= tx;
    arr[3,1]:= ty;
    arr[3,2]:= tz;
    arr[3,3]:= 1.0;

end;

procedure TMatrix4f.ScaleGL(const x, y, z: single);
begin

    arr[0][0] := x * arr[0][0];
    arr[0][1] := x * arr[0][1];
    arr[0][2] := x * arr[0][2];
    arr[0][3] := x * arr[0][3];

    arr[1][0] := y * arr[1][0];
    arr[1][1] := y * arr[1][1];
    arr[1][2] := y * arr[1][2];
    arr[1][3] := y * arr[1][3];

    arr[2][0] := z * arr[2][0];
    arr[2][1] := z * arr[2][1];
    arr[2][2] := z * arr[2][2];
    arr[2][3] := z * arr[2][3];

end;

function TMatrix4f.TransformVector(const vec: Vector): Vector;
begin

    result:= MatrixTransformVector(vec, self);

end;

class operator TMatrix4f.*(matrixa: TMatrix4f; matrixb: TMatrix4f): TMatrix4f;
begin
    result.RawComponents[0,0]:=(matrixa.RawComponents[0,0]*matrixb.RawComponents[0,0])+(matrixa.RawComponents[0,1]*matrixb.RawComponents[1,0])+(matrixa.RawComponents[0,2]*matrixb.RawComponents[2,0])+(matrixa.RawComponents[0,3]*matrixb.RawComponents[3,0]);
    result.RawComponents[0,1]:=(matrixa.RawComponents[0,0]*matrixb.RawComponents[0,1])+(matrixa.RawComponents[0,1]*matrixb.RawComponents[1,1])+(matrixa.RawComponents[0,2]*matrixb.RawComponents[2,1])+(matrixa.RawComponents[0,3]*matrixb.RawComponents[3,1]);
    result.RawComponents[0,2]:=(matrixa.RawComponents[0,0]*matrixb.RawComponents[0,2])+(matrixa.RawComponents[0,1]*matrixb.RawComponents[1,2])+(matrixa.RawComponents[0,2]*matrixb.RawComponents[2,2])+(matrixa.RawComponents[0,3]*matrixb.RawComponents[3,2]);
    result.RawComponents[0,3]:=(matrixa.RawComponents[0,0]*matrixb.RawComponents[0,3])+(matrixa.RawComponents[0,1]*matrixb.RawComponents[1,3])+(matrixa.RawComponents[0,2]*matrixb.RawComponents[2,3])+(matrixa.RawComponents[0,3]*matrixb.RawComponents[3,3]);
    result.RawComponents[1,0]:=(matrixa.RawComponents[1,0]*matrixb.RawComponents[0,0])+(matrixa.RawComponents[1,1]*matrixb.RawComponents[1,0])+(matrixa.RawComponents[1,2]*matrixb.RawComponents[2,0])+(matrixa.RawComponents[1,3]*matrixb.RawComponents[3,0]);
    result.RawComponents[1,1]:=(matrixa.RawComponents[1,0]*matrixb.RawComponents[0,1])+(matrixa.RawComponents[1,1]*matrixb.RawComponents[1,1])+(matrixa.RawComponents[1,2]*matrixb.RawComponents[2,1])+(matrixa.RawComponents[1,3]*matrixb.RawComponents[3,1]);
    result.RawComponents[1,2]:=(matrixa.RawComponents[1,0]*matrixb.RawComponents[0,2])+(matrixa.RawComponents[1,1]*matrixb.RawComponents[1,2])+(matrixa.RawComponents[1,2]*matrixb.RawComponents[2,2])+(matrixa.RawComponents[1,3]*matrixb.RawComponents[3,2]);
    result.RawComponents[1,3]:=(matrixa.RawComponents[1,0]*matrixb.RawComponents[0,3])+(matrixa.RawComponents[1,1]*matrixb.RawComponents[1,3])+(matrixa.RawComponents[1,2]*matrixb.RawComponents[2,3])+(matrixa.RawComponents[1,3]*matrixb.RawComponents[3,3]);
    result.RawComponents[2,0]:=(matrixa.RawComponents[2,0]*matrixb.RawComponents[0,0])+(matrixa.RawComponents[2,1]*matrixb.RawComponents[1,0])+(matrixa.RawComponents[2,2]*matrixb.RawComponents[2,0])+(matrixa.RawComponents[2,3]*matrixb.RawComponents[3,0]);
    result.RawComponents[2,1]:=(matrixa.RawComponents[2,0]*matrixb.RawComponents[0,1])+(matrixa.RawComponents[2,1]*matrixb.RawComponents[1,1])+(matrixa.RawComponents[2,2]*matrixb.RawComponents[2,1])+(matrixa.RawComponents[2,3]*matrixb.RawComponents[3,1]);
    result.RawComponents[2,2]:=(matrixa.RawComponents[2,0]*matrixb.RawComponents[0,2])+(matrixa.RawComponents[2,1]*matrixb.RawComponents[1,2])+(matrixa.RawComponents[2,2]*matrixb.RawComponents[2,2])+(matrixa.RawComponents[2,3]*matrixb.RawComponents[3,2]);
    result.RawComponents[2,3]:=(matrixa.RawComponents[2,0]*matrixb.RawComponents[0,3])+(matrixa.RawComponents[2,1]*matrixb.RawComponents[1,3])+(matrixa.RawComponents[2,2]*matrixb.RawComponents[2,3])+(matrixa.RawComponents[2,3]*matrixb.RawComponents[3,3]);
    result.RawComponents[3,0]:=(matrixa.RawComponents[3,0]*matrixb.RawComponents[0,0])+(matrixa.RawComponents[3,1]*matrixb.RawComponents[1,0])+(matrixa.RawComponents[3,2]*matrixb.RawComponents[2,0])+(matrixa.RawComponents[3,3]*matrixb.RawComponents[3,0]);
    result.RawComponents[3,1]:=(matrixa.RawComponents[3,0]*matrixb.RawComponents[0,1])+(matrixa.RawComponents[3,1]*matrixb.RawComponents[1,1])+(matrixa.RawComponents[3,2]*matrixb.RawComponents[2,1])+(matrixa.RawComponents[3,3]*matrixb.RawComponents[3,1]);
    result.RawComponents[3,2]:=(matrixa.RawComponents[3,0]*matrixb.RawComponents[0,2])+(matrixa.RawComponents[3,1]*matrixb.RawComponents[1,2])+(matrixa.RawComponents[3,2]*matrixb.RawComponents[2,2])+(matrixa.RawComponents[3,3]*matrixb.RawComponents[3,2]);
    result.RawComponents[3,3]:=(matrixa.RawComponents[3,0]*matrixb.RawComponents[0,3])+(matrixa.RawComponents[3,1]*matrixb.RawComponents[1,3])+(matrixa.RawComponents[3,2]*matrixb.RawComponents[2,3])+(matrixa.RawComponents[3,3]*matrixb.RawComponents[3,3]);

end;

function TMatrix4f.MatrixInverseV2(): boolean;
var
	i, j, k, swap: integer;
	t: double;
	//src_access: array[0..16] of single absolute src;
    temp: Tmatrix4f; //array[0..3,0..3] of single;
    inverse: Tmatrix4f;
    inverse_access: array[0..16] of single absolute inverse;
begin

	result:= false;

	Move(arr, temp.arr, sizeof(arr)); // faster

	{  for i:=0 to 3 do begin
	  for j:= 0 to 3 do begin
	      temp[i][j] := src_access[i*4+j];
	  end;
	end;}

	inverse.SetIdentity();

	for i:= 0 to 3 do begin

		// Look for largest element in column

		swap := i;

		for j := i + 1 to 3 do begin
			if (fabs(temp.arr[j][i]) > fabs(temp.arr[i][i])) then begin
				swap := j;
			end;
		end;

		if (swap <> i) then begin
			// Swap rows.
			for k := 0 to 3 do begin
				t := temp.arr[i][k];
				temp.arr[i][k] := temp.arr[swap][k];
				temp.arr[swap][k] := t;

				t := inverse_access[i*4+k];
				inverse_access[i*4+k] := inverse_access[swap*4+k];
				inverse_access[swap*4+k] := t;
			end;
		end;

		if (temp.arr[i][i] = 0) then begin
			// No non-zero pivot. The matrix is singular, which shouldn't happen. This means the user gave us a bad matrix.
		    result:= false;
		    exit;
		end;

		t := temp.arr[i][i];

		for k := 0 to 3 do begin
			//temp[i][k] /= t;
			temp.arr[i][k] := temp.arr[i][k] / t;
			inverse_access[i*4+k]:= inverse_access[i*4+k] / t;
			//inverse_access[i*4+k] /= t;
		end;

		for j := 0 to 3 do begin
			if (j <> i) then begin
				t := temp.arr[j][i];
				for k:= 0 to 3 do begin
					//temp[j][k] -= temp[i][k]*t;
					//inverse_access[j*4+k] -= inverse_access[i*4+k]*t;

					temp.arr[j][k] := temp.arr[j][k] - temp.arr[i][k]*t;
					inverse_access[j*4+k] := inverse_access[j*4+k] - inverse_access[i*4+k]*t;

				end;
			end;
		end;
	end;

	result:= true;

	Move(inverse_access, arr, sizeof(arr)); // copy over

end;

end.

