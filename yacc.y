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

	// Variable que llevara el manejo de direcciones.
	int dir;
	// Variable que llevara la cuenta de variables temporales.
	int temporales;
	// Variable que indica la siguiente instruccion.
	int siginst;
	// Variable que guarda el tipo heredado.
	int global_tipo;
	// Variable que guardara la dimension heredada.
	int global_dim;
	// Variable que llevara el numero de parametros que tiene una funcion.
	int num_args;
	// Lista que guarda los tipos de los parametros.
	int* list_args;

	void init();
	int busca_main();
	int existe_en_alcance(char*);
	int existe_globalmnete(char*);
	int max(int, int);
	void new_Temp(char*);
	expresion operacion(expresion, expresion, char*);
	expresion numero_entero(int);
	expresion numero_flotante(float);
	expresion numero_doble(double);
	expresion caracter(char);
	condition relacional(expresion, expresion, char*);
	condition and(condition, condition);
	condition or(condition, condition);

	expresion identificador(char *s);
	void newLabel(char *s);

	void yyerror(char*);

%}

%union{
	int line;
	char* sval;
	type tval;
	expresion eval;
	num num;
	args_list args_list;
	condition cond;
	sentence sent;
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
%left<sval> EQEQ DIF
%left<sval> GRT SMT GREQ SMEQ
%left<sval> MAS MENOS
%left<sval> PROD DIV MOD
%left NOT
%nonassoc PRA CTA PRC CTC
%left IF
%left ELSE

/* Tipos */
%type<tval> T D C I
%type<sval> R
%type<eval> E
%type<args_list> A G
%type<cond> B
%type<sent> S

%%

/* P -> D F */
P: 	{ init(); } D F {
		if(busca_main() == -1){
			yyerror("Falta definir funcion principal.");
			exit(0);
		}
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
	| STRUCT {
		create_symbols_table();
		create_types_table();
	} LLA D LLC { 
		ttype t;
		t.type = "struct";
		t.dim = 0;
		t.base = -1;
		$$.type = insert_type(t);
		$$.dim = dir;
		delete_symbols_table();
		delete_types_table();
	}
	;

/* L -> L, id C | id C */
L: 	L COMA ID C { 
		if(existe_en_alcance($3) == -1){
			symbol sym;
			sym.id = $3;
			sym.dir = dir;
			sym.type = $4.type;
			sym.var = "variable";
			sym.num_args = 0;
			sym.list_types = malloc(sizeof(int) * 100);
			insert_symbol(sym);
			dir += $4.dim;
		} else{ yyerror("Identificadores duplicados en el mismo alcance"); exit(0); }
	}
	| ID C {
		if(existe_en_alcance($1) == -1){
			symbol sym;
			sym.id = $1;
			sym.dir = dir;
			sym.type = $2.type;
			sym.var = "variable";
			sym.num_args = 0;
			sym.list_types = malloc(sizeof(int) * 100);
			insert_symbol(sym);
			dir += $2.dim;
		} else{ yyerror("Identificadores duplicados en el mismo alcance"); exit(0); }
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
		} else { yyerror("La dimension del arreglo debe ser entera"); exit(0); }
	}
	| { 
		if(global_tipo != 0){
			$$.type = global_tipo;
			$$.dim = global_dim;
		} else { yyerror("No se pueden declarar variables de tipo void"); exit(0); }
	}
	;

/* func T id (A) { D S } F | epsilon */
/* Debemos reiniciar el numero de args y la lista en cada funcion. *
/* Crear una nueva tabla de simbolos y de tipos. */
F:	FUNCION T ID {
		num_args = 0;
		list_args = malloc(sizeof(int) * 100);
		create_symbols_table();
		create_types_table();
	}
	PRA A PRC LLA D S LLC {
		if(existe_globalmente($3) == -1){
			//if(strcpm($2.type, $10.return) == 0){
				ttype t;
				char* tipo = malloc(sizeof(char) * 10);
				sprintf(tipo, "%d", $2.type);
				t.type = tipo;
				t.base = -1;
				t.dim = 0;

				symbol sym;
				sym.id = $3;
				sym.dir = -1;
				sym.type = $2.type; // Falta agregar el tipo t.
				sym.var = "funcion";
				sym.num_args = $6.total;
				sym.list_types = $6.args;
				insert_global_symbol(sym);
			//} else { yyerror("El valor de retorno no coincide"); exit(0); }
		} else { yyerror("Funcion declarada anteriormente"); exit(0); }
		delete_symbols_table();
		delete_types_table();
	}
	F
	| {}
	;

/* A -> G | epsilon */
A:	G { $$ = $1; }
	| { $$.total = 0; }
	;

/* G -> G , T id I | T id I */
G:	G COMA T {
		global_tipo = $3.type;
		global_dim = $3.dim;
	}
	ID I {
		if(existe_en_alcance($5) == -1){
			symbol sym;
			sym.id = $5;
			sym.dir = dir;
			sym.type = $6.type;
			sym.var = "parametro";
			sym.num_args = 0;
			insert_symbol(sym);
			dir += $6.dim;
			*(list_args + num_args) = $6.type;
			num_args++;
		} else { yyerror("Parametro duplicado en funcion"); exit(0); }
	}
	| T {
		global_tipo = $1.type;
		global_dim = $1.dim;
	}
	ID I {
		if(existe_en_alcance($3) == -1){
			symbol sym;
			sym.id = $3;
			sym.dir = dir;
			sym.type = $4.type;
			sym.var = "parametro";
			sym.num_args = 0;
			insert_symbol(sym);
			dir += $4.dim;
			*(list_args + num_args) = $4.type;
			num_args++;
			$$.total = num_args;
			$$.args = list_args;
		} else { yyerror("Parametro duplicado en funcion"); exit(0); }
	}
	;

/* I -> [] I | epsilon */
I:	CTA CTC I {
		ttype t;
		t.type = "array";
		t.dim = $3.dim;
		t.base = $3.type;
		$$.type = insert_type(t);
		$$.dim = $3.dim;
	}
	| {
		if(global_tipo != 0){
			$$.type = global_tipo;
			$$.dim = global_dim;
		} else { yyerror("No se pueden declarar variables de tipo void"); exit(0); }
	}
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
B: 	B OR B { $$ = or($1, $3); }
	| B AND B { $$ = and($1, $3); }
	| NOT B
	| PRA B PRC { $$ = $2; }
	| E R E
	| TRUE
	| FALSE
	;

/* R -> < | > | >= | <= | != | == */
R:	SMT { $$ = $1; }
	| GRT { $$ = $1; }
	| GREQ { $$ = $1; }
	| SMEQ { $$ = $1; }
	| DIF { $$ = $1; }
	| EQEQ { $$ = $1; }
	;

%%

/* Funcion encargada de iniciar las variables, la tabla de simbolos,  
   la pila de simbolos y la pila de tipos. */
void init(){
	dir = 0;
	temporales = 0;
	num_args = 0;
	list_args = malloc(sizeof(int) * 100);
	init_symbols();
	init_types();
}

/* Funcion encargada de buscar que exista la funcion principal. */
int busca_main(){
	return search_global("main");
}

/* Funcion encarda de decirnos si un identificador ya fue declarado en
   el mismo alcance. */
int existe_en_alcance(char* id){
	return search_scope(id);
}

/* Funcion encargada de decirnos si un identificador ya fue declarado globalmente. */
int existe_globalmente(char* id){
	return search_global(id);
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

/* Funcion encargada de generar el codigo intermedio para una operacion relacional. */
condition relacional(expresion e1, expresion e2, char* oprel){
	condition c;
	char* arg1 = malloc(sizeof(char) * 50);
	sprintf(arg1, "%s %s %s", e1.dir, oprel, e2.dir);
	siginst = gen_code("if", arg1, "goto", "");
	c.ltrue = create_list(siginst);
	siginst = gen_code("goto", "", "", "");
	c.lfalse = create_list(siginst);
	if(e1.first != -1)
		c.first = e1.first;
	else if(e2.first != -1)
		c.first = e2.first;
	else
		c.first = siginst - 1;
	return c;
}

/* Funcion encargada de tomar un operacion OR y guardarla como condicion. */
condition or(condition c1, condition c2){
	condition c;
	backpatch(c1.lfalse, c2.first);
	c.ltrue = merge(c1.ltrue, c2.ltrue);
	c.lfalse = c2.lfalse;
	return c;
}

/* Funcion encargada de tomar un operacion AND y guardarla como condicion. */
condition and(condition c1, condition c2){
    condition c;
    backpatch(c1.ltrue, c2.first);
    c.ltrue= c2.ltrue;
    c.lfalse = merge(c1.lfalse,c2.lfalse);
    return c;
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