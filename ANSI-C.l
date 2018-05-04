%{
#include <stdio.h>
#include "y.tab.h"
%}

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
EQUAL		"=="

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

{INTEGER}		return CONSTANTE;
{REAL}			return CONSTANTE;
{HEXA}			return CONSTANTE;
{EXP}			return CONSTANTE;

{INT}			return INT;
{FLOAT}			return FLOAT;
{VOID}			return VOID;

{IDENTIFICATEUR} 	return IDENTIFICATEUR;

{PLUS}			return PLUS;
{MOINS}			return MOINS;
{MUL}			return MUL;
{DIV}			return DIV;
{LSHIFT}		return LSHIFT;
{RSHIFT}		return RSHIFT;
{NOT}			return NOT;
{AND}			return AND;
{OR}			return OR;
{EQUAL}			return EQUAL;
{ADD1}			return ADD1;
{MIN1}			return MIN1;

{WHITESPACE}		return WHITESPACE;

.			return yytext[0]; /* Echec de reconnaissance -> erreur OU caractères spécial (";" "," "{" "}" etc ...) */
%%
