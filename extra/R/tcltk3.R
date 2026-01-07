library(tcltk)
#' @title tkscrolled puts scrollbars around existing widgets
#' @description tkscrolled puts scrollbars around existing widgets
#' @return Nothing
#' @param parent parent frame of widget
#' @param widget widget which gets the scrollbars
#' @param \dots not used
#' @importFrom tcltk tclRequire tkpack tcl tkconfigure tkset tkgrid tkgrid.rowconfigure tkxview tkyview ttkscrollbar
#' @importFrom tcltk tkgrid.columnconfigure
#' @author Detlef Groth <email: dgroth@uni-potsdam.de>
#' @export

tkscrolled = function (parent,widget,...) {
 scrx <- ttkscrollbar(parent, orient = 'horizontal',
    command = function(...) tkxview(widget, ...))
 scry <- ttkscrollbar(parent, orient = 'vertical',
    command = function(...) tkyview(widget, ...))
 tkconfigure(widget, xscrollcommand = 
    function(...) tkset(scrx, ...),
     yscrollcommand = function(...) tkset(scry, ...))
  tkgrid(widget, scry, sticky = 'nsew')
  tkgrid.rowconfigure(parent, widget, weight = 1)
  tkgrid.columnconfigure(parent, widget, weight = 1)
  tkgrid(scrx, sticky = 'ew')  
}
#' @title tkautoscrolled puts autohiding scrollbars around existing widgets
#' @description tkautoscrolled puts autohiding scrollbars around existing widgets
#' @return Nothing
#' @param parent parent frame of widget
#' @param widget widget which gets the scrollbars
#' @param \dots not used
#' @importFrom tcltk tclRequire tkpack tcl tkconfigure tkset ttkscrollbar
#' @author Detlef Groth <email: dgroth@uni-potsdam.de>
#' @export

tkautoscrolled = function (parent,widget,...) {
 tclRequire('autoscroll')
 scrx <- ttkscrollbar(parent, orient = 'horizontal',
    command = function(...) tcltk::tkxview(widget, ...))
 scry <- ttkscrollbar(parent,orient = 'vertical',
    command = function(...) tcltk::tkyview(widget, ...))
 tcltk::tkconfigure(widget, xscrollcommand = 
    function(...) tcltk::tkset(scrx, ...),
    yscrollcommand = function(...) tcltk::tkset(scry, ...))
    tcltk::tkpack(scrx,side='bottom',fill='x')
    tcltk::tkpack(scry,side='right',fill='y')
    tcltk::tkpack(widget,side='top',fill='both',expand=TRUE)
    tcltk::tcl('::autoscroll::autoscroll',scry)
    tcltk::tcl('::autoscroll::autoscroll',scrx)
}
#' @title `tkbodypath` R wrapper for tktablelist body path command.
#' @description `tkbodypath` R wrapper for tktablelist body path command.
#' @return Nothing
#' @param widget the widget the the bodypath should be queried.
#' @param \dots delegated options to the body path function.
#' @importFrom tcltk tcl
#' @author Detlef Groth <email: dgroth@uni-potsdam.de>
#' @export

tkbodypath = function (widget, ...) {
    tcl(widget,"bodypath",...)
}

#' @title `tkselection` R wrapper for selection widget command.
#' @description `tkselection` R wrapper for selection widget command.
#' @return Nothing
#' @param widget the widget the selection should be changed or queried.
#' @param \dots delegated options to the selection function.
#' @importFrom tcltk tcl
#' @author Detlef Groth <email: dgroth@uni-potsdam.de>
#' @export

tkselection = function (widget, ...) {
    tcl(widget,"selection",...)
}

#' @title `tkchildren` R wrapper for children widget command.
#' @description `tkchildren` R wrapper for children widget command.
#' @return Nothing
#' @param widget the widget the children should be changed or queried.
#' @param \dots delegated options to the children function.
#' @importFrom tcltk tcl
#' @author Detlef Groth <email: dgroth@uni-potsdam.de>
#' @export

tkchildren = function(widget,...) {
        tcl(widget,"children",...)
}

#' @title `tkcellcget` R wrapper for cellcget widget command.
#' @description `tkcellcget` R wrapper for cellcget widget command.
#' @return Nothing
#' @param widget the widget the cellcget command should be applied.
#' @param \dots delegated options to the widgets cellcget function.
#' @importFrom tcltk tcl
#' @author Detlef Groth <email: dgroth@uni-potsdam.de>
#' @export

tkcellcget = function(widget,...) {
        tcl(widget,"cellcget",...)
}

#' @title `tkcellselection` R wrapper for cellselection widget command.
#' @description `tkcellselection` R wrapper for cellselection widget command.
#' @return Nothing
#' @param widget the widget the cellselection command should be applied.
#' @param \dots delegated options to the widgets cellselection function.
#' @importFrom tcltk tcl
#' @author Detlef Groth <email: dgroth@uni-potsdam.de>
#' @export

tkcellselection = function(widget,...) {
        tcl(widget,"cellselection",...)
}

#' @title `tkcolumnconfigure` R wrapper for columnconfigure widget command.
#' @description `tkcolumnconfigure` R wrapper for columnconfigure widget command.
#' @return Nothing
#' @param widget the widget the columnconfigure command should be applied.
#' @param \dots delegated options to the widgets columnconfigure function.
#' @importFrom tcltk tcl
#' @author Detlef Groth <email: dgroth@uni-potsdam.de>
#' @export

tkcolumnconfigure = function(widget,...) {
        tcl(widget,"columnconfigure",...)
}

#' @title `tkinsertlist` R wrapper for insertlist widget command.
#' @description `tkinsertlist` R wrapper for insertlist widget command.
#' @return Nothing
#' @param widget the widget the insertlist command should be applied.
#' @param \dots delegated options to the widgets insertlist function.
#' @importFrom tcltk tcl
#' @author Detlef Groth <email: dgroth@uni-potsdam.de>
#' @export

tkinsertlist = function(widget,...) {
        tcl(widget,"tkinsertlist",...)
}

#' @title `tknotetraverse` R wrapper for enableTraversal for notebook widgets.
#' @description `tknotetraverse` R wrapper for enableTraversal for notebook widgets.
#' @return Nothing
#' @param nb the notebook widget which should be accessible using standard hotkeys.
#' @importFrom tcltk tcl
#' @author Detlef Groth <email: dgroth@uni-potsdam.de>
#' @export

tknotetraverse = function (nb) {
    tcl("ttk::notebook::enableTraversal", nb)
}

tkheading = function(widget,...) {
        tcl(widget,"heading",...)
}

#'  * _tkpkginstall(pkgname)_ - check if the given package is installed, if not provide the user with a message box informing on the choice to insrtall it

tkpkginstall = function (x)  {
    ## Default repo
    local({r <- getOption("repos")
          r["CRAN"] <- "http://cran.r-project.org" 
          options(repos=r)
      })
    repos="https://cran.uni-muenster.de/" #;"http://cran.fhcrc.org","https://cran.stat.unipd.it/","https://cran.stat.auckland.ac.nz/","https://cran.mirror.ac.za/","https://stat.ethz.ch/CRAN/","https://cran.ma.imperial.ac.uk/","http://cran.wustl.edu/"
    require(tools)
    deps=package_dependencies(x,recursive=TRUE)[[1]]
    print(deps)
    if (!require(x,character.only = TRUE)) {
        tt=tktoplevel()
        tkwm.title(tt,"Installation ...")
        tkl=ttklabel(tt,text=paste("installing package",x))
        tkpack(tkl,side="top",fill="both",expand=TRUE,padx=10,pady=10)
        tcl("wm", "attributes", tt, topmost=TRUE); 
        tcl("wm", "attributes", tt, topmost=FALSE)
        tkfocus(tt)
        
        res=tclvalue(tkmessageBox(message=paste("Package",x,"is missing!\nInstallation might take some time, be patient!!\nInstall it?"),title="Info",
                                  type="yesno",icon="question",parent=tt))
        if (res== "yes") {
            deps=package_dependencies(x,recursive=TRUE)[[1]]
            idx = which(!(deps %in% rownames(installed.packages())))
            deps=deps[idx]
            if (!file.exists(Sys.getenv("R_LIBS_USER"))) {
                dir.create(Sys.getenv("R_LIBS_USER"),recursive=TRUE)
            }
            path=Sys.getenv("R_LIBS_USER")
            if (path=="") {
                path=.libPaths()[2]
            } else {
                .libPaths(c(path,.libPaths()))
            }
            n=length(deps)+1
            i=1
            tcl("wm", "attributes", tt, topmost=TRUE); 
            for (p in deps) {
                tkconfigure(tkl,text=paste("installing package",i,"/",n,"\npackage: ",p,"...\nbe patient ..."))
                .Tcl("update idletasks")	
                utils::install.packages(p,dep=TRUE,lib=path,repos=repos)
                i=i+1
            }
            tkconfigure(tkl,text=paste("installing package",i,"/",n,"\npackage: ",x,"...\nbe patient ..."))
            .Tcl("update idletasks")	
            utils::install.packages(x,lib=path,repos=repos)
            tkconfigure(tkl,text=paste("installing package",n,"/",n,"\n completed!"))
            .Tcl("update idletasks")	
            Sys.sleep(5)
        }
        if(!require(x,character.only = TRUE)) {
            tkmessageBox(title="Error",message=paste("Package",x,"not found!\nInstallation was not succesfull!"),icon="error",type="ok",parent=tt)
        }
        tkdestroy(tt)
    }
}

