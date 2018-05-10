#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct Expression{
	int size;
	int length;
	int temp_var;
	
	char* declarations;
	char* code;
}

void init_expr(struct Expression *expr){
	expr->size = 1024;
	expr->length = 0;
	epxr->decl_length = 0;
	expr->temp_var = 0;
	
	expr->declarations = calloc(expr->size, sizeof(char));
	expr->code = calloc(expr->size, sizeof(char));
}
