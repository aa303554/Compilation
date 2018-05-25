

void setAntiracine(struct Arbre* arbre, char* racine){
	char symbols[6][3] = {"<", ">", "<=", ">=", "==", "!="};
	char antisym[6][3] = {">=", "<=", ">", "<", "!=", "=="};
	for(int i = 0; i < 6; i++){
		if(strcmp(racine, symbols[i]) == 0){
			char* antiracine = calloc(3, sizeof(char));
			strcpy(antiracine, antisym[i]);
			arbre->antiracine = antiracine;
			return;
		}
	}
}

//Initialise l'arbre
void init_arbre(struct Block* block, char* variable, char* racine, struct Arbre* gauche, struct Arbre* droit){
	struct Arbre* arbre = calloc(1, sizeof(struct Arbre));
	arbre->variable = variable;
	arbre->racine = racine;
	setAntiracine(arbre, racine);
	arbre->gauche = gauche;
	arbre->droit = droit;
	arbre->isReturn = 0;
	arbre->feuille = (gauche == NULL) && (droit == NULL);
	char* value = "";
	block->arbre = arbre;
	arbre->minus = 0;
	arbre->parenthesis = 0;
	arbre->isnot = 0;
	arbre->antiarbre = 0;
	arbre->array_name = NULL;
	arbre->function_name = NULL;
}

//Renvoie la racine d'un arbre
char* arbre_getRacine(struct Arbre* arbre){
	if(arbre->antiarbre != 0){
		return arbre->antiracine;
	}
	return arbre->racine;
}

void printArbre(struct Arbre* arbre, int indent){
	char* indentation = calloc(indent, sizeof(char));
	for(int i = 0; i < indent; i++){
		strcat(indentation, "\t");	
	}
	printf("%sPERE : %s\n", indentation, arbre_getRacine(arbre));
	indent++;
	if(arbre->gauche != NULL){
		printf("%sFILS GAUCHE :\n", indentation);
		printArbre(arbre->gauche,indent);
	}
	if(arbre->droit != NULL){
		printf("%sFILS DROIT :\n", indentation);
		printArbre(arbre->droit,indent);
	}
}

//Renvoie la valeur d'un arbre.
char* arbre_getValue2(struct Arbre* arbre){
	char* neg = calloc(2, sizeof(char));
	char* isnot = calloc(2, sizeof(char));
	char* val;
	if(arbre->feuille != 0){
		val = arbre->value;
	} else {
		val = arbre->variable;
	}
	if(arbre->minus != 0){
		concatenate(neg, 1, "-");
	}
	if(arbre->isnot != 0){
		concatenate(isnot, 1, "!");
	}
	if(arbre->parenthesis != 0){
		char* parenthesis = calloc(strlen(val) + strlen(neg) + strlen(isnot) + 3, sizeof(char));
		concatenate(parenthesis, 5, isnot, "(", neg, val, ")");
		return parenthesis;
	}
	char* res = calloc(strlen(val) + strlen(neg) + strlen(isnot) + 1, sizeof(char));
	concatenate(res, 3, isnot, neg, val);
	return res;
}

char* arbre_getValue(struct Arbre* arbre){
	if(arbre->function_name != NULL){
		char* value = arbre_getValue2(arbre);
		char* res = calloc(strlen(arbre->function_name) + strlen(value) + 3, sizeof(char));
		concatenate(res, 4, arbre->function_name, "(", value, ")");
		return res;
	} else if(arbre->array_name != NULL){
		char* value = arbre_getValue2(arbre);
		char* res = calloc(strlen(arbre->array_name) + strlen(value) + 3, sizeof(char));
		concatenate(res, 4, arbre->function_name, "[", value, "]");
		return res;
	} else {
		return arbre_getValue2(arbre);
	}
}

//Evalue l'arbre. Rajoute de façon dynamique le code évalué dans le bloc.
void arbre_eval(struct Arbre* arbre, struct Block *block){
	if(arbre->feuille == 0){
		char* gauche = "";
		char* droit = "";
		arbre->gauche->isReturn = 1;
		arbre_eval(arbre->gauche, block);
		gauche = arbre_getValue(arbre->gauche);
		arbre->droit->isReturn = 1;
		arbre_eval(arbre->droit, block);
		droit = arbre_getValue(arbre->droit);
		if((arbre->isReturn != 0 || !(arbre->gauche->feuille != 0 && arbre->droit->feuille != 0)) && arbre->racine != ","){
			//si l'arbre n'est pas celui de départ, alors on doit lui rajouter une variable temporaire
			if(arbre->variable == ""){
				arbre->variable = new_tmp(block);	//fonction de block.h pour ajouter une variable temporaire;
			}
			//taille de la variable + "=" + l'evaluation de gauche + droite + racine + ";" + \0
			char* value = calloc(strlen(arbre->variable) + strlen(gauche) + strlen(droit) + strlen(arbre_getRacine(arbre)) + 3, sizeof(char));
			concatenate(value, 6, arbre->variable, "=", gauche, arbre_getRacine(arbre), droit, ";\n");
			arbre->value = arbre->variable;
			insert_block(block, value);
		} else {
			char* value = calloc(strlen(gauche) + strlen(droit) + strlen(arbre_getRacine(arbre)) + 1, sizeof(char));
			concatenate(value, 3, gauche, arbre_getRacine(arbre), droit);
			arbre->variable = value;
		}
	} else {
		arbre->value = arbre_getRacine(arbre);
	}
	if(arbre->function_name != NULL){
		char* val = arbre_getValue(arbre);
		arbre->variable = new_tmp(block);
		char* new_value = calloc(strlen(val) + strlen(arbre->variable) + 4, sizeof(char));
		concatenate(new_value, 4, arbre->variable, "=", val, ";\n");
		arbre->value = arbre->variable;
		insert_block(block, new_value);
		arbre->function_name = NULL;
	}
	if(arbre->array_name != NULL){
		/* t[i] -> [t : array_name] ; [i : val] */
		char* array_name = arbre->array_name;
		arbre->array_name = NULL;

		char* val = arbre_getValue(arbre);
		char* pointer = new_pnt(block);

		char* offset = calloc(strlen(val) + strlen(pointer) + strlen(array_name) + 5, sizeof(char));
		// _tX = t + i;
		concatenate(offset, 6, pointer, "=", array_name, "+", val, ";\n");
		insert_block(block, offset);
		if(arbre->infunction == 1){
			char* new_value = new_tmp(block);
			char* to_pnt = calloc(strlen(pointer) + strlen(new_value) + 4, sizeof(char)); //_t3=*_t2;
			concatenate(to_pnt, 4, new_value, "=*", pointer, ";\n");
			arbre->value = new_value;
			arbre->variable = new_value;
			insert_block(block, to_pnt);
		} else {
			char* new_value = calloc(strlen(pointer) + 2, sizeof(char));
			concatenate(new_value, 2, "*", pointer);
			arbre->value = new_value;
			arbre->variable = new_value;
		}
	}
	block->value = arbre_getValue(arbre);
	block->arbre = arbre;
}
