{+--------------------------------------------------------------------------+
 | Unit:	mwFixedRecSort
 | Created:	11.97
 | Author:	Martin Waldenburg
 | Copyright	1997, all rights reserved.
 | Description: A buffered sorter for an unlimmited amount of records with a fixed
 |		length using a three-way merge for memory and a buffered
 |		three-way merge  for files.
 | Version:	1.2
 | Status	FreeWare
 | It's provided as is, without a warranty of any kind.
 | You use it at your own risc.
 | E-Mail me at Martin.Waldenburg@t-online.de}

{--------------------------------------------------------------------}
{ Martin Waldenburg
	Landaeckerstrasse 27
	71642 Ludwigsburg
	Germany
	Share your Code
 +--------------------------------------------------------------------------+}

{$IFDEF FPC}
{$MODE DELPHI}
{$ENDIF}

unit mwFixedRecSort;

{$R-}



interface

uses
{$IFNDEF FPC}
  Windows,
{$ENDIF}
  SysUtils, Classes;

type
  {** DObject are TVarRecs, and can store any kind of atomic value. }
  DObject = TVarRec;
  {** A pointer to an individual DObject. }
  PDObject = ^DObject;

  {** A closure that can compare two objects and returns less than zero if
  obj1 is less than obj2, 0 if obj1 equals obj2, and greater than zero if
  obj1 is greater than obj2;
  @param obj1 The first object (left hand side).
  @param obj2 The second object (right hand side).}
  DComparator = reference to function (const obj1, obj2 : DObject) : Integer;

  PMergeArray = ^TMergeArray;
  TMergeArray = array of PDObject;

{ TSub3Array defines the boundaries of a SubArray and determines if
  the SubArray is full or not.
  The MergeSort Algorithm is easier readable with this class.}
  TSub3Array = class(TObject)
  private
    FMax: LongInt;
  public
    FLeft: LongInt;  { - Initialized to 0. }
    FRight: LongInt;  { - Initialized to 0. }
    Full: Boolean;
    constructor Create(MaxValue: LongInt);
    destructor Destroy; override;
    procedure Init(LeftEnd, RightEnd: LongInt);
    procedure Next;
  end;  { TSub3Array }

{ TM3Array class }
  TM3Array = class(TObject)
  private
    FLeftArray, FMidArray, FRightArray: TSub3Array;
    FM3Array, TempArray, SwapArray: TMergeArray;
    FCount: Integer;
    fCapacity:Integer;
    procedure SetCapacity(NewCapacity:Integer);
    procedure Expand;
  protected
    function Get(Index: Integer): PDObject;
    procedure Put(Index: Integer; Item: PDObject);
    procedure Merge(SorCompare: DComparator);
  public
    destructor Destroy; override;
    function Add(Item: PDObject): Integer;
    procedure Clear;
    function Last: PDObject;
    procedure MergeSort(SorCompare: DComparator);
    procedure QuickSort(SorCompare: DComparator);
    property Count: Integer read FCount write FCount;
    property Items[Index: Integer]: PDObject read Get write Put; default;
    property M3Array: TMergeArray read FM3Array;
    property Capacity:Integer read fCapacity write SetCapacity;
  end;	 { TM3Array }

  TmIOBuffer = class(TObject)
  private
    fBuffFile: File;
    fFileName: String;
    fFilledSize:Longint;
    fBufferSize: LongInt;
    fBufferPos: LongInt;
    fBuffer: Pointer;
    fNeedFill: Boolean;
    fEof:Boolean;
    fFileEof: Boolean;
		FRecCount: Cardinal;
		fSize:Longint;
		fDataLen:Longint;
    procedure AllocBuffer;
  public
    constructor Create(const FileName: String; DataLen, BuffSize: Integer);
    destructor Destroy; override;
    procedure FillBuffer;
    function ReadData:Pointer;
    procedure WriteData(Var NewData);
    procedure FlushBuffer;
    procedure CloseBuffFile;
    procedure DeleteBuffFile;
    property Eof:Boolean read fEof;
    property RecCount: Cardinal read FRecCount;
    property Size:Longint read fSize;
    property DataLen:Longint read fDataLen;
  end;	{ TmIOBuffer }

  TTempFile = class(TObject)
  private
    fFileName: String;
    Reader: TmIOBuffer;
    fFull:Boolean;
  protected
  public
    FLeft: PDObject;
    constructor Create;
    destructor Destroy; override;
    procedure Next;
    procedure Init(const FileName: String);
    property Full:Boolean read fFull;
  end;	{ TTempFile }

  TMergeFile = class(TObject)
  private
    FFileOne, FFileTwo, FFileThree: TTempFile;
    Writer: TmIOBuffer;
    fInList, fOutList, TempList: TStringList;
    fFileName: String;
  public
    constructor Create(InList: TStringList);
    destructor Destroy; override;
    procedure FileMerge(MergeCompare: DComparator);
    procedure MergeSort(MergeCompare: DComparator);
    property FileName: String read fFileName;
  end;	{ TMergeFile }

  TFixRecSort = class(TObject)
  private
    Reader, Writer: TmIOBuffer;
    FMaxLines: LongInt;
    fMerArray: TM3Array;
    MergeFile: TMergeFile;
    fFileName: String;
    fTempFileList: TStringList;
    fCompare: DComparator;
    fMaxMem:LongInt;
    fUseMergesort:Boolean;
    function GetMaxMem:LongInt;
    procedure SetMaxMem(value:LongInt);
  public
    constructor Create(RecLen: LongInt);
    destructor Destroy; override;
    procedure Start(Compare: DComparator);
    procedure Init(const FileName: String);
    property MaxLines: LongInt read FMaxLines write FMaxLines default 60000;
    property MaxMem:LongInt read GetMaxMem write SetMaxMem;
    property UseMergesort:Boolean read fUseMergesort write fUseMergesort;
  end;	 { TFixRecSort }

var
  FRecLen, fBuffersSize: Integer;

implementation

constructor TSub3Array.Create(MaxValue: LongInt);
begin
  inherited Create;
  FLeft := 0;
  FRight := 0;
  Full := False;
  FMax := MaxValue;
end;	{ Create }

procedure TSub3Array.Init(LeftEnd, RightEnd: LongInt);	{ public }
begin
  FLeft:= LeftEnd;
  FRight:= RightEnd;
  if FLeft > FMax then Full:= False else Full:= True;
end;	{ Init }

procedure TSub3Array.Next;
begin
  inc(FLeft);
  if (FLeft > FRight) or (FLeft > FMax) then Full:= False;
end;	{ Next }

destructor TSub3Array.Destroy;
begin
  inherited Destroy;
end;	{ Destroy }

{ TM3Array }
destructor TM3Array.Destroy;
begin
  Clear;
  inherited Destroy;
end;

function TM3Array.Add(Item: PDObject): Integer;
begin
  Result := FCount;
  if Result = FCapacity then Expand;
  FM3Array[Result] := Item;
  Inc(FCount);
end;

procedure TM3Array.Expand;
begin
  SetCapacity(FCapacity + 8192);
end;

procedure TM3Array.SetCapacity(NewCapacity:Integer);
begin
  FCapacity:= NewCapacity;
  SetLength(FM3Array, FCapacity * 4);
end;

procedure TM3Array.Clear;
begin
  FCount:= 0;
  SetLength(TempArray, 0);
  SetLength(FM3Array, 0);
  FCapacity:= 0;
end;

function TM3Array.Get(Index: Integer): PDObject;
begin
  Result := FM3Array[Index];
end;

function TM3Array.Last: PDObject;
begin
  Result := Get(FCount - 1);
end;

procedure TM3Array.Put(Index: Integer; Item: PDObject);
begin
  FM3Array[Index] := Item;
end;

{ Based on a non-recursive QuickSort from the SWAG-Archive.
  ( TV Sorting Unit by Brad Williams ) }
procedure TM3Array.QuickSort(SorCompare: DComparator);
var Left, Right, SubArray, SubLeft, SubRight:LongInt;
    Temp, Pivot: PDObject;
    Stack : array[1..128] of record First, Last : LongInt; end;
begin
  SubArray := 1;
  Stack[SubArray].First := 0;
  Stack[SubArray].Last := Count - 1;
  repeat
    Left := Stack[SubArray].First;
    Right := Stack[SubArray].Last;
    Dec(SubArray);
    repeat
      SubLeft := Left;
      SubRight := Right;
      Pivot := FM3Array[(Left + Right) shr 1];
      repeat
	while SorCompare(FM3Array[SubLeft]^, Pivot^) < 0 do Inc(SubLeft);
	while SorCompare(FM3Array[SubRight]^, Pivot^) > 0 do Dec(SubRight);
	IF SubLeft <= SubRight then
	  begin
	    Temp := FM3Array[SubLeft];
	    FM3Array[SubLeft] := FM3Array[SubRight];
	    FM3Array[SubRight] := Temp;
	    Inc(SubLeft);
	    Dec(SubRight);
	  end;
      until SubLeft > SubRight;
      IF SubLeft < Right then
	begin
	  Inc(SubArray);
	  Stack[SubArray].First := SubLeft;
	  Stack[SubArray].Last := Right;
	end;
      Right := SubRight;
    until Left >= Right;
  until SubArray = 0;
end;  { QuickSort }

{This is a three way merge routine.
 Unfortunately the " Merge " routine needs additional memory}
procedure TM3Array.Merge(SorCompare: DComparator);
var
  TempPos : integer;
begin
  TempPos := FLeftArray.FLeft;
  while ( FLeftArray.Full ) and ( FMidArray.Full ) and ( FRightArray.Full ) do  {Main Loop}
    begin
      if SorCompare(FM3Array[FLeftArray.FLeft]^, FM3Array[FMidArray.FLeft]^) <= 0 then
	begin
	  if SorCompare(FM3Array[FLeftArray.FLeft]^, FM3Array[FRightArray.FLeft]^) <= 0 then
	    begin
	      TempArray[ TempPos ] := FM3Array[ FLeftArray.FLeft ];
	      FLeftArray.Next;
	    end
	  else
	    begin
	      TempArray[ TempPos ] := FM3Array[ FRightArray.FLeft ];
	      FRightArray.Next;
	    end;
	end
      else
	begin
	  if SorCompare(FM3Array[FMidArray.FLeft]^, FM3Array[FRightArray.FLeft]^) <= 0 then
	    begin
	      TempArray[ TempPos ] := FM3Array[ FMidArray.FLeft ];
	      FMidArray.Next;
	    end
	  else
	    begin
	      TempArray[ TempPos ] := FM3Array[ FRightArray.FLeft ];
	      FRightArray.Next;
	    end;
	end;
      inc(TempPos);
    end;

  while ( FLeftArray.Full ) and ( FMidArray.Full ) do
    begin
      if SorCompare(FM3Array[FLeftArray.FLeft]^, FM3Array[FMidArray.FLeft]^) <= 0 then
	begin
	  TempArray[ TempPos ] := FM3Array[ FLeftArray.FLeft ];
	  FLeftArray.Next;
	end
      else
	begin
	  TempArray[ TempPos ] := FM3Array[ FMidArray.FLeft ];
	  FMidArray.Next;
	end;
      inc(TempPos);
    end;

  while ( FMidArray.Full ) and ( FRightArray.Full ) do
    begin
      if SorCompare(FM3Array[FMidArray.FLeft]^, FM3Array[FRightArray.FLeft]^) <= 0 then
	begin
	  TempArray[ TempPos ] := FM3Array[ FMidArray.FLeft ];
	  FMidArray.Next;
	end
      else
	begin
	  TempArray[ TempPos ] := FM3Array[ FRightArray.FLeft ];
	  FRightArray.Next;
	end;
      inc(TempPos);
    end;

  while ( FLeftArray.Full ) and ( FRightArray.Full ) do
    begin
      if SorCompare(FM3Array[FLeftArray.FLeft]^, FM3Array[FRightArray.FLeft]^) <= 0 then
	begin
	  TempArray[ TempPos ] := FM3Array[ FLeftArray.FLeft ];
	  FLeftArray.Next;
	end
      else
	begin
	  TempArray[ TempPos ] := FM3Array[ FRightArray.FLeft ];
	  FRightArray.Next;
	end;
      inc(TempPos);
    end;

 while FLeftArray.Full do    { Copy Rest of First Sub3Array }
    begin
      TempArray[ TempPos ] := FM3Array[ FLeftArray.FLeft ];
      inc(TempPos); FLeftArray.Next;
    end;

  while FMidArray.Full do    { Copy Rest of Second Sub3Array }
    begin
      TempArray[ TempPos ] := FM3Array[ FMidArray.FLeft ];
      inc(TempPos); FMidArray.Next;
    end;

 while FRightArray.Full do   { Copy Rest of Third Sub3Array }
    begin
      TempArray[ TempPos ] := FM3Array[ FRightArray.FLeft ];
      inc(TempPos); FRightArray.Next;
    end;

end;  { Merge }

{Non-recursive Mergesort.
 Very fast, if enough memory available.
 The number of comparisions used is nearly optimal, about 3/4 of QuickSort.
 If comparision plays a very more important role than exchangement,
 it outperforms QuickSort in any case.
 ( Large keys in pointer arrays, for example text with few short lines. )
 From all Algoritms with O(N lg N) it's the only stable, meaning it lefts
 equal keys in the order of input. This may be important in some cases. }
procedure TM3Array.MergeSort(SorCompare: DComparator);
var
  a, b, c, N, todo: LongInt;
begin
  SetLength(TempArray, FCount * 4);
  FLeftArray:= TSub3Array.Create(FCount -1);
  FMidArray:= TSub3Array.Create(FCount -1);
  FRightArray:= TSub3Array.Create(FCount -1);
  N:= 1;
  repeat
    todo:= 0;
    repeat
      a:= todo;
      b:= a +N;
      c:= b +N;
      todo:= C +N;
      FLeftArray.Init(a, b -1);
      FMidArray.Init(b, c -1);
      FRightArray.Init(c, todo -1);
      Merge(SorCompare);
    until todo >= Fcount;
    SwapArray:= FM3Array; {Alternating use of the arrays.}
    FM3Array:= TempArray;
    TempArray:= SwapArray;
    N:= N+ N +N;
  until N >= Fcount;
  FLeftArray.Free;
  FMidArray.Free;
  FRightArray.Free;
  SetLength(TempArray, 0);
end;  { MergeSort }

constructor TmIOBuffer.Create(const FileName: String; DataLen, BuffSize: Integer);
var
  fHandle: Integer;
begin
  inherited create;
  FDataLen:= DataLen;
  fFileName:= FileName;
  if not FileExists(FileName) then
  begin
    fHandle:= FileCreate(FileName);
    FileClose(fHandle);
  end;
  fBufferSize:= BuffSize;
  FRecCount:= BuffSize Div DataLen;
  fBufferSize:= DWORD(DataLen) * FRecCount;
  AssignFile(fBuffFile, FileName);
  Reset(fBuffFile, 1);
  fSize:= FileSize(fBuffFile);
  fNeedFill:= True;
  fEof:= False;
  fFileEof:= False;
  AllocBuffer;
  fBufferPos:= 0;
end;  { create }

destructor TmIOBuffer.destroy;
begin
  ReallocMem(fBuffer, 0);
  CloseBuffFile;
  inherited destroy;
end;  { destroy }

procedure TmIOBuffer.AllocBuffer;
begin
  fFilledSize:= fBufferSize;
  ReallocMem(fBuffer, fBufferSize);
end; { SetBufferSize }

procedure TmIOBuffer.FillBuffer;
var
  Readed: LongInt;
begin
  Readed := 0;
  BlockRead(fBuffFile, fBuffer^, fBufferSize, Readed);
  if FilePos(FBuffFile) = FSize then fFileEof:= True;
  fBufferPos:= 0;
  fFilledSize:= Readed;
  fNeedFill:= False;
end;   { FillBuffer }

function TmIOBuffer.ReadData:Pointer;
begin
  fEof:= False;
  if fNeedFill then FillBuffer;
  {$IFDEF FPC}
  Result:= Pointer(fBuffer + fBufferPos);
  {$ELSE}
  Result:= Pointer(Integer(fBuffer) + fBufferPos);
  {$ENDIF}
  inc(fBufferPos, fDataLen);
  if fBufferPos >= fFilledSize then
  begin
    fNeedFill:= True;
    if FFileEof then FEof:= True;
  end;
end;   { ReadData }

procedure TmIOBuffer.WriteData(Var NewData);
var
  Pos: LongInt;
begin
  if (fBufferPos >= 0) and (Pointer(NewData) <> nil) then
  begin
    Pos := fBufferPos + fDataLen;
    if Pos > 0 then
    begin
      if Pos >= FBufferSize then
	  begin
        FlushBuffer;
	  end;
      {$IFDEF FPC}
      Move(NewData, Pointer(fBuffer + fBufferPos)^, fDataLen);
      {$ELSE}
      Move(NewData, Pointer(LongInt(fBuffer) + fBufferPos)^, fDataLen);
      {$ENDIF}
      inc(fBufferPos, fDataLen);
    end;
  end;
end;  { WriteData }

procedure TmIOBuffer.FlushBuffer;
var
  Written: LongInt;
begin
  Written := 0;
  BlockWrite(fBuffFile, fBuffer^, fBufferPos, Written);
  fBufferPos:= 0;
end;  { FlushBuffer }

procedure TmIOBuffer.CloseBuffFile;
begin
  CloseFile(fBuffFile);
end;  { CloseBuffFile }

procedure TmIOBuffer.DeleteBuffFile;
begin
  SysUtils.DeleteFile(fFileName);
end;  { DeleteBuffFile }

constructor TTempFile.Create;
begin
  inherited Create;
   fFull:= False;
end;  { Create }

procedure TTempFile.Init(const FileName: String);
begin
  fFull:= False;
  fFileName:= FileName;
  if fFileName <> '' then
    begin
      Reader:= TmIOBuffer.Create(fFileName, FRecLen, fBuffersSize);
      if not Reader.Eof then
	begin
	  fLeft:= Reader.ReadData;
	  fFull:= True;
	end
      else
	begin
	  Reader.Free;
	  SysUtils.DeleteFile(fFileName);
	  fFileName:= '';
	end;
    end;
end; { Init }

procedure TTempFile.Next;
begin
  if not Reader.Eof then
    begin
      fLeft:= Reader.ReadData;
      fFull:= True;
    end
  else
    begin
      fFull:= False;
      if fFileName <> '' then
      begin
	Reader.Free;
	SysUtils.DeleteFile(fFileName);
	fFileName:= '';
      end;
    end
end;  { Next }

destructor TTempFile.Destroy;
begin
  if fFileName <> '' then
  begin
    Reader.Free;
    SysUtils.DeleteFile(fFileName);
  end;
  inherited Destroy;
end;  { Destroy }


constructor TMergeFile.Create(InList: TStringList);
begin
  inherited Create;
  fInList:= InList;
end;  { Create }

destructor TMergeFile.Destroy;
begin
  inherited Destroy;
end;  { Destroy }

procedure TMergeFile.FileMerge(MergeCompare: DComparator);
begin

  while ( FFileOne.Full ) and ( FFileTwo.Full ) and ( FFileThree.Full ) do
    begin
      if MergeCompare(FFileOne.FLeft^, FFileTwo.FLeft^) <= 0 then
	begin
	  if MergeCompare(FFileOne.FLeft^, FFileThree.FLeft^) <= 0 then
	    begin
	      Writer.WriteData(FFileOne.fLeft^);
	      FFileOne.Next;
	    end
	  else
	    begin
	      Writer.WriteData(FFileThree.fLeft^);
	      FFileThree.Next;
	    end;
	end
      else
	begin
	  if MergeCompare(FFileTwo.FLeft^, FFileThree.FLeft^) <= 0 then
	    begin
	      Writer.WriteData(FFileTwo.fLeft^);
	      FFileTwo.Next;
	    end
	  else
	    begin
	      Writer.WriteData(FFileThree.fLeft^);
	      FFileThree.Next;
	    end;
	end;
    end;

  while ( FFileOne.Full ) and ( FFileTwo.Full ) do
    begin
      if MergeCompare(FFileOne.FLeft^, FFileTwo.FLeft^) <= 0 then
	begin
	  Writer.WriteData(FFileOne.fLeft^);
	  FFileOne.Next;
	end
      else
	begin
	  Writer.WriteData(FFileTwo.fLeft^);
	  FFileTwo.Next;
	end;
    end;

  while ( FFileOne.Full ) and ( FFileThree.Full ) do
    begin
      if MergeCompare(FFileOne.FLeft^, FFileThree.FLeft^) <= 0 then
	begin
	  Writer.WriteData(FFileOne.fLeft^);
	  FFileOne.Next;
	end
      else
	begin
	  Writer.WriteData(FFileThree.fLeft^);
	  FFileThree.Next;
	end;
    end;

  while ( FFileTwo.Full ) and ( FFileThree.Full ) do
    begin
      if MergeCompare(FFileTwo.FLeft^, FFileThree.FLeft^) <= 0 then
	begin
	  Writer.WriteData(FFileTwo.fLeft^);
	  FFileTwo.Next;
	end
      else
	begin
	  Writer.WriteData(FFileThree.fLeft^);
	  FFileThree.Next;
	end;
    end;

  while FFileOne.Full do    { Write Rest of First SubFile }
    begin
      Writer.WriteData(FFileOne.fLeft^);
      FFileOne.Next;
    end;

  while FFileTwo.Full do    { Write Rest of Second SubFile }
    begin
      Writer.WriteData(FFileTwo.fLeft^);
      FFileTwo.Next;
    end;

  while FFileThree.Full do   { Write Rest of Third SubFile }
    begin
      Writer.WriteData(FFileThree.fLeft^);
      FFileThree.Next;
    end;

end; { FileMerge }

procedure TMergeFile.MergeSort(MergeCompare: DComparator);
var
  a, b, c: String;
  N, todo: LongInt;
begin
  fOutList:= TStringList.Create;
  fOutList.Clear;
  todo:= 0;
  N:= fInList.Count;
  fFileOne:= TTempFile.Create;
  fFileTwo:= TTempFile.Create;
  fFileThree:= TTempFile.Create;
  while fInList.Count > 1 do
  begin
    while todo < fInList.Count do
    begin
      fFileName:= 'Temp' + IntToStr(N);
      inc(N);
      Writer:= TmIOBuffer.Create(fFileName, fRecLen, fBuffersSize*3);
      fOutList.Add(fFileName);
      a:= fInList.Strings[todo]; inc(todo);
      if todo < fInList.Count then begin b:= fInList.Strings[todo]; inc(todo) end else b:= '';
      if todo < fInList.Count then begin c:= fInList.Strings[todo]; inc(todo) end else c:= '';
      FFileOne.Init(a);
      FFileTwo.Init(b);
      FFileThree.Init(c);
      FileMerge(MergeCompare);
      Writer.FlushBuffer;
      Writer.Free;
      if todo = fInList.Count -1 then
	begin
	  fOutList.Add(fInList.Strings[todo]);
	  inc(todo);
	end;
    end;
    todo:= 0;
    TempList:= fInList;
    fInList:= fOutList;
    fOutList:= TempList;
    fOutList.Clear;
  end;
  fFileOne.Free;
  fFileTwo.Free;
  fFileThree.Free;
  fOutList.Free
end;  { MergeSort }

constructor TFixRecSort.Create(RecLen: LongInt);
begin
  inherited Create;
  FRecLen:= RecLen;
  fFileName:= '';
  FMaxLines := 60000;
  FUseMergesort:= True;
end;  { Create }

procedure TFixRecSort.Init(const FileName: String);
begin
  fFileName:= FileName;
  fTempFileList:= TStringList.Create;
end;

function TFixRecSort.GetMaxMem:LongInt;
begin
  Result:= fMaxMem;
end;   { GetMaxMem }

procedure TFixRecSort.SetMaxMem(value:LongInt);
var
  RecLenPlus, CountRec: Integer;
begin
  if Value < 100000 then Value:= 100000;
  fBuffersSize:= value div 6;
  RecLenPlus:= FRecLen +8;
  CountRec:= fBuffersSize div RecLenPlus;
  fBuffersSize:= CountRec *FRecLen;
  fMaxMem:= Value;
end;  { SetMaxMem }

procedure TFixRecSort.Start(Compare: DComparator);
var
  TempFileName, BackFileName, InFileName: String;
  I, K: Integer;
begin
  FCompare:= Compare;
  I:= 0;
  InFileName:= fFileName;
  BackFileName:= ChangeFileExt(fFileName, '.bak');
  if FileExists(BackFileName) then DeleteFile(PChar(BackFileName));
  Reader:= TmIOBuffer.Create(FFileName, fRecLen, fBuffersSize *5);
  while not Reader.Eof do
  begin
    fMerArray:= TM3Array.Create;
    TempFileName:= 'Temp' + IntToStr(I);
    fTempFileList.Add(TempFileName);
    Writer:= TmIOBuffer.Create(TempFileName, fRecLen, fBuffersSize);
    inc(I);
    while (fMerArray.Count < fMaxLines) and (DWORD(fMerArray.Count) <= Reader.RecCount) and (not Reader.Eof) do
    begin
      fMerArray.Add(Reader.ReadData);
    end;	{ while }
    if UseMergesort then fMerArray.MergeSort(fCompare)
    else fMerArray.QuickSort(fCompare);
    for K := 0 to  fMerArray.Count -1 do       { Iterate }
    begin
      Writer.WriteData(fMerArray[K]^);
    end;	{ for }
    Writer.FlushBuffer;
    Writer.Free;
    fMerArray.Free;
  end;	      { while }
  Reader.Free;
  if fTempFileList.Count > 1 then
  begin
    MergeFile:= TMergeFile.Create(fTempFileList);
    MergeFile.MergeSort(fCompare);
    RenameFile(InFileName, BackFileName);
    RenameFile(MergeFile.FileName, FFileName);
    MergeFile.Free;
  end else
  begin
    RenameFile(InFileName, BackFileName);
    RenameFile(TempFileName, FFileName);
  end;
end;  { Start }

destructor TFixRecSort.Destroy;
begin
  inherited Destroy;
end;  { Destroy }

end.


