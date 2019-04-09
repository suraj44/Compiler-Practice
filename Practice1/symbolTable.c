#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MOD 1007
#define PRIME 23


typedef struct Node {
	char str[100], type[100];
	int scope;
	int num_params;
	int array_dims;
	struct Node * next;

} node;

node * symbolTable[MOD] = {NULL};
node * stack[1000];
int tos = -1;

int hash(const char * str) {
	int len = strlen(str);
	int hashVal = 0;
	for(int i=0; i < len;i++) {
		hashVal = (hashVal*PRIME + str[i]) % MOD;
	}

	return hashVal;

}


node * lookup(const char *str) {

	int hashVal = hash(str);
	
	node * temp = symbolTable[hashVal];

	while(temp != NULL) {
		if(!strcmp(str, temp->str)) {
			return temp;
		}
	}

	return NULL;
}

void undeclared(const char *str) {
	int i = tos;
	while(i >= 0) {
		if(!strcmp(stack[i]->str, str)) {
			return;
		}
		i--;
	}
	printf("\n");
	printf("Line %3d: %s is undeclared\n", yylineno, str);
	exit(1);
}

void redeclared(const char *str, int scope) {
	int i = tos;
	while( i >=0 && stack[i]->scope == scope) {
		if(!strcmp(str, stack[i]->str) ){
			printf("Line %3d: %s redeclared\n", yylineno, str);
			exit(1);		
		}
	i--;
	} 
}

void setfunc(int params) {
	stack[tos]->num_params = params;
}

void isfunc(const char *str) {
	int i = tos;
	while(i >=0) {
		if(!strcmp(stack[i]->str, str)) {
			if(stack[i]->num_params == -1) {
				printf("Line %3d: %s is not a function\n", yylineno, str);
				exit(1);
			}
		}
	i--;
	}
}

void check_params(const char *str, int params) {

	int i = tos;
	while(i >=0) {
		if(!strcmp(stack[i]->str, str)) {
			if(stack[i]->num_params == params) {
				return;
			} 
			printf("Line %3d: Expected %d arguments, but got %d\n", yylineno, stack[i]->num_params, params);
			exit(1);
			
		}
	i--;
	}
	
}

void setarray(int dims) {
	stack[tos]->array_dims = dims;
}

void isarr(const char *str) {
	int i = tos;
	while(i >=0) {
		if(!strcmp(stack[i]->str, str)) {
			if(stack[i]->array_dims == -1) {
				printf("Line %3d: %s is not an array\n", yylineno,str);
			exit(1);
			} 
			
			
		}
	i--;
	}
}

void checkdims(const char *str, int dims) {
	int i = tos;
	if(dims < 0) {
		printf("Line %3d: Array dimensions cannot be negative\n", yylineno);
		exit(1);
	}
	while(i >=0) {
		if(!strcmp(stack[i]->str, str)) {
			if(dims >= stack[i]->array_dims) {
				printf("Line %3d: Out of bound array access \n", yylineno);
			exit(1);
			} 
			
			
		}
	i--;
	}

}

void insert(const char *name, const char *type, int scope) {
	int hashVal = hash(name);
	node * temp = (node*)malloc(sizeof(node));
	strcpy(temp->str, name);
	strcpy(temp->type, type);
	temp->scope = scope;
	temp->num_params = -1;
	temp->array_dims = -1;
	temp->next = symbolTable[hashVal];
	symbolTable[hashVal] = temp;
	stack[++tos] = temp;
}

void displayTable() {

	printf("------------------------------------------------------------------------------\n");
	printf("%15s %15s %15s %15s %15s\n", "Data Type", "Symbol", "Scope", "Params", "Array Dims");
	printf("------------------------------------------------------------------------------\n");

	for(int i=0 ;i < MOD;i++) {
		node * temp = symbolTable[i];
		while(temp != NULL) {
			printf("%15s %15s %15d %15d %15d\n", temp->type, temp->str, temp->scope, temp->num_params, temp->array_dims);
			temp = temp->next;
		}
	}
}
