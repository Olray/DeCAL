unit Test_RandomTesting;

interface

uses
  System.SysUtils,
  TestFramework,
  DUnitX.TestFramework,
  DeCAL;

const Executions = 100;
const Cycles = 10;

type
  TOperation = (opAdd, opRemove, opClear, opFind);

  [TestFixture]
  TTestRandomTesting = class(TTestCase)
  private
    FContainerClasses : DArray;
    FSequenceClasses : DArray;
    FSetClasses : DArray;
    FMapClasses : DArray;
    function verifyTreeNodeRuleNOTRR(node: DTreeNode): boolean;
    function getLeafNodeBlackCount(tree: DRedBlackTree; treeNode: DTreeNode): Integer;
    function isLeaf(treeNode: DTreeNode): boolean;
  public
    Constructor Create;
    Destructor Destroy; override;
  published

    [Test]
    procedure Test_Special;
    [Test]
    procedure Test_MapTesting;
    [Test]
    procedure Test_ContainerTesting;
  end;

implementation


Constructor TTestRandomTesting.Create;
begin
  FContainerClasses := DArray.Create;
  FSequenceClasses := DArray.Create;
  FSetClasses := DArray.Create;
  FMapClasses := DArray.Create;

  FContainerClasses.add([DArray, DList, DMultiSet, DMultiHashSet]);
  FSequenceClasses.add([DArray, DList]);
  FSetClasses.add([DSet, DMultiSet, DHashSet, DMultiHashSet]);
  FMapClasses.add([DMap, DHashMap]);
end;

Destructor TTestRandomTesting.Destroy;
begin
  FreeAll([FContainerClasses, FSequenceClasses, FSetClasses, FMapClasses]);
end;

function TTestRandomTesting.verifyTreeNodeRuleNOTRR(node: DTreeNode) : boolean;
begin
  Result := true;
  if(node.color = tnfRed) then
  begin
    if(node.left <> nil_node) and (node.left.color = tnfRed) then
      Exit(false);
    if(node.right <> nil_node) and (node.right.color = tnfRed) then
      Exit(false);
  end;
end;

function TTestRandomTesting.isLeaf(treeNode: DTreeNode): boolean;
begin
  Result := (treeNode.left = nil_node) or (treeNode.right = nil_node);
end;

function TTestRandomTesting.getLeafNodeBlackCount(tree: DRedBlackTree; treeNode: DTreeNode): Integer;
var node : DTreeNode;
var header : DTreeNode;
begin
  Result := 0;
  header := tree.getHeader;
  node := treeNode;
  repeat
    if(node.color = tnfBlack) then Inc(Result);
    node := node.parent;
  until(node = header);
end;

procedure TTestRandomTesting.Test_ContainerTesting;
var exec, cycle : Integer;
    cls : DContainerClass;
    con1, con2 : DContainer;
    value, test, count : Integer;
    iter1, iter2 : DIterator;
    v1,v2, diff : DArray;
    scenarioNumber : Integer;
begin

  v1 := DArray.Create;
  v2 := DArray.Create;
  diff := Darray.Create;

  for exec := 1 to Executions do
    begin
        // Randomly choose two container classes
      RandomShuffle(FContainerClasses);

      cls := DContainerClass(FContainerClasses.atAsClass(0));
      con1 := cls.Create;
      cls := DContainerClass(FContainerClasses.atAsClass(1));
      con2 := cls.Create;

      for cycle := 1 to cycles do
        begin
          scenarioNumber := exec * cycles + cycle;

          case Random(4) of
            0:
              begin
                count := Random(100);
                for test := 1 to count do
                begin
                  value := Random(1000);
                  con1.add([value]);
                  con2.add([value]);
                  Assert.AreEqual(con1.size, con2.size, Format('Error: %d case %d', [scenarioNumber, 0]));
                end;
              end;
            1:
              begin
                count := Random(100);
                for test := 1 to count do
                begin
                  value := Random(1000);
                  con1.remove([value]);
                  con2.remove([value]);

                  Assert.AreEqual(con1.size, con2.size, Format('Error: %d case %d', [scenarioNumber, 1]));

                end;
              end;
            2:
              begin
                con1.clear;
                con2.clear;
              end;
            3:
              begin
                count := Random(100);
                for test := 1 to count do
                  begin
                    value := Random(1000);
                    iter1 := find(con1, [value]);
                    iter2 := find(con2, [value]);

                    if not atEnd(iter1) then
                    begin
                      var csize := con1.size;
                      if (getInteger(iter1) <> value) then
                      begin
                        var iter := find(con1, [value]);
                        var newValue := getInteger(iter);
                      end;
                      Assert.AreEqual(value, getInteger(iter1), Format('Error: %d case %d-1 find returned %d instead of %d in class (%s)', [scenarioNumber, 3, getInteger(iter1), value, con1.ClassName]));
                    end;

                    if not atEnd(iter2) then
                    begin
                      var csize := con2.size;
                      if (getInteger(iter2) <> value) then
                      begin
                        var iter := find(con2, [value]);
                        var newValue := getInteger(iter);
                      end;
                      Assert.AreEqual(value, getInteger(iter2), Format('Error: %d case %d-1 find returned %d instead of %d in class (%s)', [scenarioNumber, 3, getInteger(iter2), value, con2.ClassName]));
                    end;
//                    Assert.AreEqual(atEnd(iter1), atEnd(iter2), Format('Error: %d case %d-1 (%s %s)', [scenarioNumber, 3, con1.ClassName, con2.ClassName]));
//                    if not atEnd(iter1) then
//                      Assert.AreEqual(getInteger(iter1), getInteger(iter2), Format('Error: %d case %d-2', [scenarioNumber, 3]));
                  end;
              end;

          end;

            // Verify that they're the same.
          Assert.AreEqual(con1.size, con2.size, Format('Container sizes are different: %d', [scenarioNumber]));

            // Verify they contain the same stuff.
          v1.Clear;
          v2.Clear;
          diff.Clear;

          CopyContainer(con1, v1);
          Assert.AreEqual(con1.size, v1.size, Format('Error: %d CopyContainer con1->v1', [scenarioNumber]));

          CopyContainer(con2, v2);
          Assert.AreEqual(con2.size, v2.size, Format('Error: %d CopyContainer con2->v2', [scenarioNumber]));

          sort(v1);
          sort(v2);
          Assert.AreEqual(v1.size, v2.size, Format('Error: %d Lost items while sorting', [scenarioNumber]));

          setSymmetricDifference(v1, v2, diff.finish);
          Assert.IsFalse(diff.size > 0, Format('Difference found: %d differences %d (%s %s)', [diff.size, scenarioNumber, con1.ClassName, con2.ClassName]));

        end;

      FreeAll([con1, con2]);
    end;

  FreeAll([v1, v2, diff]);

end;

procedure TTestRandomTesting.Test_MapTesting;
var exec, cycle : Integer;
    cls : DAssociativeClass;
    con1, con2 : DAssociative;
    value, test, count : Integer;
    iter1, iter2 : DIterator;
    v1,v2, diff : DArray;
    scenarioNumber : Integer;
begin

  v1 := DArray.Create;
  v2 := DArray.Create;
  diff := Darray.Create;

  for exec := 1 to Executions do
    begin

      // Randomly choose two container classes
      RandomShuffle(FMapClasses);

      cls := DAssociativeClass(FMapClasses.atAsClass(0));
      con1 := cls.Create;
      cls := DAssociativeClass(FMapClasses.atAsClass(1));
      con2 := cls.Create;

      for cycle := 1 to cycles do
      begin

        scenarioNumber := exec * cycles + cycle;

        case Random(4) of
          0:
            begin
              count := Random(100);
              for test := 1 to count do
                begin
                  value := Random(1000);

                  con1.putPair([value, value]);
                  con2.putPair([value, value]);

                  Assert.AreEqual(con1.size, con2.size, Format('Error: %d %d', [scenarioNumber, test]));
                end;
            end;
          1:
            begin
              count := Random(100);
              for test := 1 to count do
                begin
                  // happens on iteration 30?
                  value := Random(1000);

                  con1.remove([value]);
                  con2.remove([value]);

                  Assert.AreEqual(con1.size, con2.size, Format('Error: %d case %d', [scenarioNumber, 1]));

                end;
            end;
          2:
            begin
              con1.clear;
              con2.clear;
            end;
          3:
            begin
              count := Random(100);
              for test := 1 to count do
                begin
                  value := Random(1000);
                  iter1 := find(con1, [value]);
                  iter2 := find(con2, [value]);
                  Assert.AreEqual(atEnd(iter1), atEnd(iter2), Format('Error: %d case %d', [scenarioNumber, 3]));
                end;
            end;

        end;

        // Verify that they're the same.
        Assert.AreEqual(con1.size, con2.size, Format('Container sizes are different: %d', [scenarioNumber]));

        // Verify they contain the same stuff.
        v1.Clear;
        v2.Clear;
        diff.Clear;

        CopyContainer(con1, v1);
        Assert.AreEqual(con1.size, v1.size, Format('Error: %d CopyContainer con1->v1', [scenarioNumber]));

        CopyContainer(con2, v2);
        Assert.AreEqual(con2.size, v2.size, Format('Error: %d CopyContainer con2->v2', [scenarioNumber]));

        sort(v1);
        sort(v2);
        Assert.AreEqual(v1.size, v2.size, Format('Error: %d Lost items while sorting', [scenarioNumber]));

        setSymmetricDifference(v1, v2, diff.finish);
        Assert.IsFalse(diff.size > 0, Format('Difference found: %d differences %d', [diff.size, scenarioNumber]));
      end;

      FreeAll([con1, con2]);
    end;

  FreeAll([v1, v2, diff]);

end;

{
  About this test:
  A red-black tree is a self-aligning b-tree that guarantees a time of
  O(log n) for search, insert, and delete operations.
  See: https://en.wikipedia.org/wiki/Red%E2%80%93black_tree
  The original "test" simply generated a couple of temporary files that
  contained the red/black value of every node in the tree. The purpose of this
  test was to verify correctness of the red-black tree implementation.
  However, there were no verification rules present in the original testing
  unit so Ross Judson must have had some external tool to verify correctness of
  this test result which I'm not going to reproduce.
  There are two additional rules for red-black trees:
    !RR : a red node may not have another red child
    S#= : every leaf has the same amount of black nodes in it's root path
  I'm testing these instead. To do so I have to expose the variable nil_node
  and the member FHeader of DBlackRedTree when running the test.
}
procedure TTestRandomTesting.Test_Special;

  procedure AssertAllSame(arr: DArray);
  var iter: DIterator;
  var treeHeight: Integer;
  begin
    iter := arr.start;
    treeHeight := getInteger(iter);
    while(iterateOver(iter)) do
      Assert.AreEqual(treeHeight, getInteger(iter));
  end;

var map : DMap;
    i : Integer;
    iter : DIterator;
var treeHeights : DArray;
begin
  var puts := [
    866, 208, 669, 847, 14 , 917, 558, 494, 617, 660, 372, 297, 508, 542,
    44 , 739, 904, 368, 20 , 869, 942, 55 , 741, 942, 823, 997, 913, 908,
    203, 743, 328, 744, 781, 595, 311, 855, 236, 996, 72 , 27 , 944, 802,
    516, 673, 145, 809, 313, 359, 488, 137, 264, 825, 105, 338, 270, 15 ,
    671, 332, 441, 821, 84 , 526, 156, 549, 714, 742, 102, 324, 382, 788,
    606, 933, 491, 810, 800, 822, 982, 758, 414, 258, 38 , 596, 241, 858,
    709, 101, 589, 0  , 870, 370, 238];

  var removes := [
    722, 845, 113, 262, 980, 334, 723, 18 , 658, 74 , 445, 988, 623, 108,
    714, 243, 490, 521, 855, 617, 182, 493, 249, 201, 861, 80 , 208, 423,
    738, 487, 241];

  map := DMap.Create;

  for i := Low(puts) to High(puts) do
  begin
    map.putPair([puts[i], puts[i]]);

    treeHeights := DArray.Create;
    iter := map.start;
    while iterateOver(iter) do
    begin
      Assert.IsTrue(verifyTreeNodeRuleNOTRR(iter.treeNode));

      if isLeaf(iter.treeNode) then
        treeHeights.add([getLeafNodeBlackCount(iter.tree, iter.treeNode)]);
    end;
      // treeHeight must contain all the same values for rule S#=
    AssertAllSame(treeHeights);
    treeHeights.Free;

  end;

  for i := Low(removes) to High(removes) do
  begin
    map.remove([removes[i]]);

    treeHeights := DArray.Create;
    iter := map.start;
    while iterateOver(iter) do
    begin
      Assert.IsTrue(verifyTreeNodeRuleNOTRR(iter.treeNode));

      if isLeaf(iter.treeNode) then
        treeHeights.add([getLeafNodeBlackCount(iter.tree, iter.treeNode)]);
    end;
      // treeHeight must contain all the same values for rule S#=
    AssertAllSame(treeHeights);
    treeHeights.Free;

  end;

  map.free;

end;

initialization
  TDUnitX.RegisterTestFixture(TTestRandomTesting);

end.
