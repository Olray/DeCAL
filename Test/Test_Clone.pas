unit Test_Clone;

interface

uses
  TestFramework,
  DUnitX.TestFramework,
  DeCAL;

type
  [TestFixture]
  TTestClone = class(TTestCase)
  private
    procedure FillContainer(Container: DContainer);
    procedure TestOrderedContainer(Container: DContainer; const ContainerType: string);
    procedure TestUnorderedContainer(Container: DContainer; const ContainerType: string);
  published

    [Test]
    procedure Test_ContainerCloning;

    [Test]
    procedure Test_ClonedContainersHaveUniqueStrings;

  end;

implementation
uses
  System.SysUtils,
  System.Hash;

procedure TTestClone.FillContainer(Container: DContainer);
begin
  for var i := 1 to 10 do
  begin
    if(Container is DAssociative) then
      (Container as DAssociative).putPair([i, IntToStr(i)])
    else
      Container.add([i]);
  end;
end;

procedure TTestClone.TestOrderedContainer(Container: DContainer; const ContainerType: string);
var iter: DIterator;
    i: Integer;
begin
  iter := Container.start;
  for i := 1 to 10 do
  begin
    Assert.IsFalse(atEnd(iter), Format('Container %s has lost content', [Container.ClassName]));
    Assert.AreEqual(i, getInteger(iter), Format('Order of items in Container %s has changed', [Container.ClassName]));
    advance(iter);
  end;
  Assert.IsTrue(atEnd(iter), Format('Found extra item in Container %s', [Container.ClassName]));
end;

procedure TTestClone.TestUnorderedContainer(Container: DContainer; const ContainerType: string);
var i: Integer;
begin
  for i := 1 to 10 do
  begin
    Assert.IsTrue((Container as DAssociative).contains([IntToStr(i)]),
        Format('Container %s (%s)has lost content', [Container.ClassName, ContainerType]));
  end;
  Assert.AreEqual(10, Container.size,
        Format('Found extra item in Container %s (%s)', [Container.ClassName, ContainerType]));
end;

procedure TTestClone.Test_ContainerCloning;

  procedure Test(Container : DContainer);
  var Clone: DContainer;
  begin
      // add numbers 1..10
    FillContainer(Container);
    Assert.AreEqual(10, Container.size,
        Format('Container %s didn''t store all values', [Container.ClassName]));
      // clone the Container
    Clone := Container.clone;
      // class names must equal
    Assert.AreEqual(Container.ClassName, Clone.ClassName,
        Format('Container and clone are not of the same class (%s %s)', [Container.ClassName, Clone.ClassName]));
      // delete an item from Container after cloning to make sure it's not a shallow copy
    Container.remove([1]);
      // Clone must be a new instance
    Assert.IsFalse(@Container = @Clone,
        'Both Container and Clone refer to the same instance');
      // Clone needs to contain numbers 1..10
    if(Container is DAssociative) then
      TestUnorderedContainer(Clone, 'clone')
    else
      TestOrderedContainer(Clone, 'clone');
    Clone.Free;
  end;

var LContainerClasses: DArray;
    iter: DIterator;
    ContainerClass: DContainerClass;
    Container: DContainer;
begin
  LContainerClasses := DArray.Create;
  LContainerClasses.add([DArray, DList, DMap, DMultiMap, DHashMap, DMultiHashMap]);
  iter := LContainerClasses.start;
  while IterateOver(iter) do
  begin
    ContainerClass := DContainerClass(getClass(iter));
    Container := ContainerClass.Create;
    Test(Container);
    Container.Free;
  end;
  LContainerClasses.Free;
end;

procedure TTestClone.Test_ClonedContainersHaveUniqueStrings;
var RandomString: string;
    RandomString2: string;
    Arr: DArray;
    ArrClone: DArray;
    iter: DIterator;
    Map: DMap;
    MapClone: DMap;
begin
  RandomString := THash.GetRandomString(10);
  RandomString2 := THash.GetRandomString(10);

  Arr := DArray.Create;
  Arr.add([RandomString]);

  ArrClone := Arr.clone as DArray;

  iter := Arr.start;
  Assert.AreEqual(RandomString, getString(iter));

    // free arr and check if we still have access to this random string
  Arr.Free;
  iter := ArrClone.start;
  Assert.AreEqual(RandomString, getString(iter));

  ArrClone.Free;

    // try the same with a map

  Map := DMap.Create;
  Map.putPair([1, RandomString]);
  MapClone := Map.clone as DMap;
  iter := Map.start;
  Assert.AreEqual(RandomString, getString(iter));
  Map.Free;
  iter := MapClone.start;
  Assert.AreEqual(RandomString, getString(iter));
  MapClone.Free;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestClone);

end.
