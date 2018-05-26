%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include "table.c"
extern char* yytext;
table_s* table_symboles;
char* last_label;

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
	int isReturn;	//si l'expression doit retourner une nouvelle variable quoiqu'il arrive
	int minus;	//si l'expression est négative
	int parenthesis;
	int isnot;
	char* antiracine;
	int antiarbre;
	char* array_name;
	char* function_name;
	int infunction;
};

%}

%union{
	char* value;
	char* ident;
	struct Block{
		char* variables[100];	//variables du bloc
		int var_num;		//nombre de variables
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
		struct Arbre* arbre;	//arbre de représentation pour les expressions

		int isFunction;
	} block;

	struct Declarations{
		int type;		//type des déclarartions
		int size;		//taille du tableau de variables
		char* variables[100];	//tableau de variables
		char* text;		//text de la declaration
		struct Declaration* next;	//declarations suivantes
	} declarations;

	struct Declarateurs{
		int size;		//taille des declarateurs
		char* variables[100];	//nom des variables
		char* text;		//text des declarateurs
	} declarators;

	struct Tableaux{
		int arity;
		int* values;
		char* text;
	} tabs;

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

%type <string> binary_comp binary_rel
%type <string> programme fonction liste_fonctions
%type <string> type
%type <string> liste_parms parm
%type <block> liste_instructions instruction iteration selection saut affectation bloc appel liste_expressions expression variable condition
%type <declarations> liste_declarations declaration
%type <declarators> liste_declarateurs declarateur
%type <tabs> tableaux_decl

%left BOR BAND
%left LSHIFT RSHIFT
%left PLUS MOINS
%left DIV MUL
%left LAND LOR
%nonassoc THEN
%nonassoc ELSE
%left REL
%start programme
%%
programme	:	
		liste_declarations liste_fonctions	{char* p = calloc(strlen($1.text) + strlen($2) + 1, sizeof(char)); concatenate(p, 2, $1.text, $2); $$ = p; printf("%s", $$); }
;
liste_declarations	:	
		liste_declarations declaration {
			char* p = calloc(strlen($1.text) + strlen($2.text) + 2, sizeof(char)); strcat(p, $1.text); strcat(p, $2.text);
			$$.text = p;
		}
	|	{ $$.text = "";}
;
liste_fonctions	:	
		liste_fonctions fonction	{char* p = calloc(strlen($1) + strlen($2) + 1, sizeof(char)); strcat(p, $1); strcat(p, $2); $$ = p;}
|               fonction	{ $$ = $1; }
;
declaration	:	
		type liste_declarateurs ';'	{
			char* p = calloc(strlen($1) + strlen($2.text) + 4, sizeof(char)); strcat(p, $1); strcat(p, " "); strcat(p, $2.text); strcat(p, ";\n");
			$$.text = p;
		}
;
liste_declarateurs	:	
		liste_declarateurs ',' declarateur	{
			char* p = calloc(strlen($1.text) + strlen($3.text) + 2, sizeof(char)); strcat(p, $1.text); strcat(p, ","); strcat(p, $3.text);
			$$ = $1;
			$$.text = p;
			$$.variables[$$.size] = $3.variables[0];
			$$.size++;
		}
	|	declarateur	{ $$ = $1; }
;
declarateur	:	
		IDENTIFICATEUR	{ $$.text = $1; $$.size = 1; $$.variables[0] = $1; }
	|	IDENTIFICATEUR tableaux_decl	{
			char* p = calloc(strlen($1) + strlen($2.text) + 3, sizeof(char)); strcat(p, $1); strcat(p, $2.text);
			$$.text = p;
			modify_array($1, $2.arity, $2.values);
			/* AFFICHE LES INFORMATIONS SUR LE TABLEAU MODIFIE **DEBUG**
			variable* var = get_variable($1);
			printf("INFO ON %s :\n\tARITY : [%d]\n", var->name, var->arity);
			for(int i = 0; i < var->arity; i++){
				printf("\tVAL %d : [%d]\n", i, var->values[i]);
			}
			*/
		}
;
tableaux_decl	:
		tableaux_decl '[' CONSTANTE ']' {
			$$ = $1;
			$$.values[$$.arity] = $3;
			$$.arity++;
			char* p = calloc(strlen($1.text) + strlen($3) + 3, sizeof(char));
			concatenate(p, 4, $1.text, "[", $3, "]");
			$$.text = p;
		}
	|	'[' CONSTANTE ']' {
			$$.arity = 1;
			$$.values = calloc(100, sizeof(int));
			$$.values[0] = atoi($2);
			char* p = calloc(strlen($2) + 3, sizeof(char));
			concatenate(p, 3, "[", $2, "]");
			$$.text = p;
		}
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
			$5.arbre->parenthesis = 1;
			$5.arbre->antiarbre = 1;
			arbre_eval($5.arbre, &$5);
			//on génère les labels
			char* if_label = new_label();
			char* else_label;
			//On génère un else label si jamais il n'a pas été généré plus tôt (pour un break)
			if(last_label == NULL){
				//Non généré
				else_label = new_label();
			} else {
				//Généré
				else_label = last_label;
				last_label = NULL;
			}
			//on insère les déclarations si besoin
			dinsert_block(&$$, $3.declarations); dinsert_block(&$$, $7.declarations);
			/* Génère l'entête de la boucle */
			int header_length = strlen(if_label) + strlen($5.value) + strlen(else_label) + 17;
			char* header = calloc(header_length, sizeof(char));
			sprintf(header, "%s: if %s goto %s;\n", if_label, $5.value, else_label);

			/* Génère le pied de la boucle goto) */
			struct Block* footer = calloc(1, sizeof(struct Block));
			init_block(footer);
			insert_block(footer, "goto "); insert_block(footer, if_label); insert_block(footer, ";\n");
			insert_block(footer, else_label); insert_block(footer, ": ");
			link_block(&$9, footer);

			/* On assemble le code */
			insert_block(&$$, $3.code);
			insert_block(&$$, ";\n");
			insert_block(&$$, header);
			insert_block(&$7, ";\n");
			insert_block(&$9, $7.code);
			dinsert_block(&$9, $7.declarations);
			char* code = block_code(&$9);
			insert_block(&$$, code);
		}
	|	WHILE '(' condition ')' instruction	{
			init_block(&$$);
			$3.arbre->parenthesis = 1;
			arbre_eval($3.arbre, &$3);
			//on génère les labels
			char* if_label = new_label();
			char* else_label;
			//On génère un else label si jamais il n'a pas été généré plus tôt (pour un break)
			if(last_label == NULL){
				//Non généré
				else_label = new_label();
			} else {
				//Généré
				else_label = last_label;
				last_label = NULL;
			}

			/* Génère l'entête de la boucle */
			int header_length = strlen(if_label) + strlen($3.value) + strlen(else_label) + 14;
			char* header = calloc(header_length, sizeof(char));
			sprintf(header, "%s: if %s goto %s;\n", if_label, $3.value, else_label);

			/* Génère le pied de la boucle goto) */
			struct Block* footer = calloc(1, sizeof(struct Block));
			init_block(footer);
			insert_block(footer, "goto "); insert_block(footer, if_label); insert_block(footer, ";\n");
			insert_block(footer, else_label); insert_block(footer, ": ");
			link_block(footer, &$5);

			/* On assemble le code */
			char* code = block_code(footer);
			insert_block(&$$, code);
			insert_block(&$$, header);
		}
;
selection	:	
		IF '(' condition ')' instruction %prec THEN
		{	
			init_block(&$$);
			$3.arbre->parenthesis = 1;
			$3.arbre->antiarbre = 1;
			arbre_eval($3.arbre, &$3);
			//on génère le label
			char* else_label = new_label();
			//on insère les déclarations si besoin
			dinsert_block(&$$, $3.declarations);
			insert_block(&$$, $3.code);
			
			/* Génère l'entête de la selection */
			int header_length = strlen($3.value) + strlen(else_label) + 20;
			char* header = calloc(header_length, sizeof(char));
			sprintf(header, "if %s goto %s;\n", $3.value, else_label);

			/* Génère le pied de la boucle selection */
			struct Block* footer = calloc(1, sizeof(struct Block));
			init_block(footer);
			insert_block(footer, else_label); insert_block(footer, ": ");

			/* On assemble le code */
			link_block(&$5, footer);
			insert_block(&$$, header);
			char* code = block_code(&$5);
			insert_block(&$$, code);
		}
	|	IF '(' condition ')' instruction ELSE instruction
		{
			init_block(&$$);
			$3.arbre->parenthesis = 1;
			$3.arbre->antiarbre = 1;
			arbre_eval($3.arbre, &$3);
			//on génère les labels
			char* if_label = new_label();
			char* else_label = new_label();
			//on insère les déclarations si besoin
			dinsert_block(&$$, $3.declarations);
			insert_block(&$$, $3.code);
			
			/* Génère l'entête de la selection */
			int header_length = strlen($3.value) + strlen(if_label) + 20;
			char* header = calloc(header_length, sizeof(char));
			sprintf(header, "if %s goto %s;\n", $3.value, if_label);

			/* Génère le pied de la selection (goto) */
			struct Block* footer = calloc(1, sizeof(struct Block));
			init_block(footer);
			insert_block(footer, "goto "); insert_block(footer, else_label); insert_block(footer, ";\n");
			insert_block(footer, if_label); insert_block(footer, ": ");
			insert_block(&$7, else_label);
			insert_block(&$7, ": ");

			/* On assemble le code */
			link_block(&$5, footer);
			link_block(footer, &$7);
			insert_block(&$$, header);
			char* code = block_code(&$5);
			insert_block(&$$, code);
		}
	|	SWITCH '(' expression ')' instruction
		{
			init_block(&$$);
			arbre_eval($3.arbre, &$3);
			char* header = calloc(strlen($3.value) + 10, sizeof(char)); concatenate(header, 3, "switch (", $3.value, ")"); 
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
		BREAK ';'		{
			//Si pas de label n'a encore été créé, alors on en créer un nouveau
			if(last_label == NULL){
				last_label = new_label();
			}
			char* p = calloc(strlen(last_label) + 7, sizeof(char));
			concatenate(p, 3, "goto ", last_label, ";\n");
			init_block(&$$); insert_block(&$$, p);
		}
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
			concatenate(p, 3, "return ", $2.value, ";\n");
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
			if($1.arbre != NULL){
				arbre_eval($1.arbre, &$$);
				$1.value = $$.value;
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
			dinsert_block(&$$, $2.text);
			dinsert_block(&$$, $3.declarations);
			//on insere le code
			insert_block(&$$, $3.code);
		}
;
appel	:	
		IDENTIFICATEUR '(' liste_expressions ')' ';'	{
			init_block(&$$);
			$3.arbre->infunction = 1;
			arbre_eval($3.arbre, &$$);
			$3.value = $$.value;
			char* p = calloc(strlen($1) + strlen($3.value) + 5, sizeof(char));
			concatenate(p, 4, $1, "(", $3.value, ");\n");
			insert_block(&$$, p);
			$$.value = p;
		}
;
variable	:	
		IDENTIFICATEUR	{
			init_block(&$$);
			init_arbre(&$$, "", $1, NULL, NULL);
			int pos = search($1);
			if(pos < 0){
				fprintf(stderr, "/* ERROR : %s UNDECLARED BEFORE USE */\n", $1);
			}
			$$.value = $1;
		}
	|	variable '[' expression ']'	{
			init_block(&$$);
			if($1.arbre != NULL){
				arbre_eval($1.arbre, &$$);
			}
			$$.arbre = $3.arbre;
			$$.arbre->isReturn = 1;
			$$.arbre->array_name = $$.value;
		}
;
expression	:	
		'(' expression ')'	{
			$$ = $2;
			//on lève le flag indicant que la valeur doit être entre parenthèses
			$$.arbre->parenthesis = 1;
		}
	|	expression BAND expression %prec BAND	{ 
			init_block(&$$);
			//on construit simplement l'arbre à partir du fils gauche et du fils droit
			init_arbre(&$$, "", "&", $1.arbre, $3.arbre);
		}
	|	expression BOR expression %prec BOR	{ 
			init_block(&$$);
			//on construit simplement l'arbre à partir du fils gauche et du fils droit
			init_arbre(&$$, "", "|", $1.arbre, $3.arbre);
		}
	|	expression LSHIFT expression %prec LSHIFT	{ 
			init_block(&$$);
			//on construit simplement l'arbre à partir du fils gauche et du fils droit
			init_arbre(&$$, "", "<<", $1.arbre, $3.arbre);
		}
	|	expression RSHIFT expression %prec RSHIFT	{ 
			init_block(&$$);
			//on construit simplement l'arbre à partir du fils gauche et du fils droit
			init_arbre(&$$, "", ">>", $1.arbre, $3.arbre);
		}
	|	expression PLUS expression %prec PLUS	{ 
			init_block(&$$);
			//on construit simplement l'arbre à partir du fils gauche et du fils droit
			init_arbre(&$$, "", "+", $1.arbre, $3.arbre);
			char* var1 = $1.arbre->racine;
			char* var2 = $3.arbre->racine;
			check_operation(var1, "+", var2);
		}
	|	expression MOINS expression %prec MOINS	{ 
			init_block(&$$);
			//on construit simplement l'arbre à partir du fils gauche et du fils droit
			init_arbre(&$$, "", "-", $1.arbre, $3.arbre);
		}
	|	expression DIV expression %prec DIV	{ 
			init_block(&$$);
			//on construit simplement l'arbre à partir du fils gauche et du fils droit
			init_arbre(&$$, "", "/", $1.arbre, $3.arbre);
		}
	|	expression MUL expression %prec MUL	{ 
			init_block(&$$);
			//on construit simplement l'arbre à partir du fils gauche et du fils droit
			init_arbre(&$$, "", "*", $1.arbre, $3.arbre);
		}
	|	MOINS expression	{
			$$ = $2;
			//on lève le flag de la négation de l'expression (expression est sous forme d'arbre)
			$$.arbre->minus = 1;
		}
	|	CONSTANTE	{
			init_block(&$$);
			//on construit l'arbre dont la racine est la valeur de la constante
			init_arbre(&$$, "", $1, NULL, NULL);
		}
	|	variable	{
			$$ = $1;
		}
	|	IDENTIFICATEUR '(' liste_expressions ')'	{
			$$ = $3;
			$$.arbre->function_name = $1;
		}
;
liste_expressions	:	
		liste_expressions ',' expression	{
			init_block(&$$);
			init_arbre(&$$, "", ",", $1.arbre, $3.arbre);
		}
	|	expression				{ $$ = $1; if($$.arbre->function_name == NULL && $$.arbre->array_name == NULL) { $$.arbre->isReturn = 1; }}
	|	{ init_block(&$$); }
;
condition	:	
		NOT '(' condition ')'	{
			$$ = $3;
			//la valeur final est une négation et doit être entre parenthèses
			$$.arbre->isnot = 1;
			$$.arbre->parenthesis = 1;
		}
	|	condition binary_rel condition %prec REL { 
			init_block(&$$);
			//on construit simplement l'arbre
			init_arbre(&$$, "", $2, $1.arbre, $3.arbre);
		}
	|	'(' condition ')'	{ 
			$$ = $2;
			//la valeur final doit être entre parenthèses
			$$.arbre->parenthesis = 1;
		}
	|	expression binary_comp expression { 
			init_block(&$$);
			//on construit simplement l'arbre
			init_arbre(&$$, "", $2, $1.arbre, $3.arbre);
		}
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
	table_symbole = calloc(1, sizeof(table_s));
	yyparse();
	return 1;
}
