%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
extern char* yytext;

struct Loop{
	int length;
	int size;
	char* code;
	char* affectation1;
	char* condition;
	char* affectation2;
	char* instructions;
	char* if_label;
	char* else_label;
} loop;

%}

%union{
	char* value;
	char* ident;
	struct Block{
		int length;		//Longueur du code
		int size;		//Taille du tableau code
		char* code;		//Tableau du code
		char* value;		//Valeur finale du bloc (chiffre ou variable) pour les expressions.
	} block;
	char* string;
}

%{
#include "block.h"
#include "loop.h"
%}

%token <ident> IDENTIFICATEUR 
%token <value> CONSTANTE
%token <string> VOID INT FOR WHILE IF ELSE SWITCH CASE DEFAULT
%token <string> BREAK RETURN PLUS MOINS MUL DIV LSHIFT RSHIFT BAND BOR LAND LOR LT GT 
%token <string> GEQ LEQ EQ NEQ NOT EXTERN

%type <string> affectation condition instruction selection iteration saut bloc appel variable
%type <string> binary_op binary_comp binary_rel
%type <string> liste_expressions expression programme fonction liste_fonctions liste_instructions
%type <string> declarateur liste_declarations type declaration liste_declarateurs
%type <string> liste_parms parm

%left PLUS MOINS
%left MUL DIV
%left LSHIFT RSHIFT
%left BOR BAND
%left LAND LOR
%nonassoc THEN
%nonassoc ELSE
%left OP
%left REL
%start programme
%%
programme	:	
		liste_declarations liste_fonctions	{char* p = calloc(strlen($1) + strlen($2) + 1, sizeof(char)); strcat(p, $1); strcat(p, $2); $$ = p; printf("%s", $$); }
;
liste_declarations	:	
		liste_declarations declaration {char* p = calloc(strlen($1) + strlen($2) + 2, sizeof(char)); strcat(p, $1); strcat(p, $2); $$ = p; }
	|	{ $$ = ""; }
;
liste_fonctions	:	
		liste_fonctions fonction	{char* p = calloc(strlen($1) + strlen($2) + 1, sizeof(char)); strcat(p, $1); strcat(p, $2); $$ = p;}
|               fonction	{ $$ = $1; }
;
declaration	:	
		type liste_declarateurs ';'	{char* p = calloc(strlen($1) + strlen($2) + 4, sizeof(char)); strcat(p, $1); strcat(p, " "); strcat(p, $2); strcat(p, ";\n"); $$ = p;}
;
liste_declarateurs	:	
		liste_declarateurs ',' declarateur	{ char* p = calloc(strlen($1) + strlen($3) + 2, sizeof(char)); strcat(p, $1); strcat(p, ","); strcat(p, $3); $$ = p; }
	|	declarateur	{ $$ = $1; }
;
declarateur	:	
		IDENTIFICATEUR	{ $$ = $1; }
	|	declarateur '[' CONSTANTE ']'	{ char* p = calloc(strlen($1) + strlen($3) + 3, sizeof(char)); strcat(p, $1); strcat(p, "["); strcat(p, $3); strcat(p, "]"); $$ = p;}
;
fonction	:	
		type IDENTIFICATEUR '(' liste_parms ')' '{' liste_declarations liste_instructions '}'{ 
			char* p = calloc(strlen($1) + strlen($2) + strlen($4) + strlen($7) + strlen($8) + 8, sizeof(char));
			strcat(p, $1); strcat(p, " "); strcat(p, $2); strcat(p, "("); strcat(p, $4); strcat(p, "){\n"); strcat(p, $7); strcat(p, $8); strcat(p, "\n}\n"); $$ = p; }

	|	EXTERN type IDENTIFICATEUR '(' liste_parms ')' ';'	{ char* p = calloc(strlen($2) + strlen($3) + strlen($5) + 12, sizeof(char));
			strcat(p, "extern "); strcat(p, $2); strcat(p, " "); strcat(p, $3); strcat(p, "("); strcat(p, $5); strcat(p, ");\n"); $$ = p; }
;
type	:	
		VOID	{ $$ = "void"; }
	|	INT	{ $$ = "int"; }
;
liste_parms	:	
		parm ',' liste_parms { char* p = calloc(strlen($1) +  strlen($3) + 2, sizeof(char)); strcat(p, $1); strcat(p, ", "); strcat(p, $3); $$ = p; }
	|	parm	{ $$ = $1; }
;
parm	:	
		INT IDENTIFICATEUR	{ char* p = calloc(strlen($2) + 5, sizeof(char)); strcat(p, "int "); strcat(p, $2); $$ = p; }
|		{ $$ = "void"; }
;
liste_instructions :	
		liste_instructions instruction	{ char* p = calloc(strlen($1) +  strlen($2) + 1, sizeof(char)); strcat(p, $1); strcat(p, $2); $$ = p; }
	|	{ $$ = ""; }
;
instruction	:	
		iteration	{ $$ = $1; }
	|	selection	{ $$ = $1; }
	|	saut		{ $$ = $1; }
	|	affectation ';'	{ char* p = calloc(strlen($1) + 3, sizeof(char)); strcat(p, $1); strcat(p, ";\n"); $$ = p;}
	|	bloc		{ $$ = $1; }
	|	appel		{ $$ = $1; }
;
iteration	:	
		FOR '(' affectation ';' condition ';' affectation ')' instruction	{ init_loop(&loop); create(&loop, $3, $5, $7, $9); $$ = loop.code; }
	|	WHILE '(' condition ')' instruction					{ init_loop(&loop); create(&loop, "i=0", $3, "i++", $5); $$ = loop.code; }
;
selection	:	
		IF '(' condition ')' instruction %prec THEN
		{	char* p = calloc(strlen($1) + strlen($3) + strlen($5) + 3, sizeof(char));
			strcat(p, $1); strcat(p, "("); strcat(p, $3);
			strcat(p, ")"); strcat(p, $5); $$ = p; }
	|	IF '(' condition ')' instruction ELSE instruction
		{	char* p = calloc(strlen($1) + strlen($3) + strlen($5) + strlen($6) + strlen($7) + 3, sizeof(char));
			strcat(p, $1); strcat(p, "("); strcat(p, $3);
			strcat(p, ")"); strcat(p, $5); strcat(p, $6); strcat(p, $7); $$ = p; }
	|	SWITCH '(' expression ')' instruction
		{	char* p = calloc(strlen($1) + strlen($3) + strlen($5) + 3, sizeof(char));
			strcat(p, $1); strcat(p, "("); strcat(p, $3);
			strcat(p, ")"); strcat(p, $5); $$ = p; }
	|	CASE CONSTANTE ':' instruction
		{	char* p = calloc(strlen($1) + strlen($2) + strlen($4) + 2, sizeof(char));
			strcat(p, $1); strcat(p, $2);
			strcat(p, ":"); strcat(p, $4); $$ = p; }
	|	DEFAULT ':' instruction
		{	char* p = calloc(strlen($1) + strlen($3) + 2, sizeof(char));
			strcat(p, $1); strcat(p, ":"); strcat(p, $3);
			$$ = p; }
;
saut	:	
		BREAK ';'		{ $$ = "break;"; }
	|	RETURN ';'		{ $$ = "return;"; }
	|	RETURN expression ';'	{ char* p = calloc(strlen($2) + 9, sizeof(char)); strcat(p, "return "); strcat(p, $2); strcat(p, ";\n"); $$ = p; }
;
affectation	:	
		variable '=' expression		{ char* p = calloc(strlen($1) + strlen($3) + 2, sizeof(char)); strcat(p, $1); strcat(p, "="); strcat(p, $3); $$ = p; }
;
bloc	:	
		'{' liste_declarations liste_instructions '}'		{ char* p = calloc(strlen($2) + strlen($3) + 6, sizeof(char)); strcat(p, "{\n"); strcat(p, $2); strcat(p, $3); strcat(p, "\n}\n"); $$ = p; }
;
appel	:	
		IDENTIFICATEUR '(' liste_expressions ')' ';'	{char* p = calloc(strlen($1) + strlen($3) + 4, sizeof(char)); strcat(p, $1); strcat(p, "("); strcat(p, $3); strcat(p, ");"); $$ = p;}
;
variable	:	
		IDENTIFICATEUR			{$$ = $1;}
	|	variable '[' expression ']'	{char* p = calloc(strlen($1) + strlen($3) + 3, sizeof(char)); strcat(p, $1); strcat(p, "["); strcat(p, $3); strcat(p, "]"); $$ = p;}
;
expression	:	
		'(' expression ')'				{ char* p = calloc(strlen($2) + 3, sizeof(char)); strcat(p, "("); strcat(p, $2); strcat(p, ")"); $$ = p; }
	|	expression binary_op expression %prec OP	{ char* p = calloc(strlen($1) + strlen($2) + strlen($3) + 1, sizeof(char)); strcat(p, $1); strcat(p, $2); strcat(p, $3); $$ = p; }
	|	MOINS expression				{ char* p = calloc(strlen($1) + strlen($2) + 1, sizeof(char)); strcat(p, $1); strcat(p, $2); $$ = p; }
	|	CONSTANTE					{ $$ = $1;}
	|	variable					{ $$ = $1; }
	|	IDENTIFICATEUR '(' liste_expressions ')'	{ char* p = calloc(strlen($1) + strlen($3) + 3, sizeof(char)); strcat(p, $1); strcat(p, "(");  strcat(p, $3); strcat(p, ")"); $$ = p; }
;
liste_expressions	:	
		liste_expressions ',' expression	{ char* p = calloc(strlen($1) + strlen($3) + 2, sizeof(char)); strcat(p, $1); strcat(p, ","); strcat(p, $3); $$ = p; }
	|	expression				{ $$ = $1; }
	|	{ $$ = ""; }
;
condition	:	
		NOT '(' condition ')'	{ char* res = calloc(strlen($3) + 4, 1); strcat(res, "!("); strcat(res, $3); strcat(res, ")"); $$ = res;}
	|	condition binary_rel condition %prec REL { char* res = calloc(strlen($1) + strlen($2) + strlen($3) + 1, 1); strcat(res, $1); strcat(res, $2); strcat(res, $3); $$ = res; }
	|	'(' condition ')'	{ char* res = calloc(strlen($2) + 3, 1); strcat(res, "("); strcat(res, $2); strcat(res, ")"); $$ = res;}
	|	expression binary_comp expression { char* res = calloc(strlen($1) + strlen($2) + strlen($3) + 1, 1); strcat(res, $1); strcat(res, $2); strcat(res, $3); $$ = res;}
;
binary_op	:	
		PLUS	{ $$ = "+"; }
	|       MOINS	{ $$ = "-"; }
	|	MUL	{ $$ = "*"; }
	|	DIV	{ $$ = "/"; }
	|       LSHIFT	{ $$ = "<<"; }
	|       RSHIFT	{ $$ = ">>"; }
	|	BAND	{ $$ = "&"; }
	|	BOR	{ $$ = "|"; }
;
binary_rel	:	
		LAND	{ $$ = "&&"; }
	|	LOR	{ $$ = "||"; }
;
binary_comp	:	
		LT	{ $$ = "<"; }
	|	GT	{ $$ = ">"; }
	|	GEQ	{ $$ = ">="; }
	|	LEQ	{ $$ = "<="; }
	|	EQ	{ $$ = "=="; }
	|	NEQ	{ $$ = "!="; }
;
%%
void yyerror(const char *s) { 
	fprintf(stderr, "Error : %s\n", s); 
}
int main(){ 
	while(yyparse()){
	}
	return 1;
}
