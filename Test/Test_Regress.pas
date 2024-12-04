unit Test_Regress;

{ This test unit partly imports the original "tests" from Ross Judson's
  RegressDeCAL project. }

interface

uses
  DeCAL,
  DUnitX.TestFramework;

type
  [TestFixture]
  TDecalRegress = class
  private

    procedure SequentialBasicCanStoreAndRetrieveSimpleTypes(Sequence: DSequence);
    procedure SequentialBasicCanCloneItself(Sequence: DSequence);
    procedure SequentialAlgoCanSortIntegers(Sequence : DSequence);

    procedure AssociativeBasicCanStoreAndRetrieveSimpleTypes(Assoc: DAssociative);
    procedure AssociativeBasicCanCloneItself(Assoc : DAssociative);

  public

    [Test]
    procedure TestDArray;

    [Test]
    procedure TestDList;

    [Test]
    procedure TestDMap;

    [Test]
    procedure TestDSet;

    [Test]
    procedure TestDHashSet;
  end;

implementation
uses
  System.SysUtils,  // IntToStr
  DeCAL.MockData;

{ Suitable for
  - DList,
  - DArray }
procedure TDecalRegress.SequentialBasicCanStoreAndRetrieveSimpleTypes(Sequence: DSequence);
const ErrorMessage = 'SequentialBasicCanStoreAndRetrieveSimpleTypes: '+
                     'DSequence ist not empty after calling clear()';
begin
  AddSimpleTestData(Sequence);
  VerifySimpleAddedTestData(Sequence);

  Sequence.clear;
  Assert.IsTrue(Sequence.isEmpty,
    EReport(ErrorMessage, Sequence));
end;

procedure TDecalRegress.SequentialBasicCanCloneItself(Sequence: DSequence);
const ErrorMessage = 'SequentialBasicCanCloneItself: '+
                     'DSequence ist not empty after calling clear()';
var Clone : DContainer;
begin
  AddSimpleTestData(Sequence);

  Clone := Sequence.clone;
  // the Clone must pass the verification
  VerifySimpleAddedTestData(Clone);

  Sequence.clear;
  Assert.IsTrue(Sequence.isEmpty,
      EReport(ErrorMessage, Sequence));

  Clone.Free;
end;

procedure TDecalRegress.SequentialAlgoCanSortIntegers(Sequence : DSequence);
const ErrorSorting = 'Sorting failed with %d being smaller than %d';
      ErrorNotEmpty = 'SequentialAlgoCanSortIntegers: '+
                      'DSequence ist not empty after calling clear()';
var MaxVal : Integer;
    Val : Integer;
    Iter : DIterator;
begin
  AddRandomIntegers(Sequence);
  sort(Sequence);

  MaxVal := -1;
  Iter := Sequence.start;
  while IterateOver(Iter) do
  begin
    Val := getInteger(Iter);
    Assert.IsTrue(MaxVal < Val,
        EReport(Format(ErrorSorting, [Val, MaxVal]), Sequence));
    MaxVal := Val;
  end;

  Sequence.clear;
  Assert.IsTrue(Sequence.isEmpty,
      EReport(ErrorNotEmpty, Sequence));
end;

procedure TDecalRegress.AssociativeBasicCanCloneItself(Assoc: DAssociative);
const ErrorNotEmpty = 'AssociativeBasicCanCloneItself: '+
                      'DAssociative ist not empty after calling clear()';
var Clone : DAssociative;
begin
  PutSimpleTestData(Assoc);
  Clone := Assoc.clone as DAssociative;
  // Clone must pass verification
  VerifySimplePutTestData(Clone, False);
  Clone.Free;

  Assoc.clear;
  Assert.IsTrue(Assoc.isEmpty,
      EReport(ErrorNotEmpty, Assoc));
end;

procedure TDecalRegress.AssociativeBasicCanStoreAndRetrieveSimpleTypes(Assoc: DAssociative);
const ErrorMessage = 'AssociativeBasicCanStoreAndRetrieveSimpleTypes: '+
                     'DAssociative ist not empty after calling clear()';
begin
  PutSimpleTestData(Assoc);
  { false means to walk the ordered Container and not use locate }
  VerifySimplePutTestData(Assoc, False);

  Assoc.clear;
  Assert.IsTrue(Assoc.isEmpty,
      EReport(ErrorMessage, Assoc));
end;

procedure TDecalRegress.TestDArray;
var Container : DArray;
begin
  Container := DArray.Create;
  SequentialBasicCanStoreAndRetrieveSimpleTypes(Container);
  SequentialBasicCanCloneItself(Container);
  SequentialAlgoCanSortIntegers(Container);
  Container.Free;
end;

procedure TDecalRegress.TestDList;
var Container : DList;
begin
  Container := DList.Create;
  SequentialBasicCanStoreAndRetrieveSimpleTypes(Container);
  SequentialBasicCanCloneItself(Container);
  SequentialAlgoCanSortIntegers(Container);
  Container.Free;
end;

procedure TDecalRegress.TestDMap;
var Container : DMap;
begin
  Container := DMap.Create;
  AssociativeBasicCanStoreAndRetrieveSimpleTypes(Container);
  AssociativeBasicCanCloneItself(Container);
  Container.Free;
end;

procedure TDecalRegress.TestDSet;
const ErrorNotFound = 'Item not found in DSet, but it should be there';
var Container : DSet;
    Integers : DArray;
    Iter : DIterator;
    RndInteger : Integer;
begin
  // get a list of integers to play with
  Integers := DArray.Create;
  AddRandomIntegers(Integers);

  // copy integers to set
  Container := DSet.Create;
  Iter := Integers.start;
  while IterateOver(Iter) do
    Container.add([getInteger(Iter)]);

  // test if every 10th integer is included
  Iter := Integers.start;
  while not atEnd(Iter) do
  begin
    Assert.IsTrue(Container.includes([getInteger(Iter)]), ErrorNotFound);
    advanceBy(Iter, 10);
  end;

  // test if non-existing integers are excluded
  for var i := 1 to 50 do
  begin
    RndInteger := Random(MaxInt);
    Iter := find(Integers, [RndInteger]);
    if atEnd(Iter) then
      Assert.IsFalse(Container.includes([RndInteger]));
  end;

  Integers.Free;
  Container.Free;
end;

procedure TDecalRegress.TestDHashSet;
const ErrorValueNotFound = 'Expected value %d not in DHashSet';
var i : Integer;
    HashSet : DHashSet;
begin
  HashSet := DHashSet.Create;
  for i := 0 to 100 do
    HashSet.add([i]);

  for i := 0 to 100 do
    Assert.IsTrue(HashSet.includes([i]), Format(ErrorValueNotFound, [i]));

  HashSet.Free;
end;

initialization
  TDUnitX.RegisterTestFixture(TDecalRegress);

end.
