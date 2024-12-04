program DeCAL.Test;

{$STRONGLINKTYPES ON}
uses
  {$IFDEF DEBUG}
  FastMM4,
  {$ENDIF }
  System.SysUtils,
  TestInsight.DUnitX,
  DUnitX.TestFramework,
  DeCAL in '..\DeCAL.pas',
  DeCALIO in '..\DeCALIO.pas',
  SuperStream in '..\SuperStream.pas',
  mwFixedRecSort in '..\mwFixedRecSort.pas',
  DeCAL.MockClasses in 'DeCAL.MockClasses.pas',
  DeCAL.MockData in 'DeCAL.MockData.pas',
  Test_Map in 'Test_Map.pas',
  Test_SuperStream in 'Test_SuperStream.pas',
  Test_Regress in 'Test_Regress.pas',
  Test_Transformations in 'Test_Transformations.pas',
  Test_Algorithms in 'Test_Algorithms.pas',
  Test_Sort in 'Test_Sort.pas',
  Test_Iterator in 'Test_Iterator.pas',
  Test_RandomTesting in 'Test_RandomTesting.pas',
  Test_Clone in 'Test_Clone.pas';

begin
  TestInsight.DUnitX.RunRegisteredTests;
end.
