#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define MOD 1007
#define PRIME 23

typedef struct Node {
	char str[100], type[100];
	int scope;
	struct Node * next;
} node;

node * symbolTable[MOD] = {NULL};
node * constantTable[MOD] = {NULL};
node* stack[MOD];
int tos = -1;

int hash(const char *str) {
	int len = strlen(str);
	int hashval = 0;
	for(int i=0; i < len ;i++) {
		hashval = (hashval* PRIME + str[i])%MOD;
	}
	return hashval;
}


node * lookup(const char *str) {
	int hashval = hash(str);
	node* temp = symbolTable[hashval];
	while(temp != NULL) {
		if(!strcmp(str, temp->str)) {
			return temp;
		}
	}
	return NULL;
}

void insertc(char * str) {

	node * temp = lookup(str);
	if(temp != NULL) 
		return;

	int hashval = hash(str);
	
	temp = (node*)malloc(sizeof(node));
	strcpy(temp->str, str);
	
	temp->next = constantTable[hashval];
	constantTable[hashval] = temp;
}

void insert(char * str, char * type, int scope) {

	int hashval = hash(str);
	printf("inserting %s\n", str);
	
	node * temp = (node*)malloc(sizeof(node));
	strcpy(temp->str, str);
	strcpy(temp->type, type);
	temp->scope = scope;
	temp->next = symbolTable[hashval];
	symbolTable[hashval] = temp;
	
	stack[++tos] = temp;
}

void undeclared(const char *str) {
	int i = tos;
	while(i >= 0) {
	if(!strcmp(stack[i]->str, str)) {
		return;
	}
	i--;
	}
	printf("Line %3d: %s Undeclared\n", yylineno, str);
	exit(1);
}

void redec(const char * str, int scope) {
	int i = tos;
	printf("looking for %s\n", str);
	while(i >= 0 && stack[i]->scope == scope) {
		printf("%s " , stack[i]->str);
		if(!strcmp(stack[i]->str, str)) {
			printf("Line %3d: %s Redeclared\n", yylineno, str);
			exit(1);
		}
		i--;
	}
	printf("\n");
	
}

void displaytable() {
	printf("------------------------------------------------------\n");
	printf("%15s %15s %15s\n", "Symbol", "Type" ,"Scope");
	printf("------------------------------------------------------\n");
	for(int i =0; i < MOD; i++) {
		node* temp = symbolTable[i];
		while(temp != NULL){
			printf("%15s %15s %15d\n", temp->str, temp->type, temp->scope);
			temp= temp->next;		
		}
	}
}

void displayConst() {
	printf("------------------------------------------------------\n");
	printf("%15s\n", "Constant");
	printf("------------------------------------------------------\n");
	for(int i =0; i < MOD; i++) {
		node* temp = constantTable[i];
		while(temp != NULL){
			printf("%15s\n", temp->str);
			temp= temp->next;		
		}
	}
}
