#define MAX_VAR 512

#define VIDE 0
#define ENTIER 1
#define POINTEUR 2

typedef struct _variable{
	int type;
	char* name;
} variable;

typedef struct _table_s{
	struct _table_s* above;
	struct _table_s* below;
	variable* variables[MAX_VAR];
	
	int range;
} table_s;

int put(int type, char* name);
int check_operation( char* var1, char* op, char* var2);
