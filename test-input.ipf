#include "abcd"
#include "efgh" menus=0
#include "ijkl", optional
#include "mnop", version=123, optional

constant myConst=123 ///< This is a really special number

/// The first alphabet letters
strconstant myStrConst="abcd"

strConstant url = "https://example.com" // test "efgh"
strConstant someOtherUrl = "https://test.com"

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

override Function FooBarOv()
	print 9
End

// decorators and return types
static Function/DF FooBarStaticDFR()
	print 7
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

// parameters
Function FooParamVar(var)
	variable var
End

Function FooParamStr(str)
	string str
End

Function FooParamStruct(s)
	STRUCT struct1 &s
End

StrConstant abcd = "This text is not a function declaration"

Picture Pic1
	ASCII85Begin
	M,6r;%14!\!!!!.8Ou6I!!!"5!!!!C#R18/!*gQ=PlLda"EQn$<!Wa8#^cngL]@DY'hLeZ<+nYd>>6
	"J
	ASCII85End
End

static Picture StaticPic2
	ASCII85Begin
	M,6r;%14!\!!!!.8Ou6I!!!"5!!!!C#R18/!*gQ=PlLda"EQn$<!Wa8#^cngL]@DY'hLeZ<+nYd>>6
	"J
	ASCII85End
End
