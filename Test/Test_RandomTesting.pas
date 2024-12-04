unit Test_RandomTesting;

interface

uses
  TestFramework,
  DUnitX.TestFramework,
  DeCAL;

const Executions = 100;
      Cycles = 10;

type
  [TestFixture]
  TTestRandomTesting = class(TTestCase)
  private
    FContainerClasses : DArray;
    FSequenceClasses : DArray;
    FSetClasses : DArray;
    FMapClasses : DArray;
      // test red-black tree
    function VerifyTreeNodeRuleNOTRR(Node: DTreeNode): Boolean;
    function GetLeafNodeBlackCount(Tree: DRedBlackTree; TreeNode: DTreeNode): Integer;
    function IsLeaf(TreeNode: DTreeNode): Boolean;
      // test containers
    procedure AddValuesToContainers(Container1, Container2: DContainer);
    procedure AddValuesToContainersAssoc(Container1, Container2: DAssociative);
    procedure RemoveValuesFromContainers(Container1, Container2: DContainer);
    procedure FindInContainers(Container1, Container2: DContainer);
    procedure ClearContainers(Container1, Container2: DContainer);
    procedure CompareContainerContents(Container1, Container2: DContainer);

  public
    constructor Create;
    destructor Destroy; override;
  published

    [Test]
    procedure Test_Special;

    [Test]
    procedure Test_MapTesting;

    [Test]
    procedure Test_ContainerTesting;
  end;

implementation
uses
  System.SysUtils;


constructor TTestRandomTesting.Create;
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

destructor TTestRandomTesting.Destroy;
begin
  FreeAll([FContainerClasses, FSequenceClasses, FSetClasses, FMapClasses]);
  inherited;
end;

function TTestRandomTesting.VerifyTreeNodeRuleNOTRR(Node: DTreeNode) : Boolean;
begin
  Result := True;
  if(Node.color = tnfRed) then
  begin
    if(Node.left <> nil_node) and (Node.left.color = tnfRed) then
      Exit(False);
    if(Node.right <> nil_node) and (Node.right.color = tnfRed) then
      Exit(False);
  end;
end;

function TTestRandomTesting.IsLeaf(TreeNode: DTreeNode): Boolean;
begin
  Result := (TreeNode.left = nil_node) or (TreeNode.right = nil_node);
end;

function TTestRandomTesting.GetLeafNodeBlackCount(Tree: DRedBlackTree; TreeNode: DTreeNode): Integer;
var Node : DTreeNode;
    Header : DTreeNode;
begin
  Result := 0;
  Header := Tree.getHeader;
  Node := TreeNode;
  repeat
    if(Node.color = tnfBlack) then Inc(Result);
    Node := Node.parent;
  until(Node = Header);
end;

const ErrorStr = 'Container sizes not the same (case %d: (%d, %d) items)';

procedure TTestRandomTesting.AddValuesToContainers(Container1, Container2 : DContainer);
var i: Integer;
    Value: Integer;
    Count: Integer;
begin
  Count := Random(100);
  for i := 1 to Count do
  begin
    Value := Random(1000);
    Container1.add([Value]);
    Container2.add([Value]);
    Assert.AreEqual(Container1.size, Container2.size,
        Format(ErrorStr, [0, Container1.size, Container2.size]));
  end;
end;

procedure TTestRandomTesting.AddValuesToContainersAssoc(Container1, Container2 : DAssociative);
var i: Integer;
    Value: Integer;
    Count: Integer;
begin
  Count := Random(100);
  for i := 1 to Count do
  begin
    Value := Random(1000);
    Container1.putPair([Value, Value]);
    Container2.putPair([Value, Value]);
    Assert.AreEqual(Container1.size, Container2.size,
        Format(ErrorStr, [0, Container1.size, Container2.size]));
  end;
end;

procedure TTestRandomTesting.RemoveValuesFromContainers(Container1, Container2 : DContainer);
var i: Integer;
    Value: Integer;
    Count: Integer;
begin
  Count := Random(100);
  for i := 1 to Count do
  begin
    Value := Random(1000);
    Container1.remove([Value]);
    Container2.remove([Value]);
    Assert.AreEqual(Container1.size, Container2.size,
        Format(ErrorStr, [0, Container1.size, Container2.size]));
  end;
end;

procedure TTestRandomTesting.FindInContainers(Container1, Container2 : DContainer);
var i: Integer;
    Value: Integer;
    Count: Integer;
    Iter1, Iter2: DIterator;
begin
  Count := Random(100);
  for i := 1 to Count do
  begin
    Value := Random(1000);
    Iter1 := find(Container1, [Value]);
    Iter2 := find(Container2, [Value]);

    if not atEnd(Iter1) then
      Assert.AreEqual(Value, getInteger(Iter1),
          Format('Error: case %d-1 find returned %d instead of %d in class (%s)',
            [3, getInteger(Iter1), Value, Container1.ClassName]));

    if not atEnd(Iter2) then
      Assert.AreEqual(Value, getInteger(Iter2),
          Format('Error: case %d-1 find returned %d instead of %d in class (%s)',
            [3, getInteger(Iter2), Value, Container2.ClassName]));
  end;
end;

procedure TTestRandomTesting.ClearContainers(Container1: DContainer; Container2: DContainer);
begin
  Container1.clear;
  Container2.clear;
end;

procedure TTestRandomTesting.CompareContainerContents(Container1, Container2: DContainer);
var SortableContainer1,
    SortableContainer2,
    DifferenceContainer : DArray;
begin
  SortableContainer1 := DArray.Create;
  SortableContainer2 := DArray.Create;
  DifferenceContainer := DArray.Create;

      // Verify that they're the same.
  Assert.AreEqual(Container1.size, Container2.size,
      Format('Container sizes are different: %s, %s', [Container1.ClassName, Container2.ClassName]));

    // Verify they contain the same stuff.

  copyContainer(Container1, SortableContainer1);
  Assert.AreEqual(Container1.size, SortableContainer1.size,
      Format('Error: CopyContainer %s(Container1)->SortableContainer1', [Container1.ClassName]));

  copyContainer(Container2, SortableContainer2);
  Assert.AreEqual(Container2.size, SortableContainer2.size,
      Format('Error: CopyContainer %s(Container2)->SortableContainer2', [Container2.ClassName]));

  sort(SortableContainer1);
  sort(SortableContainer2);
  Assert.AreEqual(SortableContainer1.size, SortableContainer2.size,
      'Error: Containers lost items while sorting');

  setSymmetricDifference(SortableContainer1, SortableContainer2, DifferenceContainer.finish);
  Assert.IsFalse(DifferenceContainer.size > 0,
      Format('%d differences found: (%s %s)',
        [DifferenceContainer.size, Container1.ClassName, Container2.ClassName]));

  FreeAll([SortableContainer1, SortableContainer2, DifferenceContainer]);
end;


procedure TTestRandomTesting.Test_ContainerTesting;
var Exec, Cycle : Integer;
    Cls : DContainerClass;
    Container1, Container2 : DContainer;
begin
  for Exec := 1 to Executions do
    begin
        // Randomly choose two container classes
      randomShuffle(FContainerClasses);

      Cls := DContainerClass(FContainerClasses.atAsClass(0));
      Container1 := Cls.Create;
      Cls := DContainerClass(FContainerClasses.atAsClass(1));
      Container2 := Cls.Create;

      for Cycle := 1 to Cycles do
      begin
        case Random(4) of
          0: AddValuesToContainers(Container1, Container2);
          1: RemoveValuesFromContainers(Container1, Container2);
          2: ClearContainers(Container1, Container2);
          3: FindInContainers(Container1, Container2);
        end;

        CompareContainerContents(Container1, Container2);

      end;

      FreeAll([Container1, Container2]);
    end;

end;

procedure TTestRandomTesting.Test_MapTesting;
var Exec, Cycle : Integer;
    Cls : DAssociativeClass;
    Container1, Container2 : DAssociative;
begin

  for Exec := 1 to Executions do
  begin

    // Randomly choose two container classes
    randomShuffle(FMapClasses);

    Cls := DAssociativeClass(FMapClasses.atAsClass(0));
    Container1 := Cls.Create;
    Cls := DAssociativeClass(FMapClasses.atAsClass(1));
    Container2 := Cls.Create;

    for Cycle := 1 to Cycles do
    begin
      case Random(4) of
        0: AddValuesToContainersAssoc(Container1, Container2);
        1: RemoveValuesFromContainers(Container1, Container2);
        2: ClearContainers(Container1, Container2);
        3: FindInContainers(Container1, Container2);
      end;
    end;

    CompareContainerContents(Container1, Container2);

    FreeAll([Container1, Container2]);
  end;

end;

{
  About this test:
  A red-black tree is a self-aligning b-tree that guarantees a time of
  O(log n) for search, insert, and delete operations.
  See: https://en.wikipedia.org/wiki/Red%E2%80%93black_tree
  The original "test" simply generated a couple of temporary files that
  contained the red/black value of every Node in the tree. The purpose of this
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

  procedure AssertAllSame(Arr: DArray);
  var Iter: DIterator;
      TreeHeight: Integer;
  begin
    Iter := Arr.start;
    TreeHeight := getInteger(Iter);
    while IterateOver(Iter) do
      Assert.AreEqual(TreeHeight, getInteger(Iter));
  end;

var Map : DMap;
    i : Integer;
    Iter : DIterator;
    TreeHeights : DArray;
begin
  var Puts := [
    866, 208, 669, 847, 14 , 917, 558, 494, 617, 660, 372, 297, 508, 542,
    44 , 739, 904, 368, 20 , 869, 942, 55 , 741, 942, 823, 997, 913, 908,
    203, 743, 328, 744, 781, 595, 311, 855, 236, 996, 72 , 27 , 944, 802,
    516, 673, 145, 809, 313, 359, 488, 137, 264, 825, 105, 338, 270, 15 ,
    671, 332, 441, 821, 84 , 526, 156, 549, 714, 742, 102, 324, 382, 788,
    606, 933, 491, 810, 800, 822, 982, 758, 414, 258, 38 , 596, 241, 858,
    709, 101, 589, 0  , 870, 370, 238];

  var Removes := [
    722, 845, 113, 262, 980, 334, 723, 18 , 658, 74 , 445, 988, 623, 108,
    714, 243, 490, 521, 855, 617, 182, 493, 249, 201, 861, 80 , 208, 423,
    738, 487, 241];

  Map := DMap.Create;

  for i := Low(Puts) to High(Puts) do
  begin
    Map.putPair([Puts[i], Puts[i]]);

    TreeHeights := DArray.Create;
    Iter := Map.start;
    while IterateOver(Iter) do
    begin
      Assert.IsTrue(VerifyTreeNodeRuleNOTRR(Iter.treeNode));

      if IsLeaf(Iter.treeNode) then
        TreeHeights.add([GetLeafNodeBlackCount(Iter.tree, Iter.treeNode)]);
    end;
      // treeHeight must contain all the same values for rule S#=
    AssertAllSame(TreeHeights);
    TreeHeights.Free;

  end;

  for i := Low(Removes) to High(Removes) do
  begin
    Map.remove([Removes[i]]);

    TreeHeights := DArray.Create;
    Iter := Map.start;
    while IterateOver(Iter) do
    begin
      Assert.IsTrue(VerifyTreeNodeRuleNOTRR(Iter.treeNode));

      if IsLeaf(Iter.treeNode) then
        TreeHeights.add([GetLeafNodeBlackCount(Iter.tree, Iter.treeNode)]);
    end;
      // treeHeight must contain all the same values for rule S#=
    AssertAllSame(TreeHeights);
    TreeHeights.Free;

  end;

  Map.Free;

end;

initialization
  TDUnitX.RegisterTestFixture(TTestRandomTesting);

end.
