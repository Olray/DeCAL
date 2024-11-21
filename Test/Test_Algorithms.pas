unit Test_Algorithms;

interface

uses
  System.SysUtils, // Format
  TestFramework,
  DUnitX.TestFramework,
  DeCAL;

type
  [TestFixture]
  TTestAlgorithms = class(TTestCase)
  private
    FSum: Integer;
    function IsEvenInteger(const obj : DObject) : Boolean;
    procedure AddValueToMemberVar(const obj: DObject); // DApply
    function CalcSum(const obj1, obj2 : DObject): DObject; // DBinary
  published
    // 2024-10-27 Reported by Doug Winsby
    [Test]
    procedure TestRemoveCopyIfIn;

    [Test]
    procedure TestApply;
  end;

implementation

{
  From the documentation:
    The removeCopy algorithm copies a sequence of items from one location to
    another, removing any matching items as it goes.
    The size of the container doesn�t change; the remove family of functions
    return an iterator positioned at the end of the new sequence. (p. 48)

  A bug was reported by Doug Winsby on 27th Oct 2024 claiming that the
  behavior of removeCopyIfIn routine was reversed: Instead of removing
  objects for which the DTest function returned true, it was including
  them, effectively reversing the intended behavior.

  The test below is passed after adding a "not" to the line
   --   if test(o^) then
}

  // Type DTest
function TTestAlgorithms.IsEvenInteger(const obj : DObject) : Boolean;
begin
  Result := (obj.VInteger MOD 2 = 0);
end;

procedure TTestAlgorithms.TestRemoveCopyIfIn;
var c1, c2 : DArray;
var i : DIterator;
begin
  c1 := DArray.Create;
  try
      // add numbers 1-100 to container
    for var temp := 1 to 100 do
      c1.add([temp]);

    c2 := DArray.Create;
    try
        // copy container to c2 except even numbers
      i := removeCopyIfIn(c1.start, c1.finish, c2.finish, IsEvenInteger);

        // expected results:

        // removeCopyIfIn returns iterator at end of new sequence
      Assert.AreEqual(true, atEnd(i));
        // last odd number in new sequence must be 99
      advanceBy(i, -1);
      Assert.AreEqual(99, getInteger(i));
        // still 100 items in source container
      Assert.AreEqual(100, c1.size);
        // half of the amount in target container
      Assert.AreEqual(50, c2.size);

        // check if all objects in new container are odd numbers
      i := c2.start;
      while(iterateOver(i)) do
      begin
        var n := getInteger(i);
        Assert.IsFalse(n MOD 2 = 0);
      end;

    finally
      c2.Free;
    end;

  finally
  c1.Free;
  end;
end;


procedure TTestAlgorithms.TestApply;
const n = 200;
var i: Integer;
var iter: DIterator;
var arr: DArray;
var sum: DObject;
var expected: Integer;
begin
  arr := DArray.Create;
  try
    for i := 1 to n do
      arr.add([i]);
    expected := (n*(n+1)) div 2;

    sum := inject(arr, [0], CalcSum);
    Assert.AreEqual(expected, sum.VInteger, Format('Wrong sum calculated with inject. Expected: %d, received: %d', [expected, sum.VInteger]));
      // modify start value and try again
    sum := inject(arr, [1], CalcSum);
    Assert.AreEqual(expected+1, sum.VInteger, Format('Wrong sum calculated with inject. Expected: %d, received: %d', [expected+1, sum.VInteger]));

    FSum := 0;
    forEach(arr, AddValueToMemberVar);
    Assert.AreEqual(expected, FSum, Format('Wrong sum calculated with forEach. Expected: %d, received: %d', [expected, FSum]));

  finally
    FreeAndNil(arr);
  end;
end;

procedure TTestAlgorithms.AddValueToMemberVar(const obj: DObject);
begin
  FSum := FSum + obj.VInteger;
end;

function TTestAlgorithms.CalcSum(const obj1, obj2 : DObject): DObject;
begin
  Result.VInteger := obj1.VInteger + obj2.VInteger;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestAlgorithms);

end.
