

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
char* arbre_getValue(struct Arbre* arbre){
	char* neg = calloc(2, sizeof(char));
	char* isnot = calloc(2, sizeof(char));	
	if(arbre->minus != 0){
		concatenate(neg, 1, "-");
	}
	if(arbre->isnot != 0){
		concatenate(isnot, 1, "!");
	}
	if(arbre->feuille != 0){
		if(arbre->parenthesis != 0){
			char* parenthesis = calloc(strlen(arbre->value) + strlen(neg) + strlen(isnot) + 3, sizeof(char));
			concatenate(parenthesis, 5, isnot, "(", neg, arbre->value, ")");
			return parenthesis;
		}
		char* res = calloc(strlen(arbre->value) + strlen(neg) + strlen(isnot) + 1, sizeof(char));
		concatenate(res, 3, isnot, neg, arbre->value);
		return res;
	}
	if(arbre->parenthesis != 0){
		char* parenthesis = calloc(strlen(arbre->variable) + strlen(neg) + strlen(isnot) + 3, sizeof(char));
		concatenate(parenthesis, 5, isnot, "(", neg, arbre->variable, ")");
		return parenthesis;
	}
	char* res = calloc(strlen(arbre->variable) + strlen(neg) + strlen(isnot) + 1, sizeof(char));
	concatenate(res, 3, isnot, neg, arbre->variable);
	return res;
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
		if(arbre->isReturn != 0 || !(arbre->gauche->feuille != 0 && arbre->droit->feuille != 0)){
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
	block->value = arbre_getValue(arbre);
	block->arbre = arbre;
}
