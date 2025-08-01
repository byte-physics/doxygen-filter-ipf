# Copyright: Thomas Braun, support (at) byte (minus) physics (dot) de
# License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
# Version: 0.28
#
# Proof of concept implementation for using doxygen to document Igor Pro procedures.
#
# This awk script serves as input filter for Igor procedures and produces a C++-ish version of the code
# Tested with Igor Pro 7.06 and doxygen 1.8.13. Works also with breathe and sphinx.

# Supported Features:
# -Functions
# -Macros
# -File constants
# -Menu items are currently ignored

# TODO
# - don't delete the function/macro subType

BEGIN{
  # allows to bail out for code found outside of functions/macros
  DO_WARN=0
  IGNORECASE=1
  output=""
  warning=""

  menuEndCount     = 0
  insideNamespace  = 0
  insideFunction   = 0
  insideStructure  = 0
  insideMacro      = 0
  insideMenu       = 0
  insideASCIIBlock = 0

  namespace=""
}

# Convert Igor wave types to valid C++ types
function nicifyWaveType(str)
{
  # change wave type specifiers to something sphinx likes
  if(match(str, /\yWave\/[a-z]+/))
  {
    # more complex ones are at the top
    gsub("Wave/Z/Wave", "WaveRefWaveOrNull", str)
    gsub("Wave/Wave/Z", "WaveRefWaveOrNull", str)
    gsub("Wave/Z/I",    "WaveIntegerOrNull", str)
    gsub("Wave/I/Z",    "WaveIntegerOrNull", str)
    gsub("Wave/Z/D",    "WaveDoubleOrNull",  str)
    gsub("Wave/D/Z",    "WaveDoubleOrNull",  str)
    gsub("Wave/Z/R",    "WaveRealOrNull",    str)
    gsub("Wave/R/Z",    "WaveRealOrNull",    str)
    gsub("Wave/Z/C",    "WaveComplexOrNull", str)
    gsub("Wave/C/Z",    "WaveComplexOrNull", str)
    gsub("Wave/Z/T",    "WaveTextOrNull",    str)
    gsub("Wave/T/Z",    "WaveTextOrNull",    str)
    gsub("Wave/Wave",   "WaveRefWave",       str)
    gsub("Wave/Z",      "WaveOrNull",        str)
    gsub("Wave/T",      "WaveText",          str)
    gsub("Wave/I",      "WaveInteger",       str)
    gsub("Wave/D",      "WaveDouble",        str)
    gsub("Wave/R",      "WaveReal",          str)
    gsub("Wave/C",      "WaveComplex",       str)
  }

  return str
}

# Remove whitespace at beginning and end of string
# Return the whitespace in front of the string in the
# global variable frontSpace to be able
# to reconstruct the indentation
function trimAndRememberIndentation(str)
{
  gsub(/[[:space:]]+$/,"",str)

  if(match(str, /^[[:space:]]+/))
  {
    frontSpace = substr(str, 1, RLENGTH)
    str = substr(str, RLENGTH + 1)
  }
  else
    frontSpace = ""

  return str
}

# Remove whitespace at beginning and end of string
function trim(str)
{
  gsub(/[[:space:]]+$/,"",str)

  if(match(str, /^[[:space:]]+/))
  {
    return substr(str, RLENGTH + 1)
  }

  return str
}

# Split an already trimmed line into words
# Returns the number of words
function splitIntoWords(str, a)
{
  return split(str,a,/[[:space:],&*]+/)
}

# Split at comma
function splitAtComma(str, a)
{
  return split(str,a,/,/)
}

# Split params into words and prefix each with "__Param__$i"
# where $i is increased for every parameter
# Returns the concatenation of all prefixed parameters
function handleParameterOldStyle(params, a,  i, iOpt, str, entry)
{
  numParams = splitIntoWords(params, a)
  str=""
  entry=""
  iOpt=numParams
  for(i=1; i <= numParams; i++)
  {
    # convert igor optional parameters to something doxygen understands
    # igor dictates that the optional arguments are the last arguments,
    # meaning no normal argument can follow the optional arguments
    if(gsub(/[\[\]]/,"",a[i]) || i > iOpt)
    {
      iOpt  = i
      entry = a[i] " = defaultValue"
    }
    else
      entry = a[i]

    str = str "__Param__" i " " entry
    if(i < numParams)
     str = str ", "
  }
  return str
}

# New style inline parameters have already the correct type, but we still need
# to handle optional parameters
function handleParameterNewStyle(params, a, i, iOpt, str, entry)
{
  numParams = splitAtComma(params, tokenArray)

  # print "numParams: " numParams

  str=""
  iOpt=1e6
  for(i=1; i <= numParams; i += 1)
  {
    tokenArray[i] = trim(tokenArray[i])
    # print "tokenArray[i]: " tokenArray[i]

    if(match(tokenArray[i],/\[$/))
      iOpt = i + 1
    else if(match(tokenArray[i],/\[[a-z]+/))
      iOpt = i

    gsub(/[\[\]]/, "", tokenArray[i])

    # convert igor optional parameters to something doxygen understands
    # igor dictates that the optional arguments are the last arguments,
    # meaning no normal argument can follow the optional arguments
    if(i >= iOpt)
    {
      entry = formatSingleNewStyleParameter(tokenArray[i], 1)
    }
    else
    {
      entry = formatSingleNewStyleParameter(tokenArray[i], 0)
    }

    str = str "" entry

    if(i < numParams)
     str = str ", "
  }

  return str
}

# Format the given token as inline function parameter
# isOptional is a boolean parameter
function formatSingleNewStyleParameter(token, isOptional,  numElements, name, type, paramLine)
{
  if(match(token,/&/))
  {
    typeSuffix = "*"
  }
  else
  {
    typeSuffix = ""
  }

  # translate module separator "#" to C++ namespace separator
  gsub("#", "::", token)

  numElements = splitIntoWords(token, a)

  # print "a[1]: " a[1]
  # print "a[2]: " a[2]
  # print "a[3]: " a[3]

  if(numElements == 3 && (a[1] == "funcref" || a[1] == "struct"))
  {
    type = a[2]
    name = a[3]
  }
  else
  {
    type = tolower(a[1])
    name = a[2]
  }

  paramLine = nicifyWaveType(type) typeSuffix " " name

  if(isOptional)
  {
    paramLine = paramLine " = defaultValue"
  }

  return paramLine
}

{
  # split current line into code and comment
  if(match($0,/(\t| |^)\/\/.*/))
  {
    code=substr($0,1,RSTART-1)
    comment=substr($0,RSTART,RLENGTH)
  }
  else
  {
    code=$0
    comment=""
  }
  code=trimAndRememberIndentation(code)

  if(match(code, /^#pragma independentModule\s*=\s*/))
  {
	  namespace = substr(code, RSTART + RLENGTH)
	  code = "namespace " namespace " {"
	  insideNamespace = 1
  }

  # begin of macro definition
  if(!insideFunction && !insideMacro && ( match(code,/^Window/)|| match(code,/^Proc/) || match(code,/^Macro/) ) )
  {
    insideMacro=1
    gsub(/^Window/,"void",code)
    gsub(/^Macro/,"void",code)
    gsub(/^Proc/,"void",code)

    # add opening bracket, this also throws away any function subType
    gsub(/\).*/,"){",code)
  }
  # end of macro definition
  else if(!insideFunction && insideMacro && ( match(code,/^EndMacro$/) || match(code,/^End$/) ) )
  {
    insideMacro=0
    code = "}"
  }
  # begin of function declaration with inline parameter declarations
  else if(!insideFunction && match(code,/^((threadsafe|static|override)?[[:space:]]+)*function[[:space:]]*\[.*\][[:space:]]+[A-Z0-9_]+[[:space:]]*\(/))
  {
    insideFunction=1

    # don't use the parameter handling code for old style (IP6 and before) parameter definition
    paramsToHandle=0

    # add opening bracket, this also throws away any function subType
    gsub(/\).*/,"){",code)

    # uses multiple return value syntax?
    if(match(code,/function[[:space:]]*\[[^\[]+\]/))
    {
      returnParams = substr(code, RSTART, RLENGTH)
      # print "return params: " returnParams

      # remove "function " prefix
      gsub(/function[[:space:]]*/, "", returnParams)

      # remove [ and ]
      returnParams = substr(returnParams, 2, length(returnParams) - 2)

      # remove struct keyword
      gsub(/\ystruct\y[[:space:]]*/, "", returnParams)

      numWords = splitIntoWords(returnParams, entries)
      types = ""
      for(i=1; i <= numWords; i+=2)
      {
        types = types "" entries[i] ", "
      }

      gsub(/, $/, "", types)

      # print "return params: " returnParams
      # print "return types: " types

      gsub(/function[[:space:]]*\[[^\[]+\]/, "std::tuple<" types ">", code)
    }

    if(match(code,/\(.*[a-z]+.*\)/))
    {
      paramsStartIndex = RSTART
      paramsLength = RLENGTH
      paramStr = substr(code, paramsStartIndex + 1, paramsLength - 2)
      paramStrWithTypes = handleParameterNewStyle(paramStr, params)

      # print "paramStr __ " paramStr
      # print "paramStrWithTypes __ " paramStrWithTypes

      code = substr(code, 1, paramsStartIndex) "" paramStrWithTypes "" substr(code, paramsStartIndex + paramsLength - 1)
    }
  }
  # begin of function declaration with old-schoool or inline parameter declarations
  else if(!insideFunction && match(code,/^((threadsafe|static|override)?[[:space:]]+)*function[[:space:]]*(\/(df|wave|c|s|t|d))?[[:space:]]+[A-Z0-9_]+[[:space:]]*\(/))

  {
    insideFunction=1
    paramsToHandle=0
    # remove whitespace between function and return type flag
    gsub(/function[[:space:]]*\//,"function/",code)

    # different return types
    gsub(/function /,"variable ",code)
    gsub(/function\/df/,"dfref",code)
    gsub(/function\/wave/,"wave",code)
    gsub(/function\/c/,"complex",code)
    gsub(/function\/s/,"string",code)
    gsub(/function\/t/,"string",code) # deprecated definition of string return type
    gsub(/function\/d/,"variable",code)

    # add opening bracket, this also throws away any function subType
    gsub(/\).*/,"){",code)

    # do we have function parameters
    if(match(code,/\(.*[a-z]+.*\)/))
    {
      paramsStartIndex = RSTART
      paramsLength = RLENGTH
      paramStr = trim(substr(code, paramsStartIndex + 1,paramsLength - 2))

      if(match(paramStr, /^\[?(variable|string|wave|dfref|funcref|struct|int|int64|uint64|double|complex)\y/))
      {
        # inline parameter declaration
        paramStrWithTypes = handleParameterNewStyle(paramStr, params)
      }
      else
      {
        # old style parameter declaration in code in the function

        paramStrWithTypes = handleParameterOldStyle(paramStr, params)
        paramsToHandle = numParams

        # print "paramsToHandle __ " paramsToHandle
      }

      # print "paramStr __ " paramStr
      # print "paramStrWithTypes __ " paramStrWithTypes
      code = substr(code, 1, paramsStartIndex) "" paramStrWithTypes "" substr(code, paramsStartIndex + paramsLength - 1)
    }
  }
  else if(insideFunction && paramsToHandle > 0)
  {
   numEntries = splitIntoWords(code,entries)

   # printf("Found %d words in line \"%s\"\n",numEntries,code)
    for(i=2; i <= numEntries; i++)
      for(j=1; j <= numParams; j++)
      {
        variableName = entries[i]
        if( entries[i] == params[j] )
        {
          paramsToHandle--
          # now replace __Param__$i with the real parameter type
          if(entries[1] == "struct" || entries[1] == "funcref")
            paramType = entries[2]
          else
            paramType = tolower(entries[1])

          # add asterisk for call-by-reference parameters
          if(match(code,/&/))
            paramType = paramType "*"

          # translate module separator "#" to C++ namespace separator
          gsub("#", "::", paramType)

          paramType = nicifyWaveType(paramType)

          output = gensub("__Param__" j " ",paramType " ","g",output)
          # printf("Found parameter type %s at index %d\n",paramType,j)
        }
      }
  }
  # end of function declaration
  else if(insideFunction && match(code,/^end$/))
  {
    insideFunction=0
    code = "}"
  }
  else if(!insideMacro && !insideFunction && match(code,/^(static )?Picture/))
  {
    insideMacro=1
    gsub(/Picture/,"void",code)
    code = code "(){"
  }
  else if(insideMacro && match(code,/ASCII85Begin/))
  {
    insideASCIIBlock=1
  }
  else if(insideASCIIBlock && match(code,/^ASCII85End$/))
  {
    insideASCIIBlock=0
    code = "// " code
  }

  if(insideFunction || insideMacro)
  {
    # invalidate the names of functions behind proc=
    gsub(/\yproc\y=[[:space:]]*/,"&__", code)
    # invalidate the names of functions behind hook(.+)=
    gsub(/\yhook\y(\([^\)]+\))?[[:space:]]*=[[:space:]]*/, "&__", code)
    # comment out FUNCREF lines
    gsub(/^FUNCREF/, "//&", code)

    # translate function calls to functions located in modules to use
    # the C++ namespace separator
    # We don't have to translated references to constants in modules as
    # this is at least for independent modules impossible to use in Igor Pro.
    if(match(code, /\y[A-Za-z0-9_-]+\y#\y[A-Za-z0-9_-]+\y\(/))
    {
      part = substr(code, RSTART, RLENGTH)
      gsub("#", "::", part)
      code = substr(code, 1, RSTART - 1) "" part "" substr(code, RSTART + RLENGTH)
    }
  }

  # structure declaration
  if(!insideFunction && !insideMacro && ( match(code,/[[:space:]]structure[[:space:]]/) || match(code,/^structure[[:space:]]/) )  )
  {
    insideStructure=1
    gsub(/structure/,"struct",code)
    code = code "{"
  }
  else if(insideStructure && match(code,/^FUNCREF/))
  {
    # remove the name of the prototype function
    # in C/C++ we don't use function pointer the igor way
    # so there is little sense in keeping it
    numEntries = splitIntoWords(code, entries)
    code = "funcref " entries[numEntries]
  }
  else if(insideStructure && match(code,/^STRUCT/))
  {
    # make structure declarations valid C++
    gsub(/\ystruct\y/,"",code)
  }
  else if(insideStructure && match(code,/EndStructure/))
  {
    insideStructure=0
    code = "}"
  }

  # translate "#if defined(symbol)" to "#ifdef symbol"
  if(!insideFunction && !insideMacro && !insideMenu && !insideStructure && match(code,/^#if[[:space:]]+defined\(.+\)[[:space:]]*$/))
  {
    gsub(/^#if[[:space:]]+defined\(/,"#ifdef ",code)
    gsub(/)/,"",code)
  }

  # menu definition
  # submenues can be nested in menus. Therefore we have to keep track
  # of the number of expected "End" keywords
  if(!insideFunction && !insideMacro && ( match(code,/\yMenu\y/) || match(code,/\ySubMenu\y/) ))
  {
    menuEndCount++
    insideMenu=1
  }

  if(insideMenu && match(code,/\yEnd[[:space:]]*/))
  {
    menuEndCount--
    if(menuEndCount == 0)
    {
      insideMenu=0
      code = ""
    }
  }

  # global constants
  gsub(/\ystrconstant\y/,"const string",code)
  gsub(/\yconstant\y/,"const double",code)
  # prevent that doxygen sees elseif as a function call
  gsub(/\yelseif\y/,"else if",code)

  # fix case of static keyword
  gsub(/^Static\y/,"static",code)

  # make threadsafe/override a valid c++11 attribute
  gsub(/^threadsafe\y/,"[[ threadsafe ]]",code)
  gsub(/^override\y/,"[[ override ]]",code)

  if(insideStructure || insideFunction || insideMacro)
  {
    code = nicifyWaveType(code)
  }

  # remove specifiers after an include statement
  if(match(code,/^#include.*(menus|version|optional)[[:space:]]*=?[[:space:]]*.*$/))
  {
    gsub(/,?[[:space:]]*(menus|version|optional)[[:space:]]*=?[[:space:]]*.*$/, "", code)
  }

  # code outside of function/macro definitions is "translated" into statements
  if(!insideFunction && !insideMacro && !insideMenu && code != "" && substr(code,1,1) != "#")
  {
    if(code != "}" && !insideStructure && DO_WARN)
      warning = warning "\n" "warning " NR ": outside code \"" code "\""

    code = code ";"
  }

  # comment out code in ASCII85Begin/ASCII85End blocks
  if(insideASCIIBlock)
  {
    code = "// " code
  }

  # print "frontSpace: __" frontSpace "__"

  if(!insideMenu)
  {
    output = output frontSpace code comment
  }

  output = output "\n"
}

END{
  print output

  if(insideNamespace)
	  print "} // closing namespace " namespace

  if(DO_WARN)
    print warning
}
