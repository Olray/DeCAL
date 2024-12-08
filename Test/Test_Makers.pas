unit Test_Makers;

interface

uses
  DUnitX.TestFramework,
  DeCAL;

type
  [TestFixture]
  TTestMakers = class
    FStart: Integer;
    function GenerateInteger: DObject;
    function ObjIntegerGenerator: DObject;
    procedure FillTestArray(const Arr: DArray);
  public
    [Test]
    procedure Test_Generators;

    [Test]
    procedure Test_GeneratorsScope;

    [Test]
    procedure Test_Comparators;
  end;

implementation
uses
  System.SysUtils;

type
  TTestClass = class
    FName: string;
    FScore: Integer;
    constructor Create(Name: string; Score: Integer);
  end;

{ TTestMakers }

function GenerateIntegerProc(Ptr : Pointer): DObject;
begin
  InitDObject(Result);
  Result.VInteger := Random(1000);
  Result.VType := vtInteger;
end;

function TTestMakers.GenerateInteger: DObject;
begin
  InitDObject(Result);
  Result.VInteger := Random(1000);
  Result.VType := vtInteger;
end;

procedure TTestMakers.Test_Generators;
var Arr: DArray;
begin
  Arr := DArray.Create;
  generate(Arr, 100,
    function: DObject
    begin
      InitDObject(Result);
      Result.VInteger := Random(1000);
      Result.VType := vtInteger;
    end);
    // Arr should now contain 100 integers
  Assert.AreEqual(100, Arr.size);

  Arr.clear;
  generate(Arr, 100, GenerateInteger);
    // Arr should now contain 100 integers
  Assert.AreEqual(100, Arr.size);

  Arr.clear;
  generate(Arr, 100, MakeGenerator(GenerateIntegerProc));
    // Arr should now contain 100 integers
  Assert.AreEqual(100, Arr.size);

  Arr.Free;
end;

procedure TTestMakers.FillTestArray(const Arr: DArray);
begin
  Arr.add(
    [TTestClass.Create('Mia', 60),
     TTestClass.Create('Sophia', 20),
     TTestClass.Create('Luna', 100),
     TTestClass.Create('Olivia', 80),
     TTestClass.Create('Charlotte', 40)
    ]);
end;

function TTestMakers.ObjIntegerGenerator: DObject;
begin
  InitDObject(Result);
  Result.VInteger := FStart;
  Inc(FStart);
  Result.VType := vtInteger;
end;

procedure TTestMakers.Test_GeneratorsScope;
var Arr: DArray;
    Start: Integer;
begin
  Arr := DArray.Create;
    // test if anonymous method has access to variables
  Start := 1;
  generate(Arr, 100,
    function: DObject
    begin
      InitDObject(Result);
      Result.VInteger := Start;
      Inc(Start);
      Result.VType := vtInteger;
    end);

  Assert.AreEqual(101, Start, 'local variable hasn''t been touched');

  Arr.clear;
    // test if procedure of object has access to object vars
  FStart := 1;
  generate(Arr, 100, ObjIntegerGenerator);
  Assert.AreEqual(101, FStart, 'class variable hasn''t been touched');

  Arr.Free;
end;

procedure TTestMakers.Test_Comparators;
var Arr: DArray;
    Iter: DIterator;
    BufS: string;
    BufI: Integer;
begin
  Arr := DArray.CreateWith(
    function(const Obj1, Obj2: DObject): Integer
    var Object1, Object2: TTestClass;
    begin
      Object1 := Obj1.VObject as TTestClass;
      Object2 := Obj2.VObject as TTestClass;
      Result := CompareStr(Object1.FName, Object2.FName);
    end
  );
  FillTestArray(Arr);
   // sorting by name
  sort(Arr);

    // expecting ascending names
  Iter := Arr.start;
  BufS := (getObject(Iter) as TTestClass).FName;
  Assert.AreEqual('Charlotte', BufS);
  advance(Iter);
  while not atEnd(Iter) do
  begin
    var TempS := (getObject(Iter) as TTestClass).FName;
    Assert.IsTrue(TempS > BufS);
    BufS := TempS;
    advance(Iter);
  end;

  objFree(Arr);
  Arr.Free;

  Arr := DArray.CreateWith(
    function(const Obj1, Obj2: DObject): Integer
    var Object1, Object2: TTestClass;
    begin
      Object1 := Obj1.VObject as TTestClass;
      Object2 := Obj2.VObject as TTestClass;
      Result := Object1.FScore - Object2.FScore;
    end
  );
  FillTestArray(Arr);
    // sorting by score
  sort(Arr);

    // expecting ascending scores
  Iter := Arr.start;
  BufI := (getObject(Iter) as TTestClass).FScore;
  Assert.AreEqual(20, BufI);
  advance(Iter);
  while not atEnd(Iter) do
  begin
    var TempI := (getObject(Iter) as TTestClass).FScore;
    Assert.IsTrue(TempI > BufI);
    BufI := TempI;
    advance(Iter);
  end;

  objFree(Arr);
  Arr.Free;
end;

{ TTestClass }

constructor TTestClass.Create(Name: string; Score: Integer);
begin
  FName := Name;
  FScore := Score;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestMakers);

end.
