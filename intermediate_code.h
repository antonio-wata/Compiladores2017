#ifndef INTERMEDIATE_CODE_H
#define INTERMEDIATE_CODE_H

#include <string.h>


typedef struct _quad
{
	char op[20];
	char arg1[50];
	char arg2[20];
	char res[20];
} quad;

typedef struct _intermediate_code
{
	quad items[10000];
	int i;
} intermediate_code;

typedef struct _label
{
	int items[100];
	int i;
} label;

intermediate_code CODE;

void init_code();

int gen_code(char *op , char *arg1, char *arg2, char *res);


label create_list(int l);

label merge(label l1, label l2);

void backpatch(label l, int inst);

void print_code();
#endif
