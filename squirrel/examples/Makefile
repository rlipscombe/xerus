all: cnuts xxds

SQ ?= sq

%.cnut: %.nut
	$(SQ) -c -o $@ $<

%.hex: %.cnut
	xxd -g1 $< > $@

NUTS=$(wildcard *.nut)
CNUTS=$(patsubst %.nut,%.cnut,$(NUTS))
XXDS=$(patsubst %.nut,%.hex,$(NUTS))

cnuts: $(CNUTS)

xxds: $(XXDS)
