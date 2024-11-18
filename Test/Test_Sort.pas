unit Test_Sort;

interface

uses
  System.SysUtils, // Format
  TestFramework,
  DUnitX.TestFramework,
  DeCAL;

type

  PairItem = class
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
    function IntegerComparator(const obj1, obj2: DObject) : Integer;
    procedure RunTestContainer(container: DSequence);
    procedure TestContainer(container: DSequence);
    procedure TestContainerForIncreasingIntegers(container : DContainer);
      // stableSort
    function PairGenerator : DObject;
    function PairComparator(const obj1, obj2: DObject) : Integer;
    procedure RunTestContainerStable(container: DSequence);
    procedure TestContainerStable(container: DSequence);
    procedure TestStableContainerForIncreasingIntegers(container : DContainer);
  public
    Constructor Create;
  published

    [Test]
    procedure TestCanSortIntegerArray;
    [Test]
    procedure TestCanStableSortIntegerArray;

  end;

implementation


Constructor TTestSort.Create;
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
function TTestSort.IntegerComparator(const obj1, obj2 : DObject) : Integer;
begin
  Result := obj1.VInteger - obj2.VInteger;
end;

procedure TTestSort.TestContainerForIncreasingIntegers(container: DContainer);
var smallest: Integer;
var test: Integer;
var iter: DIterator;
begin
  smallest := 0;
  iter := container.start;
  while iterateOver(iter) do
  begin
    test := getInteger(iter);
    Assert.IsTrue((test - smallest) >= 0, Format('%s is not sorted because %d is smaller than %d', [container.ClassName, test, smallest]));
    smallest := test;
  end;
end;

procedure TTestSort.RunTestContainer(container: DSequence);
begin
  try
    TestContainer(container);
  finally
    FreeAndNil(container);
  end;
end;

procedure TTestSort.TestContainer(container: DSequence);
begin
  Generate(container, FTestCount, IntegerGenerator);
  sort(container);
  Assert.AreEqual(FTestCount, container.size, Format('%s has lost a member!', [container.ClassName]));
  TestContainerForIncreasingIntegers(container);
end;

procedure TTestSort.TestCanSortIntegerArray;
begin
  FMaxRandomNumber := 1000;
  RunTestContainer(DArray.CreateWith(IntegerComparator));
  RunTestContainer(DList.CreateWith(IntegerComparator));
end;

  // DGeneratorProc
function TTestSort.PairGenerator : DObject;
var obj : PairItem;
begin
  Result.VType := vtObject;
  obj := PairItem.Create;
  obj.SortValue := Random(FMaxRandomNumber);
  obj.Order := FIndex;
  Inc(FIndex);
  Result.VObject := obj;
end;

  // Type DComparator
function TTestSort.PairComparator(const obj1, obj2 : DObject) : Integer;
begin
  Result := (obj1.VObject as PairItem).SortValue - (obj2.VObject as PairItem).SortValue;
end;

procedure TTestSort.TestContainerStable(container: DSequence);
begin
  FIndex := 0;
  Generate(container, FTestCount, PairGenerator);
  stableSort(container);
  Assert.AreEqual(FTestCount, container.size, Format('%s has lost a member!', [container.ClassName]));
  TestStableContainerForIncreasingIntegers(container);
end;

procedure TTestSort.TestStableContainerForIncreasingIntegers(container : DContainer);
var smallest: Integer;
var order: Integer;
var obj: PairItem;
var iter: DIterator;
begin
  smallest := -1;
  order := -1;
  iter := container.start;
  while iterateOver(iter) do
  begin
    obj := getObject(iter) as PairItem;
      // SortValue must be greater or equal to smallest
    Assert.IsTrue((obj.SortValue - smallest) >= 0, Format('%s is not sorted because %d is smaller than %d', [container.ClassName, obj.SortValue, smallest]));
      // if SortValue is equal to smallest, Order must be greater than order
    if(obj.SortValue = smallest) then
    begin
      Assert.IsTrue(obj.Order > order, Format('%s is unstable because order %d is smaller or equal to %d', [container.ClassName, obj.Order, order]));
      order := obj.Order;
    end
    else // reset order on new SortValue
      order := 0;

    smallest := obj.SortValue;
  end;
end;

procedure TTestSort.RunTestContainerStable(container: DSequence);
begin
  try
    TestContainerStable(container);
  finally
    ObjFree(container);
    FreeAndNil(container);
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
