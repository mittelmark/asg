#!/usr/bin/env Rscript
if (!exists("Emil")) {
   source("Emil.R")
   source("tcltk3.R")
   source("tktip.R")
}
library(tcltk)
#' ---
#' title: RGui-class documentation
#' author: Detlef Groth, University of Potsdam
#' date: 2021-10-13
#' ---
#' 
#' ## NAME
#' 
#' _RGui_ basic class to build GUI applications with R and tcltk
#'
#' ## DESCRIPTION
#' 
#' The class _RGui_ provides a basic application with menubar, mainframe, statusbar etc. to create R applications
#' with a graphical user interface. The application can be extended easily with additional menu points and other widgets by inserting them into the main frame of the application.
#' 
#' ## SYNOPSIS 
#' 
#' ```
#' gui = RGui$new()
#' gui$main()
#' gui$addStatusBar()
#' gui$setStatus("RGui starting done!")
#' gui$setProgress(100)
#' mnuFile=gui$getMenu("File")
#' tkinsert(mnuFile, 1, "command", label="Open directory",
#'          command=function()  print("Open directory") ,underline=5)
#' mframe=gui$getCenterFrame()
#' ttv=ttktreeview(mframe)
#' tkpack(ttv)
#' gui$mainloop()
#' ```
#' 
#' ## METHODS
#' 
#' The class has the following public methods:
#' 
#'  * _RGui$about()_ - about message box
#'  * _RGui$addStatusBar()_ - displays a status bar at the bottom of the main window
#'  * _RGui$exit()_ - Usually called via File->Quit, asks before closing the application
#'  * _RGui$getCenterFrame()_ - gets the frame widget in the center, usually used as main frame of the application
#'  * _RGui$getMenu(entry)_ - gets the menu item for entry or creates a new top cascade
#'  * _RGui$getScript()_ - gets the main script filename executed via Rscript
#'  * _RGui$getScriptDir()_ - Returns the script directory
#'  * _RGui$getTitle(title)_ - gets GUI title
#'  * _RGui$getTopFrame()_ - returns the frame on top, usually for a button bar used
#'  * _RGui$iniRead(filename,defaults)_ - returns a nested list for the ini-values in the given inifile
#'  * _RGui$iniWrite(filename,ini)_ - writes the given nested list into the given ini-filename
#'  * _RGui$main()_ - start basic Gui with intialization of major variables
#'  * _RGui$mainloop()_ - starts the Gui mainloop
#'  * _RGui$openfile()_ - a dummy open file function, should be overwritten by inheriting applications
#'  * _RGui$reloadSession()_ - loads a recent R session into current session
#'  * _RGui$saveSession()_ - saves the current R session
#'  * _RGui$setProgress(value)_ - sets the progress in percent in the progressbar
#'  * _RGui$setStatus(message)_ - sets the status message in the statusbar
#'  * _RGui$setTitle(title)_ - sets GUI title to title
#'  * _RGui$terror()_ - returns last Tcl/Tk error message
#'
#' ## EXAMPLES
#' 
#' ```
#' mgui=RGui$new()
#' mgui$main()
#' mgui$addStatusBar()
#' mgui$setStatus("RGui starting done!")
#' mgui$setProgress(100)
#' mnuFile=gui$getMenu("File")
#' tkinsert(mnuFile, 1, "command",
#'          label="Open directory",
#'         command=function()  print("Open directory") ,underline=5)
#' 
#' mgui$setTitle('MguiApp 2021')
#' mgui$mainloop()
#' ```
#' 
#' ## AUTHOR
#' 
#' Detlef Groth, University of Potsdam dgroth(at)uni-potsdam(dot)de
#'
#' ## LICENSE
#' 
#' Copyright (c) 2021-2022, Detlef Groth, University of Potsdam
#' 
#' Permission is hereby granted, free of charge, to any person obtaining a copy
#' of this software and associated documentation files (the "Software"), to deal
#' in the Software without restriction, including without limitation the rights
#' to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#' copies of the Software, and to permit persons to whom the Software is
#' furnished to do so, subject to the following conditions:
#' 
#' The above copyright notice and this permission notice shall be included in all
#' copies or substantial portions of the Software.
#' 
#' THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#' IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#' FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#' AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#' LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#' OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#' SOFTWARE.
#' 
##' @name RGui-class
##' @aliases RGui
##' @importFrom tcltk tclVar tkimage.create
##' @export

RGui = Emil$new()

RGui$terror = function (this) {
    tkmessageBox(
                 title="Error!",
                 message = paste("R error:",geterrmessage()),
                 icon="error")
}   

RGui$init = function (this) {
    this$status=tclVar("Starting ...")
    this$progress=tclVar(100)
    this$excelData=NULL
    this$menu=list()
    this$author="Dr. Detlef Groth"
    this$company="University of Potsdam"
    this$tlistdata=data.frame(Test=as.numeric(c()))
    this$iniData=list()
    # did not work


}

RGui$setTitle = function (this,title) {
    tcltk::tkwm.title(this$tt,title)
 
}

RGui$startGui = function (this) {
    #this$init()
    
    tt <- tcltk::tktoplevel()
    this$tt=tt
    tcltk::tkwm.title(tt,"RGui")
    
    topMenu<-tcltk::tkmenu(tt,tearoff=FALSE)
    tcltk::tkconfigure(tt,menu=topMenu)
    fileMenu<-tcltk::tkmenu(topMenu, tearoff=FALSE)
    tcltk::tkadd(fileMenu,"command",label="Open File", 
                 command=function () { this$openfile() },underline=0)
    tkadd(fileMenu,'separator')    
    tkadd(fileMenu,"command",label="Save session", 
          command=this$saveSession,
          underline=2)
    tkadd(fileMenu,"command",label="Reload session", 
          command=this$reloadSession,
          underline=2)
    tkadd(fileMenu,'separator')    

    tkadd(fileMenu,"command",label="Restart", 
          command=this$restart,
          underline=0)

    tkadd(fileMenu,'separator')    

    tkadd(fileMenu,"command",label="Quit", 
          command=this$exit,
          underline=0)

    tkadd(topMenu, "cascade", label="File",
          menu=fileMenu,    underline=0) 
    
    debugMenu<-tkmenu(topMenu, tearoff=FALSE)

    tkadd(debugMenu,"command",label="error message", 
          command=this$terror,underline=0)

    tkadd(topMenu, "cascade", label="Debug",
          menu=debugMenu,
          underline=0) 
    
    helpMenu<-tkmenu(topMenu, tearoff=FALSE)

    tkadd(helpMenu,"command",label="About", 
          command=this$about,underline=0)
    tkadd(topMenu, "cascade", label="Help",
          menu=helpMenu,
          underline=0) 
    this$menu[["Root"]]=topMenu
    this$menu[["File"]]=fileMenu
    this$menu[["Help"]]=helpMenu
    tkfocus(tt)
    tftop= ttkframe(tt,borderwidth=2,relief="groove")
    tfcenter = ttkframe(tt)
    tkpack(tftop,side='top',fill='x',expand=FALSE)
    tkpack(tfcenter,side="top",fill="both",expand=TRUE)
    tfbottomframe=ttkframe(tt,borderwidth=2,relief="groove")
    status=ttklabel(tfbottomframe,textvariable=this$status)
    tkpack(status,side='left',fill='x',padx=5,pady=5)
    progress=ttkprogressbar(tfbottomframe,variable=this$progress)
    tkpack(progress,side='right',fill='x',padx=5,pady=5)
    tkpack(tfbottomframe,side='top',fill='x',expand=FALSE)
    # some internal variables
    this$top=tftop
    this$centerframe=tfcenter
    this$bottomframe=tfbottomframe
    tkraise(tt)
    tcl("wm", "attributes", tt, topmost=TRUE); 
    tcl("wm", "attributes", tt, topmost=FALSE)
    tkfocus(tt)
}


RGui$getTitle = function (this) {
    return(tkwm.title(this$tt))
}
RGui$getMenu = function (this,key,underline=0) {
    if (any(names(this$menu)==key)) {
        return(this$menu[[key]])
    } else {
        idx=length(names(this$menu))-1
        newMenu<-tcltk::tkmenu(this$menu[["Root"]], tearoff=FALSE)
        tkinsert(this$menu[["Root"]], idx, "cascade", label=key,
              menu=newMenu, underline=underline,...) 
        this$menu[[key]]=newMenu
        return(newMenu)
    }
}
RGui$addStatusBar = function (this) {
    tkpack(this$bottomframe,side='top',fill='x')
}
RGui$setStatus = function (this,status) {
    tclvalue(this$status)=status
    .Tcl("update idletasks")	
}
RGui$setProgress = function (this,value) {
    tclvalue(this$progress)=value
    .Tcl("update idletasks")	
}
RGui$getTopFrame = function (this) {
    return(this$tftop)
}

RGui$getCenterFrame = function (this) {
    return(this$centerframe)
}

RGui$restart = function (this) {
    print("restart")
}
RGui$openfile = function (this) {
    print("openfile")
}
RGui$saveSession = function (this) {
    filename <- tclvalue(tkgetSaveFile(filetypes = "{ {RData Files} {.RData} } { {All Files} * }"))
    print(this)
    if (filename != "") {
        save.image(filename)
    }
}
RGui$reloadSession = function (this) {
    filename <- tclvalue(tkgetOpenFile(filetypes = "{ {RData Files} {.RData} } { {All Files} * }"))
    if (filename != "") {
        print(ls(this))
        load(filename)
    }
}

RGui$exit = function (this) {
    value=tclvalue(tkmessageBox(
                                title="Question",
                 message = "Do you want to quit?",
                 icon = "question", type = "yesno", 
                 default = "yes"))
    if (value=="yes") {
        tkdestroy(this$tt)
    }
}
RGui$about = function (this) {
    tkmessageBox(
                 message = paste(this$title(),"\n",this$author,"\n",this$company,sep=""), 
                 icon = "info", type = "ok")
}
RGui$title = function (this,title='') {
    if (title == '') {
        return(tclvalue(tkwm.title(this$tt)))
    } else {
        return(tclvalue(tkwm.title(this$tt,title)))
    }
}
RGui$mainloop = function (this) {
    tcltk::tkwait.window(this$tt)

}
RGui$getScript = function (this) {
    args=commandArgs(trailingOnly = FALSE)
    if (any(grepl("--file",args))) {
        idx=grep("--file=",args)
        script=gsub("--file=","",args[idx])
        return(script)
    } else if (any(grepl("^-f",args))) {
        idx=grep("^-f",args)
        return(args[idx+1])
    } else {
        print("here ...")
        # call via source
        .calls=sys.calls()
        srx=grep("^source",.calls)
        idx=srx[length(srx)]
        filename = gsub("source\\(.(.+).\\)","\\1",.calls[idx])
        return(filename)
    }
}

RGui$getScriptDir = function (this) {
    script=this$getScript()
    dir=dirname(script)
    return(dir)
}


RGui$iniRead <- function (this,filename,defaults=list()) {
    ini=defaults
    if (!file.exists(filename)) {
        this$iniFilename=filename
        return(ini)
    }
    connection <- file(filename)
    lines  <- readLines(connection)
    close(connection)
    section="NULL"
    for (line in lines) {
        if (grepl("^\\[.+\\]",line)) {
            section=gsub("^\\[(.+)\\]","\\1",line)
            ini[[section]]=list()
        } else if (grepl("^.+=.+",line)) {
            key=gsub("^(.+?)=.+","\\1",line)
            val=gsub("^.+?=(.+)","\\1",line)
            ini[[section]][[key]]=val
        }
    }
    this$iniFilename=filename
    this$iniData=ini
    return(ini)
}

RGui$iniWrite <- function (this) {
    fout = file(this$iniFilename,'w')
    for (section in names(this$iniData)) {
        cat(sprintf("[%s]\n",section),file=fout)
        for (key in names(this$iniData[[section]])) {
            cat(sprintf("%s=%s\n",key,this$iniData[[section]][[key]]),file=fout)
        }
    }
    close(fout)
}

RGui$iniSet <- function (this,section,key,value) {
    if (!any(names(this$iniData) %in% section)) {
        this$iniData[[section]]=list()
    } 
    this$iniData[[section]][key]=value
    this$iniWrite()
}
RGui$iniGet <- function (this,section,key) {
    if (!any(names(this$iniData) %in% section)) {
        return(NULL)
    } 
    if (!any(names(this$iniData[[section]]) %in% key)) {
        return(NULL)
    }
    return(this$iniData[[section]][[key]])
}

RGui$main = function (this,argv) {
    this$init()
    this$startGui()
}
# images

main <- function (argv) {
    gui = RGui$new()
    gui$main(argv)
    gui$addStatusBar()
    gui$setStatus("RGui starting done!")
    gui$setProgress(100)
    mnuFile=gui$getMenu("File")
    tkinsert(mnuFile, 1, "command",
          label="Open directory",
          command=function()  print("Open directory") ,underline=5)
    mnuDemo=gui$getMenu("Demo",underline=1)
    tkadd(mnuDemo, "command",
          label="new data",
          command=function()  print("new data") ,underline=0)

    gui$mainloop()
    return()
}
if (sys.nframe() == 0L && !interactive()) {
    main(commandArgs(trailingOnly=TRUE))
}

