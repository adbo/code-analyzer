Code analyzer - this application can take a grammar as input and perform lexical analysis of a code which using the language described by this grammar. Application use a open source library Jison (https://zaa.ch/jison/) to build a JS capable of parsing a code.

Prerequisites:
Node.JS - https://nodejs.dev/

Installation:
npm init

Using:
node index.js grammar.jison program.lang

where grammar.jison is a grammar, and program.lang is a code in the language decibed by the grammar.



