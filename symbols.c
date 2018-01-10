#include "symbols.h"
#include <stdio.h>
#include <string.h>

void init_table(){
    symbols_table SYM_TABLE;
    SYM_TABLE.next=0;
}

int search(char *id){
    for(int i = 0; i <= SYM_TABLE.next; i++){
        if(strcmp(id, (SYM_TABLE.syms+i)->id)==0){
            return i;
        }
    }
    return -1;
}

int insert(symbol sym){
    int pos = search(sym.id);
    
    if(SYM_TABLE.next<1000 && pos ==-1){        
        *(SYM_TABLE.syms+SYM_TABLE.next) = sym;
        SYM_TABLE.next++;
        return SYM_TABLE.next;
    }
    return -1;
}
    

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


void print_table(){
    printf("*** TABLA DE SIMBOLOS ***\n");
    printf("pos\tid\ttipo\tdir\tvar\n");
    for(int i = 0; i<SYM_TABLE.next; i++){
        printf("%d\t%s\t%d\t%d\t%d\n",i,(SYM_TABLE.syms+i)->id, (SYM_TABLE.syms+i)->type, (SYM_TABLE.syms+i)->dir, (SYM_TABLE.syms+i)->var);
    }
}
