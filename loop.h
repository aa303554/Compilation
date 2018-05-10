#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int label_number = 0; //Nombre d'étiquettes créées par le compilateur

/* Fourni une nouvelle étiquette */
char* new_label(){
	char* label = calloc(4, sizeof(char));
	label_number++;
	sprintf(label, "L%d", label_number);
	return label;
}

/* Initialise la boucle */
void init_loop(struct Loop *loop){
	loop->size = 1024;
	loop->length = 0;
	loop->code = calloc(loop->size, sizeof(char));
	loop->condition = calloc(1024, sizeof(char));
	loop->if_label = new_label();
	loop->else_label = new_label();
}

void build(struct Loop *loop){
	//On créer l'entête de la boucle (e : "L1: if (i < 100) goto L2;")
	int header_length = strlen(loop->if_label) + strlen(loop->condition) + strlen(loop->else_label) + 14;
	char* header = calloc(header_length, sizeof(char));
	sprintf(header, "%s: if %s goto %s;\n", loop->if_label, loop->condition, loop->else_label);
	
	//On créer le bas de la boucle (e : goto L1)
	int footer_length = strlen(loop->if_label) + 8 + strlen(loop->else_label);
	char* footer = calloc(footer_length, sizeof(char));
	sprintf(footer, "goto %s;\n%s:", loop->if_label, loop->else_label);

	//On assemble le code
	int length = strlen(header) + strlen(footer) + strlen(loop->instructions) + strlen(loop->affectation1) + strlen(loop->affectation2);
	char* code = calloc(loop->size, sizeof(char));
	while(loop->size < length){
		loop->size = loop->size * 2;
		char* code = calloc(loop->size, sizeof(char));
		loop->code = code;
	}
	strcat(loop->code, loop->affectation1);
	strcat(loop->code, ";\n");
	strcat(loop->code, header);
	strcat(loop->code, loop->instructions);
	strcat(loop->code, loop->affectation2);
	strcat(loop->code, "\n");
	strcat(loop->code, footer);
}

void create(struct Loop *loop, char* affectation1, char* condition, char* affectation2, char* instructions){
	loop->affectation1 = affectation1;
	loop->condition = condition;
	loop->affectation2 = affectation2;
	loop->instructions = instructions;
	build(loop);
}
