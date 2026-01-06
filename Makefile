##-*- makefile -*-############################################################
#
# Copyright (C) 2026 MicroEmacs User.
#
# All rights reserved.
#
# Synopsis:    
# Authors:     MicroEmacs User
#
##############################################################################

CURRENT_MAKEFILE := $(lastword $(MAKEFILE_LIST))

## argument delegation
ARGS=

VERSION := $(shell grep -E '^Version:' DESCRIPTION | sed 's/Version: //')
PKG     := $(shell basename `pwd`)

## default: list existing tasks 
.PHONY: tasks
tasks:  ## list all tasks
	@grep -Eo '^[a-z0-9]+:.+' $(CURRENT_MAKEFILE) | sed -E 's/:\s+##/\t- /g'

build:
	echo 'library(roxygen2); setwd("."); roxygenize();' | R --slave
	R CMD build .
	#echo 'library(devtools); build(".",path="repo/src/contrib");' | R --slave	
	#echo '.libPaths(c("~/workspace/delfgroth/myr/rlibs/",.libPaths())); library(devtools); build("$(pkg)",path="repo/src/contrib");' | R --slave	
	#echo 'library(tools); setwd("repo/src/contrib") ; library(tools); write_PACKAGES();' | R --slave	
	
check:  vignette
	R CMD build .
	R CMD check $(PKG)_$(VERSION).tar.gz
	#echo 'library(evaluate);library(devtools); check("$(pkg)");' | R --slave	

help:
	 echo "library(mcgraph);help(mcg.cross)" | R --slave	

doc:
	R CMD Rdconv -t txt $(pkg)/man/$(func).Rd | less

vignette:
	#echo '.libPaths(c("~/workspace/delfgroth/myr/rlibs/",.libPaths())); library(devtools); devtools::build_vignettes("$(pkg)");' | R --slave
	cd $(pkg)/vignettes && echo "library(knitr);knitr::knit('$(pkg).Rmd');" | R --slave
	cd $(pkg)/vignettes && /usr/bin/pandoc -i $(pkg).md --toc --citeproc --bibliography bibliography.bib  -o $(pkg).pdf
	#cd $(pkg)/vignettes && pandoc -i $(pkg).md --toc -o $(pkg).pdf	
	mkdir -p $(pkg)/inst/doc/
	cp $(pkg)/vignettes/$(pkg).pdf $(pkg)/inst/doc/
	rm -rf $(pkg)/vignettes/figure
	
pdf:
	 pandoc $(pkg)/doc/$(pkg).html -V geometry:"top=2cm, bottom=2cm, left=2cm, right=2cm" --pdf-engine=xelatex -o $(pkg)/doc/$(pkg).pdf
pandoc:
	cd $(pkg)/vignettes &&	echo 'library(knitr);  knit("$(pkg).Rmd","$(pkg).md");' | R --slave
	cd $(pkg)/vignettes &&	pandoc -s $(pkg).md -o $(pkg).html
	cd $(pkg)/vignettes &&	pandoc -s $(pkg).md -o $(pkg).pdf
	cd $(pkg)/vignettes &&	cp $(pkg).pdf ../doc


linux-gui:
	cd extra/tcl && tpack snha.tapp
	Rscript extra/bin/rcompiler.R R/asg.R extra/R/Emil.R \
		extra/R/tktip.R extra/R/tcltk3.R extra/R/RGui.R \
		extra/R/RGuiPlot.R extra/R/RGuiColSelect.R extra/R/snapp.R > snapp-app.R
		
		
