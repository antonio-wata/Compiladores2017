%{

	#include <stdio.h>
	#include <string.h>
	#include <stdlib.h>
	#include "yacc.tab.h"

%}

%option noyywrap
%option yylineno

id [a-zA-Z][a-zA-Z0-9_]*
int	[0-9]+
double [0-9]+("."[0-9]+)?
float [0-9]+("."[0-9]+)?[fF]
char '[a-zA-z0-9]'
cadena \"[a-zA-Z0-9]*\"
comment [/][*][^*]*[*]+([^*/][^*]*[*]+)*[/]
uncomment [/][*]

%%

{uncomment}		{ printf("Error comentario mal declarado: %s\n", yytext); }

{comment}		{}

{int}			{ yylval.line = yylineno; return NUMERO; }

{double}		{ yylval.line = yylineno; return NUMERO; }

{float}			{ yylval.line = yylineno; return NUMERO; }

{char}			{ yylval.line = yylineno; return CARACTER; }

{cadena}		{ yylval.line = yylineno; return CADENA; }

int				{ yylval.line = yylineno; return INT; }

double			{ yylval.line = yylineno; return DOUBLE; }

float			{ yylval.line = yylineno; return FLOAT; }

char			{ yylval.line = yylineno; return CHAR; }

void			{ yylval.line = yylineno; return VOID; }

struct			{ yylval.line = yylineno; return STRUCT; }

func			{ yylval.line = yylineno; return FUNCION; }

if 				{ yylval.line = yylineno; return IF; }

else 			{ yylval.line = yylineno; return ELSE; }

while			{ yylval.line = yylineno; return WHILE; }

do 				{ yylval.line = yylineno; return DO; }

for				{ yylval.line = yylineno; return FOR; }

return			{ yylval.line = yylineno; return RETURN; }

switch			{ yylval.line = yylineno; return SWITCH; }

case			{ yylval.line = yylineno; return CASE; }

default			{ yylval.line = yylineno; return DEFAULT; }

break			{ yylval.line = yylineno; return BREAK; }

print 			{ yylval.line = yylineno; return PRINT; }

true 			{ yylval.line = yylineno; return TRUE; }

false			{ yylval.line = yylineno; return FALSE; }

{id}			{ yylval.line = yylineno; return ID; }

"+"				{ yylval.line = yylineno; return MAS; }

"-"				{ yylval.line = yylineno; return MENOS; }

"*"				{ yylval.line = yylineno; return PROD; }

"/"				{ yylval.line = yylineno; return DIV; }

"%"				{ yylval.line = yylineno; return PORC; }

"(" 			{ yylval.line = yylineno; return PRA; }

")" 			{ yylval.line = yylineno; return PRC; }

"["				{ yylval.line = yylineno; return CTA; }

"]"				{ yylval.line = yylineno; return CTC; }

"{"				{ yylval.line = yylineno; return LLA; }	

"}"				{ yylval.line = yylineno; return LLC; }	

"="				{ yylval.line = yylineno; return EQ; }	

":"				{ yylval.line = yylineno; return DPTS; }	

";"				{ yylval.line = yylineno; return PYC; }	

","				{ yylval.line = yylineno; return COMA; }

"!"				{ yylval.line = yylineno; return NOT; }	

"||"			{ yylval.line = yylineno; return OR; }	

"&&"			{ yylval.line = yylineno; return AND; }	

"<"				{ yylval.line = yylineno; return SMT; }

">"				{ yylval.line = yylineno; return GRT; }

">="			{ yylval.line = yylineno; return GREQ; }

"<="			{ yylval.line = yylineno; return SMEQ; }

"!="			{ yylval.line = yylineno; return DIF; }

"=="			{ yylval.line = yylineno; return EQEQ; }

[ \n\t\r]		{}

.				{ printf("Error lexico en la linea: %d\n", yylineno);}

%%

