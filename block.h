#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int nombre_vartmp = 0; //Nombre de variable temporaire généré par le compilateur


/* Initialise un bloc à partir de rien */
void init_block(struct Block *block){
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
}

/* Affiche le bloc d'instruction */
void printBlock(struct Block *block){
	printf("%s", block->code);
}

/* Ajoute un bloc d'instruction à un autre */
void concatenate_block(struct Block *destination, struct Block *source){
	int length = destination->length + source->length + 1; //ne pas oublier le "\0" de fin de chaîne

	//Si le tableau n'est pas assez grand pour stocker la concaténation des deux codes, on le double.
	while(length > destination->size){
		destination->size = destination->size * 2;
		char* code = calloc(destination->size, sizeof(char));
		strcpy(code, destination->code); //on copie le code existant dans le nouveau tableau
		destination->code = code;	 //on remplace le tableau
	}
	
	//Ajoute source->code à la fin de destination->code)
	strcat(destination->code, source->code);
	destination->length = length;
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

/* Ajoute une nouvelle variable dans le code égal à l'expression */
void new_tmp(struct Block *block, char* expr){
	char var_name[9];
	sprintf(var_name, "_temp%d", nombre_vartmp);
	nombre_vartmp++;
	insert_block(block, var_name);
}

char* block_code(struct Block* block){
	if(block->bracket != 0){
		char* code = calloc(block->size + 6, sizeof(char));
		strcat(code, "{\n");
		strcat(code, block->code);
		strcat(code, "\n}\n");
		return code;
	}
	return block->code;
}
