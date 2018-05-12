struct Arbre{
	char* racine;	//symbole de la racine. ex : "*", "+", "variable", "4", etc...
	Arbre* gauche;	//fils gauche. null si pas de fils (-> la racine n'est pas une opération)
	Arbre* droit;	//file droit. null si pas de fils (-> la racine n'est pas une opération)
	int feuille;	//booléen. 0 si ce n'est pas une feuille, 1 si c'est une feuille
	char* value;	//evaluation de l'arbre.
	char* variable;	//nom de la variable dans laquelle est stockée le resultat de l'expression. Si la racine est une opération, alors value prend la valeur d'une variable temporaire.
}

//Initialise l'arbre
void init_arbre(struct Arbre* arbre, char* variable, char* racine, struct Arbre* gauche, struct Arbre* droit){
	arbre->variable = variable;
	arbre->racine = racine;
	arbre->gauche = gauche;
	arbre->droit = droit;
	arbre->feuille = (gauche == null) && (droit == null);
	char* value = "";
}

//Renvoie la valeur d'un arbre.
char* arbre_getValue(struct Arbre* arbre){
	if(arbre->feuille){
		return arbre->value;
	}
	return arbre->variable;
}

//Evalue l'arbre. Rajoute de façon dynamique le code évalué dans l'expression.
void arbre_eval(struct Arbre* arbre, struct Expression *expr){
	if(arbre->feuille){
		arbre->value = arbre->racine;
	} else {
		arbre_eval(arbre->gauche);
		arbre_eval(arbre->droit);
		//si l'arbre n'est pas celui de départ, alors on doit lui rajouter une variable temporaire
		if(arbre->variable == ""){
			arbre->variable == new_tmp(expr);	//fonction d'expression.h pour ajouter une variable temporaire;
		}
		char* gauche = arbre_getValue(arbre->gauche);
		char* droit = arbre_getValue(arbre->droit);
		//taille de la variable + "=" + l'evaluation de gauche + droite + racine + ";" + \0
		char* value = calloc(strlen(arbre->variable) + strlen(gauche) + strlen(droite) + strlen(racine) + 3, sizeof(char));
		concatenate(value, 5, arbre->variable, "=", gauche, racine, droite, ";");
		arbre->value = value;
		//ajoute l'évaluation de l'arbre à l'expression
		expr_insert(expr, arbre->value);
	}
}
