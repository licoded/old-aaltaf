SRCS				= 	$(wildcard *solver.cpp) $(wildcard *checker.cpp) evidence.cpp util/utility.cpp utility.cpp formula/aalta_formula.cpp formula/olg_formula.cpp formula/olg_item.cpp main.cpp
TARGET_DIR			= 	tmp
LTLPARSER_DIR		=	ltlparser
_OBJS				= 	$(SRCS:.cpp=.o)
OBJS				=	$(addprefix $(TARGET_DIR)/, $(_OBJS))

PROG				=	aaltaf
CC					=	g++
CFLAG_INCLUDE_DIRS	=	-I ./ -I ./minisat
CFLAG_nonconforming	=	-fpermissive
CFLAG_ignore_Warn	=	-isystem minisat -isystem ltlparser
DEBUGFLAGS			=	-D DEBUG -g -pg
CFLAGS				=	-Wall $(CFLAG_INCLUDE_DIRS) $(CFLAG_nonconforming) $(CFLAG_ignore_Warn) $(DEBUGFLAGS) 

# ===	MINISAT		===
MINISAT_SOLVER_FILE	=	minisat/core/Solver.cc
MINISAT_TARGETS		=	minisat_solver.o

# ===	LTLPARSER	===
PARSER_FILES		=	ltlparser/ltl_formula.c ltlparser/ltllexer.c ltlparser/ltlparser.c ltlparser/trans.c

# ===	FORMULA		===
FORMULA_FILE		=	formula/aalta_formula.cpp formula/olg_formula.cpp formula/olg_item.cpp

# g++ formula/aalta_formula.cpp -I./ -c -o tmp/aalta_formula.o

.PHONY : pre-build clean depend

# first run `make depend` and paste/replace in the end of this file (Makefile)
all: main

maind:			$(OBJS) $(PARSER_FILES)
	$(CC)	\
		$(addprefix $(TARGET_DIR)/, $(MINISAT_TARGETS))		\
		$^ $(CFLAGS) -lz -o aaltafd

main:			$(SRCS) $(PARSER_FILES) $(FORMULA_FILE) $(MINISAT_SOLVER_FILE)
	$(CC)	\
		$^ $(CFLAGS) -lz -o aaltaf


# ===	MINISAT		===
minisat_build:	$(MINISAT_TARGETS:.o=)

minisat_solver:	$(MINISAT_SOLVER_FILE)
	$(CC) $^ $(CFLAGS) -c -o $(TARGET_DIR)/$@.o


ltlparser/ltllexer.c :
	ltlparser/grammar/ltllexer.l
	flex ltlparser/grammar/ltllexer.l

ltlparser/ltlparser.c :
	ltlparser/grammar/ltlparser.y
	bison ltlparser/grammar/ltlparser.y


depend: $(SRCS)
	rm -f "$@"
	$(CC) $(CFLAGS) -MM $^ > ".$@"
	sed -i '/^[^ ]/ s/^/tmp\//' ".$@"

pre-build:
	mkdir -p tmp
	mkdir -p tmp/formula
	mkdir -p tmp/util

clean :
	rm $(PROG) $(PROG)d $(OBJS) $(addprefix $(TARGET_DIR)/, $(MINISAT_TARGETS)) > /dev/null || true

rebuild-debug:
	make clean
	make minisat_build
	make maind

rebuild-all:
	make rebuild-debug
	make main


tmp/aaltasolver.o: aaltasolver.cpp aaltasolver.h minisat/core/Solver.h
	$(CC) $< $(CFLAGS) -c -o $@
tmp/carsolver.o: carsolver.cpp carsolver.h solver.h aaltasolver.h \
 minisat/core/Solver.h formula/aalta_formula.h util/define.h \
 util/hash_map.h util/hash_set.h ltlparser/ltl_formula.h debug.h \
 util/hash_set.h
	$(CC) $< $(CFLAGS) -c -o $@
tmp/solver.o: solver.cpp solver.h aaltasolver.h minisat/core/Solver.h \
 formula/aalta_formula.h util/define.h util/hash_map.h util/hash_set.h \
 ltlparser/ltl_formula.h debug.h utility.h
	$(CC) $< $(CFLAGS) -c -o $@
tmp/ltlfchecker.o: ltlfchecker.cpp ltlfchecker.h formula/aalta_formula.h \
 util/define.h util/hash_map.h util/hash_set.h ltlparser/ltl_formula.h \
 solver.h aaltasolver.h minisat/core/Solver.h debug.h carsolver.h \
 util/hash_set.h evidence.h formula/olg_formula.h formula/olg_item.h \
 formula/aalta_formula.h
	$(CC) $< $(CFLAGS) -c -o $@
tmp/carchecker.o: carchecker.cpp carchecker.h ltlfchecker.h \
 formula/aalta_formula.h util/define.h util/hash_map.h util/hash_set.h \
 ltlparser/ltl_formula.h solver.h aaltasolver.h minisat/core/Solver.h \
 debug.h carsolver.h util/hash_set.h evidence.h formula/olg_formula.h \
 formula/olg_item.h formula/aalta_formula.h
	$(CC) $< $(CFLAGS) -c -o $@
tmp/evidence.o: evidence.cpp evidence.h formula/aalta_formula.h util/define.h \
 util/hash_map.h util/hash_set.h ltlparser/ltl_formula.h \
 formula/olg_formula.h formula/olg_item.h formula/aalta_formula.h \
 util/hash_map.h
	$(CC) $< $(CFLAGS) -c -o $@
tmp/util/utility.o: util/utility.cpp util/utility.h util/define.h
	$(CC) $< $(CFLAGS) -c -o $@
tmp/utility.o: utility.cpp utility.h formula/aalta_formula.h util/define.h \
 util/hash_map.h util/hash_set.h ltlparser/ltl_formula.h
	$(CC) $< $(CFLAGS) -c -o $@
tmp/formula/aalta_formula.o: formula/aalta_formula.cpp formula/aalta_formula.h \
 util/define.h util/hash_map.h util/hash_set.h ltlparser/ltl_formula.h \
 util/utility.h ltlparser/trans.h ltlparser/ltl_formula.h \
 ltlparser/ltlparser.h ltlparser/ltllexer.h minisat/core/Dimacs.h \
 minisat/core/Solver.h minisat/core/SolverTypes.h
	$(CC) $< $(CFLAGS) -c -o $@
tmp/formula/olg_formula.o: formula/olg_formula.cpp formula/olg_formula.h \
 formula/olg_item.h formula/aalta_formula.h util/define.h util/hash_map.h \
 util/hash_set.h ltlparser/ltl_formula.h util/utility.h
	$(CC) $< $(CFLAGS) -c -o $@
tmp/formula/olg_item.o: formula/olg_item.cpp formula/olg_item.h \
 formula/aalta_formula.h util/define.h util/hash_map.h util/hash_set.h \
 ltlparser/ltl_formula.h util/utility.h minisat/core/Dimacs.h \
 minisat/core/Solver.h minisat/core/SolverTypes.h
	$(CC) $< $(CFLAGS) -c -o $@
tmp/main.o: main.cpp formula/aalta_formula.h util/define.h util/hash_map.h \
 util/hash_set.h ltlparser/ltl_formula.h ltlfchecker.h solver.h \
 aaltasolver.h minisat/core/Solver.h debug.h carsolver.h util/hash_set.h \
 evidence.h formula/olg_formula.h formula/olg_item.h \
 formula/aalta_formula.h carchecker.h
	$(CC) $< $(CFLAGS) -c -o $@
