program Example;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  DeCAL,
  System.SysUtils;

procedure PrintContainer(arr: DContainer; Title: string);
begin
  WriteLn(Title + Format(' (%d items)', [arr.size]));
  var Iter := arr.start;
  while IterateOver(Iter) do
    WriteLn(getString(Iter));
end;

function StudentName(i : Integer): string;
const Familynames: array[0..5] of string = ('Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Doe');
const Surenames : array[0..5] of string = ('Mia', 'Sophia', 'Luna', 'Lily', 'Mary', 'Charlotte');
begin
  Result := Surenames[i mod 5] + ' ' + Familynames[i div 5];
end;

{ In contrast to the example from Page 11 of the documentation the following was
  changed to make the example more "enjoyable":

  DMap replaced with DMultiMap - allows to have more than one student with the
    same test score.
  RandomName generator changed to StudentName which returns unique names in
    a fixed order to prevent duplicate names which might be confusing.
  Added a base score of 50 points (it's an elite school!) to get a higher
    possibility for matches.
  The intersection algorithms rely on both containers being sorted. However,
    a DArray is unsorted. For the example to work, you have to copy the good
    students to a DMap which is sorted automagically (by internal use of the
    RB-tree.)

  I'm sorry that this example is not as catchy as the one in the docs.
}
procedure Test;
var class1,
    class2 : DMultiMap;
    GoodStudentsClass1,
    GoodStudentsClass2,
    GoodStudentsOverall : DSet;
    i : Integer;
    Iter : DIterator;
begin
    // fill our classes with random students and grades
  class1 := DMultiMap.Create;
  class2 := DMultiMap.Create;
  for i := 1 to 25 do
  begin
    class1.putPair([Random(50)+50, StudentName(i)]);
    class2.putPair([Random(50)+50, StudentName(i)]);
  end;

  Iter := class1.lower_bound([80]);
  GoodStudentsClass1 := DSet.Create;
  copyInTo(Iter, class1.finish, GoodStudentsClass1.finish);

  Iter := class2.lower_bound([80]);
  GoodStudentsClass2 := DSet.Create;
  copyInTo(Iter, class2.finish, GoodStudentsClass2.finish);

  GoodStudentsOverall := DSet.Create;
  setIntersection(GoodStudentsClass1, GoodStudentsClass2, GoodStudentsOverall.finish);
  reverse(GoodStudentsOverall);
  PrintContainer(GoodStudentsOverall, 'Overall good students');

  FreeAll([class1, class2, GoodStudentsClass1, GoodStudentsClass2, GoodStudentsOverall]);
End;

begin
  try
    Randomize;
    Test;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
