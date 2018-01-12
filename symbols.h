#ifndef SYMBOLS_H
#define SYMBOLS_H

/* Estructura de una lista de parametros. */
// type - La cabeza de la lista.
// next_arg - La cola de la lista.
typedef struct _list_args list_args;
struct _list_args{
	char* type;
	list_args* next_arg;
};

/* Estructura de un simbolo */
// id - Identificador
// var - Clase de simbolo (variable, funcion, paramentro).
// type - Tipo del simbolo.
// dir - Direccion donde se encentra.
// num_args - Numero de parametros, si es que tiene.
typedef struct _symbol{
    char* id;
    char* var;
    char* type;
    int dir;
    int num_args;
    list_args type_args;
} symbol;

/* Estructura de la tabla de simbolos. */
// symbols - Lista de simbolos.
// total - Total de simbolos guardados.
typedef struct _symbols_table{
    symbol* symbols;
    int total;
} symbols_table;

/* Pila que guardara las tablas de simbolos. */
// tables - Lista de tablas.
// total - Total de tablas guardadas.
typedef struct _symbols_stack symbols_stack;
struct _symbols_stack{
	symbols_table* tables;
	int total;
};

/* Tabla de simbolos global del compilador */
symbols_table SYM_TABLE;

/* Pila de tabla de simbolos del compilador */
symbols_stack SYM_STACK;

// FUNCIONES:

void init_table();

char* get_List_Types(list_args* args);

int search_scope(char *id);

int search_global(char *id);

void insert_symbol(symbol sym);

char* get_type(char *id);

int get_dir(char *id);

char* get_var(char *id);

int set_type(char *id, int type);

int set_dir(char *id, int dir);

int set_var(char *id, int var);

void print_table();

#endif
