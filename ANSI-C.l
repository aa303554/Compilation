%{
#include <stdio.h>
#include "y.tab.h"
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


/********* ANALYSE **********/
/* Important ! Analyser les */
/* mots réservés avant les  */
/* identificateurs etc...   */
/****************************/
%%
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

{INTEGER}		yyval.value = yytext; return CONSTANTE;
{REAL}			yyval.value = yytext; return CONSTANTE;
{HEXA}			yyval.value = yytext; return CONSTANTE;
{EXP}			yyval.value = yytext; return CONSTANTE;

{INT}			return INT;
{VOID}			return VOID;

{IDENTIFICATEUR} 	yyval.ident = yytext; return IDENTIFICATEUR;

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
{EQ}			return EQ;

.			return yytext[0]; /* Echec de reconnaissance -> erreur OU caractères spécial (";" "," "{" "}" etc ...) */
%%

void yyerror(char const *s){
	fprintf(stderr, "%s\n", s);
}
