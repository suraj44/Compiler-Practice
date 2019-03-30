#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "lex.yy.c"

#define MOD 1007
#define PRIME 23
#define BIG_NUMBER 1000



typedef struct Node {
	char name[100], type[100];
	struct Node * next;
	int scope;
	int num_params;
	int arr_dim;
} node;

node * symbolTable[MOD] = {NULL};
node * stack[BIG_NUMBER];
int curr_scope = 0;
int tos = -1;

int hash(const char *str) {
	int len = strlen(str);
	int hashVal = 0;
	for(int i=0 ; i < len ; i++) {
		hashVal = (hashVal * PRIME + str[i]) % MOD;
	}
	return hashVal;
}

node * lookup(const char *str) {
	int len = strlen(str);
	int hashVal = hash(str);

	node* temp = symbolTable[hashVal];

	while(temp != NULL) {
		if(!strcmp(temp->name,str))
			return temp;
	}

	return NULL;
}	

node*  insert(const char *name, const char *type, int scope) {
	int hashVal = hash(name);
	
	node *temp = (node*)malloc(sizeof(node));
	// printf("in insert %s\n", name);
	strcpy(temp->name,name);
	strcpy(temp->type, type);
	temp->scope = scope;
	temp->num_params = -1;
	temp->arr_dim = -1;

	temp->next = symbolTable[hashVal];
	symbolTable[hashVal] = temp;
	stack[++tos] = temp;

	return temp;

	
}

void undeclared(const char * str) {
	int ptr = tos;
	while(ptr >= 0) {
		printf("stack %s\n", stack[ptr]->name);
		if(!(strcmp(stack[ptr]->name, str)))
			return;
		ptr--;
	}
	printf("Line %3d: %s has not been declared.\n", yylineno, str);
	// exit(1);
}

void redeclared(const char * str) {
	int ptr = tos;
	while(ptr >=0 && stack[ptr]->scope == curr_scope) {
		if(!strcmp(stack[ptr]->name, str)) {
			printf("Line %3d: %s has been redeclared.\n", yylineno, str);
			exit(1);		
		}
		ptr--;
	}

}

void not_function(const char * str) {
	int ptr = tos;
	while(ptr >= 0) {
		if(!(strcmp(stack[ptr]->name, str))) {
			if(stack[ptr]->num_params == -1) {
				printf("Line %3d: %s is not a function.\n", yylineno, str);	
				exit(1);		
			}
		}
		ptr--;
	}
}

void num_params_check(const char *str, int call_params) {
	int ptr = tos;
	while(ptr >= 0) {
		if(!strcmp(stack[ptr]->name, str)) {
			if(stack[ptr]->num_params != call_params) {
				printf("Line %3d: Function call has unequal number of parameters as function arguments\n", yylineno);
				exit(1);
			}
		}
		ptr--;
	}
}

void non_negative_size(int size) {
	if(size < 0) {
		printf("Line %3d: Size of array cannot be negative\n", yylineno);
		exit(1);
	}
}

void array_dim_check(const char *str, int size) {
	int ptr = tos;
	while(ptr >=0) {
		if(!strcmp(stack[ptr]->name, str)) {
			if(size >= stack[ptr]->arr_dim) {
				printf("Line %3d: Cannot access index %d out of declared range %d\n", yylineno, size, stack[ptr]->arr_dim); 
				exit(1);
			} 
		}
		ptr--;
	}
}



void printSymbolTable() {

	printf("----------------------------------------------------------------------------------------------------------\n");
	printf("%15s %15s %15s %15s %15s\n", "Data Type", "Symbol", "Scope", "Num Params", "Array Dims");
	printf("----------------------------------------------------------------------------------------------------------\n");

	for(int i=0 ; i <MOD;i++) {
		node* temp = symbolTable[i];
		while(temp != NULL) {
			printf("%15s %15s %15d %15d %15d\n", temp->type, temp->name, temp->scope, temp->num_params, temp->arr_dim);
			temp = temp->next;
		}
	}
}


