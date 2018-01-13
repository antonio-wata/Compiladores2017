%{

	#include <stdio.h>
	#include <string.h>
	#include <stdlib.h>
	#include "attribs.h"
	#include "symbols.h"
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
	int global_tipo;
	int global_dim;

	void init();
	int existe(char *id);
	int existe_en_alcance(char*id);
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
	type tval;
	array tarrval;
}

%start P

%token<sval> ID
%token<nval> ENTERO
%token<dval> DOBLE
%token<fval> FLOTANTE
%token INT
%token FLOAT
%token DOUBLE
%token CHAR
%token VOID
%token STRUCT
%token LLA
%token LLC
%token COMA
%token PYC
%token DPTS
%token PT
%token FUNCION
%token IF
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
%token TRUE
%token FALSE

/* Presedencia y asociatividad de operadores */
%left ASIG
%left OR
%left AND
%left<ssval> EQEQ DIF
%left<ssval> GRT SMT GREQ SMEQ
%left<ssval> MAS MENOS
%left<ssval> PROD DIV MOD
%left NOT
%nonassoc PRA CTA PRC CTC
%left IF
%left ELSE

/* Tipos */
%type<tval> T
%type<tarrval> C

%%

/* P -> D F */
P: 	{ init(); } D F { print_table(); print_code();}
	;


/* D -> T L ; D | epsilon*/
D: 	T { global_tipo = $1.type; global_dim = $1.dim; } L PYC D
	|
	;

/* T -> int | float | double | char | void | struct { D } */
T: 	INT { $$.type = 1; $$.dim = 2; }
	| FLOAT { $$.type = 2; $$.dim = 4; }
	| DOUBLE { $$.type = 3; $$.dim = 8; }
	| CHAR { $$.type = 4; $$.dim = 1; }
	| VOID { $$.type = 0; $$.dim = 0; }
	| STRUCT LLA D LLC { $$.type = 5; $$.dim = -1; }
	;

/* L -> L, id C | id C */
L: 	L COMA ID C { 
		if(existe_en_alcance($3) == -1){
			symbol sym;
			sym.id = $3;
			sym.dir = dir;
			sym.type = $4.type;
			sym.var = "variable";
			insert_symbol(sym);
			dir += $4.dim;
		} else yyerror("Identificadores duplicados en el mismo alcance");
	}
	| ID C {
		if(existe_en_alcance($1) == -1){
			symbol sym;
			sym.id = $1;
			sym.dir = dir;
			sym.type = $2.type;
			sym.var = "variable";
			insert_symbol(sym);
			dir += $2.dim;
		} else yyerror("Identificadores duplicados en el mismo alcance");
	}
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

void init(){
	dir = 0;
	temporales = 0;
	init_table();
}

int existe_en_alcance(char* id){
	return search_scope(id);
}

void yyerror(char *s){
	(void) s;
	fprintf(stderr, "Error Sintactico: %s. En la linea: %d\n", s, yylineno);
}

int main(int argc, char *argv[]){
	yyin = fopen(argv[1], "r");
	yyparse();
	fclose(yyin);
	return 0;
}