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
    function IsOddInteger(const Obj : DObject) : Boolean;
    function IsEvenInteger(const Obj: DObject) : Boolean;
  published
    [Test]
    procedure Test_DIterFilter;

    [Test]
    procedure Test_DIterSkipper;
  end;


implementation


{ TTestIterator }

function TTestIterator.IsOddInteger(const Obj : DObject) : Boolean;
begin
  Result := not IsEvenInteger(Obj);
end;

function TTestIterator.IsEvenInteger(const Obj: TVarRec): Boolean;
begin
  Result := (Obj.VInteger mod 2 = 0);
end;

procedure TTestIterator.Test_DIterFilter;
var Container1 : DArray;
    iter : DIterator;
    IterFilter : DIterFilter;
begin
  Container1 := DArray.Create;
  try
      // add numbers 1-100 to container
    for var i := 1 to 100 do
      Container1.add([i]);

    iter := Container1.start;
    IterFilter := DIterFilter.Create(iter, IsOddInteger);
    try
      iter.Handler := IterFilter;

        // should only return odd numbers
      while IterateOver(iter) do
        Assert.AreEqual(1, getInteger(iter) mod 2);

    finally
      IterFilter.Free;
    end;
  finally
    Container1.Free;
  end;
end;

procedure TTestIterator.Test_DIterSkipper;
var Container1 : DArray;
    iter : DIterator;
    IterSkipper : DIterSkipper;
begin
  Container1 := DArray.Create;
  try
      // add numbers 1-100 to container
    for var i := 1 to 100 do
      Container1.add([i]);

    iter := Container1.start;
    IterSkipper := DIterSkipper.Create(iter, 2);
    try
      iter.Handler := IterSkipper;

        // should only return odd numbers
      while IterateOver(iter) do
        Assert.AreEqual(1, getInteger(iter) mod 2);

    finally
      IterSkipper.Free;
    end;
  finally
    Container1.Free;
  end;
end;


initialization
  TDUnitX.RegisterTestFixture(TTestIterator);

end.
