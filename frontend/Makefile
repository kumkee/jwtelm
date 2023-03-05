# Commands
CC := elm make
MINC := uglifyjs

# Directaries
SRCDIR := ./src/
BLDDIR := ./build/

# Sever locations
LOCALSRV := ~/tmp/htdocs
# SRV := rock.local:~/srv

# Files
BASEJS = app.js
BASEMINJS = app.min.js
SRC := $(SRCDIR)Main.elm
SRCHTML := $(SRCDIR)index.src.html
HTML := $(BLDDIR)index.html
JS := $(BLDDIR)$(BASEJS)
MINJS := $(BLDDIR)$(BASEMINJS)
OPTJS := $(BLDDIR)app.opt.js

EMPTY :=
SPACE := $(EMPTY) $(EMPTY)
COMMA := ,

ltr_num = $(foreach n,$(shell seq $(2) 1 $(3)),$(1)$(n))

PURFFN := $(subst $(SPACE),$(COMMA),$(foreach a,F A,$(call ltr_num,$(a),2,9)))

# Flags
OPTFLAG := --optimize
OUTFLAG := --output
COMPSWCH := 'pure_funcs=[$(PURFFN)],pure_getters,keep_fargs=false,unsafe_comps,unsafe'
COMPRESSFLAG := --compress $(COMPSWCH)
MANGLEFLAG := --mangle

.PHONY: all compile optimize clean cphtml local upload

all: $(MINJS) cphtml

compile: $(JS) $(HTML)

optimize: $(OPTJS)

clean:
	rm -f $(BLDDIR)*

cphtml: $(SRCHTML)
	cp -f $(SRCHTML) $(HTML)

local: $(JS) $(HTML)
	cp $^ -iv $(LOCALSRV)

upload: all
	cp $(MINJS) $(HTML) $(LOCALSRV)

$(HTML): $(SRCHTML) $(JS)
	sed "s/$(BASEMINJS)/$(BASEJS)/g" $(SRCHTML) > $@

$(OPTJS): $(SRC)
	$(CC) $? $(OPTFLAG) $(OUTFLAG) $@

$(JS): $(SRC)
	$(CC) $? $(OUTFLAG) $@

$(MINJS): $(OPTJS)
	$(MINC) $? $(COMPRESSFLAG) | $(MINC) $(MANGLEFLAG) $(OUTFLAG) $@
