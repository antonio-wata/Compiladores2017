#ifndef TYPE_TABLE_H
#define TYPE_TABLE_H

#include <stdio.h>
#include <string.h>

/* Estructura para un tipo. */
// type - Guarda el tipo.
// dim - Dimension del tipo.
// base - Base del tipo.
typedef struct _type{
	char* type;
	int dim;
	int base;
} type;

/* Estructura de la tabla de tipos. */
// types - Lista de tipos.
// total - Total de tipos guardados.
typedef struct _types_table{
	type* types;
	int total;
} types_table;

/* Pila que guardara las tablas de tipos. */
// tables - Lista de tablas.
// total - Total de tablas guardados.
typedef struct _types_stack{
	types_table* tables;
	int total;
} types_stack;

/* Tabla de tipos global del compilador. */
types_table TYP_TABLE;

/* Pila de tablas de tipos del compilador. */
types_stack TYP_STACK;

// FUNCIONES:

void init_table();
int insert_type(type t);
void print_table();

#endif