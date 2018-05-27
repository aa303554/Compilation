#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "table.h"

char* types[3] = {"VOID", "INT", "POINTER"};

//Portée courante
int current_range = 0;

//Table de portée globale
table_s* table_symbole;

/* FONCTIONS UTILES */
//Fonction de hachage
int hash_var(char* name){
	int hash = 0;
	int i = 0;
	while(name[i] != '\0'){
		hash += name[i]*(i+1);
		i++;
	}
	hash = hash % MAX_VAR;
	return hash;
}

void init_table(table_s* table){
	table->above = NULL;
	table->below = NULL;
	table->range = current_range;
}

/* TABLE DES SYMBOLES */

table_s* get_current_table(){
	table_s* current_table = table_symbole;
	for(int i = 0; i < current_range; i++){
		current_table = current_table->below;
	}
	return current_table;
}


//Création d'une nouvelle table
int new_table(){
	table_s* current_table = get_current_table();
	current_range++;
	table_s* new_table = calloc(1, sizeof(table_s));
	init_table(new_table);
	new_table->range = current_range;
	new_table->above = current_table;
	current_table->below = new_table;
	//printf("NEW TABLE %d\n", current_range);
	return current_range;
}

//Suppresion de la table de portée courante
int destroy_table(){
	table_s* current_table = get_current_table();
	current_table = current_table->above;
	current_table->below = NULL;
	//printf("DESTROY TABLE %d\n", current_range);
	current_range--;
	return current_range;
}

//Ajout d'un element à la table
int put(int type, char* name){
	int hash;
	table_s* current_table = get_current_table();
	variable* var = calloc(1, sizeof(variable));
	var->type = type;
	var->name = name;
	var->arity = 0;
	var->values = calloc(100, sizeof(int));
	hash = hash_var(name);
	while(current_table->variables[hash] != NULL){
		if(strcmp(current_table->variables[hash]->name, name) == 0){
			if(current_table->mode == 0){ printf("/* WARNING : REDEFINITION "); }
			//redéfinition incohérente
			if(current_table->variables[hash]->type != type){
				if(current_table->mode == 0){ printf("INCOHERENTE DE %s [%s, MAINTENANT %s] */\n", current_table->variables[hash]->name, types[current_table->variables[hash]->type], types[type]); }
				return -1;
			//redéfinition cohérente
			} else {
				if(current_table->mode == 0){ printf("COHERENTE DE %s [%s] */\n", current_table->variables[hash]->name, types[type]); }
				return hash;
			}
			break;
		} else {
			hash = (hash+1)%MAX_VAR;
		}
	}
	current_table->variables[hash] = var;
	return hash;
}

//Recherche d'un element dans une table avec une portée défini
int search_range(char* name, int range){
	table_s* current_table = table_symbole;
	int hash = hash_var(name);
	int searched = 0;
	for(int i = 0; i < range; i++){
		current_table = current_table->below;
	}

	//Possible collision de hash
	while(current_table->variables[hash] != NULL){
		if(strcmp(current_table->variables[hash]->name, name) != 0){
			hash = (hash+1)%MAX_VAR;
			searched++;
			//Si on a fait tout le tableau et qu'il y a toujours des collisions
			if(searched > MAX_VAR){
				return -1;
			}
		} else {
			return hash;
		}
	}
	return -1;
}
	
	

//Recherche d'un element
int search(char* name){
	int range = current_range;
	int found = -1;
	while(found == -1 && range >= 0){
		found = search_range(name, range);
		range--;
	}
	return found;
}

//Recherche le type d'un élément dans la table des symboles
int get_type(char* name){
	int range = current_range;
	int found = -1;
	while(found == -1 && range >= 0){
		found = search_range(name, range);
		range--;
	}
	if(found >= 0){
		table_s* current_table = table_symbole;
		for(int i = 0; i < range+1; i++){
			current_table = current_table->below;
		}
		return current_table->variables[found]->type;
	}
	return -1;
}

//Modifie les valeurs d'un tableaux
int modify_array(char* name, int arity, int* values){
	int range = current_range;
	int found = -1;
	while(found == -1 && range >= 0){
		found = search_range(name, range);
		range--;
	}
	if(found >= 0){
		table_s* current_table = table_symbole;
		for(int i = 0; i < range+1; i++){
			current_table = current_table->below;
		}
		current_table->variables[found]->arity = arity;
		current_table->variables[found]->values = values;
		return 1;
	}
	return 0;
}

//Retourne la variable avec le nom name
variable* get_variable(char* name){
	int range = current_range;
	int found = -1;
	while(found == -1 && range >= 0){
		found = search_range(name, range);
		range--;
	}
	if(found >= 0){
		table_s* current_table = table_symbole;
		for(int i = 0; i < range+1; i++){
			current_table = current_table->below;
		}
		return current_table->variables[found];
	}
	return NULL;
}

int check_operation(char* var1, char* op, char* var2){
	int type1=1, type2=1;
	if(var1 != NULL){
		type1 = get_type(var1);
		if(type1==-1){type1=1;}
	}
	if(var2 != NULL){
		type2 = get_type(var2);
		if(type2==-1){type2=1;}
	}
	if(type1 == 0 || type2 == 0){
		fprintf(stderr, "/* WARNING : TRYING OPERATION WITH VOID TYPE ! */\n");
	}
	if(type1 != type2){
		fprintf(stderr, "/* ERROR : TRYING && OPERATOR ON DIFFERENT TYPES ! (%s %s %s) */\n", types[type1], op, types[type2]);
		return 0;	
	}
	return 1;
}

void change_mode(int mode){
	table_s* table = get_current_table();
	table->mode = mode;
}

/*
int main(){
	table_symbole = calloc(1, sizeof(table_s));
	init_table(table_symbole);	
	printf("CURRENT RANGE : [%d]\n", current_range);
	int pos2 = put(0, "abc");
	new_table();
	int pos = put(1, "cba");
	printf("CURRENT RANGE : [%d]\n", current_range);
	printf("SEARCHING test : [%d]\n", get_type("abc"));
	printf("SEARCHING test : [%d]\n", get_type("cba"));
	destroy_table();
	//printf("SEARCHING test : [%d]\n", get_type("cba"));
	return 1;
}*/
