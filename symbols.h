#ifndef SYMBOLS_H
#define SYMBOLS_H

typedef struct _symbol{
    char* id;
    int dir;
    int type;
    int var;
} symbol;


typedef struct _symbols_table{
    symbol* syms;
    int next;
} symbols_table;

symbols_table SYM_TABLE;

void init_table();

int search(char *id);

int insert(symbol sym);

int get_type(char *id);

int get_dir(char *id);

int get_var(char *id);


int set_type(char *id, int type);

int set_dir(char *id, int dir);

int set_var(char *id, int var);

void print_table();

#endif
