unit Test_Map;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TDecalMapTest = class
  private
    procedure NilWithoutFree(var Obj : Pointer);
  public

    [Test]
    procedure TestCanStoreAndRetriveSimpleTypes;

    [Test]
    procedure TestCanStoreAndRetriveObjects;

    [Test]
    procedure TestCanStoreAndRetriveInterfaces;
  end;

implementation
uses
  DeCAL,
  DeCAL.MockClasses;

// This function suppresses compiler warning H2077 (value never used)
procedure TDecalMapTest.NilWithoutFree(var Obj: Pointer);
begin
  Obj := nil;
end;

procedure TDecalMapTest.TestCanStoreAndRetriveSimpleTypes;
var Map : DMap;
    MockAnsiString : AnsiString;
    iter : DIterator;
begin
  Map := DMap.Create;
  try
    Map.putPair([1, 100]);
    Map.putPair([2, 'A Wide String']);
    Map.putPair([3, 3.1415]);
    MockAnsiString := 'An Ansi String';
    Map.putPair([4, MockAnsiString]);

    // check if added vars are in order
    iter := Map.start;
    SetToKey(iter);
    for var i := 1 to 4 do
    begin
      Assert.IsTrue(i = getInteger(iter));
      advance(iter);
    end;

    iter := Map.start;
    SetToValue(iter);
    Assert.AreEqual(100, getInteger(iter), 'getInteger() error');
    advance(iter);
    Assert.AreEqual('A Wide String', getString(iter), 'getString() error');
    advance(iter);
    Assert.AreEqual(3.1415, getExtended(iter), 'getExtended() error');
    advance(iter);
    Assert.AreEqual(MockAnsiString, getAnsiString(iter), 'getAnsiString() error');
  finally
    Map.Free;
  end;

end;

procedure TDecalMapTest.TestCanStoreAndRetriveObjects;
var Map : DMap;
    iter : DIterator;
    MockObject : TDecalMockClassSimple;
begin
  Map := nil;
  try
    Map := DMap.Create;
    MockObject := TDecalMockClassSimple.Create(4711);
    Map.putPair([1000, MockObject]);

    // suppressing warning H2077 (value never used) is intended
    NilWithoutFree(Pointer(MockObject));

    iter := Map.start;
    SetToValue(iter);
    MockObject := getObject(iter) as TDecalMockClassSimple;
    Assert.IsNotNull(MockObject);
    Assert.AreEqual('TDecalMockClassSimple', MockObject.ClassName, 'getObject() returning wrong class');
    Assert.AreEqual(MockObject.GetIdentifier, 4711);

  finally
    if Assigned(Map) then
    begin
      objFree(Map);
      Map.Free;
    end;
  end;

end;


procedure TDecalMapTest.TestCanStoreAndRetriveInterfaces;
var Map : DMap;
    iter : DIterator;
    InterfaceTest : IDeCALTestInterface;
begin
  Map := DMap.Create;
  try
    InterfaceTest := TDecalInterfacedClass.Create;
    Map.putPair([2000, InterfaceTest]);

    iter := Map.start;
    SetToValue(iter);

    InterfaceTest := IDeCALTestInterface(DeCAL.getInterface(iter));
    Assert.AreEqual(4711, InterfaceTest.GetIdentifier, 'getInterface() error');

  finally
    Map.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TDecalMapTest);

end.
