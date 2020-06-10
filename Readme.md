This project here is a proof of concept implementation in AWK of an filter
which translates procedure files into C++-ish output for doxygen consumption.
Works with breathe and sphinx as well.

Requires GNU AWK. Available for Windows [here](http://gnuwin32.sourceforge.net/packages/gawk.htm).

### Supported Features:

- Functions, including parameter type resolution, call-by-reference recognition and optional parameters
- Constants
- Macros

### Workflow

- Comment procedure files using doxygen commands
- Tweak doxygen config file and define at least

```
FILE_PATTERNS   = *.ipf
FILTER_PATTERNS = "*.ipf=gawk -f doxygen-filter-ipf.awk"
```

Alternatively you can use the supplied example `Doxyfile`.

- Execute doxygen

An example of the result can be seen [here](https://docs.byte-physics.de/igor-unit-testing-framework/).

### Missing features

- Igor help file generation
- Function subtype support
