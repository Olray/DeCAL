unit Test_SuperStream;

interface

uses
  WinAPI.Windows,  // DeleteFile
  System.SysUtils, // FileExists
  DeCAL,
  DeCALIO,
  SuperStream,
  DUnitX.TestFramework;

type
  [TestFixture]
  TSuperStreamTest = class
  private
    procedure FillContainerWithTestData(container: DContainer);
    procedure VerifyContainerWithTestData(iter : DIterator);
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure TestCanWriteAndReadLongUnicodeStringsMap;
    [Test]
    procedure TestCanWriteAndReadLongUnicodeStringsArray;
  end;

implementation

procedure TSuperStreamTest.FillContainerWithTestData(container: DContainer);
var MyString : String;
var i : Integer;
begin
  for i := 1 to 1000 do
  begin
    MyString := Format('Test öäüÖÄÜß Nummer %d!', [i]);

    // cannot use container.usesPairs because DMap obviously uses pairs but
    // returns false. Changing this behavior however crashes most Map related
    // tests.
    if container is DMap then
      (container as DMap).putPair([i, MyString])
    else if container is DArray then
      (container as DArray).add([MyString])
    else
      raise Exception.Create('TSuperStreamTest.FillContainerWithTestData can only fill DMap and DArray');
  end;
end;

procedure TSuperStreamTest.VerifyContainerWithTestData(iter : DIterator);
var MyString : String;
var i : Integer;
begin
  for i := 1 to 1000 do
  begin
    MyString := Format('Test öäüÖÄÜß Nummer %d!', [i]);
    Assert.AreEqual(MyString, getString(iter));
    Advance(iter);
  end;
end;

procedure TSuperStreamTest.Setup;
begin
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
var iter     : DIterator;
begin
  try

    Arr := DArray.Create;
    FillContainerWithTestData(Arr);

    TObjStream.WriteObjectToFile('tempArray.ss', [], Arr);
    FreeAndNil(Arr);

    Arr := TObjStream.ReadObjectInFile('tempArray.ss', []) as DArray;
    iter := Arr.start;
    SetToValue(iter);
    VerifyContainerWithTestData(iter);

  finally
    FreeAndNil(Arr);
  end;
end;

procedure TSuperStreamTest.TestCanWriteAndReadLongUnicodeStringsMap;
var Map      : DMap;
var iter     : DIterator;
begin
  try

    Map := DMap.Create;
    FillContainerWithTestData(Map);

    TObjStream.WriteObjectToFile('tempMap.ss', [], Map);
    FreeAndNil(Map);

    Map := TObjStream.ReadObjectInFile('tempMap.ss', []) as DMap;
    iter := Map.start;
    VerifyContainerWithTestData(iter);

  finally
    FreeAndNil(Map);
  end;
end;


initialization
  TDUnitX.RegisterTestFixture(TSuperStreamTest);

end.
