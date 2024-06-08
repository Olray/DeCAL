# About this Test
This is just a simple test to check if a bug I stumpled upon and fixed has been solved. In no way it certifies DeCAL (XE) for production use.

**However, feel free to add as many tests as you like.**

## Necessary tools
I'm using FastMM4 for memory leak detection. Copy the precompiled units and the `FastMM_FullDebugMode.dll` to 
`./Win32/Debug` before running these tests.

Alternatively you can remove the following lines from the DeCAL.Test.dpr to disable FastMM4:
```
  {$IFDEF DEBUG}
  FastMM4,
  {$ENDIF}
```
