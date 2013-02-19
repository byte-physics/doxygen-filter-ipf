
constant myConst=123 ///< This is a really special number

/// The first alphabet letters
strconstant myStrConst="abcd"

///@name Functions with different return types
///@{
Function FooBar()
print 1
End

/// Function with subtype
///
/// The subtype is currently ignored
Function FooBarSubType() : ButtonControl
print 1
End

Function/D FooBarVar()
print 2
End

Function/DF FooBarDFR()
print 3
End

Function/C FooBarComp()
print 4
End

Function/S FooBarStr()
print 5
End

Function/Wave FooBarWave()
print 6
End
///@}

// decorators
static Function FooBarStatic()
print 7
End

threadsafe static Function FooBarStaticThreadsafe()
print 8
End

threadsafe Function FooBarThread()
print 9
End

/// My structure definition
Structure struct1
	string str
  variable var 
EndStructure

static Structure struct2
	string str
  variable var 
EndStructure

