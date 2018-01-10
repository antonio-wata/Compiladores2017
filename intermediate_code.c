#include "intermediate_code.h"
#include <stdio.h>

void init_code(){
	CODE.i =0;
}

int gen_code(char *op , char *arg1, char *arg2, char *res){
	quad q;
	strcpy(q.op, op);
	strcpy(q.arg1, arg1);
	strcpy(q.arg2, arg2);
	strcpy(q.res, res);

	CODE.items[CODE.i] = q;
	CODE.i++;
	return CODE.i -1;
}


label create_list(int l){
	label list;
	list.i=0;
	list.items[list.i] = l;
	list.i++;
	return list;
}

label merge(label l1, label l2){
	label l;
	l = l1;
	for(int i=0; i<l2.i; i++){
		l.items[l.i] = l2.items[i];
		l.i++;
	}
	return l;
}

void backpatch(label l, int inst){
	for(int i = 0; i < l.i ; i++){		
		sprintf(CODE.items[l.items[i]].res, "%d", inst);
	}
}

void print_code(){
    printf("*** CODIGO INTERMEDIO ***\n");
    printf("inst\top\targ1\targ2\tres\n");
    for(int i=0; i <CODE.i ;i++){
        printf("%d\t%s\t%s\t%s\t%s\n",i, CODE.items[i].op, CODE.items[i].arg1, CODE.items[i].arg2, CODE.items[i].res);
    }
}
