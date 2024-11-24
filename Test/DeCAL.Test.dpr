program DeCAL.Test;

{$STRONGLINKTYPES ON}
uses
  {$IFDEF DEBUG}
  FastMM4,
  {$ENDIF }
  System.SysUtils,
  TestInsight.DUnitX,
  DUnitX.TestFramework,
  Test_Map in 'Test_Map.pas',
  DeCAL.MockClasses in 'DeCAL.MockClasses.pas',
  Test_SuperStream in 'Test_SuperStream.pas',
  Test_Regress in 'Test_Regress.pas',
  Test_Transformations in 'Test_Transformations.pas',
  DeCAL.MockData in 'DeCAL.MockData.pas',
  Test_Algorithms in 'Test_Algorithms.pas',
  Test_Sort in 'Test_Sort.pas',
  DeCAL in '..\DeCAL.pas',
  Test_Iterator in 'Test_Iterator.pas',
  Test_RandomTesting in 'Test_RandomTesting.pas',
  mwFixedRecSort in '..\mwFixedRecSort.pas',
  DeCALIO in '..\DeCALIO.pas',
  SuperStream in '..\SuperStream.pas',
  Test_Clone in 'Test_Clone.pas';

begin
  TestInsight.DUnitX.RunRegisteredTests;
end.
