/* CMSC 430 Compiler Theory and Design
   Project 2 Skeleton
   UMGC CITE
   Summer 2023 */

/* This file contains flex input file */

%{
#include <cstdio>
#include <string>
#include <vector>
#include "types.h"
using namespace std;

#include "listing.h"
#include "tokens.h"
%}

%option noyywrap

ws        [ \t\r]+
comment   "//".*\n
comment2   "--".*\n
line      \n
id        [A-Za-z]([A-Za-z0-9])*
digit     [0-9]
exp       [eE][+-]?{digit}+
real      {digit}+"."{digit}*{exp}?|{digit}*"."{digit}+{exp}?
SQUOTE    \'
charlit   {SQUOTE}([^\\']|\\[nrt0'\\]){SQUOTE}
punc      [\(\),:;]


%%

[ \t\r]+                   { ECHO; }
("//"|"--").*              { ECHO; nextLine(); }
\n                         { ECHO; nextLine(); }

"+"                        { ECHO; return(ADDOP); }
"-"                        { ECHO; return(ADDOP); }
"*"                        { ECHO; return(MULOP); }
"/"                        { ECHO; return(MULOP); }
"%"                        { ECHO; return(MODOP); }
"^"                        { ECHO; return(EXPOP); }
"~"                        { ECHO; return(NEGOP); }
"&"                        { ECHO; return(ANDOP); }
"|"                        { ECHO; return(OROP); }
"!"                        { ECHO; return(NOTOP); }

"<="                       { ECHO; return(RELOP); }
">="                       { ECHO; return(RELOP); }
"<>"                       { ECHO; return(RELOP); }
"<"                        { ECHO; return(RELOP); }
">"                        { ECHO; return(RELOP); }
"="                        { ECHO; return(RELOP); }
"=>"                       { ECHO; return(ARROW); }

begin                      { ECHO; return(BEGIN_); }
case                       { ECHO; return(CASE); }
character                  { ECHO; return(CHARACTER); }
else                       { ECHO; return(ELSE); }
end                        { ECHO; return(END); }
endswitch                  { ECHO; return(ENDSWITCH); }
endif                      { ECHO; return(ENDIF); }
fold                       { ECHO; return(FOLD); }
endfold                    { ECHO; return(ENDFOLD); }
function                   { ECHO; return(FUNCTION); }
if                         { ECHO; return(IF); }
elsif                      { ECHO; return(ELSIF); }
integer                    { ECHO; return(INTEGER); }
real                       { ECHO; return(REAL); }
is                         { ECHO; return(IS); }
left                       { ECHO; return(LEFT); }
list                       { ECHO; return(LIST); }
of                         { ECHO; return(OF); }
others                     { ECHO; return(OTHERS); }
returns                    { ECHO; return(RETURNS); }
right                      { ECHO; return(RIGHT); }
switch                     { ECHO; return(SWITCH); }
then                       { ECHO; return(THEN); }
when                       { ECHO; return(WHEN); }

[A-Za-z][A-Za-z0-9]*        { ECHO; return(IDENTIFIER); }
([0-9]+\.[0-9]*|\.[0-9]+)([eE][+-]?[0-9]+)? {
    ECHO;
    yylval.realVal = atof(yytext);
    return(REAL_LITERAL);
}
"#"[0-9A-Fa-f]+ {
    ECHO;
    sscanf(yytext + 1, "%x", &yylval.intVal); // Skip '#' and convert hex to int
    return(INT_LITERAL);
}
[0-9]+                      { ECHO; return(INT_LITERAL); }
\'(\\.|[^\\'])\'            { ECHO; return(CHAR_LITERAL); }

[\(\),:;]                   { ECHO; return(yytext[0]); }
.                           { ECHO; appendError(LEXICAL, yytext); }

%%