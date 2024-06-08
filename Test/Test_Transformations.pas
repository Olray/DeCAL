unit Test_Transformations;

interface

uses
  System.SysUtils,  // IntToStr
  DeCAL,
  DeCAL.MockClasses,
  DUnitX.TestFramework;

type
  [TestFixture]
  TDecalTransformTests = class
  private
    function UnaryTestFunction(const obj : DObject) : DObject;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure TestTransformUnary;
  end;

implementation

procedure TDecalTransformTests.Setup;
begin
end;

procedure TDecalTransformTests.TearDown;
begin
end;

//  DUnary = function(const obj : DObject) : DObject of object;
function TDecalTransformTests.UnaryTestFunction(const obj : DObject) : DObject;
begin
  Result := make([IntToStr(obj.VInteger)]);
end;

procedure TDecalTransformTests.TestTransformUnary;
var arr1, arr2 : DArray;
var iter : DIterator;
var i : Integer;
begin
   arr1 := DArray.Create;
   for i := 1 to 100 do
     arr1.add([i]);

   arr2 := DArray.Create;

   transformUnary(arr1, arr2, UnaryTestFunction);

   // arr2 should now contain the numbers of 1 to 100 as strings
   iter := arr2.start;
   for i := 1 to 100 do
   begin
     Assert.AreEqual(IntToStr(i), getString(iter));
     Advance(iter);
   end;
   Assert.IsTrue(atEnd(iter));

   FreeAll([arr1, arr2]);
end;


end.

