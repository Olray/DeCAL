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
    procedure FillContainer(container: DContainer);
    procedure FillSet(container: DContainer);
    procedure TestOrderedContainer(container: DContainer; const containerType: String);
    procedure TestUnorderedContainer(container: DContainer; const containerType: String);
    procedure TestSetContainer(container: DContainer; const containerType: String);
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

procedure TTestClone.FillContainer(container: DContainer);
begin
  for var i := 1 to 10 do
  begin
    if(Container is DAssociative) then
      (container as DAssociative).putPair([i, IntToStr(i)])
    else
      container.add([i]);
  end;
end;

procedure TTestClone.FillSet(container: DContainer);
begin
  for var i := 1 to 10 do
    (container as DAssociative).add([i]);
end;

procedure TTestClone.TestOrderedContainer(container: DContainer; const containerType: String);
var iter: DIterator;
var i: Integer;
begin
  iter := container.start;
  for i := 1 to 10 do
  begin
    Assert.IsFalse(atEnd(iter), Format('Container %s has lost content', [container.ClassName]));
    Assert.AreEqual(i, getInteger(iter), Format('Order of items in container %s has changed', [container.ClassName]));
    advance(iter);
  end;
  Assert.IsTrue(atEnd(iter), Format('Found extra item in container %s', [container.ClassName]));
end;

procedure TTestClone.TestUnorderedContainer(container: DContainer; const containerType: String);
var iter: DIterator;
var i: Integer;
begin
  for i := 1 to 10 do
  begin
    Assert.IsTrue((Container as DAssociative).contains([IntToStr(i)]), Format('Container %s (%s)has lost content', [container.ClassName, containerType]));
  end;
  Assert.AreEqual(10, container.size, Format('Found extra item in container %s (%s)', [container.ClassName, containerType]));
end;

procedure TTestClone.TestSetContainer(container: DContainer; const containerType: String);
var iter: DIterator;
var i: Integer;
begin
  for i := 1 to 10 do
  begin
    Assert.IsTrue((Container as DAssociative).contains([i]), Format('Container %s (%s)has lost content', [container.ClassName, containerType]));
  end;
  Assert.AreEqual(10, container.size, Format('Found extra item in container %s (%s)', [container.ClassName, containerType]));
end;

procedure TTestClone.Test_ContainerCloning;

  procedure Test(Container : DContainer);
  var Clone: DContainer;
  begin
      // add numbers 1..10
    FillContainer(Container);
    Assert.AreEqual(10, container.size, Format('Container %s didn''t store all values', [Container.ClassName]));
      // clone the container
    Clone := Container.clone;
      // class names must equal
    Assert.AreEqual(Container.ClassName, Clone.ClassName, Format('Container and clone are not of the same class (%s %s)', [Container.ClassName, Clone.ClassName]));
      // delete an item from Container after cloning to make sure it's not a shallow copy
    Container.remove([1]);
      // Clone must be a new instance
    Assert.IsFalse(@Container = @Clone, 'Both Container and Clone refer to the same instance');
      // Clone needs to contain numbers 1..10
    if(Container is DAssociative) then
      TestUnorderedContainer(Clone, 'clone')
    Else
      TestOrderedContainer(Clone, 'clone');
    Clone.Free;
  end;

var LContainerClasses: DArray;
var iter: DIterator;
var ContainerClass: DContainerClass;
var Container: DContainer;
begin
  LContainerClasses := DArray.Create;
  LContainerClasses.add([DArray, DList, DMap, DMultiMap, DHashMap, DMultiHashMap]);
  iter := LContainerClasses.start;
  while(iterateOver(iter)) do
  begin
    ContainerClass := DContainerClass(getClass(iter));
    Container := ContainerClass.Create;
    Test(Container);
    Container.Free;
  end;
  LContainerClasses.Free;
end;

procedure TTestClone.Test_ClonedContainersHaveUniqueStrings;
var RandomString: String;
var RandomString2: String;
var arr: DArray;
var arrClone: DArray;
var iter: DIterator;
var map: DMap;
var mapClone: DMap;
begin
  RandomString := THash.GetRandomString(10);
  RandomString2 := THash.GetRandomString(10);

  arr := DArray.Create;
  arr.add([RandomString]);

  arrClone := arr.clone as DArray;

  iter := arr.start;
  Assert.AreEqual(RandomString, getString(iter));

    // free arr and check if we still have access to this random string
  arr.Free;
  iter := arrClone.start;
  Assert.AreEqual(RandomString, getString(iter));

  arrClone.Free;

    // try the same with a map

  map := DMap.Create;
  map.putPair([1, RandomString]);
  mapClone := map.clone as DMap;
  iter := map.start;
  Assert.AreEqual(RandomString, getString(iter));
  map.Free;
  iter := mapClone.start;
  Assert.AreEqual(RandomString, getString(iter));
  mapClone.Free;
end;

end.
