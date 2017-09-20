.PHONY: clean
clean:
	rm *.aux *.dvi *.log *.nav *.out *.snm *.toc

.PHONY: pdfs
pdfs:
	mv *.pdf pdf
