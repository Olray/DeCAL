unit DeCAL.MockData;

interface

uses
  DeCAL,
  System.SysUtils, // IntToStr
  DUnitX.TestFramework;

const TestCases = 1000;

Function eReport(const AMessage : String; ACulprit : DContainer) : String;

// non-associative test data
procedure AddSimpleTestData(container : DContainer);
procedure VerifySimpleAddedTestData(container : DContainer);

// for sorting tests
procedure AddRandomIntegers(container : DContainer);
procedure PutRandomIntegers(container : DAssociative);

// associative test data
procedure PutSimpleTestData(container : DAssociative);
procedure VerifySimplePutTestData(container : DAssociative; UseLocate : Boolean);

implementation

Function eReport(const AMessage : String; ACulprit : DContainer) : String;
begin
  Result := AMessage + ' (in ' + ACulprit.ClassName + ')';
end;

procedure AddSimpleTestData(container : DContainer);
var SomeAnsiString : AnsiString;
begin
  container.add([100]);
  container.add(['A Wide String']);
  container.add([3.1415]);
  SomeAnsiString := 'An Ansi String';
  container.add([SomeAnsiString]);
  container.add([True]);
end;

procedure VerifySimpleAddedTestData(container : DContainer);
var iter : DIterator;
var SomeAnsiString : AnsiString;
begin
  SomeAnsiString := 'An Ansi String';
  iter := container.start;
  Assert.AreEqual(100, getInteger(iter), eReport('getInteger() error', container));
  Advance(iter);
  Assert.AreEqual('A Wide String', getString(iter), eReport('getString() error', container));
  Advance(iter);
  Assert.AreEqual(3.1415, getExtended(iter), eReport('getExtended() error', container));
  Advance(iter);
  Assert.AreEqual(SomeAnsiString, getAnsiString(iter), eReport('getAnsiString() error', container));
  Advance(iter);
  Assert.IsTrue(getBoolean(iter), eReport('getBoolean() error', container));
end;

procedure AddRandomIntegers(container : DContainer);
begin
  for var i := 1 to TestCases do
    container.add([random(MaxInt)]);
end;

procedure PutRandomIntegers(container : DAssociative);
var rnd : Integer;
begin
  for var i := 1 to TestCases do
  begin
    rnd := random(MaxInt);
    container.putPair([rnd, IntToStr(rnd)]);
  end;
end;

procedure PutSimpleTestData(container : DAssociative);
var SomeAnsiString : AnsiString;
begin
  SomeAnsiString := 'An Ansi String';
  container.putPair([100, 4711]);
  container.putPair([200, 'A Wide String']);
  container.putPair([300, 3.1415]);
  container.putPair([400, SomeAnsiString]);
  container.putPair([500, True]);
end;

procedure VerifySimplePutTestData(container : DAssociative; UseLocate : Boolean);
var iterators : array[1..5] of DIterator;
var iter : DIterator;
var SomeAnsiString : AnsiString;
var i : Integer;
begin
  if UseLocate then
  begin
    for i := 1 to 5 do
      iterators[i] := container.locate([100 * i]);
  end
  else
  begin
    iter := container.start;
    for i := 1 to 5 do
    begin
      iterators[i] := iter;
      Advance(iter);
    end;
  end;

  SomeAnsiString := 'An Ansi String';
  Assert.AreEqual(4711, getInteger(iterators[1]), eReport('getInteger() error', container));
  iter := container.locate([200]);
  Assert.AreEqual('A Wide String', getString(iterators[2]), eReport('getString() error', container));
  iter := container.locate([300]);
  Assert.AreEqual(3.1415, getExtended(iterators[3]), eReport('getExtended() error', container));
  iter := container.locate([400]);
  Assert.AreEqual(SomeAnsiString, getAnsiString(iterators[4]), eReport('getAnsiString() error', container));
  iter := container.locate([500]);
  Assert.IsTrue(getBoolean(iter), eReport('getBoolean() error', container));
end;

end.
