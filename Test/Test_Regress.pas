unit Test_Regress;

{ This test unit partly imports the original "tests" from Ross Judson's
  RegressDeCAL project. }

interface

uses
  System.SysUtils,  // IntToStr
  DeCAL,
  DeCAL.MockClasses,
  DUnitX.TestFramework;

type
  [TestFixture]
  TDecalRegress = class
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure TestAssociative;
    [Test]
    procedure TestSorting;
//    [Test]
//    procedure TestCanStoreAndRetriveObjects;
//    [Test]
//    procedure TestCanStoreAndRetriveInterfaces;
  end;

implementation

procedure TDecalRegress.Setup;
begin
end;

procedure TDecalRegress.TearDown;
begin
end;

procedure TDecalRegress.TestAssociative;
var h : DHashMap;
    i : Integer;
    iter : DIterator;
    s : DHashSet;
begin
  h := DHashMap.Create;

  for i := 0 to 100 do
    h.putPair([i, IntToStr(i)]);

  iter := h.start;
  while IterateOver(iter) do
  begin
    SetToKey(iter);
    i := getInteger(iter);
    SetToValue(iter);
    Assert.AreEqual(i, StrToInt(getString(iter)));
//    writeln(GetString(iter));
  end;

  iter := h.locate([55]);
  Assert.IsFalse(atEnd(iter));
//  if not atEnd(iter) then
//    writeln(getString(iter));

  iter := h.locate([9000]);
  Assert.IsTrue(atEnd(iter));
//  if not atEnd(iter) then
//    writeln('error');

  h.free;

  s := DHashSet.Create;
  for i := 0 to 100 do
    s.add([i]);

  for i := 0 to 100 do
    Assert.IsTrue(s.includes([i]), 'Expected value '+IntToStr(i)+' not in DHashSet');

  s.free;
end;

procedure TDecalRegress.TestSorting;
var a : DArray;
    last, i : Integer;
    iter, x : DIterator;
begin
  a := DArray.Create;

  for i := 1 to 1000 do
    a.add([Random(32000)]);

  sort(a);

  // show the first 25 entries
  iter := a.start;
  x := iter;
  advanceBy(x, 25);

  last := -1;
  while not DeCAL.equals(iter, x) do
    begin
      i := getInteger(iter);
      Assert.IsFalse(last > i, 'Sorting error');
//      if last > i then
//        writeln('Sorting error found');
      last := i;
//      writeln(i);
      advance(iter);
    end;

  a.free;
end;

end.
