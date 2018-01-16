%{

	#include <stdio.h>
	#include <string.h>
	#include <stdlib.h>
	#include "attribs.h"
	#include "symbols.h"
	#include "types.h"
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
	int existe_en_alcance(char*);
	int max(int, int);
	void new_Temp(char*);
	expresion operacion(expresion, expresion, char*);
	expresion numero_entero(int);
	expresion numero_flotante(float);
	expresion numero_doble(double);
	expresion caracter(char);

	expresion identificador(char *s);
	condition relacional(expresion e1, expresion e2, char *oprel);
	condition and(condition c1, condition c2);
	condition or(condition c1, condition c2);
	void newLabel(char *s);

	void yyerror(char*);

%}

%union{
	int line;
	char sval[40];
	char opval[4];
	type tval;
	expresion eval;
	num num;
	args_list args_list;
}

%start P

%token<sval> ID
%token<num> ENTERO
%token<num> DOBLE
%token<num> FLOTANTE
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
%left<opval> EQEQ DIF
%left<opval> GRT SMT GREQ SMEQ
%left<opval> MAS MENOS
%left<opval> PROD DIV MOD
%left NOT
%nonassoc PRA CTA PRC CTC
%left IF
%left ELSE

/* Tipos */
%type<tval> T D C
%type<opval> R
%type<eval> E
%type<args_list> A G

%%

/* P -> D F */
P: 	{ init(); } D F { 
		print_symbols_table(); 
		print_types_table(); 
		print_code(); 
	}
	;


/* D -> T L ; D | epsilon*/
D: 	T { global_tipo = $1.type; global_dim = $1.dim; } L PYC D
	| {}
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
			printf("%s\n", $1);
			sym.dir = dir;
			sym.type = $2.type;
			sym.var = "variable";
			insert_symbol(sym);
			dir += $2.dim;
		} else yyerror("Identificadores duplicados en el mismo alcance");
	}
	;

/* C -> [numero] C | epsilon */
C:	CTA ENTERO CTC C {
		ttype t;
		if($2.type == 1){
			t.type = "array";
			t.dim = $2.ival;
			t.base = $4.type;
			$$.type = insert_type(t);
			$$.dim = $4.dim * $2.ival;
		} else yyerror("La dimension del arreglo debe ser entera");
	}
	| { 
		if(global_tipo != 0){
			$$.type = global_tipo;
			$$.dim = global_dim;
		} else yyerror("No se pueden declarar variables de tipo void");
	}
	;

/* func T id (A) { D S } F | epsilon */
F:	FUNCION T ID PRA A PRC LLA D S LLC F
	|
	;

/* A -> G | epsilon */
A:	G { $$ = $1; }
	| { $$.total = -1; }
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
E:	E MAS E { $$ = operacion($1, $3, $2); }
	| E MENOS E { $$ = operacion($1, $3, $2); }
	| E PROD E { $$ = operacion($1, $3, $2); }
	| E DIV E { $$ = operacion($1, $3, $2); }
	| E MOD E { $$ = operacion($1, $3, $2); }
	| U
	| CADENA
	| ENTERO { $$ = numero_entero($1.ival); }
	| DOBLE { $$ = numero_doble($1.dval); }
	| FLOTANTE { $$ = numero_flotante($1.fval); }
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
R:	SMT { strcpy($$, $1); }
	| GRT { strcpy($$, $1); }
	| GREQ { strcpy($$, $1); }
	| SMEQ { strcpy($$, $1); }
	| DIF { strcpy($$, $1); }
	| EQEQ { strcpy($$, $1); }
	;

%%

/* Funcion encargada de iniciar las variables, la tabla de simbolos,  
   la pila de simbolos y la pila de tipos. */
void init(){
	dir = 0;
	temporales = 0;
	init_symbols();
	init_types();
}

/* Funcion encarda de decirnos si un identificador ya fue declarado en
   el mismo alcance. */
int existe_en_alcance(char* id){
	return search_scope(id);
}

/* Funcion encargada de revisar los tipos, si son correctos toma el de
   mayor rango, e.o.c manda un mensaje de error. 
   void = 0, int = 1, float = 2, double = 3, char = 4, struct = 5*/
int max(int t1, int t2){
	if(t1 == t2) return t1;
	else if (t1 == 1 && t2 == 2) return t1;
	else if (t1 == 2 && t2 == 1) return t2;
	else if (t1 == 1 && t2 == 3) return t1;
	else if (t1 == 3 && t2 == 1) return t2;
	else if (t1 == 1 && t2 == 4) return t1;
	else if (t1 == 4 && t1 == 1) return t2;
	else if (t1 == 3 && t1 == 2) return t1;
	else if (t1 == 2 && t2 == 3) return t2;
	else{ yyerror("Tipos no compatibles"); return -1; }
}

/* Funcion encargada de generar una nueva variable temporal. */
void new_Temp(char* dir){
	char* temp;
	char* num;
	strcpy(temp, "t");
	sprintf(num, "%d", temporales);
	temporales++;
	strcat(temp, num);
	strcpy(dir, temp);
}

/* Funcion encargada de generar el codigo para las operaciones de expresiones. */
expresion operacion(expresion e1, expresion e2, char* op){
	expresion new_exp;
	new_exp.type = max(e1.type, e2.type);
	new_Temp(new_exp.dir);
	siginst = gen_code(op, e1.dir, e2.dir, new_exp.dir);
	if(e1.first != -1)
		new_exp.first = e1.first;
	else{
		if(e2.first != -1)
			new_exp.first = e2.first;
		else
			new_exp.first = siginst;
	}
	return new_exp;
}

/* Funcion encargada de tomar un numero entero y guardarlo como expresion. */
expresion numero_entero(int num){
	expresion new_exp;
	sprintf(new_exp.dir, "%d", num);
	new_exp.type = 1;
	new_exp.first = -1;
	return new_exp;
}

/* Funcion encargada de tomar un numero flotante y guardarlo como expresion. */
expresion numero_flotante(float num){
	expresion new_exp;
	sprintf(new_exp.dir, "%.3f", num);
	new_exp.type = 2;
	new_exp.first = -1;
	return new_exp;
}

/* Funcion encargada de tomar un numero doble y guardarlo como expresion. */
expresion numero_doble(double num){
	expresion new_exp;
	sprintf(new_exp.dir, "%.3f", num);
	new_exp.type = 3;
	new_exp.first = -1;
	return new_exp;
}

/* Funcion encargada de tomar un caracter y guardarlo como expresion. */
expresion caracter(char c){
	expresion new_exp;
	sprintf(new_exp.dir, "%c", c);
	new_exp.type = 4;
	new_exp.first = -1;
	return new_exp;
}

/* Funcion encargada de manejar los errores. */
void yyerror(char *s){
	(void) s;
	fprintf(stderr, "Error: %s. En la linea: %d\n", s, yylineno);
}

/* Funcion principal. */
int main(int argc, char *argv[]){
	yyin = fopen(argv[1], "r");
	yyparse();
	fclose(yyin);
	return 0;
}