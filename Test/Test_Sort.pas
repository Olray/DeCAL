unit Test_Sort;

interface

uses
  TestFramework,
  DUnitX.TestFramework,
  DeCAL;

type

  TPairItem = class
    SortValue : Integer;
    Order : Integer;
  end;

  [TestFixture]
  TTestSort = class(TTestCase)
  private
    FMaxRandomNumber : Integer;
    FTestCount : Integer;
    FIndex: Integer;
      // sort
    function IntegerGenerator : DObject;
    function IntegerComparator(const Object1, Object2: DObject) : Integer;
    procedure RunTestContainer(Container: DSequence);
    procedure TestContainer(Container: DSequence);
    procedure TestContainerForIncreasingIntegers(Container : DContainer);
      // stableSort
    function PairGenerator : DObject;
    function PairComparator(const Object1, Object2: DObject) : Integer;
    procedure RunTestContainerStable(Container: DSequence);
    procedure TestContainerStable(Container: DSequence);
    procedure TestStableContainerForIncreasingIntegers(Container : DContainer);
  public
    constructor Create;
  published

    [Test]
    procedure TestCanSortIntegerArray;
    [Test]
    procedure TestCanStableSortIntegerArray;

  end;

implementation
uses
  System.SysUtils; // Format


constructor TTestSort.Create;
begin
  FMaxRandomNumber := 1000;
  FTestCount := 1000;
end;

  // DGeneratorProc
function TTestSort.IntegerGenerator : DObject;
begin
  Result.VType := vtInteger;
  Result.VInteger := Random(FMaxRandomNumber);
end;

  // Type DComparator
function TTestSort.IntegerComparator(const Object1, Object2 : DObject) : Integer;
begin
  Result := Object1.VInteger - Object2.VInteger;
end;

procedure TTestSort.TestContainerForIncreasingIntegers(Container: DContainer);
const ErrorOrder = '%s is not sorted because %d is smaller than %d';
var Smallest: Integer;
    Test: Integer;
    Iter: DIterator;
begin
  Smallest := 0;
  Iter := Container.start;
  while IterateOver(Iter) do
  begin
    Test := getInteger(Iter);
    Assert.IsTrue((Test - Smallest) >= 0,
        Format(ErrorOrder, [Container.ClassName, Test, Smallest]));
    Smallest := Test;
  end;
end;

procedure TTestSort.RunTestContainer(Container: DSequence);
begin
  try
    TestContainer(Container);
  finally
    FreeAndNil(Container);
  end;
end;

procedure TTestSort.TestContainer(Container: DSequence);
begin
  generate(Container, FTestCount, IntegerGenerator);
  sort(Container);
  Assert.AreEqual(FTestCount, Container.size, Format('%s has lost a member!', [Container.ClassName]));
  TestContainerForIncreasingIntegers(Container);
end;

procedure TTestSort.TestCanSortIntegerArray;
begin
  FMaxRandomNumber := 1000;
  RunTestContainer(DArray.CreateWith(IntegerComparator));
  RunTestContainer(DList.CreateWith(IntegerComparator));
end;

  // DGeneratorProc
function TTestSort.PairGenerator : DObject;
var Obj : TPairItem;
begin
  Result.VType := vtObject;
  Obj := TPairItem.Create;
  Obj.SortValue := Random(FMaxRandomNumber);
  Obj.Order := FIndex;
  Inc(FIndex);
  Result.VObject := Obj;
end;

  // Type DComparator
function TTestSort.PairComparator(const Object1, Object2 : DObject) : Integer;
begin
  Result := (Object1.VObject as TPairItem).SortValue - (Object2.VObject as TPairItem).SortValue;
end;

procedure TTestSort.TestContainerStable(Container: DSequence);
begin
  FIndex := 0;
  generate(Container, FTestCount, PairGenerator);
  stablesort(Container);
  Assert.AreEqual(FTestCount, Container.size, Format('%s has lost a member!', [Container.ClassName]));
  TestStableContainerForIncreasingIntegers(Container);
end;

procedure TTestSort.TestStableContainerForIncreasingIntegers(Container : DContainer);
const ErrorUnsorted = '%s is not sorted because %d is smaller than %d';
      ErrorUnstable = '%s is unstable because order %d is smaller or equal to %d';
var Smallest: Integer;
    Order: Integer;
    Obj: TPairItem;
    Iter: DIterator;
begin
  Smallest := -1;
  Order := -1;
  Iter := Container.start;
  while IterateOver(Iter) do
  begin
    Obj := getObject(Iter) as TPairItem;
      // SortValue must be greater or equal to smallest
    Assert.IsTrue((Obj.SortValue - Smallest) >= 0,
        Format(ErrorUnsorted, [Container.ClassName, Obj.SortValue, Smallest]));
      // if SortValue is equal to smallest, Order must be greater than order
    if(Obj.SortValue = Smallest) then
    begin
      Assert.IsTrue(Obj.Order > Order,
          Format(ErrorUnstable, [Container.ClassName, Obj.Order, Order]));
      Order := Obj.Order;
    end
    else // reset order on new SortValue
      Order := 0;

    Smallest := Obj.SortValue;
  end;
end;

procedure TTestSort.RunTestContainerStable(Container: DSequence);
begin
  try
    TestContainerStable(Container);
  finally
    objFree(Container);
    FreeAndNil(Container);
  end;
end;

procedure TTestSort.TestCanStableSortIntegerArray;
begin
  FMaxRandomNumber := 10;
  RunTestContainerStable(DArray.CreateWith(PairComparator));
  RunTestContainerStable(DList.CreateWith(PairComparator));
end;


initialization
  TDUnitX.RegisterTestFixture(TTestSort);

end.
