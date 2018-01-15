#include "types.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/* Inicializa la pila de tipos. */
void init_types(){
	TYP_STACK.total = -1;
	TYP_STACK.tables = malloc(sizeof(types_table)*100);
	create_types_table();
}

/* Crea una nueva tabla de tipos dentro de la pila de tipos. */
void create_types_table(){
	types_table new_table;
	new_table.types = malloc(sizeof(ttype) * 100);

	(new_table.types + 0)->type = "void";
	(new_table.types + 0)->dim = 0;
	(new_table.types + 0)->base = -1;

	(new_table.types + 1)->type = "int";
	(new_table.types + 1)->dim = 2;
	(new_table.types + 1)->base = -1;

	(new_table.types + 2)->type = "float";
	(new_table.types + 2)->dim = 4;
	(new_table.types + 2)->base = -1;

	(new_table.types + 3)->type = "double";
	(new_table.types + 3)->dim = 8;
	(new_table.types + 3)->base = -1;

	(new_table.types + 4)->type = "char";
	(new_table.types + 4)->dim = 1;
	(new_table.types + 4)->base = -1;

	(new_table.types + 5)->type = "struct";
	(new_table.types + 5)->dim = 0;
	(new_table.types + 5)->base = -1;

	new_table.total = 5;

	TYP_STACK.total++;

	*(TYP_STACK.tables + TYP_STACK.total) = new_table;
}

/* Agrega un tipo a la ultima tabla de la pila. */
int insert_type(ttype t){
	types_table* top = TYP_STACK.tables + TYP_STACK.total;
	(top->total)++;
	*(top->types + top->total) = t;
}

/* Imprime la tabla de tipos que este en la cima de la pila. */
void print_types_table(){
	types_table* top = TYP_STACK.tables + TYP_STACK.total;
	printf("\n*** TABLA DE TIPOS ***\n");
	printf("pos\ttipo\tdim\tbase\n");
	for(int i = 0; i <= top->total; i++)
		printf("%d\t%s\t%d\t%d\n", i, (top->types + i)->type, (top->types + i)->dim, (top->types + i)->base);
}