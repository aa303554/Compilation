#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Initialise un bloc à partir de rien */
void init_block(struct Block *block){
	//Taille des déclarations initialisé à 1024
	block->decl_size = 1024;
	//Initialisation à partir de rien, donc le code des déclarations est nul (= 0)
	block->decl_length = 0;
	//On alloue la mémoire pour les déclarations
	block->declarations = calloc(block->decl_size, sizeof(char));

	//Taille du code initialisé à 1024
	block->size = 1024;
	//Initialisation à partir de rien, donc le code est nul (= 0)
	block->length = 0;
	//On alloue la mémoire pour le code
	block->code = calloc(block->size, sizeof(char));

	//On alloue la mémoire pour la valeur (utile pour les expressions);
	block->value = calloc(103, sizeof(char));
	//Le bloc n'est pas entouré d'accolades par défaut
	block->bracket = 0;

	//Pas de bloc avant ni après, pas d'arbre non plus
	block->suivant = NULL;
	block->precedent = NULL;
	block->arbre = NULL;
}

/* Génère le bloc sous forme d'une chaîne de caractères */
char* block_code(struct Block* block){
	char* code = calloc(block->length + block->decl_length + 6, sizeof(char));
	if(block->bracket != 0){
		concatenate(code, 4, "{\n", block->declarations, block->code, "\n}\n");
	} else {
		concatenate(code, 2, block->declarations, block->code);
	}
	if(block->suivant != NULL){
		char* suivant = block_code(block->suivant);
		char* all = calloc(strlen(code) + strlen(suivant) + 1, sizeof(char));
		concatenate(all, 2, code, suivant);
		return all;	
	}
	return code;
}

/* Affiche le bloc d'instruction */
void printBlock(struct Block *block){
	char* code = block_code(block);
	if(block->suivant != NULL){
		printBlock(block->suivant);
	}
	printf("%s", code);
}

/* Lie deux blocs entre eux */
void link_block(struct Block *first, struct Block *second){
	first->suivant = calloc(1, sizeof(struct Block));
	second->precedent = calloc(1, sizeof(struct Block));
	first->suivant = second;
	second->precedent = first;
}

/* Ajoute un morceau de code à la fin du bloc */
void insert_block(struct Block *block, char* string){
	int length = strlen(string) + block->length + 2;
	while(length > block->size){
		block->size = block->size * 2;
		char* code = calloc(block->size, sizeof(char));
		strcpy(code, block->code); //on copie le code existant dans le nouveau tableau
		block->code = code;	   //on remplace le tableau
	}
	
	//Ajoute string à la fin du code
	strcat(block->code, string);
	block->length = length;
}

/* Ajoute des déclarations au bloc */
void dinsert_block(struct Block *block, char* declarations){
	int length = strlen(declarations) + block->decl_length + 2;
	while(length > block->decl_size){
		block->decl_size = block->decl_size * 2;
		char* code = calloc(block->decl_size, sizeof(char));
		strcpy(code, block->declarations); //on copie le code existant dans le nouveau tableau
		block->declarations = code;	   //on remplace le tableau
	}
	
	//Ajoute string à la fin du code
	strcat(block->declarations, declarations);
	block->decl_length = length;
}

/* Ajoute un morceau de code au début du bloc */
void finsert_block(struct Block *block, char* string){
	int length = strlen(string) + block->length + 2;
	char* code = calloc(block->size, sizeof(char));
	strcpy(code, string);
	string = code;
	while(length > block->size){
		block->size = block->size * 2;
		char* code = calloc(block->size, sizeof(char));
		strcpy(code, string); //on copie le code existant dans le nouveau tableau
		string = code;	   //on remplace le tableau
	}
	
	//Ajoute string à la fin du code
	strcat(string, block->code);
	block->length = length;
}

/* Ajoute un bloc d'instruction à un autre */
void concatenate_block(struct Block *destination, struct Block *source){
	insert_block(destination, source->code);
	dinsert_block(destination, source->declarations);
}

/* Ajoute une nouvelle variable dans le code et retourne sa valeur */
char* new_tmp(struct Block *block){
	char* var_name = calloc(5, sizeof(char));
	block->temp_var++;
	sprintf(var_name, "_t%d", block->temp_var);
	char* p = calloc(9, sizeof(char));
	concatenate(p, 3, "int ", var_name, ";\n");
	dinsert_block(block, p);
	return var_name;
}

/* Ajoute un nouveau pointeur dans le code et retourne sa valeur */
char* new_pnt(struct Block *block){
	char* var_name = calloc(5, sizeof(char));
	block->temp_var++;
	sprintf(var_name, "_t%d", block->temp_var);
	char* p = calloc(10, sizeof(char));
	concatenate(p, 3, "int *", var_name, ";\n");
	dinsert_block(block, p);
	return var_name;
}
