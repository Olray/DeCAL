unit DeCAL.MockData;

interface

uses
  DeCAL;

const TestCases = 1000;

function EReport(const AMessage : string; ACulprit : DContainer) : string;

// non-associative test data
procedure AddSimpleTestData(Container : DContainer);
procedure VerifySimpleAddedTestData(Container : DContainer);

// for sorting tests
procedure AddRandomIntegers(Container : DContainer);

// associative test data
procedure PutSimpleTestData(Container : DAssociative);
procedure VerifySimplePutTestData(Container : DAssociative; UseLocate : Boolean);

implementation
uses
  DUnitX.TestFramework;

function EReport(const AMessage : string; ACulprit : DContainer) : string;
begin
  Result := AMessage + ' (in ' + ACulprit.ClassName + ')';
end;

procedure AddSimpleTestData(Container : DContainer);
var SomeAnsiString : AnsiString;
begin
  Container.add([100]);
  Container.add(['A Wide string']);
  Container.add([3.1415]);
  SomeAnsiString := 'An Ansi string';
  Container.add([SomeAnsiString]);
  Container.add([True]);
end;

procedure VerifySimpleAddedTestData(Container : DContainer);
var iter : DIterator;
    SomeAnsiString : AnsiString;
begin
  SomeAnsiString := 'An Ansi string';
  iter := Container.start;
  Assert.AreEqual(100, getInteger(iter), EReport('getInteger() error', Container));
  advance(iter);
  Assert.AreEqual('A Wide string', getString(iter), EReport('getString() error', Container));
  advance(iter);
  Assert.AreEqual(3.1415, getExtended(iter), EReport('getExtended() error', Container));
  advance(iter);
  Assert.AreEqual(SomeAnsiString, getAnsiString(iter), EReport('getAnsiString() error', Container));
  advance(iter);
  Assert.IsTrue(getBoolean(iter), EReport('getBoolean() error', Container));
end;

procedure AddRandomIntegers(Container : DContainer);
begin
  for var i := 1 to TestCases do
    Container.add([Random(MaxInt)]);
end;

procedure PutSimpleTestData(Container : DAssociative);
var SomeAnsiString : AnsiString;
begin
  SomeAnsiString := 'An Ansi string';
  Container.putPair([100, 4711]);
  Container.putPair([200, 'A Wide string']);
  Container.putPair([300, 3.1415]);
  Container.putPair([400, SomeAnsiString]);
  Container.putPair([500, True]);
end;

procedure VerifySimplePutTestData(Container : DAssociative; UseLocate : Boolean);
var Iterators : array[1..5] of DIterator;
    iter : DIterator;
    SomeAnsiString : AnsiString;
    i : Integer;
begin
  if UseLocate then
  begin
    for i := 1 to 5 do
      Iterators[i] := Container.locate([100 * i]);
  end
  else
  begin
    iter := Container.start;
    for i := 1 to 5 do
    begin
      Iterators[i] := iter;
      advance(iter);
    end;
  end;

  SomeAnsiString := 'An Ansi string';
  Assert.AreEqual(4711, getInteger(Iterators[1]), EReport('getInteger() error', Container));
  iter := Container.locate([200]);
  Assert.AreEqual('A Wide string', getString(Iterators[2]), EReport('getString() error', Container));
  iter := Container.locate([300]);
  Assert.AreEqual(3.1415, getExtended(Iterators[3]), EReport('getExtended() error', Container));
  iter := Container.locate([400]);
  Assert.AreEqual(SomeAnsiString, getAnsiString(Iterators[4]), EReport('getAnsiString() error', Container));
  iter := Container.locate([500]);
  Assert.IsTrue(getBoolean(iter), EReport('getBoolean() error', Container));
end;

end.
