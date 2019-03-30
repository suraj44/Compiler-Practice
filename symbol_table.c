#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define MOD 1007
#define PRIME 23

typedef struct Node {
	char name[100], type[100];
	struct Node * next;
} node;

node * symbolTable[MOD] = {NULL};

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

void insert(const char *name, const char *type) {
	if(lookup(name) != NULL) 
		return;

	int hashVal = hash(name);
	
	node *temp = (node*)malloc(sizeof(node));
	// printf("in insert %s\n", name);
	strcpy(temp->name,name);
	strcpy(temp->type, type);

	temp->next = symbolTable[hashVal];
	symbolTable[hashVal] = temp;

	
}

void printSymbolTable() {

	printf("---------------------------------------------------------------------------------\n");
	printf("%30s %30s\n", "Data Type", "Symbol");
	printf("---------------------------------------------------------------------------------\n");

	for(int i=0 ; i <MOD;i++) {
		node* temp = symbolTable[i];
		while(temp != NULL) {
			printf("%30s %30s\n", temp->type, temp->name);
			temp = temp->next;
		}
	}
}


