#' ---
#' title: RGuiColSelect-class documentation
#' author: Detlef Groth, University of Potsdam
#' date: 2021-10-13
#' ---
#' 
#' ## NAME
#' 
#' _RGuiColSelect_ select columns dialog for Excel and Tab files.
#'
#' ## DESCRIPTION
#' 
#' The class _RGuiColSelect_ provides a R-tcltk widget to select specific columns and Excel sheets from Tab
#' and Excel files to use only those columns in an R analysis.
#' 
#' ## SYNOPSIS 
#' 
#' ```
#' library(tcltk)
#' tt2=tcltk::tktoplevel()
#' res=RGuiColSelect$columnSelect(tt2,filename)
#' ```
#' 
#' ## METHODS
#' 
#' The class _RGuiColSelect_ has the following public methods:
#' 
library(tcltk)
if (!exists("Emil")) {
   source("Emil.R")
   source("tcltk3.R")
}
RGuiColSelect = Emil$new()

RGuiColSelect$ComboChange = function (this, W) {
    sheet=tclvalue(tcl(W,"get"))
    if (grepl("[Tt][Aa][bB]$",sheet)) {
        this$fillTabfile(file.path(this$lastDir,sheet))
    } else {
        this$fillTable(this$filename,sheet)
    }
}
RGuiColSelect$columnClick = function (this,W,x,y) {
    sel= as.character(tcl(W, "identify","column",x,y))
    img=tclvalue(tcl(W,"heading",sel,"-image"))
    if (img =="actcheck16") {
        tcl(W,"heading",sel,"-image","actcross16")
    } else if (img =="actcross16") {
        tcl(W,"heading",sel,"-image","actcheck16")
    }
    this$LoadData()
    #print(paste(W,y,y));
}
RGuiColSelect$fillTable = function (this,filename,sheet=1) {
    tlist=this$tlist
    tkdelete(tlist,tkchildren(tlist,''))
    M=read.xlsx(filename,sheet=sheet)
    colnames(M)=gsub("[^A-Za-z0-9]+","_",colnames(M))
    if (!all(grepl("^[A-Za-z]",colnames(M)))) {
        tkmessageBox(title="Error!",icon="error", message = "Not all column names start with Letters, problem with the column names!\nTry to remove any formatting!\nOr try to export the data to a CSV file!",type="ok")
        return(NULL)
    }
    tkconfigure(tlist,columns=c("Row.Names",colnames(M)),show='headings')
    for (col in strsplit(tclvalue(tkcget(tlist,'-columns'))," ")[[1]]) {
        tcl(tlist,"heading",col,'-text',col)
        if (col != "Row.Names") {
            tcl(tlist,"heading",col,'-image','actcheck16')
        }
        tcl(tlist,"column",col,'-anchor','center')
    }
    for (i in 1:nrow(M)) {
        tkinsert(tlist, '','end', values=unlist(c(rownames(M)[i],M[i,])))
        if (i == 200) { break }
    }
    this$data=M
    this$selfData=M
    tkconfigure(this$tkinfo,text=paste("Data loaded with",nrow(M),"rows and",ncol(M),"columns!"))
}
RGuiColSelect$fillTabfile = function (this,filename) {
    tlist=this$tlist
    tkdelete(tlist,tkchildren(tlist,''))
    if (grepl("csv$",filename)) {
        M=read.table(filename,sep=",",header=TRUE)
    } else {
        M=read.table(filename,sep="\t",header=TRUE)
    }
    tkconfigure(tlist,columns=c("Row.Names",colnames(M)),show='headings')
    for (col in strsplit(tclvalue(tkcget(tlist,'-columns'))," ")[[1]]) {
        tcl(tlist,"heading",col,'-text',col)
        if (col != "Row.Names") {
            tcl(tlist,"heading",col,'-image','actcheck16')
        }
    }
    for (i in 1:nrow(M)) {
        tkinsert(tlist, '','end', values=unlist(c(rownames(M)[i],M[i,])))
        if (i == 200) { break }
    }
    tkconfigure(this$tkinfo,text=paste("Data loaded with",nrow(M),"rows and",ncol(M),"columns!"))
    this$data=M
    this$selData=M
}
RGuiColSelect$LoadData = function (this) {
    cols=c()
    for (col in strsplit(tclvalue(tkcget(this$tlist,'-columns'))," ")[[1]]) {
        img=tclvalue(tcl(this$tlist,"heading",col,"-image"))
        if (img == "actcheck16") {
            cols=c(cols,col)
        }
    }
    #print(head(this$data))
    dt=this$data
    if (grepl("[A-za-z]",tclvalue(tkget(this$tke)))) {
        tr=try({eval(parse(text=paste('dt=with(dt,dt[',tclvalue(tkget(this$tke)),',])')))},silent=TRUE)
        if(class(tr)[1] == "try-error") {
            msg=gsub(".+object ","",tr[1])
            tkmessageBox(title="Error!",icon="error", message = msg)
            return()
        }
    } 
    this$selData=dt[,cols]
    M=dt
    tkdelete(this$tlist,tkchildren(tlist,''))
    for (i in 1:nrow(M)) {
        tkinsert(this$tlist, '','end', values=unlist(c(rownames(M)[i],M[i,])))
        if (i == 200) { break }
    }
    tkconfigure(this$tkinfo,text=paste("Data loaded with",nrow(M),"rows and",ncol(M),"columns!"))
}
#'
#' * _RGuiColSelect$columnSelect(parent,filename="",sheet=1,dismiss=TRUE)_ 
#' 
#' >  Initialize the dialog in the given parent, if the filename is not given opens a file open dialog is called. The following options are supported:
#'
#' > - _parent_ - the parent widget
#'   - _filename_ - the filename to load, if given as NULL no file will be loaded, if an empty string is provides calls the file open dialog, default: empty string
#'   - _sheet_ - if the file is an Excel file load the given sheet, default: 1
#'   - _dismiss_ - should the widget be destroyed after column selection, default: TRUE

RGuiColSelect$columnSelect = function (this,parent,filename="",sheet=1,dismiss=TRUE) {
    if (!is.null(filename)) {
        this$filename=filename
        this$dirname=dirname(filename)
    }
    .Tcl("image create photo actcheck16 -data {
         R0lGODlhEAAQAIIAAPwCBMT+xATCBASCBARCBAQCBEQCBAAAACH5BAEAAAAA
         LAAAAAAQABAAAAM2CLrc/itAF8RkdVyVye4FpzUgJwijORCGUhDDOZbLG6Nd
         2xjwibIQ2y80sRGIl4IBuWk6Af4EACH+aENyZWF0ZWQgYnkgQk1QVG9HSUYg
         UHJvIHZlcnNpb24gMi41DQqpIERldmVsQ29yIDE5OTcsMTk5OC4gQWxsIHJp
         Z2h0cyByZXNlcnZlZC4NCmh0dHA6Ly93d3cuZGV2ZWxjb3IuY29tADs=
     }")
        .Tcl("image create photo actcross16 -data {
             R0lGODlhEAAQAIIAAASC/PwCBMQCBEQCBIQCBAAAAAAAAAAAACH5BAEAAAAA
             LAAAAAAQABAAAAMuCLrc/hCGFyYLQjQsquLDQ2ScEEJjZkYfyQKlJa2j7AQn
             MM7NfucLze1FLD78CQAh/mhDcmVhdGVkIGJ5IEJNUFRvR0lGIFBybyB2ZXJz
             aW9uIDIuNQ0KqSBEZXZlbENvciAxOTk3LDE5OTguIEFsbCByaWdodHMgcmVz
             ZXJ2ZWQuDQpodHRwOi8vd3d3LmRldmVsY29yLmNvbQA7
         }")

    this$selData=NULL
    tf=ttkframe(parent)
    tkpack(tf,side='top',fill='x',expand=FALSE)
    tfb=ttkframe(parent)
    .Tcl("ttk::style configure Treeview.Heading -padding [list 3 3 10 3]")
    tlist=ttktreeview(tfb)
    this$tlist=tlist
    tkbind(tlist,"<Button-1>",function (W,x,y) { this$columnClick(W,x,y) })
    tkpack(tfb,side="top",fill="both",expand=TRUE)
    tkscrolled(tfb,tlist)
    tfe = ttkframe(parent)
    tfee = ttkframe(tfe)
    tkpack(ttkbutton(tfee,text="Open file",width=20,command=this$openFile),side="left",padx=10,pady=10)
    if (dismiss) {
        #tkpack(ttkbutton(tfee,text="Load data",width=20,command=function () { 
        #                 this$LoadData(); tkdestroy(parent) }),side="left",padx=10,pady=10)
        tkpack(ttkbutton(tfee,text="Cancel",width=20,command= function () { this$selData = NULL; tkdestroy(parent) }),side="left",padx=10,pady=10)
    } else {
        #tkpack(ttkbutton(tfee,text="Load data",width=20,
        #                 command=this$LoadData),
        #                 side="left",padx=10,pady=10)
        
    }
    tkpack(tfe,side="top",fill="x",expand=FALSE)
    tkpack(tfee,side="top")
    tkpack(ttklabel(tf,text=" Select Sheet:"),side="left",padx=5,pady=5)
    tkc=ttkcombobox(tf,width=30)
    tkbind(tkc,"<<ComboboxSelected>>",function (W) {  this$ComboChange(W) })
    tkpack(tkc,side='left',fill='x',expand=TRUE,padx=5,pady=5)
    tkpack(ttklabel(tf,text=" Filter: "),side="left",padx=5,pady=5)
    tke=ttkentry(tf,width=30)
    tkbind(tke,"<Return>",function (W) {  this$LoadData()  } )
    tkpack(tke,side='left',fill='x',expand=TRUE,padx=5,pady=5)    
    this$tkc=tkc
    this$tke=tke
    this$tfee=tfee
    tkfinfo=ttkframe(parent,borderwidth=2,relief="groove")
    tklinfo=ttklabel(tkfinfo,text="Press the 'Open file' button to load a file!")
    tkpack(tkfinfo,side="top",fill="x",expand=FALSE,padx=5,pady=5)
    tkpack(tklinfo,side="left",fill="x",expand=FALSE,padx=5,pady=5)
    this$tkinfo=tklinfo
    if (!is.null(filename)) {
        this$openFile(filename,sheet=sheet)
    }
    if (dismiss) {
        tcltk::tkwait.window(parent)
    }
    return(this$selData)
}

#'
#' * _RGuiColSelect$getButtonFrame()_ 
#' 
#' >  Returns the button frame below of the table widget.
#'
#'
RGuiColSelect$getButtonFrame = function (this) {
    return(this$tfee)
}

#'
#' * _RGuiColSelect$getData()_ 
#' 
#' >  Returns the currently selected data for the checked columns only.
#'
#'
RGuiColSelect$getData = function (this) {
    this$LoadData()
    return(this$selData)
}

#'
#' * _RGuiColSelect$getFilter()_ 
#' 
#' >  Returns the text in the filter entry.
#'
#'
RGuiColSelect$getFilter = function (this) {
    return(tclvalue(tkget(this$tke)))
}

#'
#' * _RGuiColSelect$openFile(filename="",sheet=1)_ 
#' 
#' >  Opens the given filename and if the filename is an Excel (xlsx) file the given sheet. The following arguments are supported:
#'
#' > - _filename_ - the filename to load, either a Tab file or and Excel file, if an empty string is provides calls the file open dialog, default: empty string
#'   - _sheet_ - if the file is an Excel file load the given sheet, default: 1
#'
RGuiColSelect$openFile = function (this,filename="",sheet=1) {
    if (filename == "") {
        filename <- tclvalue(tkgetOpenFile(title = 'Open Excel File',
        filetypes = "{ {Excel Files} {.xlsx} } { {CSV Files} {.csv} } { {Tab Files} {.tab} } { {All Files} * }"))
        if (filename == "") {  # Return an empty data frame
            return("") # if no file was selected
        }   
    } 

    if (grepl("[Xx][Ll][Ss][Xx]$",filename)) {
        tkpkginstall("openxlsx")
        this$filename=filename
        this$lastDir=dirname(filename)
        sheets=openxlsx::getSheetNames(filename)
        tkconfigure(this$tkc,values=sheets)
        tkset(this$tkc,sheets[sheet])
        this$fillTable(filename,sheet=sheet)
    } else if (grepl("[tTcC][aAsS][bBvV]$",filename)) {
        this$filename=filename
        this$lastDir=dirname(filename)
        files=list.files(this$lastDir,pattern=".[cCtT][sSaA][vVbB]$")
        tkconfigure(this$tkc,values=files)
        tkset(this$tkc,files[1])
        this$fillTabfile(filename)
    }
    return(filename)
}

if (sys.nframe() == 0L && !interactive()) {
    tt2=tcltk::tktoplevel()
    res=RGuiColSelect$columnSelect(tt2,"../data-2-residuals-test.xlsx")
    #tcltk::tkwait.window(tt2)
    #print("Done!")
    #print(head(RGuiColSelect$selData))
    print("res:")
    print(head(res))
    tt2=tktoplevel()
    # if embedded no autoclose
    tf=ttkframe(tt2)
    tkpack(tf,side="top",fill="both",expand=TRUE)
    res=RGuiColSelect$columnSelect(tf,"../../data/who-boys-weight-height.tab",dismiss=FALSE)
    print("res:")
    print(head(res))
}

#' 
#' ## EXAMPLES
#' 
#' ```
#' tt=tcltk::tktoplevel()
#' data=RGuiColSelect$columnSelect(tt2,"../../data/who-boys-weight-height.tab")
#' print(head(data))
#' tcltk::tkwait.window(tt)
#' ```
#' 
#' ## AUTHOR
#' 
#' Detlef Groth, University of Potsdam dgroth(at)uni-potsdam(dot)de
#'
#' ## LICENSE
#' 
#' Copyright (c) 2021, Detlef Groth, University of Potsdam
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

