unit DeCAL.MockClasses;

interface

type
  IDeCALTestInterface = interface
    function GetIdentifier : Integer;
  end;

  TDecalMockClassSimple = class
  private
    FIdentifier : Integer;
  public
    constructor Create(SomeIdentifier : Integer);
    function GetIdentifier : Integer;
  end;

  TDecalInterfacedClass = class(TInterfacedObject, IDeCALTestInterface)
    function GetIdentifier : Integer;
  end;

implementation


constructor TDecalMockClassSimple.Create(SomeIdentifier : Integer);
begin
  FIdentifier := SomeIdentifier;
  inherited Create;
end;

function TDecalMockClassSimple.GetIdentifier : Integer;
begin
  Result := FIdentifier;
end;

function TDecalInterfacedClass.GetIdentifier: Integer;
begin
  Result := 4711;
end;

end.
