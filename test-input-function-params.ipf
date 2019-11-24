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
