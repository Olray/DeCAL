unit Test_Transformations;

interface

uses
  DeCAL,
  DUnitX.TestFramework;

type
  [TestFixture]
  TDecalTransformTests = class
  private
    function UnaryTestFunction(const Obj : DObject) : DObject;
  public

    [Test]
    procedure TestTransformUnary;
  end;

implementation
uses
  System.SysUtils;  // IntToStr

function TDecalTransformTests.UnaryTestFunction(const Obj : DObject) : DObject; // DUnary
begin
  Result := make([IntToStr(Obj.VInteger)]);
end;

procedure TDecalTransformTests.TestTransformUnary;
var Array1, Array2 : DArray;
    Iter : DIterator;
    i : Integer;
begin
   Array1 := DArray.Create;
   for i := 1 to 100 do
     Array1.add([i]);

   Array2 := DArray.Create;

   transformUnary(Array1, Array2, UnaryTestFunction);

   // Array2 should now contain the numbers of 1 to 100 as strings
   Iter := Array2.start;
   for i := 1 to 100 do
   begin
     Assert.AreEqual(IntToStr(i), getString(Iter));
     advance(Iter);
   end;
   Assert.IsTrue(atEnd(Iter));

   FreeAll([Array1, Array2]);
end;

initialization
  TDUnitX.RegisterTestFixture(TDecalTransformTests);

end.

