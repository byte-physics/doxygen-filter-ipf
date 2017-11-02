#!/bin/sh

doxygen
cd latex
latexmk refman.tex
cd ..
mv latex/refman.pdf doxygen-generated-refman.pdf

git archive -o newRelease.zip HEAD
zip -qu  newRelease.zip doxygen-generated-refman.pdf
