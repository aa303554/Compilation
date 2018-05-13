%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
extern char* yytext;

/* Fait la concaténation des n chaines en paramètres dans destination. On suppose qu'on a alloué assez d'espace mémoire */
void concatenate(char* destination, int n, ...){
	va_list valist;
	va_start(valist, n);
	for(int i = 0; i < n; i++){
		strcat(destination, va_arg(valist, char*));	
	}
	va_end(valist);
}

struct Arbre{
	char* racine;	//symbole de la racine. ex : "*", "+", "variable", "4", etc...
	struct Arbre* gauche;	//fils gauche. null si pas de fils (-> la racine n'est pas une opération)
	struct Arbre* droit;	//file droit. null si pas de fils (-> la racine n'est pas une opération)
	int feuille;	//booléen. 0 si ce n'est pas une feuille, 1 si c'est une feuille
	char* value;	//evaluation de l'arbre.
	char* variable;	//nom de la variable dans laquelle est stockée le resultat de l'expression. Si la racine est une opération, alors value prend la valeur d'une variable temporaire.
	int isReturn;	//si l'expression est juste avant un return;
};

%}

%union{
	char* value;
	char* ident;
	struct Block{
		int decl_length;	//Taille des déclarations
		int decl_size;		//Taille maximum des déclarations
		char* declarations;	//Déclarations générées

		int length;		//Longueur du code
		int size;		//Taille du tableau code
		char* code;		//Code généré
		
		char* value;		//Valeur finale du bloc (chiffre ou variable) pour les expressions.
		int bracket;		//bloc entouré d'accolades ? 0 := non ; 1 := oui
		int temp_var;		//Nombre de variable temporaires crées
		
		struct Block* precedent;//bloc précédent
		struct Block* suivant;	//bloc suivant
		struct Arbre* arbre;
	} block;
	char* string;
}

%{
#include "block.h"
#include "arbre.h"
%}

%token <ident> IDENTIFICATEUR 
%token <value> CONSTANTE
%token <string> VOID INT FOR WHILE IF ELSE SWITCH CASE DEFAULT
%token <string> BREAK RETURN PLUS MOINS MUL DIV LSHIFT RSHIFT BAND BOR LAND LOR LT GT 
%token <string> GEQ LEQ EQ NEQ NOT EXTERN

%type <string> condition
%type <string> binary_op binary_comp binary_rel
%type <string> programme fonction liste_fonctions
%type <string> declarateur liste_declarations type declaration liste_declarateurs
%type <string> liste_parms parm
%type <block> liste_instructions instruction iteration selection saut affectation bloc appel liste_expressions expression variable

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
		liste_declarations liste_fonctions	{char* p = calloc(strlen($1) + strlen($2) + 1, sizeof(char)); concatenate(p, 2, $1, $2); $$ = p; printf("%s", $$); }
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
		type IDENTIFICATEUR '(' liste_parms ')' bloc {
			char* bloc = block_code(&$6);
			char* p = calloc(strlen($1) + strlen($2) + strlen($4) + strlen(bloc) + 8, sizeof(char));
			concatenate(p, 7, $1, " ", $2, "(", $4, ")", bloc);
			$$ = p;
		}
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
		liste_instructions instruction	{ 
			init_block(&$$);
			insert_block(&$$, $1.code);
			insert_block(&$$, $2.code);
			dinsert_block(&$$, $1.declarations);
			dinsert_block(&$$, $2.declarations);
		}
	|	{ init_block(&$$); }
;
instruction	:	
		iteration	{ $$ = $1; }
	|	selection	{ $$ = $1; }
	|	saut		{ $$ = $1; }
	|	affectation ';'	{ insert_block(&$1, ";\n"); $$ = $1; }
	|	bloc		{ $$ = $1; }
	|	appel		{ $$ = $1; }
;
iteration	:	
		FOR '(' affectation ';' condition ';' affectation ')' instruction	{
			init_block(&$$);
			//on génère les labels
			char* if_label = new_label(); char* else_label = new_label();
			//on insère les déclarations si besoin
			dinsert_block(&$$, $3.declarations); dinsert_block(&$$, $7.declarations);
			/* Génère l'entête de la boucle */
			int header_length = strlen(if_label) + strlen($5) + strlen(else_label) + 14;
			char* header = calloc(header_length, sizeof(char));
			sprintf(header, "%s: if %s goto %s;\n", if_label, $5, else_label);

			/* Génère le pied de la boucle goto) */
			struct Block* footer = calloc(1, sizeof(struct Block));
			init_block(footer);
			insert_block(footer, "goto "); insert_block(footer, if_label); insert_block(footer, ";\n");
			insert_block(footer, else_label); insert_block(footer, ": ");
			link_block(&$9, footer);

			/* On assemble le code */
			insert_block(&$$, header);
			insert_block(&$7, ";");
			insert_block(&$9, $7.code);
			dinsert_block(&$9, $7.declarations);
			char* code = block_code(&$9);
			insert_block(&$$, code);
		}
	|	WHILE '(' condition ')' instruction					{
			init_block(&$$);
		}
;
selection	:	
		IF '(' condition ')' instruction %prec THEN
		{	
			init_block(&$$); char* header = calloc(strlen($3) + 6, sizeof(char)); concatenate(header, 3, "if (", $3, ")"); 
			insert_block(&$$, header);
			concatenate_block(&$$, &$5);
		}
	|	IF '(' condition ')' instruction ELSE instruction
		{
			init_block(&$$); char* header = calloc(strlen($3) + 6, sizeof(char)); concatenate(header, 3, "if (", $3, ")"); 
			insert_block(&$$, header);
			concatenate_block(&$$, &$5);
			insert_block(&$$, "else");
			concatenate_block(&$$, &$7);
		}
	|	SWITCH '(' expression ')' instruction
		{
			init_block(&$$); char* header = calloc(strlen($3.value) + 10, sizeof(char)); concatenate(header, 3, "switch (", $3.value, ")"); 
			insert_block(&$$, $3.code);
			insert_block(&$$, header);
			dinsert_block(&$$, $3.declarations);
			concatenate_block(&$$, &$5);
		}
	|	CASE CONSTANTE ':' instruction
		{
			init_block(&$$); char* header = calloc(strlen($2) + 6, sizeof(char)); concatenate(header, 3, "case ", $2, ":"); 
			insert_block(&$$, header);
			concatenate_block(&$$, &$4);
		}
	|	DEFAULT ':' instruction
		{
			init_block(&$$); char* header = calloc(8, sizeof(char)); concatenate(header, 1, "default:"); 
			insert_block(&$$, header);
			concatenate_block(&$$, &$3);
		}
;
saut	:	
		BREAK ';'		{ init_block(&$$); insert_block(&$$, "break;\n"); }
	|	RETURN ';'		{ init_block(&$$); insert_block(&$$, "return;\n"); }
	|	RETURN expression ';'	{ 
			init_block(&$$);
			if($2.arbre != NULL){
				$2.arbre->isReturn = 1;
				$2.arbre->variable = "";
				arbre_eval($2.arbre, &$$);
				$2.value = $$.value;
			}
			char* p = calloc(strlen($2.value) + 9, sizeof(char));
			concatenate(p, 3, "return ", $2.value, ";");
			insert_block(&$$, $2.code);
			insert_block(&$$, p);
			dinsert_block(&$$, $2.declarations);
		}
;
affectation	:	
		variable '=' expression		{ 
			init_block(&$$);
			if($3.arbre != NULL){
				arbre_eval($3.arbre, &$$);
				$3.value = $$.value;
			}
			char* p = calloc(strlen($1.value) + strlen($3.value) + 2, sizeof(char));
			concatenate(p, 3, $1.value, "=", $3.value);
			insert_block(&$$, $3.code);
			insert_block(&$$, $1.code);
			insert_block(&$$, p);
			dinsert_block(&$$, $1.declarations); 
			dinsert_block(&$$, $3.declarations); 
		}
;
bloc	:	
		'{' liste_declarations liste_instructions '}'		{
			init_block(&$$); $$.bracket = 1;
			//on insere les declarations
			dinsert_block(&$$, $2);
			dinsert_block(&$$, $3.declarations);
			//on insere le code
			insert_block(&$$, $3.code);
		}
;
appel	:	
		IDENTIFICATEUR '(' liste_expressions ')' ';'	{
			init_block(&$$);
			insert_block(&$$, $3.code); dinsert_block(&$$, $3.declarations);
			char* p = calloc(strlen($1) + strlen($3.value) + 4, sizeof(char));
			concatenate(p, 4, $1, "(", $3.value, ");");
			insert_block(&$$, p);
			$$.value = p;
		}
;
variable	:	
		IDENTIFICATEUR	{
			init_block(&$$);
			$$.value = $1;
		}
	|	variable '[' expression ']'	{
			init_block(&$$);
			$3.arbre->isReturn = 1;	$3.arbre->variable = "";		
			arbre_eval($3.arbre, &$$);
			char* var2 = new_pnt(&$$);
			char* offset = calloc(strlen(var2) + strlen($$.value) + strlen($1.value) + 5, sizeof(char));
			concatenate(offset, 6, var2, "=", $1.value, "+", $$.value, ";\n");
			insert_block(&$$, offset);
			char* affectation = calloc(strlen(var2) + 2, sizeof(char));
			concatenate(affectation, 2, "*", var2);
			$$.value = affectation;
		}
;
expression	:	
		'(' expression ')'	{
			init_block(&$$);
			dinsert_block(&$$, $2.declarations);
			insert_block(&$$, $2.code);
			$$.value = $2.value;
			$$.arbre = $2.arbre;
		}
	|	expression binary_op expression %prec OP	{ 
			init_block(&$$);
			init_arbre(&$$, "", $2, $1.arbre, $3.arbre);
			//arbre_eval($$.arbre, &$$);
			printArbre($$.arbre, 0);
		}
	|	MOINS expression	{
			init_block(&$$);
			dinsert_block(&$$, $2.declarations);
			insert_block(&$$, $2.code);
			char* p = calloc(strlen($2.value) + 2, sizeof(char));
			concatenate(p, 2, "-", $2.value);
			insert_block(&$$, p);
		}
	|	CONSTANTE	{
			init_block(&$$);
			init_arbre(&$$, "", $1, NULL, NULL);
			//arbre_eval($$.arbre, &$$);
		}
	|	variable	{
			init_block(&$$);
			init_arbre(&$$, "", $1.value, NULL, NULL);
			//arbre_eval($$.arbre, &$$);
			insert_block(&$$, $1.code);
			//insert_block(&$$, $1.value);
			dinsert_block(&$$, $1.declarations);
			$$.value = $1.value;
		}
	|	IDENTIFICATEUR '(' liste_expressions ')'	{
			init_block(&$$);
			insert_block(&$$, $3.code); dinsert_block(&$$, $3.declarations);
			char* p = calloc(strlen($1) + strlen($3.value) + 3, sizeof(char)); concatenate(p, 4, $1, "(", $3.value, ")");
			$$.value = p;
		}
;
liste_expressions	:	
		liste_expressions ',' expression	{
			init_block(&$$);
			//insert_block(&$$, $1.code); insert_block(&$$, $3.code);
			dinsert_block(&$$, $1.declarations); dinsert_block(&$$, $3.declarations);
			char* p = calloc(strlen($1.value) + strlen($3.value) + 2, sizeof(char)); concatenate(p, 3, $1.value, ",", $3.value);
			$$.value = p;
		}
	|	expression				{ $$ = $1; }
	|	{ init_block(&$$); }
;
condition	:	
		NOT '(' condition ')'	{ char* res = calloc(strlen($3) + 4, 1); strcat(res, "!("); strcat(res, $3); strcat(res, ")"); $$ = res;}
	|	condition binary_rel condition %prec REL { char* res = calloc(strlen($1) + strlen($2) + strlen($3) + 1, 1); strcat(res, $1); strcat(res, $2); strcat(res, $3); $$ = res; }
	|	'(' condition ')'	{ char* res = calloc(strlen($2) + 3, 1); strcat(res, "("); strcat(res, $2); strcat(res, ")"); $$ = res;}
	|	expression binary_comp expression { char* res = calloc(strlen($1.value) + strlen($2) + strlen($3.value) + 1, 1); concatenate(res, 3, $1.value, $2, $3.value); $$ = res;}
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
