unit DeCAL.SuperStream.Helper;

interface
Uses DeCAL, SuperStream, System.Classes;

type
  TSuperStreamHelper = class(TObjStream)
    constructor Create(stream : TStream; owned : Boolean; options : TObjStreamOptions);
    procedure WriteVarRecItem(const item: tVarRec);
    procedure WriteVarRecItems(items : array of const);

    public
    { ** Writer helper methods ** }
    { The _write procedures include the VarType identifiers and are used for
      saving of TVarRec elements.
      The Write() procedures only save the binary data. User needs to make sure
      the order of elements are synchronized between read and write operations }
    { ** numeric }
    { integer }
    procedure _write(const item : Integer); overload;
    procedure Write(const item : Integer); overload;
    { boolean }
    procedure _write(const item : Boolean); overload;
    procedure Write(const item : Boolean); overload;
    { single }
    procedure _write(const item : Single); overload;
    procedure Write(const item : Single); overload;
    { double }
    procedure _write(const item : Double); overload;
    procedure Write(const item : Double); overload;
    { extended }
    procedure _write(const item : Extended); overload;
    procedure Write(const item : Extended); overload;
    { currency }
    procedure _write(const item : Currency); overload;
    procedure Write(const item : Currency); overload;
    { int64 }
    procedure _write(const item : Int64); overload;
    procedure Write(const item : Int64); overload;
    { object }
    procedure _write(const item : TObject); overload;
    procedure Write(const item : TObject); overload;
    { ** characters and character strings }
    { AnsiChar }
    procedure _write(const item : AnsiChar); overload;
    procedure Write(const item : AnsiChar); overload;
    { WideChar }
    procedure _write(const item : WideChar); overload;
    procedure Write(const item : WideChar); overload;
    { AnsiString }
    procedure _write(const item : AnsiString); overload;
    procedure Write(const item : AnsiString); overload;
    { WideString }
    procedure _write(const item : WideString); overload;
    procedure Write(const item : WideString); overload;
    { UnicodeString }
    procedure _write(const item : UnicodeString); overload;
    procedure Write(const item : UnicodeString); overload;
    { binary}
    procedure _write(const item : Pointer; len : Cardinal); overload;
    procedure Write(const item: Pointer; len : Cardinal); overload;

    { ** Loader helper methods ** }
    function ReadTypeIdentifier : Byte;
    function ReadVarRecItem : TVarRec;
    { numeric }
    function ReadInteger : Integer;
    function ReadBoolean : Boolean;
    function ReadSingle : Single;
    function ReadDouble : Double;
    function ReadExtended : Extended;
    function ReadCurrency : Currency;
    function ReadInt64 : Int64;
    { object }
    function ReadObject : TObject;
    { characters and character strings }
    function ReadAnsiChar : AnsiChar;
    function ReadWideChar : WideChar;
    function ReadAnsiString : AnsiString;
    function ReadWideString : WideString;
    function ReadUnicodeString : UnicodeString;
    { binary }
    function ReadBinary (len : Cardinal) : Pointer;

  end;

  const
    vtNone = 255;
    vtSingle = vtNone - 1;
    vtDouble = vtNone - 2;
    vtBinary = vtNone - 3;

  type
  { ** variant record to save memory }
  PSSVarRecord = ^TSSVarRecord;
  TSSVarRecord = record
    case Integer of
      0: (case Byte of
            vtInteger:       (VInteger  : Integer);
            vtBoolean:       (VBoolean  : Boolean);
            vtSingle:        (VSingle   : Single);
            vtDouble:        (VDouble   : Double);
            vtExtended:      (VExtended : Extended);
            vtCurrency:      (VCurrency : Currency);
            vtInt64:         (VInt64    : Int64);
//            vtUnicodeString: (VUnicodeString : UnicodeString);

            vtChar:          (VChar: AnsiChar);
            vtPointer:       (VPointer: Pointer);
            vtPChar:         (VPChar: PAnsiChar);
            vtObject:        (VObject: TObject);
            vtWideChar:      (VWideChar: WideChar);
            vtPWideChar:     (VPWideChar: PWideChar);
            vtAnsiString:    (VAnsiString: Pointer);
            vtVariant:       (VVariant: PVariant);
            vtInterface:     (VInterface: Pointer);
            vtWideString:    (VWideString: Pointer);
         );
  end;


  {
  vtInteger       = 0;
  vtBoolean       = 1;
  vtChar          = 2;
  vtExtended      = 3;
  vtString        = 4; // deprecated
  vtPointer       = 5;
  vtPChar         = 6;
  vtObject        = 7;
  vtClass         = 8;
  vtWideChar      = 9;
  vtPWideChar     = 10;
  vtAnsiString    = 11;
  vtCurrency      = 12;
  vtVariant       = 13;
  vtInterface     = 14;
  vtWideString    = 15;
  vtInt64         = 16;
  vtUnicodeString = 17;
}

  implementation

{ TSuperStreamHelper }

constructor TSuperStreamHelper.Create(stream: TStream; owned: Boolean;
  options: TObjStreamOptions);
begin
  inherited Create(stream, owned, options);
end;

// integer writers
procedure TSuperStreamHelper._write(const item: Integer);
const id : Byte = vtInteger;
begin
  write(id, SizeOf(Byte));
  Write(item);
end;

procedure TSuperStreamHelper.Write(const item: Integer);
begin
  write(item, Sizeof(Integer));
end;

// boolean writers
procedure TSuperStreamHelper._write(const item: Boolean);
const id : Byte = vtDouble;
begin
  write(id, SizeOf(Byte));
  Write(item);
end;

procedure TSuperStreamHelper.Write(const item: Boolean);
begin
  write(item, SizeOf(Boolean));
end;

// single writers
procedure TSuperStreamHelper._write(const item: Single);
const id : Byte = vtSingle;
begin
  write(id, SizeOf(Byte));
  Write(item);
end;

procedure TSuperStreamHelper.Write(const item: Single);
begin
  write(item, SizeOf(Single));
end;

// double writers
procedure TSuperStreamHelper._write(const item: Double);
const id : Byte = vtDouble;
begin
  write(id, SizeOf(Byte));
  Write(item);
end;

procedure TSuperStreamHelper.Write(const item: Double);
begin
  write(item, SizeOf(item));
end;

// extended writers
procedure TSuperStreamHelper._write(const item: Extended);
const id : Byte = vtExtended;
begin
  write(id, SizeOf(Byte));
  Write(item);
end;

procedure TSuperStreamHelper.Write(const item: Extended);
begin
  write(item, SizeOf(item));
end;

// currency writers
procedure TSuperStreamHelper._write(const item: Currency);
const id : Byte = vtCurrency;
begin
  write(id, SizeOf(Byte));
  Write(item);
end;

procedure TSuperStreamHelper.Write(const item: Currency);
begin
  write(item, SizeOf(item));
end;

// int64 writers
procedure TSuperStreamHelper._write(const item: Int64);
const id : Byte = vtInt64;
begin
  write(id, SizeOf(Byte));
  Write(item);
end;

procedure TSuperStreamHelper.Write(const item: Int64);
begin
  write(item, SizeOf(item));
end;

// object writers
procedure TSuperStreamHelper._write(const item: TObject);
const id : Byte = vtObject;
begin
  write(id, SizeOf(Byte));
  Write(item);
end;

procedure TSuperStreamHelper.Write(const item: TObject);
begin
  raise TObjStreamException.Create('Cannot write TObject yet');
end;

// AnsiChar writers
procedure TSuperStreamHelper._write(const item: AnsiChar);
const id : Byte = vtAnsiChar;
begin
  write(id, SizeOf(Byte));
  Write(item);
end;

procedure TSuperStreamHelper.Write(const item: AnsiChar);
begin
  write(item, SizeOf(item));
end;

// WideChar writers
procedure TSuperStreamHelper._write(const item: WideChar);
const id : Byte = vtAnsiChar;
begin
  write(id, SizeOf(Byte));
  Write(item);
end;

procedure TSuperStreamHelper.Write(const item: WideChar);
begin
  write(item, SizeOf(item));
end;

// AnsiString writers
procedure TSuperStreamHelper._write(const item: AnsiString);
const id : Byte = vtAnsiString;
begin
  write(id, SizeOf(Byte));
  Write(item);
end;

procedure TSuperStreamHelper.Write(const item: AnsiString);
var len : Cardinal;
begin
  len := Length(item);
  write(len, SizeOf(len));
  if len > 0 then
    write(item, len);
end;

// WideString writers
procedure TSuperStreamHelper._write(const item : WideString);
const id : Byte = vtWideString;
begin
  write(id, SizeOf(Byte));
  Write(item);
end;

procedure TSuperStreamHelper.Write(const item : WideString);
begin
    raise TObjStreamException.Create('Cannot write WideString yet');
end;

// UnicodeString writers
procedure TSuperStreamHelper._write(const item: UnicodeString);
const id : Byte = vtUnicodeString;
begin
  write(id, SizeOf(Byte));
  Write(item);
end;

procedure TSuperStreamHelper.Write(const item : UnicodeString);
var len : Cardinal;
begin
  len := Length(item);
  write(len, SizeOf(len));
  if len > 0 then
  begin
    len := len * SizeOf(WideChar);
    write(item[1], len);
  end;
end;

// binary writers
procedure TSuperStreamHelper._write(const item: Pointer; len : Cardinal);
const id : Byte = vtBinary;
begin
  write(id, SizeOf(Byte));
end;

procedure TSuperStreamHelper.Write(const item: Pointer; len : Cardinal);
begin
  write(len, SizeOf(len));
  if len > 0 then
    write(item^, len);
end;

procedure TSuperStreamHelper.WriteVarRecItem(const item: tVarRec);
begin
  case item.VType of
    vtInteger:        _write(item.VInteger);
    vtBoolean:        _write(item.VBoolean);
    vtChar:           _write(item.VChar);
    vtExtended:       _write(item.VExtended^);
//    vtString        = 4; // deprecated
//    vtPointer       = 5;
    vtPChar:          _write(item.VPChar);
//    vtObject:         Write(item.vPObject)
//    vtClass         = 8;
    vtWideChar:       _write(item.VWideChar);
    vtPWideChar:      _write(item.VPWideChar);
    vtAnsiString:     _write(AnsiString(item.VAnsiString^));
    vtCurrency:       _write(item.VCurrency^);
//    vtVariant       = 13;
//    vtInterface     = 14;
    vtWideString:     _write(item.VWideString);
    vtInt64:          _write(item.VInt64^);
    vtUnicodeString:  _write(UnicodeString(item.VUnicodeString));
    // SuperStream defined types
    else
      TObjStreamException.Create('Cannot write variable with that type');
  end;
end;

procedure TSuperStreamHelper.WriteVarRecItems(items: array of const);
begin
  for var i := Low(items) to High(items) do
    WriteVarRecItem(items[i]);
end;

function TSuperStreamHelper.ReadAnsiString : AnsiString;
begin
  raise TObjStreamException.Create('Cannot read AnsiString yet');
end;

function TSuperStreamHelper.ReadWideChar : WideChar;
begin
  raise TObjStreamException.Create('Cannot read WideChar yet');
end;

function TSuperStreamHelper.ReadAnsiChar : AnsiChar;
begin
  raise TObjStreamException.Create('Cannot read AnsiChar yet');
end;

function TSuperStreamHelper.ReadInteger : Integer;
begin
  raise TObjStreamException.Create('Cannot read Integer yet');
end;

function TSuperStreamHelper.ReadUnicodeString : UnicodeString;
VAR len : Cardinal;
begin
  ReadFixed(len, sizeof(len));
  if len > 0 then
  begin
    SetLength(Result, len);
    len := len * SizeOf(WideChar);
    readFixed(Result[1], len);
  end
  else
    Result := '';
end;

function TSuperStreamHelper.ReadWideString : WideString;
begin
  raise TObjStreamException.Create('Cannot read WideString yet');
end;

function TSuperStreamHelper.ReadObject : TObject;
begin
  raise TObjStreamException.Create('Cannot read TObject yet');
end;

function TSuperStreamHelper.ReadDouble : Double;
begin
  raise TObjStreamException.Create('Cannot read Double yet');
end;

function TSuperStreamHelper.ReadSingle : Single;
begin
  raise TObjStreamException.Create('Cannot read Single yet');
end;

function TSuperStreamHelper.ReadBoolean : Boolean;
begin
  raise TObjStreamException.Create('Cannot read Boolean yet');
end;

function TSuperStreamHelper.ReadInt64 : Int64;
begin
  raise TObjStreamException.Create('Cannot read Int64 yet');
end;

function TSuperStreamHelper.ReadCurrency : Currency;
begin
  raise TObjStreamException.Create('Cannot read Currency yet');
end;

function TSuperStreamHelper.ReadExtended : Extended;
begin
  raise TObjStreamException.Create('Cannot read Extended yet');
end;

function TSuperStreamHelper.ReadBinary(len: Cardinal): Pointer;
begin
  if len > 0 then
  begin
    GetMem(Result, len);
    read(Result^, len);
  end
  else
    Result := nil;
end;

function TSuperStreamHelper.ReadTypeIdentifier: Byte;
begin
  read(Result, sizeof(Byte));
end;

function TSuperStreamHelper.ReadVarRecItem: TVarRec;
begin
  Result.VType := ReadTypeIdentifier;
  case Result.VType of
    vtInteger:        Result.VInteger := ReadInteger;
    vtBoolean:        Result.VBoolean := ReadBoolean;
    vtChar:           Result.VChar := ReadAnsiChar;
    vtExtended:       Result.VExtended^ := ReadExtended;
//    vtString        = 4; // deprecated
//    vtPointer       = 5;
    vtPChar:          Result.VPChar^ := ReadAnsiChar;
//    vtObject:         Write(item.vPObject)
//    vtClass         = 8;
    vtWideChar:       Result.VWideChar := ReadWideChar;
    vtPWideChar:      Result.VPWideChar^ := ReadWideChar;
    vtAnsiString:     AnsiString(Result.VAnsiString^) := ReadAnsiString;
    vtCurrency:       Result.VCurrency^ := ReadCurrency;
//    vtVariant       = 13;
//    vtInterface     = 14;
    vtWideString:     WideString(Result.VWideString^) := ReadWideString;
    vtInt64:          Result.VInt64^ := ReadInt64;
    vtUnicodeString:  UnicodeString(Result.VUnicodeString^) := ReadUnicodeString;
    // SuperStream defined types
    else
      TObjStreamException.Create('Cannot write variable with that type');
  end;
{
  case item.VType of
    vtInteger:        _write(item.VInteger);
    vtBoolean:        _write(item.VBoolean);
    vtChar:           _write(item.VChar);
    vtExtended:       _write(item.VExtended^);
//    vtString        = 4; // deprecated
//    vtPointer       = 5;
    vtPChar:          _write(item.VPChar);
//    vtObject:         Write(item.vPObject)
//    vtClass         = 8;
    vtWideChar:       _write(item.VWideChar);
    vtPWideChar:      _write(item.VPWideChar);
    vtAnsiString:     _write(AnsiString(item.VAnsiString^));
    vtCurrency:       _write(item.VCurrency^);
//    vtVariant       = 13;
//    vtInterface     = 14;
    vtWideString:     _write(item.VWideString);
    vtInt64:          _write(item.VInt64^);
    vtUnicodeString:  _write(UnicodeString(item.VUnicodeString));
    // SuperStream defined types
    else
      TObjStreamException.Create('Cannot write variable with that type');
  end;
}
end;

end.
