//Initialise l'arbre
void init_arbre(struct Block* block, char* variable, char* racine, struct Arbre* gauche, struct Arbre* droit){
	struct Arbre* arbre = calloc(1, sizeof(struct Arbre));
	arbre->variable = variable;
	arbre->racine = racine;
	arbre->gauche = gauche;
	arbre->droit = droit;
	arbre->isReturn = 0;
	arbre->feuille = (gauche == NULL) && (droit == NULL);
	char* value = "";
	block->arbre = arbre;
	arbre->minus = 0;
}

void printArbre(struct Arbre* arbre, int indent){
	char* indentation = calloc(indent, sizeof(char));
	for(int i = 0; i < indent; i++){
		strcat(indentation, "\t");	
	}
	printf("%sPERE : %s\n", indentation, arbre->racine);
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
	if(arbre->feuille != 0){
		if(arbre->minus != 0){
			char* neg = calloc(strlen(arbre->value) + 2, sizeof(char));
			concatenate(neg, 2, "-", arbre->value);
			return neg;
		}
		return arbre->value;
	}
	if(arbre->minus != 0){
		char* neg = calloc(strlen(arbre->variable) + 2, sizeof(char));
		concatenate(neg, 2, "-", arbre->variable);
		return neg;
	}
	return arbre->variable;
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
			char* value = calloc(strlen(arbre->variable) + strlen(gauche) + strlen(droit) + strlen(arbre->racine) + 3, sizeof(char));
			concatenate(value, 6, arbre->variable, "=", gauche, arbre->racine, droit, ";\n");
			arbre->value = arbre->variable;
			insert_block(block, value);
		} else {
			char* value = calloc(strlen(gauche) + strlen(droit) + strlen(arbre->racine) + 1, sizeof(char));
			concatenate(value, 3, gauche, arbre->racine, droit);
			arbre->variable = value;
		}
	} else {
		arbre->value = arbre->racine;
	}
	block->value = arbre_getValue(arbre);
	block->arbre = arbre;
}
