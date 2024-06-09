unit Test_Map;

interface

uses
  DeCAL,
  DeCAL.MockClasses,
  DUnitX.TestFramework;

type
  [TestFixture]
  TDecalMapTest = class
  private
    procedure NilWithoutFree(VAR obj : Pointer);
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure TestCanStoreAndRetriveSimpleTypes;
    [Test]
    procedure TestCanStoreAndRetriveObjects;
    [Test]
    procedure TestCanStoreAndRetriveInterfaces;
  end;

implementation

procedure TDecalMapTest.Setup;
begin
end;

procedure TDecalMapTest.TearDown;
begin
end;

// This function suppresses compiler warning H2077 (value never used)
procedure TDecalMapTest.NilWithoutFree(var obj: Pointer);
begin
  obj := NIL;
end;

procedure TDecalMapTest.TestCanStoreAndRetriveSimpleTypes;
var map : DMap;
var MockAnsiString : AnsiString;
var iter : DIterator;
begin
  map := NIL;
  try
    map := DMap.Create;
    map.putPair([1, 100]);
    map.putPair([2, 'A Wide String']);
    map.putPair([3, 3.1415]);
    MockAnsiString := 'An Ansi String';
    map.putPair([4, MockAnsiString]);

    // check if added vars are in order
    iter := map.start;
    SetToKey(iter);
    for var i := 1 to 4 do
    begin
      Assert.IsTrue(i = getInteger(iter));
      Advance(iter);
    end;

    iter := map.start;
    SetToValue(iter);
    Assert.AreEqual(100, getInteger(iter), 'getInteger() error');
    Advance(iter);
    Assert.AreEqual('A Wide String', getString(iter), 'getString() error');
    Advance(iter);
    Assert.AreEqual(3.1415, getExtended(iter), 'getExtended() error');
    Advance(iter);
    Assert.AreEqual(MockAnsiString, getAnsiString(iter), 'getAnsiString() error');
  finally
    if Assigned(map) then
      Map.Free;
  end;

end;

procedure TDecalMapTest.TestCanStoreAndRetriveObjects;
var map : DMap;
var iter : DIterator;
var MockObject : TDecalMockClassSimple;
begin
  map := NIL;
  try
    map := DMap.Create;
    MockObject := TDecalMockClassSimple.Create(4711);
    map.putPair([1000, MockObject]);

    // suppressing warning H2077 (value never used) is intended
    NilWithoutFree(Pointer(MockObject));

    iter := map.start;
    SetToValue(iter);
    MockObject := getObject(iter) as TDecalMockClassSimple;
    Assert.IsNotNull(MockObject);
    Assert.AreEqual('TDecalMockClassSimple', MockObject.ClassName, 'getObject() returning wrong class');
    Assert.AreEqual(MockObject.getIdentifier, 4711);

  finally
    if Assigned(map) then
    begin
      ObjFree(map);
      map.Free;
    end;
  end;

end;


procedure TDecalMapTest.TestCanStoreAndRetriveInterfaces;
var map : DMap;
var iter : DIterator;
var interfaceTest : IDeCAlTestInterface;
begin
  map := NIL;
  try
    map := DMap.Create;
    interfaceTest := TDecalInterfacedClass.Create;
    map.putPair([2000, interfaceTest]);

    iter := map.start;
    SetToValue(iter);

    interfaceTest := IDeCALTestInterface(DeCAL.getInterface(iter));
    Assert.AreEqual(4711, interfaceTest.getIdentifier, 'getInterface() error');

  finally
    if Assigned(map) then
      Map.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TDecalMapTest);

end.
