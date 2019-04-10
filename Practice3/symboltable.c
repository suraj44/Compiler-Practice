#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define PRIME 23
#define MOD 1007

typedef struct Node {
	char str[100], type[100];
	int scope;
	struct Node* next;
} node;	

node * symbolTable[MOD] = {NULL};
node * cTable[MOD] = {NULL};

node * stack[MOD] = {NULL};
int tos =  -1;

int hash(const char *str) {
	int hashval = 0;
	int len = strlen(str);
	for(int i=0; i < len ; i++) {
		hashval = (hashval*PRIME + str[i])%MOD;
	}
	return hashval;
}

node* lookup(const char *str) {
	int hashval = hash(str);
	
	node * temp = cTable[hashval];
	while(temp!=NULL) {
		if(!strcmp(temp->str ,str)) {
			return temp;
		}
		temp = temp->next;
	}
	return NULL;
}

void insertc(const char *str) {
	if(lookup(str) != NULL) {
		return;
	}

	int hashval = hash(str);
	node * temp = (node*)malloc(sizeof(node));
	strcpy(temp->str, str);
	temp->scope = 0;
	temp->next = cTable[hashval];
	cTable[hashval] = temp;
}

void insert(const char *str, char const* type, int scope) {
	int hashval = hash(str);
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
	printf("Line %3d: %s is undeclared\n", yylineno, str);
	exit(1);
}

void redeclared(const char *str, int scope) {
	int i = tos;
	while(i >= 0 && stack[i]->scope ==scope) {
		if(!strcmp(stack[i]->str, str)) {
			printf("Line %3d: %s is redeclared\n", yylineno, str);
			exit(1);
		}
		i--;
	}
	
}

void displayS() {
	printf("-----------------------------------------------------\n");
	printf("%15s %15s %15s\n", "Symbol", "Type" , "Scope");
	printf("-----------------------------------------------------\n");
	for(int i=0;i < MOD; i++) {
		node * temp = symbolTable[i];
		while(temp != NULL) {		
			printf("%15s %15s %15d\n", temp->str, temp->type, temp->scope);
			temp = temp->next;
		}		
	}	
}

void displayC() {
	printf("-----------------------------------------------------\n");
	printf("%30s\n", "Constant");
	printf("-----------------------------------------------------\n");
	for(int i=0;i < MOD; i++) {
		node * temp = cTable[i];
		while(temp != NULL) {		
			printf("%30s\n", temp->str);
			temp = temp->next;
		}		
	}	
}


