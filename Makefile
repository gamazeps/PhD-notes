.PHONY: clean

OBJS := $(patsubst %.md, %.pdf, $(wildcard *.md))

%.pdf: %.md
	pandoc --latex-engine=xelatex $< -o $@

all: $(OBJS)

clean:
	rm *.aux *.dvi *.log *.nav *.out *.snm *.toc *.pdf

.PHONY: pdfs
pdfs:
	mv *.pdf pdf
