unit Test_Iterator;

interface

uses
  TestFramework,
  DUnitX.TestFramework,
  DeCAL;

type
  [TestFixture]
  TTestIterator = class(TTestCase)
  private
    function IsOddInteger(const obj : DObject) : Boolean;
    function IsEvenInteger(const obj: DObject) : Boolean;
  published
    [Test]
    procedure Test_DIterFilter;

    [Test]
    procedure Test_DIterSkipper;
  end;


implementation


{ TTestIterator }

function TTestIterator.IsOddInteger(const obj : DObject) : Boolean;
begin
  Result := not IsEvenInteger(obj);
end;

function TTestIterator.IsEvenInteger(const obj: TVarRec): Boolean;
begin
  Result := (obj.VInteger MOD 2 = 0);
end;

procedure TTestIterator.Test_DIterFilter;
var c1 : DArray;
var iter : DIterator;
var IterFilter : DIterFilter;
begin
  c1 := DArray.Create;
  try
      // add numbers 1-100 to container
    for var temp := 1 to 100 do
      c1.add([temp]);

    iter := c1.start;
    IterFilter := DIterFilter.Create(iter, IsOddInteger);
    try
      iter.Handler := IterFilter;

        // should only return odd numbers
      while iterateOver(iter) do
      begin
        var test := getInteger(iter);
        Assert.AreEqual(1, test MOD 2);
      end;

    finally
      IterFilter.Free;
    end;
  finally
    c1.Free;
  end;
end;

procedure TTestIterator.Test_DIterSkipper;
var c1 : DArray;
var iter : DIterator;
var IterSkipper : DIterSkipper;
begin
  c1 := DArray.Create;
  try
      // add numbers 1-100 to container
    for var temp := 1 to 100 do
      c1.add([temp]);

    iter := c1.start;
    IterSkipper := DIterSkipper.Create(iter, 2);
    try
      iter.Handler := IterSkipper;

        // should only return odd numbers
      while iterateOver(iter) do
      begin
        var test := getInteger(iter);
        Assert.AreEqual(1, test MOD 2);
      end;
    finally
      IterSkipper.Free;
    end;
  finally
    c1.Free;
  end;
end;


initialization
  TDUnitX.RegisterTestFixture(TTestIterator);

end.
