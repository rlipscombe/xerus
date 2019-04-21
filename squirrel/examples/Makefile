all: cnuts

SQ ?= sq

%.cnut: %.nut
	$(SQ) -c -o $@ $<

NUTS=$(wildcard *.nut)
CNUTS=$(patsubst %.nut,%.cnut,$(NUTS))

cnuts: $(CNUTS)
