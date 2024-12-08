# DeCAL
The Delphi Container and Algorithm Library (DeCAL) is a powerful library of reusable container classes, generic algorithms, and an easy 
to use persistence mechanism. It is similar to and based on Stepanov's STL.

Back in the first decade, DeCAL and it's predecessor STL was used in many commercial applications. It was released by Ross Judson on 
22nd Sep 2000.

## Motivation
Updating to Delphi 2009 broke DeCAL due to the lack of WideString support which is now the default 
string type in Delphi. After finding the problem and fixing it some time ago, I finally decided to share the code.

## Original Source
Source: https://sourceforge.net/projects/decal/

I didn't check in the original source to GitHub, because the Delphi IDE messes with the spaces and tabs making a diff impossible because 
almost every line is marked as changed.

## License
Mozilla Public License 1.0

## Notable Changes
* Added String support for Delphi XE standard strings (former WideString)
* Fixed a bug in Superstream. A TChar was incremented to walk a buffer which was okay when every char in a string was one byte. (Changed TChar to TByte)
* Fixed a bug in the removeCopy family of functions where the behavior was reversed to the expected one (reported by Doug Winsby on 27th Oct 2024)
* Added a noticeable amount of Tests
* Added support for anonymous functions

## Testing
I'm still using DeCAL for a bunch of projects. It's easily implemented with a very small footprint and has decent performance.
There were no TESTS included other than the original files "DeCALTesting.pas" and "RandomTesting.pas". Test Driven Development (TDD) was 
unknown in the 1990's.
**However, an increasing amount of tests have recently been added.**

I'm currently using DeCAL with Delphi 11 "Community Edition" with no problems. I wouldn't suggest using it for large projects due to the
missing tests. **Use this fix at your own risk**

## Changes
A bug was reported by Doug Winsby on 27th Oct 2024 claiming that the behavior of removeCopyIfIn routine was reversed: Instead of removing
objects for which the DTest function returned true, it was including them, effectively reversing the intended behavior.

The bug was eliminated and the function removeCopyIfIn marked as deprecated with a message leading users to this documentation. Thanks to Doug Winsby for the report.

## Anonymous functions
You can now use anonymous functions with DeCAL. Find some very basic testing of DGenerators in Tests/Test_Makers.pas. With anonymous functions you can do the following:

```
  Array := DArray.Create;
  generate(Array, 1000,
    function: DObject
	begin
	  InitDObject(Result);
	  Result.VType := vtInteger;
	  Result.VInteger := Random(1000);
	end;
	);
```

You can also create a container with an anonymous Comparator (see TTestMakers.Test_Comparators):

```  
  Array := DArray.CreateWith(
    function(const obj1, obj2: DObject): Integer
    var O1, O2: TTestClass;
    begin
      O1 := obj1.VObject as TTestClass;
      O2 := obj2.VObject as TTestClass;
      Result := CompareStr(O1.FName, O2.FName);
    end
  );
```
