unit Test_Regress;

{ This test unit partly imports the original "tests" from Ross Judson's
  RegressDeCAL project. }

interface

uses
  System.SysUtils,  // IntToStr
  DeCAL,
  DeCAL.MockData,
  DUnitX.TestFramework;

type
  DSetClass = class of DInternalMap;

  [TestFixture]
  TDecalRegress = class
  private

    procedure SequentialBasicCanStoreAndRetrieveSimpleTypes(seq: DSequence);
    procedure SequentialBasicCanCloneItself(seq: DSequence);
    procedure SequentialAlgoCanSortIntegers(seq : DSequence);

    procedure AssociativeBasicCanStoreAndRetrieveSimpleTypes(assoc: DAssociative);
    procedure AssociativeBasicCanCloneItself(assoc : DAssociative);

  public

    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

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

procedure TDecalRegress.Setup;
begin
end;

procedure TDecalRegress.TearDown;
begin
end;

{ Suitable for
  - DList,
  - DArray }
procedure TDecalRegress.SequentialBasicCanStoreAndRetrieveSimpleTypes(seq: DSequence);
begin
  AddSimpleTestData(seq);
  VerifySimpleAddedTestData(seq);

  seq.clear;
  Assert.IsTrue(seq.isEmpty, eReport('SequentialBasicCanStoreAndRetrieveSimpleTypes: DSequence ist not empty after calling clear()', seq));
end;

procedure TDecalRegress.SequentialBasicCanCloneItself(seq: DSequence);
var clone : DContainer;
begin
  AddSimpleTestData(seq);

  clone := seq.clone;
  // the clone must pass the verification
  VerifySimpleAddedTestData(clone);

  seq.clear;
  Assert.IsTrue(seq.isEmpty, eReport('SequentialBasicCanCloneItself: DSequence ist not empty after calling clear()', seq));

  clone.Free;
end;

procedure TDecalRegress.SequentialAlgoCanSortIntegers(seq : DSequence);
var maxval : Integer;
var val : Integer;
var iter : DIterator;
begin
  AddRandomIntegers(seq);
  sort(seq);

  maxval := -1;
  iter := seq.start;
  while(iterateOver(iter)) do
  begin
    val := getInteger(iter);
    Assert.IsTrue(maxval < val, eReport(Format('Sorting failed with %d being smaller than %d', [val, maxval]), seq));
    maxval := val;
  end;

  seq.clear;
  Assert.IsTrue(seq.isEmpty, eReport('SequentialAlgoCanSortIntegers: DSequence ist not empty after calling clear()', seq));
end;

procedure TDecalRegress.AssociativeBasicCanCloneItself(assoc: DAssociative);
var clone : DAssociative;
begin
  PutSimpleTestData(assoc);
  clone := assoc.clone as DAssociative;
  // clone must pass verification
  VerifySimplePutTestData(clone, False);
  clone.Free;

  assoc.clear;
  Assert.IsTrue(assoc.isEmpty, eReport('AssociativeBasicCanCloneItself: DAssociative ist not empty after calling clear()', assoc));
end;

procedure TDecalRegress.AssociativeBasicCanStoreAndRetrieveSimpleTypes(assoc: DAssociative);
begin
  PutSimpleTestData(assoc);
  { false means to walk the ordered container and not use locate }
  VerifySimplePutTestData(assoc, False);

  assoc.clear;
  Assert.IsTrue(assoc.isEmpty, eReport('AssociativeBasicCanStoreAndRetrieveSimpleTypes: DAssociative ist not empty after calling clear()', assoc));
end;

procedure TDecalRegress.TestDArray;
var container : DArray;
begin
  container := DArray.Create;
  SequentialBasicCanStoreAndRetrieveSimpleTypes(container);
  SequentialBasicCanCloneItself(container);
  SequentialAlgoCanSortIntegers(container);
  container.Free;
end;

procedure TDecalRegress.TestDList;
var container : DList;
begin
  container := DList.Create;
  SequentialBasicCanStoreAndRetrieveSimpleTypes(container);
  SequentialBasicCanCloneItself(container);
  SequentialAlgoCanSortIntegers(container);
  container.Free;
end;

procedure TDecalRegress.TestDMap;
var container : DMap;
begin
  container := DMap.Create;
  AssociativeBasicCanStoreAndRetrieveSimpleTypes(container);
  AssociativeBasicCanCloneItself(container);
  container.Free;
end;

procedure TDecalRegress.TestDSet;
var container : DSet;
var integers : DArray;
var iter : DIterator;
var rnd : Integer;
begin
  // get a list of integers to play with
  integers := DArray.Create;
  AddRandomIntegers(integers);

  // copy integers to set
  container := DSet.Create;
  iter := integers.start;
  while(iterateOver(iter)) do
    container.add([getInteger(iter)]);

  // test if every 10th integer is included
  iter := integers.start;
  while(not atEnd(iter)) do
  begin
    Assert.IsTrue(container.includes([getInteger(iter)]), 'Item not found in DSet, but it should be there');
    AdvanceBy(iter, 10);
  end;

  // test if non-existing integers are excluded
  for var i := 1 to 50 do
  begin
    rnd := random(MaxInt);
    iter := find(integers, [rnd]);
    if atEnd(iter) then
      Assert.IsFalse(container.includes([rnd]));
  end;

  integers.Free;
  container.Free;
end;

procedure TDecalRegress.TestDHashSet;
var i : Integer;
    s : DHashSet;
begin
  s := DHashSet.Create;
  for i := 0 to 100 do
    s.add([i]);

  for i := 0 to 100 do
    Assert.IsTrue(s.includes([i]), 'Expected value '+IntToStr(i)+' not in DHashSet');

  s.free;
end;


end.
