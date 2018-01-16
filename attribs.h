#ifndef ATTRIBS_H
#define ATTRIBS_H

#include "intermediate_code.h"

typedef struct _expresion{
    char dir[10];
    int type;
    int first;
} expresion;

typedef struct _condition{
    label ltrue;
    label lfalse;  
    int first;  
} condition;

typedef struct _num{
    int type;
    int ival;
    double dval;
    float fval;
} num;

typedef struct _sentence{
    label lnext;
    int first;    
} sentence;

typedef struct _type{
    int type;
    int dim;
} type;

typedef struct _args_list{
    int* args;
    int total;
} args_list;

#endif
