%{
%}
%token IDENTIFICATEUR CONSTANTE VOID INT FOR WHILE IF ELSE SWITCH CASE DEFAULT
%token BREAK RETURN PLUS MOINS MUL DIV LSHIFT RSHIFT BAND BOR LAND LOR LT GT 
%token GEQ LEQ EQ NEQ NOT EXTERN GOTO
%left PLUS MOINS
%left MUL DIV
%left LSHIFT RSHIFT
%left BOR BAND
%left LAND LOR
%nonassoc THEN
%nonassoc ELSE
%left OP
%left REL
%start programme
%%
programme	:	
		liste_declarations liste_fonctions
;
liste_declarations	:	
		liste_declarations declaration 
	|	
;
liste_fonctions	:	
		liste_fonctions fonction
|               fonction
;
declaration	:	
		type liste_declarateurs ';'
;
liste_declarateurs	:	
		liste_declarateurs ',' declarateur
	|	declarateur
;
declarateur	:	
		IDENTIFICATEUR
| MUL IDENTIFICATEUR
| IDENTIFICATEUR '[' CONSTANTE ']'
;
fonction	:	
		type IDENTIFICATEUR '(' liste_parms ')' '{' liste_declarations liste_instructions '}'
	|	EXTERN type IDENTIFICATEUR '(' liste_parms ')' ';'
;
type	:	
		VOID
	|	INT
;
liste_parms	:	
		liste_parms ',' parm
	|	parm
	|
;
parm	:	
		INT IDENTIFICATEUR
;
liste_instructions :	
		liste_instructions instruction
	|
;
instruction	:	
                instructionlabelisee
	|	saut
	|	affectation 
	|	bloc
	|	appel
;
saut	:	
		GOTO IDENTIFICATEUR ';'
	|	IF '(' condition ')' GOTO IDENTIFICATEUR ';'
        |       RETURN scalaire ';'
	|	RETURN ';'
;
instructionlabelisee: IDENTIFICATEUR ':' instruction ';'
;
affectation	:	
		IDENTIFICATEUR '=' expression ';'
		| IDENTIFICATEUR '=' MUL IDENTIFICATEUR ';'
		| MUL IDENTIFICATEUR '=' scalaire ';'
;
bloc	:	
		'{' liste_declarations liste_instructions '}'
;
appel	:	
		IDENTIFICATEUR '(' liste_scalaires ')' ';'
;
scalaire	:	
		IDENTIFICATEUR
	|	CONSTANTE
;
expression	:	
		scalaire binary_op scalaire 
	|	MOINS scalaire
|       scalaire
|	IDENTIFICATEUR '(' liste_scalaires ')'
;
liste_scalaires	:	
		liste_scalaires ',' scalaire
	|
;
condition	:	
		NOT IDENTIFICATEUR
	|	scalaire binary_rel scalaire %prec REL
	|	scalaire binary_comp scalaire
;
binary_op	:	
		PLUS
	|       MOINS
	|	MUL
	|	DIV
	|       LSHIFT
	|       RSHIFT
	|	BAND
	|	BOR
;
binary_rel	:	
		LAND
	|	LOR
;
binary_comp	:	
		LT
	|	GT
	|	GEQ
	|	LEQ
	|	EQ
	|	NEQ
;
%%
