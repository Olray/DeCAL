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
  Test_Algorithms in 'Test_Algorithms.pas';

begin
  TestInsight.DUnitX.RunRegisteredTests;
end.
