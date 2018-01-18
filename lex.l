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
char '[^\']'
cadena \"[^\"]*\"

%x com1
%x com2


%%

{int}				{ yylval.line = yylineno; yylval.num.ival = atoi(yytext); return ENTERO; }

{double}			{ yylval.line = yylineno; yylval.num.dval = atof(yytext); return DOBLE; }

{float}				{ yylval.line = yylineno; yylval.num.fval = atof(yytext); return FLOTANTE; }

{char}				{ yylval.line = yylineno; return CARACTER; }

{cadena}			{ yylval.line = yylineno; return CADENA; }

int					{ yylval.line = yylineno; return INT; }

double				{ yylval.line = yylineno; return DOUBLE; }

float				{ yylval.line = yylineno; return FLOAT; }

char				{ yylval.line = yylineno; return CHAR; }

void				{ yylval.line = yylineno; return VOID; }

struct				{ yylval.line = yylineno; return STRUCT; }

func				{ yylval.line = yylineno; return FUNCION; }

if 					{ yylval.line = yylineno; return IF; }

else 				{ yylval.line = yylineno; return ELSE; }

while				{ yylval.line = yylineno; return WHILE; }

do 					{ yylval.line = yylineno; return DO; }

for					{ yylval.line = yylineno; return FOR; }

return				{ yylval.line = yylineno; return RETURN; }

switch				{ yylval.line = yylineno; return SWITCH; }

case				{ yylval.line = yylineno; return CASE; }

default				{ yylval.line = yylineno; return DEFAULT; }

break				{ yylval.line = yylineno; return BREAK; }

print 				{ yylval.line = yylineno; return PRINT; }

true 				{ yylval.line = yylineno; return TRUE; }

false				{ yylval.line = yylineno; return FALSE; }

{id}				{ yylval.line = yylineno; yylval.sval = strdup(yytext); return ID; }

"+"					{ yylval.line = yylineno; yylval.sval = strdup(yytext); return MAS; }

"-"					{ yylval.line = yylineno; yylval.sval = strdup(yytext); return MENOS; }

"*"					{ yylval.line = yylineno; yylval.sval = strdup(yytext); return PROD; }

"/"					{ yylval.line = yylineno; yylval.sval = strdup(yytext); return DIV; }

"%"					{ yylval.line = yylineno; yylval.sval = strdup(yytext); return MOD; }

"(" 				{ yylval.line = yylineno; return PRA; }

")" 				{ yylval.line = yylineno; return PRC; }

"["					{ yylval.line = yylineno; return CTA; }

"]"					{ yylval.line = yylineno; return CTC; }

"{"					{ yylval.line = yylineno; return LLA; }	

"}"					{ yylval.line = yylineno; return LLC; }	

"="					{ yylval.line = yylineno; return ASIG; }	

":"					{ yylval.line = yylineno; return DPTS; }	

";"					{ yylval.line = yylineno; return PYC; }	

","					{ yylval.line = yylineno; return COMA; }

"!"					{ yylval.line = yylineno; return NOT; }	

"||"				{ yylval.line = yylineno; return OR; }	

"&&"				{ yylval.line = yylineno; return AND; }	

"<"					{ yylval.line = yylineno; yylval.sval = strdup(yytext); return SMT; }

">"					{ yylval.line = yylineno; yylval.sval = strdup(yytext); return GRT; }

">="				{ yylval.line = yylineno; yylval.sval = strdup(yytext); return GREQ; }

"<="				{ yylval.line = yylineno; yylval.sval = strdup(yytext); return SMEQ; }

"!="				{ yylval.line = yylineno; yylval.sval = strdup(yytext); return DIF; }

"=="				{ yylval.line = yylineno; yylval.sval = strdup(yytext); return EQEQ; }

[ \n\t\r]			{}

"/*"				{ BEGIN(com1); }

<com1>\n    		{ yylval.line = yylineno; }

<com1>[^*\n]*		{}

<com1>"*"+[^*/\n]*	{}

<com1>"*"+"/"		{ BEGIN(INITIAL); }

"//"				{ BEGIN(com2); }

<com2>[^*\n]*		{}

<com2>\n  			{ BEGIN(INITIAL); }

.					{ printf("Error lexico en la linea: %d\n", yylineno);}

%%

