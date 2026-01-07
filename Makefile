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

build:  ## create documentation and build tar.gz
	echo 'library(roxygen2); setwd("."); roxygenize();' | R --slave
	R CMD build .
	#echo 'library(devtools); build(".",path="repo/src/contrib");' | R --slave	
	#echo '.libPaths(c("~/workspace/delfgroth/myr/rlibs/",.libPaths())); library(devtools); build("$(pkg)",path="repo/src/contrib");' | R --slave	
	#echo 'library(tools); setwd("repo/src/contrib") ; library(tools); write_PACKAGES();' | R --slave	
	
check:  build ## build and check tar.gz
	R CMD check $(PKG)_$(VERSION).tar.gz
	#echo 'library(evaluate);library(devtools); check("$(pkg)");' | R --slave	

doc:
	R CMD Rdconv -t txt $(PKG)/man/$(func).Rd | less

vignette:
	#echo '.libPaths(c("~/workspace/delfgroth/myr/rlibs/",.libPaths())); library(devtools); devtools::build_vignettes("$(pkg)");' | R --slave
	cd vignettes && echo "library(knitr);knitr::knit('$(PKG).Rmd');" | R --slave
	cd vignettes && /usr/bin/pandoc -i $(PKG).md --toc --citeproc --bibliography bibliography.bib  -o $(PKG).pdf
	#cd $(pkg)/vignettes && pandoc -i $(pkg).md --toc -o $(pkg).pdf	
	mkdir -p inst/doc/
	cp vignettes/$(PKG).pdf inst/doc/
	rm -rf vignettes/figure
	
pdf:
	 pandoc $(pkg)/doc/$(pkg).html -V geometry:"top=2cm, bottom=2cm, left=2cm, right=2cm" --pdf-engine=xelatex -o $(pkg)/doc/$(pkg).pdf
pandoc:
	cd $(pkg)/vignettes &&	echo 'library(knitr);  knit("$(pkg).Rmd","$(pkg).md");' | R --slave
	cd $(pkg)/vignettes &&	pandoc -s $(pkg).md -o $(pkg).html
	cd $(pkg)/vignettes &&	pandoc -s $(pkg).md -o $(pkg).pdf
	cd $(pkg)/vignettes &&	cp $(pkg).pdf ../doc

compile:
	cd extra/tcl && tpack snha.tapp --lz4
	Rscript extra/bin/rcompiler.R R/mgraph.R R/asg.R extra/R/Emil.R \
		extra/R/tktip.R extra/R/tcltk3.R extra/R/RGui.R \
		extra/R/RGuiPlot.R extra/R/RGuiColSelect.R extra/R/snapp.R > snapp-app.R
	if [ -d snha-gui.vfs ]; then rm -rf snha-gui.vfs ; fi
	if [ ! -d snha-gui.vfs ] ; then mkdir snha-gui.vfs ; fi
	mv snapp-app.R snha-gui.vfs/main.r
	cp extra/doc/Readme.md extra/doc/snappshot-01s.png extra/doc/snappshot-02s.png  snha-gui.vfs/
	cp extra/tcl/snha.tapp snha-gui.vfs/

unix-gui: compile
	Rscript extra/bin/mapp.R --compile snha-gui.vfs
	echo "#!/Library/Frameworks/R.framework/Resources/bin/Rscript" > osx.sh
	cat osx.sh snha-gui.Rz > snha-gui-osx.Rz
	rm osx.sh snha-gui.b64 snha-gui.zip
win-gui: compile
	if [ ! -d snha-win ]; then mkdir snha-win; fi
	cp extra/win/snapp.exe snha-win/snha-app.exe
	cp snha-gui.vfs/main.r snha-win/snha-app.R
	cp extra/doc/Readme.md extra/win/License.txt extra/win/Welcome.txt snha-win/
	cp extra/tcl/snha.tapp snha-win/
	cp extra/win/snapp.ico snha-win/snha.ico
	cp extra/doc/*.png snha-win/
	cp extra/win/snapp.nsis snha-win/
	cd snha-win && makensis snapp.nsis
	#cp snha-install.exe ~/Portable/
		
		
