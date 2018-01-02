all: 
	bison -vd yacc.y
	flex lex.l
	gcc yacc.tab.c lex.yy.c -lfl -o p

clean:
	rm -f p
	rm -f *.yy.c
	rm -f *.output
	rm -f *.tab.h
	rm -f *.tab.c