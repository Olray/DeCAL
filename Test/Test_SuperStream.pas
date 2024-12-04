unit Test_SuperStream;

interface

uses
  DeCAL,
  DUnitX.TestFramework;

type
  [TestFixture]
  TSuperStreamTest = class
  private
    procedure FillContainerWithTestData(Container: DContainer);
    procedure VerifyContainerWithTestData(Iter : DIterator);
  public
    [TearDown]
    procedure TearDown;

    [Test]
    procedure TestCanWriteAndReadLongUnicodeStringsMap;

    [Test]
    procedure TestCanWriteAndReadLongUnicodeStringsArray;
  end;

implementation
uses
  System.SysUtils, // FileExists
  SuperStream;

procedure TSuperStreamTest.FillContainerWithTestData(Container: DContainer);
var MyString: string;
    i: Integer;
begin
  for i := 1 to 1000 do
  begin
    MyString := Format('Test öäüÖÄÜß Nummer %d!', [i]);

    // cannot use Container.usesPairs because DMap obviously uses pairs but
    // returns false. Changing this behavior however crashes most Map related
    // tests.
    if Container is DMap then
      (Container as DMap).putPair([i, MyString])
    else if Container is DArray then
      (Container as DArray).add([MyString])
    else
      raise Exception.Create('TSuperStreamTest.FillContainerWithTestData can only fill DMap and DArray');
  end;
end;

procedure TSuperStreamTest.VerifyContainerWithTestData(Iter : DIterator);
var MyString: string;
    i: Integer;
begin
  for i := 1 to 1000 do
  begin
    MyString := Format('Test öäüÖÄÜß Nummer %d!', [i]);
    Assert.AreEqual(MyString, getString(Iter));
    advance(Iter);
  end;
end;

procedure TSuperStreamTest.TearDown;
begin
  if FileExists('tempMap.ss') then
    DeleteFile('tempMap.ss');
  if FileExists('tempArray.ss') then
    DeleteFile('tempArray.ss');
end;

procedure TSuperStreamTest.TestCanWriteAndReadLongUnicodeStringsArray;
var Arr      : DArray;
    Iter     : DIterator;
begin
  try
    Arr := DArray.Create;
    FillContainerWithTestData(Arr);

    TObjStream.WriteObjectToFile('tempArray.ss', [], Arr);
    FreeAndNil(Arr);

    Arr := TObjStream.ReadObjectInFile('tempArray.ss', []) as DArray;
    Iter := Arr.start;
    SetToValue(Iter);
    VerifyContainerWithTestData(Iter);
  finally
    FreeAndNil(Arr);
  end;
end;

procedure TSuperStreamTest.TestCanWriteAndReadLongUnicodeStringsMap;
var Map      : DMap;
    Iter     : DIterator;
begin
  try

    Map := DMap.Create;
    FillContainerWithTestData(Map);

    TObjStream.WriteObjectToFile('tempMap.ss', [], Map);
    FreeAndNil(Map);

    Map := TObjStream.ReadObjectInFile('tempMap.ss', []) as DMap;
    Iter := Map.start;
    VerifyContainerWithTestData(Iter);

  finally
    FreeAndNil(Map);
  end;
end;


initialization
  TDUnitX.RegisterTestFixture(TSuperStreamTest);

end.
