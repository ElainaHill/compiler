/* CMSC 430 Compiler Theory and Design
   Project 4 Skeleton
   UMGC CITE
   Summer 2023
   
   Project 4 Parser with semantic actions for static semantic errors */

%{
#include <string>
#include <vector>
#include <map>

using namespace std;

#include "types.h"
#include "listing.h"
#include "symbols.h"

int yylex();
Types find(Symbols<Types>& table, CharPtr identifier, string tableName);
void yyerror(const char* message);

Symbols<Types> scalars;
Symbols<Types> lists;


// Control printing only first syntax error per parse error instance
static bool first_syntax_error = true;
    
%}

%define parse.error verbose

%union {
  char* text;
  int intVal;
  double realVal;
  char charVal;
	CharPtr iden;
	Types type;
}

%token <iden> IDENTIFIER

%token <type> INT_LITERAL CHAR_LITERAL REAL_LITERAL

%token ADDOP MULOP RELOP ANDOP ARROW MODOP EXPOP NEGOP OROP NOTOP

%token BEGIN_ CASE CHARACTER ELSE END ENDSWITCH FUNCTION INTEGER IS LIST OF OTHERS
	RETURNS SWITCH WHEN FOLD IF LEFT RIGHT THEN ELSIF ENDIF REAL ENDFOLD

%type <type> list body type statement_ statement cases case expression
	term primary additive multiplicative exponential unary expression_list

%%

program:
    function
;

function:
    function_header variable_list_opt body
;
	
function_header:
    FUNCTION IDENTIFIER parameters_opt RETURNS type ';'
  | error ';' { yyerrok; first_syntax_error = true; }
;

parameters_opt:
    parameters
  | /* empty */
;

parameters:
    parameter
  | parameters ',' parameter
;

parameter:
    IDENTIFIER ':' type
;

type:
    INTEGER {$$ = INT_TYPE;}
  | REAL {$$ = REAL_TYPE;}
  | CHARACTER {$$ = CHAR_TYPE; }
;

variable_list_opt:
    variable_list
  | /* empty */
;

variable_list:
    variable
  | variable_list variable
  | error ';' { yyerrok; first_syntax_error = true; }  /* Recover from multiple variable errors */
;
	
optional_variable:
	variable |
	%empty ;
    
variable:	
	IDENTIFIER ':' type IS statement ';' {checkAssignment($3, $5, "Variable Initialization"); scalars.insert($1, $3);} |
	IDENTIFIER ':' LIST OF type IS list ';' {lists.insert($1, $5);} ;

list:
    '(' expression_list ')'
;

expression_list:
    expression {
        $$ = $1;
    }
  | expression_list ',' expression {
        if ($1 != $3 && $1 != MISMATCH && $3 != MISMATCH)
            appendError(GENERAL_SEMANTIC, "List Element Types Do Not Match");
        $$ = ($1 == REAL_TYPE || $3 == REAL_TYPE) ? REAL_TYPE : $1;
    }
;

body:
    BEGIN_ statement_seq END ';'
;

statement_seq:
    statement_
  | statement_seq statement_
;
    
statement_:
    statement ';'
  | error ';' { yyerrok; first_syntax_error = true; }   /* Recover from bad statement */
;
	
statement:
    expression
  | WHEN condition ',' expression ':' expression
  | WHEN error ':' expression { yyerrok; first_syntax_error = true; }
  | SWITCH expression IS case_list OTHERS ARROW statement ';' ENDSWITCH
  | SWITCH expression IS case_list error ';' ENDSWITCH {
        appendError(SYNTAX, "Missing OTHERS clause in SWITCH statement");
        yyerrok;
        first_syntax_error = true;
    }
  | IF condition THEN statement_seq elsif_list_opt ELSE statement_seq ENDIF
  | FOLD direction operator list_choice ENDFOLD
;

elsif_list_opt:
    elsif_list
  | /* empty */
;

elsif_list:
    ELSIF condition THEN statement_seq
  | elsif_list ELSIF condition THEN statement_seq
;

case_list:
    case
  | case_list case
  | error ';' { yyerrok; first_syntax_error = true; }  /* recover malformed case list */
;
	
case:
    CASE INT_LITERAL ARROW statement ';'
  | CASE error ARROW statement ';' { yyerrok; first_syntax_error = true; }
;

condition:
    logical_or
;

logical_or:
    logical_and
  | logical_or OROP logical_and
;

logical_and:
    logical_not
  | logical_and ANDOP logical_not
;

logical_not:
    NOTOP logical_not
  | relational
;

relational:
    relational_expression
  | '(' condition ')'
;

relational_expression:
    expression RELOP expression
;

expression:
    additive
;

direction:
    LEFT
  | RIGHT
;

operator:
    ADDOP
  | MULOP
;

list_choice:
    list
  | IDENTIFIER
;

additive:
    additive ADDOP multiplicative
  | multiplicative
;

multiplicative:
    multiplicative MULOP exponential
  | multiplicative MODOP exponential
  | exponential
;

exponential:
    unary
  | unary EXPOP exponential
;

unary:
    NEGOP unary
  | primary
;
      
term:
	term MULOP primary {$$ = checkArithmetic($1, $3);} |
	primary ;

primary:
    '(' expression ')' { $$ = $2; } |
    INT_LITERAL { $$ = INT_TYPE; } |
    REAL_LITERAL { $$ = REAL_TYPE; } |
    CHAR_LITERAL { $$ = CHAR_TYPE; } |
    IDENTIFIER '(' expression ')' { $$ = find(lists, $1, "List"); } |
    IDENTIFIER { $$ = find(scalars, $1, "Scalar"); }
;


%%

Types find(Symbols<Types>& table, CharPtr identifier, string tableName) {
	Types type;
	if (!table.find(identifier, type)) {
		appendError(UNDECLARED, tableName + " " + identifier);
		return MISMATCH;
	}
	return type;
}

void yyerror(const char* message) {
	appendError(SYNTAX, message);
}

int main(int argc, char *argv[]) {
	firstLine();
	yyparse();
	lastLine();
	return 0;
} 