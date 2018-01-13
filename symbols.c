#include "symbols.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/* Inicializa la tabla de simbolos. */
void init_table(){
    SYM_TABLE.symbols = malloc(sizeof(symbol) * 1000);
    SYM_TABLE.total = -1;
    SYM_STACK.tables = malloc(sizeof(symbols_table) * 1000);
    *(SYM_STACK.tables) = SYM_TABLE;
    SYM_STACK.total = 0;
}

/* Funcion que obtiene los tipos de la lista pasada como parametros */
// Funcion auxiliar de print_table().
/*
char* get_list_types(list_args* args){
    char* str_list;
    while(args != NULL){
        if(args->type != NULL){
            strcat(str_list, args->type);
            strcat(str_list, " ");
        }
        args = args->next_arg;
    }
    return str_list;
}

/* Funcion que busca el identificador en el mismo alcance. */
int search_scope(char *id){
    printf("Buscando %s...\n", id);
    symbols_table* top = SYM_STACK.tables + SYM_STACK.total;
    for(int i = 0; i <= top->total; i++)
        if(strcmp(id, (top->symbols + i)->id) == 0)
            return i;
    return -1;
}

/* Funcion que busca el identificador en todas las tablas. */
int search_global(char *id){
    int j = SYM_STACK.total;
    symbols_table* tabla_actual = SYM_STACK.tables + SYM_STACK.total;
    while(j >= 0){
        for(int i = 0; i <= tabla_actual->total; i++)
            if(strcmp(id, (tabla_actual->symbols + i)->id) == 0)
                return i;
        j--;
        tabla_actual = SYM_STACK.tables + j;
    }
    return -1;
}

/* Funcion que agrega un simbolo a la tabla de simbolos actual. */
void insert_symbol(symbol sym){
    printf("Agregando %s a la tabla...\n", sym.id);
    symbols_table* scope = SYM_STACK.tables + SYM_STACK.total;
    (scope->total)++;
    *(scope->symbols + scope->total) = sym;
}

/*
int get_type(char *id){
    int pos = search(id);
    if(pos != -1){
        return (SYM_TABLE.syms+pos)->type;
    }
    return -1;
}


int get_dir(char *id){
    int pos = search(id);
    if(pos != -1){
        return (SYM_TABLE.syms+pos)->dir;
    }
    return -1;
}

int get_var(char *id){
    int pos = search(id);
    if(pos != -1){
        return (SYM_TABLE.syms+pos)->var;
    }
    return -1;
}


int set_type(char *id, int type){
    int pos = search(id);
    if(pos != -1){
        (SYM_TABLE.syms+pos)->type = type;
        return pos;
    }
    return -1;
}

int set_dir(char *id, int dir){
    int pos = search(id);
    if(pos != -1){
        (SYM_TABLE.syms+pos)->dir= dir;
        return pos;
    }
    return -1;
}

int set_var(char *id, int var){
    int pos = search(id);
    if(pos != -1){
        (SYM_TABLE.syms+pos)->var = var;
        return pos;
    }
    return -1;
}
*/

void print_table(){
    symbols_table* top = SYM_STACK.tables + SYM_STACK.total;
    printf("*** TABLA DE SIMBOLOS ***\n");
    printf("pos\tid\ttipo\tdir\tvar\t\t#args\ttipo_args\n");
    for(int i = 0; i < top->total; i++)
        printf("%d\t%s\t%d\t%d\t%s\t%d\t%s\n", i, (top->symbols + i)->id, (top->symbols + i)->type, (top->symbols + i)->dir, (top->symbols + i)->var, (top->symbols + i)->num_args);
}
