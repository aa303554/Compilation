#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct Expression{
	int size;			//taille maximale du code
	int decl_size;			//taille maximale des déclarations
	int length;			//taille du code
	int decl_length;		//taille des déclarations
	int temp_var;			//nombre de variables temporaires créés
	
	char* declarations;		//code des déclarations
	char* code;			//code du corps de l'expression
	char* final_value;		//valeur finale de l'expression
} expr;


void init_expr(struct Expression *expr){
	expr->size = 1024;
	expr->decl_size = 512;
	expr->length = 0;
	expr->decl_length = 0;
	expr->temp_var = 0;
	
	expr->declarations = calloc(expr->decl_size, sizeof(char));
	expr->code = calloc(expr->size, sizeof(char));
}


/* Ajoute une déclaration de variable */
void expr_decl_insert(struct Expression *expr, char* var){
	int length = strlen(var) + expr->decl_length + 2;
	while(length > expr->decl_size){
		expr->decl_size = expr->decl_size * 2;
		char* code = calloc(expr->decl_size, sizeof(char));
		strcpy(code, expr->declarations); 	//on copie le code existant dans le nouveau tableau
		expr->declarations = code;	   		//on remplace le tableau
	}
	
	//Ajoute string à la fin des déclarations
	strcat(expr->declarations, var);
	expr->decl_length = length;
}

/* Ajoute un morceau de code à la fin de l'expression */
void expr_insert(struct Expression *expr, char* string){
	int length = strlen(string) + expr->length + 2;
	while(length > expr->size){
		expr->size = expr->size * 2;
		char* code = calloc(expr->size, sizeof(char));
		strcpy(code, expr->code); 	//on copie le code existant dans le nouveau tableau
		expr->code = code;	   		//on remplace le tableau
	}
	
	//Ajoute string à la fin du code
	strcat(expr->code, string);
	expr->length = length;
}

/* Ajoute une nouvelle variable temporaire à l'expression et renvoie sa valeur */
char* new_var(struct Expression *expr){
	char* var_name = calloc(4, sizeof(char));
	expr->temp_var++;
	sprintf(var_name, "_t%d", expr->temp_var);
	expr_decl_insert(expr, var_name);
	return var_name;
}
