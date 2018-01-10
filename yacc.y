%{

	#include <stdio.h>
	#include <string.h>
	#include <stdlib.h>
	#include "attribs.h"
	#include "intermediate_code.h"

	extern int yylex();
	extern int yyparse();
	extern char *yytext;
	extern FILE *yyin;
	extern FILE *yyout;
	extern int yylineno;

	int dir;
	int temporales;
	int siginst;

	void init();
	int existe(char *id);
	expresion operacion(expresion e1, expresion e2, char *op);
	expresion numero(int n);
	expresion identificador(char *s);
	condition relacional(expresion e1, expresion e2, char *oprel);
	condition and(condition c1, condition c2);
	condition or(condition c1, condition c2);
	void newLabel(char *s);

	void yyerror(char*);

%}

%union{
	int line;
	int nval;
	double dval;
	float fval;
	char sval[32];
	char ssval[3];
}

%start P

%token INT
%token FLOAT
%token DOUBLE
%token CHAR
%token VOID
%token STRUCT

%token LLA
%token LLC

%token COMA

%token CTA
%token CTC

%token PRA
%token PRC

%token PYC

%token ASIG

%token DPTS

%token PT

%token ID

%token ENTERO
%token DOBLE
%token FLOTANTE

%token FUNCION

%token IF
%token ELSE
%token WHILE
%token DO
%token FOR
%token RETURN
%token SWITCH
%token BREAK
%token PRINT
%token CASE
%token DEFAULT

%token CADENA
%token CARACTER

%token MAS
%token MENOS
%token PROD
%token DIV
%token MOD

%token TRUE
%token FALSE

%token OR
%token AND
%token NOT

%token GRT
%token SMT
%token GREQ
%token SMEQ
%token DIF
%token EQEQ

/* Presedencia y asociatividad de operadores */
%left ASIG
%left OR
%left AND
%left EQEQ DIF
%left GRT SMT GREQ SMEQ
%left MAS MENOS
%left PROD DIV MOD
%left NOT
%nonassoc PRA CTA PRC CTC
%left IF
%left ELSE

%%

/* P -> D F */
P: 	D F
	;

/* D -> T L ; D | epsilon*/
D: 	T L PYC D
	|
	;

/* T -> int | float | double | char | void | struct { D } */
T: 	INT
	| FLOAT
	| DOUBLE
	| CHAR
	| VOID
	| STRUCT LLA D LLC
	;

/* L -> L, id C | id C */
L: 	L COMA ID C
	| ID C
	;

/* C -> [numero] C | epsilon */
C:	CTA ENTERO CTC C
	|
	;

/* func T id (A) { D S } F | epsilon */
F:	FUNCION T ID PRA A PRC LLA D S LLC F
	|
	;

/* A -> G | epsilon */
A:	G
	|
	;

/* G -> G , T id I | T id I */
G:	G COMA T ID I
	| T ID I
	;

/* I -> [] I | epsilon */
I:	CTA CTC I
	|
	;

/* S -> S S | if ( B ) S | if ( B ) S else S | while ( B ) S | do S while ( B ) ; | for ( S ; B ; S ) S | U = E ; | return E ; | return ; | { S } | switch ( E ) { J K } | break ; | print E ; */
S: 	S S
	| IF PRA B PRC S
	| IF PRA B PRC S ELSE S
	| WHILE PRA B PRC S
	| DO S WHILE PRA B PRC PYC
	| FOR PRA S PYC B PYC S PRC S
	| U ASIG E PYC
	| RETURN E PYC
	| RETURN PYC
	| LLA S LLC
	| SWITCH PRA E PRC LLA J K LLC
	| BREAK PYC
	| PRINT E PYC
	;

/* J -> case : numero S J | epsilon */
J:	CASE DPTS ENTERO S J
	|
	;

/* k -> default : S | epsilon */
K:	DEFAULT DPTS S
	|
	;

/* U -> id | M | id . id */
U:	ID
	| M
	| ID PT ID
	;

/* M -> id [ E ] | M [ E ] */
M:	ID CTA E CTC
	| M CTA E CTC
	;

/* E -> E + E | E - E | E * E | E / E | E % E | cadena | numero | caracter | id ( H ) */
E:	E MAS E
	| E MENOS E
	| E PROD E
	| E DIV E
	| E MOD E
	| U
	| CADENA
	| ENTERO
	| DOBLE
	| FLOTANTE
	| CARACTER
	| ID PRA H PRC
	;

/* H -> H , E | E */
H:	H COMA E
	| E
	;

/* B -> B || B | B && B | ! B | ( B ) | E R E | true | false */
B: 	B OR B
	| B AND B
	| NOT B
	| PRA B PRC
	| E R E
	| TRUE
	| FALSE
	;

/* R -> < | > | >= | <= | != | == */
R:	SMT
	| GRT
	| GREQ
	| SMEQ
	| DIF
	| EQEQ
	;

%%

void yyerror(char *s){
	(void) s;
	fprintf(stderr, "Error Sintactico en la linea %d: '%s'\n", yylineno, yytext);
}

int main(int argc, char *argv[]){
	yyin = fopen(argv[1], "r");
	yyparse();
	fclose(yyin);
	return 0;
}