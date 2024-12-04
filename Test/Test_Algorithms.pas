unit Test_Algorithms;

interface

uses
  TestFramework,
  DUnitX.TestFramework,
  DeCAL;

type
  [TestFixture]
  TTestAlgorithms = class(TTestCase)
  private
    FSum: Integer;
    function IsEvenInteger(const Obj : DObject) : Boolean;
    procedure AddValueToMemberVar(const Obj: DObject); // DApply
    function CalcSum(const Obj, Obj2 : DObject): DObject; // DBinary
  published
    // 2024-10-27 Reported by Doug Winsby
    [Test]
    procedure TestRemoveCopyIfIn;

    [Test]
    procedure TestApply;
  end;

implementation
uses
  System.SysUtils; // Format

{
  From the documentation:
    The removeCopy algorithm copies a sequence of items from one location to
    another, removing any matching items as it goes.
    The size of the container doesn’t change; the remove family of functions
    return an iterator positioned at the end of the new sequence. (p. 48)

  A bug was reported by Doug Winsby on 27th Oct 2024 claiming that the
  behavior of removeCopyIfIn routine was reversed: Instead of removing
  objects for which the DTest function returned true, it was including
  them, effectively reversing the intended behavior.

  The test below is passed after adding a "not" to the line
   --   if test(o^) then
}

  // Type DTest
function TTestAlgorithms.IsEvenInteger(const Obj : DObject) : Boolean;
begin
  Result := (Obj.VInteger mod 2 = 0);
end;

procedure TTestAlgorithms.TestRemoveCopyIfIn;
var Container1, Container2 : DArray;
    iter : DIterator;
begin
  Container1 := DArray.Create;
  try
      // add numbers 1-100 to container
    for var i := 1 to 100 do
      Container1.add([i]);

    Container2 := DArray.Create;
    try
        // copy container to Container2 except even numbers
      iter := removeCopyIfIn(Container1.start, Container1.finish, Container2.finish, IsEvenInteger);

        // expected results:

        // removeCopyIfIn returns iterator at end of new sequence
      Assert.AreEqual(True, atEnd(iter));
        // last odd number in new sequence must be 99
      advanceBy(iter, -1);
      Assert.AreEqual(99, getInteger(iter));
        // still 100 items in source container
      Assert.AreEqual(100, Container1.size);
        // half of the amount in target container
      Assert.AreEqual(50, Container2.size);

        // check if all objects in new container are odd numbers
      iter := Container2.start;
      while IterateOver(iter) do
        Assert.IsFalse(getInteger(iter) mod 2 = 0);

    finally
      Container2.Free;
    end;

  finally
  Container1.Free;
  end;
end;


procedure TTestAlgorithms.TestApply;
const TestCount = 200;
var i: Integer;
    Arr: DArray;
    Sum: DObject;
    Expected: Integer;
begin
  Arr := DArray.Create;
  try
    for i := 1 to TestCount do
      Arr.add([i]);
    Expected := (TestCount*(TestCount+1)) div 2;

    Sum := inject(Arr, [0], CalcSum);
    Assert.AreEqual(Expected, Sum.VInteger,
        Format('Wrong sum calculated with inject. Expected: %d, received: %d', [Expected, Sum.VInteger]));
      // modify start value and try again
    Sum := inject(Arr, [1], CalcSum);
    Assert.AreEqual(Expected+1, Sum.VInteger,
        Format('Wrong sum calculated with inject. Expected: %d, received: %d', [Expected+1, Sum.VInteger]));

    FSum := 0;
    forEach(Arr, AddValueToMemberVar);
    Assert.AreEqual(Expected, FSum,
        Format('Wrong sum calculated with forEach. Expected: %d, received: %d', [Expected, FSum]));

  finally
    FreeAndNil(Arr);
  end;
end;

procedure TTestAlgorithms.AddValueToMemberVar(const Obj: DObject);
begin
  FSum := FSum + Obj.VInteger;
end;

function TTestAlgorithms.CalcSum(const Obj, Obj2 : DObject): DObject;
begin
  Result.VInteger := Obj.VInteger + Obj2.VInteger;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestAlgorithms);

end.
