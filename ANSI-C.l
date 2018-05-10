%{
#include <stdlib.h>
#include "y.tab.h"

void save_ident(char* ident){
	char* p = calloc(strlen(ident)+1, sizeof(char));
	strcpy(p, ident);
	yylval.ident = p;
}
void save_value(char* value){
	char* p = calloc(strlen(value)+1, sizeof(char));
	strcpy(p, value);
	yylval.value = p;
}

%}

%option noyywrap

/* Tous les nombres */
DIGIT		[0-9]
HEXA		0[xX][a-fA-F0-9]+
EXP		[Ee][+-]?{DIGIT}+
INTEGER		{DIGIT}+
REAL		{DIGIT}+"."{DIGIT}+

/* Types */
INT		"int"
FLOAT		"float"
VOID		"void"

/* Noms de fonctions, variables */
LITTERAL	[a-zA-Z_]
IDENTIFICATEUR	{LITTERAL}+({LITTERAL}|{DIGIT})*

/* Opérations */
PLUS		"+"
MOINS		"-"
MUL		"*"
DIV		"/"
LSHIFT		"<<"
RSHIFT		">>"
BAND		"&"
BOR		"|"
NOT		"!"
LAND		"&&"
LOR		"||"

/* Opérations spéciales */
ADD1		"++"
MIN1		"--"

/* Comparaisons */
LT		"<"
GT		">"
LEQ		"<="
GEQ		">="
EQ		"=="
NEQ		"!="

/* Itérations */
FOR		"for"
WHILE		"while"

/* Sélections */
IF		"if"
THEN		"then"
ELSE		"else"
SWITCH		"switch"
CASE		"case"
DEFAULT		"default"

/* Sauts */
RETURN		"return"
BREAK		"break"
EXTERN		"extern"

/* Espaces, saut de lignes etc... */
WHITESPACE	[ \t\v\n\f]
COMMENTAIRES	("/"+"\*"+(.[^\*/]|{WHITESPACE})*"\*"+"/"+|"//".*\n)

/********* ANALYSE **********/
/* Important ! Analyser les */
/* mots réservés avant les  */
/* identificateurs etc...   */
/****************************/

%%

{COMMENTAIRES}		
{WHITESPACE}		


{FOR}			return FOR;
{WHILE}			return WHILE;

{IF}			return IF;
{THEN}			return THEN;
{ELSE}			return ELSE;
{SWITCH}		return SWITCH;
{CASE}			return CASE;
{DEFAULT}		return DEFAULT;

{RETURN}		return RETURN;
{BREAK}			return BREAK;
{EXTERN}		return EXTERN;

{INTEGER}		save_value(yytext); return CONSTANTE;
{REAL}			return CONSTANTE;
{HEXA}			return CONSTANTE;
{EXP}			return CONSTANTE;

{INT}			return INT;
{VOID}			return VOID;

{IDENTIFICATEUR} 	save_ident(yytext); return IDENTIFICATEUR;

{PLUS}			return PLUS;
{MOINS}			return MOINS;
{MUL}			return MUL;
{DIV}			return DIV;
{LSHIFT}		return LSHIFT;
{RSHIFT}		return RSHIFT;
{NOT}			return NOT;
{BAND}			return BAND;
{BOR}			return BOR;
{LAND}			return LAND;
{LOR}			return LOR;

{LT}			return LT;
{GT}			return GT;
{LEQ}			return LEQ;
{GEQ}			return GEQ;
{EQ}			return EQ;
{NEQ}			return NEQ;

.			return yytext[0]; /* Echec de reconnaissance -> erreur OU caractères spécial (";" "," "{" "}" etc ...) */
%%
