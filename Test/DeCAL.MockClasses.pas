unit DeCAL.MockClasses;

interface

type
  IDeCALTestInterface = interface
    Function getIdentifier : Integer;
  end;

  TDecalMockClassSimple = class
  private
    FIdentifier : Integer;
  public
    Constructor Create(SomeIdentifier : Integer);
    Function getIdentifier : Integer;
  end;

  TDecalInterfacedClass = class(TInterfacedObject, IDeCALTestInterface)
    function getIdentifier : Integer;
  end;

implementation


Constructor TDecalMockClassSimple.Create(SomeIdentifier : Integer);
begin
  FIdentifier := SomeIdentifier;
  inherited Create;
end;

function TDecalMockClassSimple.getIdentifier : Integer;
begin
  result := FIdentifier;
end;

function TDecalInterfacedClass.getIdentifier: Integer;
begin
  Result := 4711;
end;

end.
