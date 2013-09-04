Overview
========

A simple script that makes use of the Dygraphs <http://dygraphs.com/> library to generate dynamic plots of p-value vs either genetic distance or genome coordinates. This is tailored to consume the output of FastLMM but can be extended with a bit of fiddling to handle any GWAS-type output.

Usage
=====

fastlmm-plot.pl --file [fastlmm output text file] --title "Plot title" --position [integer column containing positional data] --log [true|false] --output [name of html file.html]
