%{

	#include <stdio.h>
	#include <string.h>
	#include <stdlib.h>

	// Variable que llevara el conteo de las lineas.
	int linea = 1;

%}

%option noyywrap
%option yylineno

id [a-zA-Z][a-zA-Z0-9_]*
int	[0-9]+
double [0-9]+("."[0-9]+)?
float [0-9]+("."[0-9]+)?[fF]
char '[a-zA-z]'

%%

{int}			{ printf("Lei un entero: %s\n", yytext); }

{double}		{ printf("Lei un doble: %s\n", yytext); }

{float}			{ printf("Lei un flotante: %s\n", yytext); }

{char}			{ printf("Lei un char: %s\n", yytext); }

int				{ printf("Tipo: %s\n", yytext); }

double			{ printf("Tipo: %s\n", yytext); }

float			{ printf("Tipo: %s\n", yytext); }

char			{ printf("Tipo: %s\n", yytext); }

void			{ printf("Tipo: %s\n", yytext); }

struct			{ printf("Tipo: %s\n", yytext); }

func			{ printf("Empieza una funcion\n"); }

if 				{ printf("Empieza un if\n"); }

else 			{ printf("Empieza un else\n"); }

while			{ printf("Empieza un while\n"); }

do 				{ printf("Empieza un do-while\n"); }

for				{ printf("Empieza un for\n"); }

return			{ printf("Regresamos algo\n"); }

switch			{ printf("Empieza un switch\n"); }

case			{ printf("Empieza un case\n"); }

default			{ printf("Empieza un default\n"); }

break			{ printf("Termina un case\n"); }

print 			{ printf("Funcion print\n"); }

true 			{ printf("TRUE\n"); }

false			{ printf("FALSE\n"); }

{id}			{ printf("Nuevo identificador: %s\n", yytext); }

"+"				{ printf("Operador: %s\n", yytext); }

"-"				{ printf("Operador: %s\n", yytext); }

"*"				{ printf("Operador: %s\n", yytext); }

"/"				{ printf("Operador: %s\n", yytext); }

"%"				{ printf("Operador: %s\n", yytext); }

"(" 			{ printf("%s\n", yytext); }

")" 			{ printf("%s\n", yytext); }

"["				{ printf("%s\n", yytext); }

"]"				{ printf("%s\n", yytext); }

"{"				{ printf("%s\n", yytext); }	

"}"				{ printf("%s\n", yytext); }	

"="				{ printf("%s\n", yytext); }	

":"				{ printf("%s\n", yytext); }	

";"				{ printf("%s\n", yytext); }	

","				{ printf("%s\n", yytext); }

"!"				{ printf("%s\n", yytext); }	

"||"			{ printf("%s\n", yytext); }	

"&&"			{ printf("%s\n", yytext); }	

"<"				{ printf("%s\n", yytext); }

">"				{ printf("%s\n", yytext); }

">="			{ printf("%s\n", yytext); }

"<="			{ printf("%s\n", yytext); }

"!="			{ printf("%s\n", yytext); }

"=="			{ printf("%s\n", yytext); }

[ \t\r]			{}

[\n]			{ linea++; }

.				{ printf("Error lexico en la linea: %i\n", linea);}

%%

// Esto se tiene que quitar, el main va en el archivo yacc.
int main(int argc, char* argv[]){
	yyin = fopen(argv[1], "r");
	yylex();
	fclose(yyin);
}