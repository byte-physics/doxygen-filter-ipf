#!/bin/bash

gawk -f doxygen-filter-ipf.awk test-input-function-params.ipf > test-input-function-params.output.ref
gawk -f doxygen-filter-ipf.awk test-input.ipf > test-input.output.ref

git diff *.output.ref
