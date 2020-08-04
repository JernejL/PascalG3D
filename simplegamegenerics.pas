unit simplegamegenerics;

{$mode delphi}

interface

uses
	Classes, SysUtils;

type

	{ TAllocatedHashTable }

    TAllocatedHashTable<T,U> = class
        	private
            	AllocBy: integer;
            public
    			hashkey: array of T;
                values: array of U;
                MaxIndex: integer;
                found: boolean;
            	constructor create(const allocbyAmout: integer);
            	destructor destroy; override;
    			procedure Push(const Addkey: T; const AddValue: U); // inline;
                procedure Eject(Key: T); inline;
                function Get(const Addkey: T): U; // inline;
                function Has(const Addkey: T): boolean; // inline;
                function Count: integer; inline;
                function highest: integer; inline;
    	end;

	TStringIntHashtable = TAllocatedHashTable<widestring,integer>;

implementation

{ TAllocatedHashTable }

constructor TAllocatedHashTable<T, U>.create(const allocbyAmout: integer);
begin

  	inherited create;

	allocby:= allocbyAmout;
	SetLength(hashkey, AllocBy); // allocate first bunch
	SetLength(values, AllocBy); // allocate first bunch
	MaxIndex:= -1;

end;

destructor TAllocatedHashTable<T, U>.destroy;
begin

	MaxIndex:= -1;
	setlength(hashkey, 0);
	setlength(values, 0);

	inherited destroy;
end;

procedure TAllocatedHashTable<T, U>.Push(const Addkey: T; const AddValue: U);
begin

	MaxIndex += 1;

	if (MaxIndex > high(hashkey)) then begin
		setlength(hashkey, length(hashkey) + AllocBy);
		setlength(values, length(values) + AllocBy);
	end;

	hashkey[MaxIndex]:= Addkey;
	values[MaxIndex]:= AddValue;

    // debug('ADDED PUSH: ' + string(hashkey[MaxIndex]));

end;

procedure TAllocatedHashTable<T, U>.Eject(Key: T);
var
	i, j: Integer;
begin

	for i:= 0 to high(hashkey) do begin

    	if (hashkey[i] = Key) then begin

          	for j:= i to high(hashkey) - 1 do begin
            	hashkey[j]:= hashkey[j+1];
                values[j]:= values[j+1];
            end;

            MaxIndex -= 1;
        	exit;

		end;

	end;
end;

function TAllocatedHashTable<T, U>.Get(const Addkey: T): U;
var
    i: integer;
begin

	fillchar(result, sizeof(result), 0);
    found:= false;

	for i:= 0 to highest do begin

        // debug(string(addkey) + ' < searching -> checking ' + string(hashkey[i]));

        if (hashkey[i] = Addkey) then begin

        	// debug('found ' + string(hashkey[i]) + ' at ' + inttostr(integer(values[i])));

          	found:= true;
        	exit(values[i]);
		end;

	end;

    //raise Exception.Create('TAllocatedHashTable<U, T>.Get not found.');

end;

function TAllocatedHashTable<T, U>.Has(const Addkey: T): boolean;
var
    i: integer;
begin

	for i:= 0 to highest do begin

        if (hashkey[i] = Addkey) then
        	exit(true);

	end;

    exit(false);

end;

function TAllocatedHashTable<T, U>.Count: integer;
begin

	if MaxIndex = -1 then exit(0);

	result:= MaxIndex + 1;

end;

function TAllocatedHashTable<T, U>.highest: integer;
begin

  	result:= MaxIndex;

end;

end.

