// functions with parameters
Function myFuncParam1(var1)
  variable var1
end

Function myFuncParam2(var1, str1)
  string str1
  variable var1
end

Structure myStructType
variable v1
EndStructure

/// This function has structure parameters, which are always call-by-reference
///@param w1        input wave
///@param str1      fancy version string
///@param myStruct1 first working struct
///@param myStruct2 second working struct
///@param myStruct3 third working struct
Function myFuncParam3(w1, str1, myStruct1, myStruct2, myStruct3)
  struct myStructType& myStruct1
  struct myStructType & myStruct2
  struct myStructType &myStruct3
  Wave/T w1
  string str1
end

Function myFuncParam4(param)
  struct myStructType& param
end

// normal parameters using call-by-reference
Function myFuncParam5(param, [str1])
  struct myStructType& param
  string& str1
end

// multiple return value syntax, introduced with IP8
Function [int64 out1, variable out2] myFuncParam6(int64 in)

	return [out1, out2]
end

Function [int64 out, struct myStructType s, WAVE/T textwave] myFuncParam7(int64 in, [variable opt])

	return [out, s, textwave]
end

Function [string data, string fName] myFuncParam8(string fileName[, string fileFilter, string message])

	return ["", ""]
End

// function modifiers

static Function myFuncS1()
End

static Function myFuncS2(var)
	variable var
End

threadsafe static Function myFuncST1()
End

threadsafe static Function myFuncST2(var)
	variable var
End

override Function myFuncSTO1()
End

override Function myFuncSTO2(var)
	variable var
End

// and this is not a function declaration
SomeStuff Function notAFunc()

Function Proto()

End

Function Test1(variable a, string s, wave w, dfref d, funcref Proto f, struct RECTF &st, int i, int64 i64, uint64 ui64, double do, complex c, [variable opt])

End

Function Test2(variable &a, funcref Proto f, [string &s])

End

Function Test3(struct RECTF& s [, string s])

End

Function/S TestWithNastyPrefix(waverefs)
	Wave/WAVE waveRefs
End
