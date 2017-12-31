%{

	#include <stdio.h>
	#include <string.h>
	#include <stdlib.h>

	// Variable que llevara el conteo de las lineas.
	int linea = 1;
	// Variable que llevara el conteo de las columnas.
	int col = 1;

%}

%option noyywrap

id [a-zA-Z][a-zA-Z0-9_]*
int	[0-9]+
double [0-9]+\.[0-9]+
float [0-9]+\.[0-9]+[fF]

%%

{int}			{ printf("Lei un entero: %s\n", yytext); col++; }

{double}		{ printf("Lei un doble: %s\n", yytext); col++; }

{float}			{ printf("Lei un flotante: %s\n", yytext); col++; }

%%

// Esto se tiene que quitar, el main va en el archivo yacc.
int main(int argc, char* argv[]){
	yyin = fopen(argv[1], "r");
	yylex();
	fclose(yyin);
}