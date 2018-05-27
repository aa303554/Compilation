#define MAX_VAR 512

#define VIDE 0
#define ENTIER 1
#define POINTEUR 2

typedef struct _variable{
	int type;	//type de la variable
	char* name;	//nom de la variable
	//Tableaux
	int arity;	//arité de la variable
	int* values;	//valeurs ou types des éléments. (t[3][4] => values = [3, 4])
			//fonction(int x, int y) => values = [1, 1]
} variable;

typedef struct _table_s{
	struct _table_s* above;		//Table des symboles au dessus dans la pile
	struct _table_s* below;		//Table des symboles en dessous dans la pile
	variable* variables[MAX_VAR];	//Variables déclarées
	
	int range;			//Portée de la table
	int mode;			//Mode de la table (debug : temporaire 1 ou normal 0)
} table_s;

//hachage de name
int hash_var(char* name);
//initialise la table de symbole
void init_table(table_s* table);
//empile une nouvelle table
int new_table();
//détruit la table courante
int destroy_table();
//ajout d'un element à la table
int put(int type, char* name);
//recherche un élément dans la table des symboles
int search(char* name);
//renvoie le type d'un élement
int get_type(char* name);
//modifie les valeurs d'un tableau
int modify_array(char* name, int arity, int* values);
//retourne la variable de nom name
variable* get_variable(char* name);
//vérifie la validité d'une opération entre deux élements
int check_operation( char* var1, char* op, char* var2);
