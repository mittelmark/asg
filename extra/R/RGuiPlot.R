
#' ---
#' title: RGuiPlot-class documentation
#' author: Detlef Groth, University of Potsdam
#' date: 2021-10-13
#' ---
#' 
#' ## NAME
#' 
#' _RGuiPlot_ widget for R plot visualizations with, history and save function.
#'
#' ## DESCRIPTION
#' 
#' The class _RGuiPlot_ provides a R-tcltk widget to visualize R-plots on a _ttklabel_. 
#' A button bar to navigate the history of plots and to resize the plotting area
#' are provided as well. Furthere there exists a pssibility to save all plots as a PDF.
#' 
#' ## SYNOPSIS 
#' 
#' ```
#' library(tcltk)
#' tt2=tkoplevel()
#' gplot=RGuiPlot$new()
#' gplot$init()
#' gplot$label(tt2)
#' gplot$plotLabel(plot,1:10,pch=1:10,cex=4,col=3)
#' tcltk::tkwait.window(tt2)
#' ```
#' 

#' ## METHODS
#' 
#' The class _RGuiPlot_ has the following public methods:
#' 

library(tcltk)
if (!exists("Emil")) {
   source("Emil.R")
   source("tcltk3.R")
   source("tktip.R")
}

RGuiPlot = Emil$new()

#' * _RGuiPlot$imageFour()_ - switch between 1x1 and 2x2 layout for the plot
RGuiPlot$imageFour = function (this) {
    if (as.numeric(tclvalue(this$vncol)) == 1) {
        tclvalue(this$vncol) = "2"
        tclvalue(this$vnrow) = "2"
    } else {
        tclvalue(this$vncol) = "1"
        tclvalue(this$vnrow) = "1"
    }
    this$navigate('redo')
}

#' * _RGuiPlot$imageSize(width,height)_ - enlarge or decrease the image by the given widht and height, usually called via the buttonbar below of the plot area.
RGuiPlot$imageSize = function (this,width,height) {
    tclvalue(this$png.height)=as.numeric(tclvalue(this$png.height))+height
    tclvalue(this$png.width)=as.numeric(tclvalue(this$png.width))+width
    this$navigate('redo')
}

#' * _RGuiPlot$init()_ - initialize the required variables
RGuiPlot$init = function (this) {
    require(tcltk)
    this$call.stack=list()
    this$call.stack.index=0
    this$png.height=tclVar(700)
    this$png.width=tclVar(900)
    this$vncol=tclVar("1")
    this$vnrow=tclVar("1")
    this$Images()
    this$png=tempfile(pattern = "file", tmpdir = tempdir(), fileext = ".png")
    if (Sys.getenv("HOME") != "") {
        this$initialdir=Sys.getenv("HOME")
    } else if (Sys.getenv("HOMEDIR") != "") {
        this$initialdir=Sys.getenv("HOMEDIR")
    } else {
        this$initialdir="~"
    }
}


RGuiPlot$Images = function (this) {
    # images
    this$imageStart=tclVar()
    tkimage.create("photo",this$imageStart,data="
                   R0lGODlhEAAQAIAAAPwCBAQCBCH5BAEAAAAALAAAAAAQABAAAAIjhI+pyxud
                   wlNyguqkqRZh3h0gl43hpoElqlHt9UKw7NG27BcAIf5oQ3JlYXRlZCBieSBC
                   TVBUb0dJRiBQcm8gdmVyc2lvbiAyLjUNCqkgRGV2ZWxDb3IgMTk5NywxOTk4
                   LiBBbGwgcmlnaHRzIHJlc2VydmVkLg0KaHR0cDovL3d3dy5kZXZlbGNvci5j
                   b20AOw==")
    this$imageEnd=tclVar()
    tkimage.create("photo",this$imageEnd,data="
                   R0lGODlhEAAQAIAAAPwCBAQCBCH5BAEAAAAALAAAAAAQABAAAAIjhI+py8Eb
                   3ENRggrxjRnrVIWcIoYd91FaenysMU6wTNeLXwAAIf5oQ3JlYXRlZCBieSBC
                   TVBUb0dJRiBQcm8gdmVyc2lvbiAyLjUNCqkgRGV2ZWxDb3IgMTk5NywxOTk4
                   LiBBbGwgcmlnaHRzIHJlc2VydmVkLg0KaHR0cDovL3d3dy5kZXZlbGNvci5j
                   b20AOw==
                   ")
    this$imageBackward=tclVar()
    tkimage.create("photo",this$imageBackward,data="
                   R0lGODlhEAAQAIAAAP///wAAACH5BAEAAAAALAAAAAAQABAAAAIdhI+pyxqd
                   woNGTmgvy9px/IEWBWRkKZ2oWrKu4hcAIf5oQ3JlYXRlZCBieSBCTVBUb0dJ
                   RiBQcm8gdmVyc2lvbiAyLjUNCqkgRGV2ZWxDb3IgMTk5NywxOTk4LiBBbGwg
                   cmlnaHRzIHJlc2VydmVkLg0KaHR0cDovL3d3dy5kZXZlbGNvci5jb20AOw==
                   ")
    
    this$imageForward=tclVar()
    tkimage.create("photo",this$imageForward,data="
                   R0lGODlhEAAQAIAAAPwCBAQCBCH5BAEAAAAALAAAAAAQABAAAAIdhI+pyxCt
                   woNHTmpvy3rxnnwQh1mUI52o6rCu6hcAIf5oQ3JlYXRlZCBieSBCTVBUb0dJ
                   RiBQcm8gdmVyc2lvbiAyLjUNCqkgRGV2ZWxDb3IgMTk5NywxOTk4LiBBbGwg
                   cmlnaHRzIHJlc2VydmVkLg0KaHR0cDovL3d3dy5kZXZlbGNvci5jb20AOw==
                   ")
    this$imageRedo=tclVar()
    tkimage.create("photo",this$imageRedo,data="
                   R0lGODlhEAAQAIUAAPwCBBxOHBxSHBRGHKzCtNzu3MTSzBQ2FLzSxIzCjCSK
                   FCyeHDzCLAxGHAwuFDSCNBxKLES+NHSmfBQ6FBxWJAQaDAQWFAw+HDSyLJzO
                   nISyjMTexAQOBAwmDAw+FMzizAQODDymNKzWrAQKDAwaDEy6TFTGTFSyXDyK
                   TAQCBAwiFBQyHAwSFAwmHAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
                   AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAAAALAAAAAAQABAAAAZ2
                   QIBwSCwaj0hAICBICgcDQsEgaB4PiIRiW0AEiE3sdsFgcK2CBsCheEAcjgYj
                   oigwJRM2pUK0XDAKGRobDRwKHUcegAsfExUdIEcVCgshImojfEUkCiUmJygH
                   ACkqHEQpqKkpogAgK5FOQywtprFDKRwptrZ+QQAh/mhDcmVhdGVkIGJ5IEJN
                   UFRvR0lGIFBybyB2ZXJzaW9uIDIuNQ0KqSBEZXZlbENvciAxOTk3LDE5OTgu
                   IEFsbCByaWdodHMgcmVzZXJ2ZWQuDQpodHRwOi8vd3d3LmRldmVsY29yLmNv
                   bQA7
                   ")
    this$imageSave=tclVar()
    tkimage.create("photo",this$imageSave,data="
                   R0lGODlhEAAQAIUAAPwCBAQCBFRSVMTCxKyurPz+/JSWlFRWVJyenKSipJSS
                   lOzu7ISChISGhIyOjHR2dJyanIyKjHx6fMzOzGRiZAQGBFxeXGRmZHRydGxq
                   bAwODOTm5ExOTERGRExKTHx+fGxubNza3Dw+PDQ2NAAAAAAAAAAAAAAAAAAA
                   AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
                   AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAAAALAAAAAAQABAAAAaA
                   QIAQECgOj0jBgFAoBpBHpaFAbRqRh0F1a30ClAhuNZHwZhViqgFhJizSjIZX
                   QCAoHOKHYw5xRBiAElQTFAoVQgINFBYXGBkZFxYHGRqIDBQbmRwdHgKeH2Yg
                   HpmkIR0HAhFeTqSZIhwCFIdIrBsjAgcPXlBERZ4Gu7xCRZVDfkEAIf5oQ3Jl
                   YXRlZCBieSBCTVBUb0dJRiBQcm8gdmVyc2lvbiAyLjUNCqkgRGV2ZWxDb3Ig
                   MTk5NywxOTk4LiBBbGwgcmlnaHRzIHJlc2VydmVkLg0KaHR0cDovL3d3dy5k
                   ZXZlbGNvci5jb20AOw==")
    this$imgWider=tclVar()
    tkimage.create("photo",this$imgWider,data="
                   R0lGODlhEAAQAIUAAPwCBAwyTBRObAw2VDR+nCRKZOzy/KTe7Pz+/KTK3Nzu
                   /Lze7FS+1AyexAyuzBSavAyOtBSmzOTy/BRqjNTm9IzO5ETS3ETa5By61Ayi
                   xByixBRmjAQGDBxCXGSivCySrCSWtBTC3AQOHAQWHAxWdEze7AQKFBRCXAwq
                   PAQCBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
                   AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAAAALAAAAAAQABAAAAZj
                   QIBwSCwahYGjUjBQGgWEpHNYMBCaT4G2UDggos+EwmBYMBpf6VBgYDgeEMgj
                   IpmoAQVKxXLBPDIXGhscRB0eHyAgDSGBGyJFASMiIiMkJYImUwAnmJqbjp4A
                   KCmhAKSlTn5BACH+aENyZWF0ZWQgYnkgQk1QVG9HSUYgUHJvIHZlcnNpb24g
                   Mi41DQqpIERldmVsQ29yIDE5OTcsMTk5OC4gQWxsIHJpZ2h0cyByZXNlcnZl
                   ZC4NCmh0dHA6Ly93d3cuZGV2ZWxjb3IuY29tADs=")
    this$imgThinner=tclVar()
    tkimage.create("photo",this$imgThinner,data="
                   R0lGODlhEAAQAIUAAPwCBBRSdBRObCQ2TBxObISevAQCBNzu/BRGZPz6/FzC
                   3Pz+/HTS5ByyzJze7Mzq9ITC3AQWLAyWvBSavFyuxAwaLAwSHBRafBSOrDzW
                   5AyixCS61ETW3CzG1AQeLAweLAxefBSStEze7CSWtCyatBSCnBRWfAwmPBRW
                   dByixAQSHAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
                   AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAAAALAAAAAAQABAAAAZi
                   QIBwSCwah4HjUTBQFgkFg3MoKBykU0QhoUAIAuAksbpgNByPxQMSGVsVDYlk
                   IqdUiJYLJqORbDgcHRseRR8gISIaEyMkGCVYRBEmeyAnlgaQkSgpmU4RAZ1O
                   KqFOpFNGfkEAIf5oQ3JlYXRlZCBieSBCTVBUb0dJRiBQcm8gdmVyc2lvbiAy
                   LjUNCqkgRGV2ZWxDb3IgMTk5NywxOTk4LiBBbGwgcmlnaHRzIHJlc2VydmVk
                   Lg0KaHR0cDovL3d3dy5kZXZlbGNvci5jb20AOw==")
    this$imgLarger=tclVar()
    tkimage.create("photo",this$imgLarger,data="
                   R0lGODlhEAAQAIUAAPwCBBRObCRKZBxCXAwyTKTK3Ozy/NTm9GSivAQWHNzu
                   /FzC3IzO5CySrAQOHAyuzETS3CSWtAyOtETa5Aw2VLze7ByWtBy61BSavAxW
                   dBRCXAwqPAQCBDR+nKTe7FS+1Eze7ByixBRmjPz+/AyexAyixAQKFBRqjAQG
                   DAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
                   AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAAAALAAAAAAQABAAAAZe
                   QIBwSCwaj0hAYCkYEJLKguGASEADigWj4bgaHpBINykwSCYRa5HCFFQsF0xG
                   o9lwhpSOwfORYC4gISJ3RAQdIyQYJSAlImNrh4uNJkl5CoKUUBQnjlB4KJ6h
                   okN+QQAh/mhDcmVhdGVkIGJ5IEJNUFRvR0lGIFBybyB2ZXJzaW9uIDIuNQ0K
                   qSBEZXZlbENvciAxOTk3LDE5OTguIEFsbCByaWdodHMgcmVzZXJ2ZWQuDQpo
                   dHRwOi8vd3d3LmRldmVsY29yLmNvbQA7")
    this$imgSmaller=tclVar()
    tkimage.create("photo",this$imgSmaller,data="
                   R0lGODlhEAAQAIUAAPwCBBRObAwSHBRSdISevBRWfAweLNzu/BSOrAQWLPz6
                   /FzC3DzW5BxObHTS5ByyzAyixEze7BSStBRWdAyWvByixAQSHCQ2TAQCBBRG
                   ZJze7CS61BSavAxefMzq9ETW3CSWtAwmPPz+/CzG1ITC3FyuxBSCnAQeLAAA
                   AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
                   AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAAAALAAAAAAQABAAAAZf
                   QIBwSCwaj8hhQJAkDggFQxMQIBwQhUSyqlgwsFpjg6BwPCARySSstC4eFAqE
                   URlYhoMLBpPRUDYcHXt7RgUeFB8gIU0BIoiKjAcUIwiLSQUkJRsmGIwJJwmE
                   U6OkfkEAIf5oQ3JlYXRlZCBieSBCTVBUb0dJRiBQcm8gdmVyc2lvbiAyLjUN
                   CqkgRGV2ZWxDb3IgMTk5NywxOTk4LiBBbGwgcmlnaHRzIHJlc2VydmVkLg0K
                   aHR0cDovL3d3dy5kZXZlbGNvci5jb20AOw==")
    this$imgFour=tclVar()
    tkimage.create("photo",this$imgFour,data="
                   R0lGODlhEAAQAIIAAPwCBDQyNAQCBPz+/PzerAAAAAAAAAAAACH5BAEAAAAA
                   LAAAAAAQABAAAAMwCLrc/ixI0WSgKoyBl+beQFACpo1AqXbKCr1wLAMWS08h
                   GG3dSZqin4sxnBmPD38CACH+aENyZWF0ZWQgYnkgQk1QVG9HSUYgUHJvIHZl
                   cnNpb24gMi41DQqpIERldmVsQ29yIDE5OTcsMTk5OC4gQWxsIHJpZ2h0cyBy
                   ZXNlcnZlZC4NCmh0dHA6Ly93d3cuZGV2ZWxjb3IuY29tADs=")
}

#' * _RGuiPlot$label(parent)_ - initialize the label widget which is used to display the plots within the given parent
RGuiPlot$label = function (this,parent) {
    # graphics
    tfcenter=ttkframe(parent,width=500)
    # graphics window buttons on top
    tknavi=ttkframe(tfcenter)
    tkpack(tknavi,side='top',anchor='s')
    this$tkSave=ttkbutton(tknavi,image=this$imageSave,command=this$saveImages)
    tktip(this$tkSave,"save all images from the current to end")
    this$tkRedo=ttkbutton(tknavi,image=this$imageRedo,command=function() { this$navigate('redo') })
    tktip(this$tkRedo,"redraw the current widget, might be with other options")
    this$tkStart=ttkbutton(tknavi,image=this$imageStart,command=function() { this$navigate('start') },state='disabled')
    tktip(this$tkStart,"redraw the first image")
    this$tkBackward=ttkbutton(tknavi,image=this$imageBackward,command=function () { this$navigate('backward') },state='disabled')
    tktip(this$tkBackward,"redraw the image before")
    this$tkForward=ttkbutton(tknavi,image=this$imageForward,command=function () { this$navigate('forward') },state='disabled')
    tktip(this$tkForward,"redraw the next image")
    this$tkEnd=ttkbutton(tknavi,image=this$imageEnd,command=function () {this$navigate('end') },state='disabled')
    tktip(this$tkEnd,"redraw the last image")
    tkpack(this$tkSave,this$tkRedo,this$tkStart,this$tkBackward,this$tkForward,this$tkEnd,padx=5,pady=5,side='left')
    tkl=ttklabel(tfcenter)
    tkbind(tkl,'<KeyPress-plus>', function () { print ("plus" ) })
    this$plotlab=tkl
    tkpack(tkl,side='top',anchor='n')
    # graphics window PlotRegion
    this$plotLabel(this$startPlot)
    tkimgsize=ttkframe(tknavi)
    tkpack((tbtnt=ttkbutton(tkimgsize,image=this$imgThinner,command=function () { this$imageSize(width=-50,height=0) })),side="left",padx=5,pady=5)
    tktip(tbtnt,"make image thinner ...")
    tkpack((tbtnw=ttkbutton(tkimgsize,image=this$imgWider,command=function () { this$imageSize(width=50,height=0) })),side="left",padx=5,pady=5)
    tktip(tbtnw,"make image wider ...")
    tkpack((tbtnl=ttkbutton(tkimgsize,image=this$imgLarger,command=function () { this$imageSize(width=0,height=50) })),side="left",padx=5,pady=5)
    tktip(tbtnl,"make image higher ...")
    tkpack((tbtns=ttkbutton(tkimgsize,image=this$imgSmaller,command=function () { this$imageSize(width=0,height=-50) })),side="left",padx=5,pady=5)
    tktip(tbtns,"make image smaller...")
    #tkpack(ttkbutton(tkimgsize,image=this$imgFour,command=function () { this$imageFour() }),side="left",padx=5,pady=5)    
    tkpack(tkimgsize,padx=5,pady=5)
    tkpack(tfcenter,fill="both",expand=TRUE)
}

#' * _RguiPlot$plotLabel(fun,...)_ plot into the label using the given plot function and the arguments
RGuiPlot$plotLabel = function (this,fun,...) {
    png(this$png,width=as.integer(tclvalue(this$png.width)),
        height=as.integer(tclvalue(this$png.height)),type="cairo") 
    nrow=as.numeric(tclvalue(this$vnrow))
    ncol=as.numeric(tclvalue(this$vncol))
    par(mai=c(1,1.2,0.8,0.6))
    #par(mfrow=c(nrow,ncol))

    dev.control(displaylist="enable") 
    this$call.stack.index=this$call.stack.index+1
    this$cursor=this$call.stack.index
    fun(...)
    this$call.stack[[this$call.stack.index]]=recordPlot()
    dev.off()
    this$image1 = tclVar()
    tkimage.create('photo', this$image1, file = this$png)
    tkconfigure(this$plotlab,image=this$image1)
    tkconfigure(this$tkForward,state='disabled')
    tkconfigure(this$tkEnd,state='disabled')

    if (this$call.stack.index>1) {
        tkconfigure(this$tkBackward,state='active')
        tkconfigure(this$tkStart,state='active')
    }
}

RGuiPlot$resetWindow = function (this) {
    nrow=as.numeric(tclvalue(this$vnrow))
    ncol=as.numeric(tclvalue(this$vncol))
    X11()
    par(mfrow=c(nrow,ncol),mai=c(1,1,0.8,0.2))
}

#' * _RGuiPlot$saveImages(...)_ - save all plots within the plot history to a PDF file
RGuiPlot$saveImages = function (this, ...) {
    filename <- tclvalue(tkgetSaveFile(
                                       filetypes = "{ {PDF Files} {.pdf} } { {PNG Files} {.png} } { {All Files} * }",
                                       initialdir = this$initialdir))
    if (filename != "") {
        this$initialdir=dirname(filename)
        if (grepl("[pP][nN][gG]$",filename)) {
            file.copy(this$png,filename)
        } else {
            width=round(7*as.integer(tclvalue(this$png.width))/504,2)
            height=round(7*as.integer(tclvalue(this$png.height))/504,2)
            pdf(filename,width=width,height=width)
            k=0
            for (i in this$cursor:this$call.stack.index) {
                replayPlot(this$call.stack[[i]])
                k=k+1
            }
            dev.off()
        }
    }
}

#' * _RGuiPlot$savePlot(filename="")_ - copy the current plot to a PDF file
RGuiPlot$savePlot = function (this,filename="") {
    if (filename == "") {
        filename <- tclvalue(tkgetSaveFile(initialdir="~",defaultextension=".pdf",
                                  initialfile="plot.pdf"))
    }
    if (filename != "") {
        dev.copy2pdf(file=filename)
    }
}



RGuiPlot$navigate = function (this,...) {
    if (...[1] == "redo") {
        # do nothing just redo last plot
    } else if (...[1] == "start") {
        this$cursor=1
    } else if (...[1] == "end") {
        this$cursor=this$call.stack.index
    }  else if (...[1] == "backward")  {
        this$cursor = this$cursor -1
    } else if (...[1] == "forward") {
        this$cursor = this$cursor +1 
    }
    png("test-plot.png",width=as.integer(tclvalue(this$png.width)),
        height=as.integer(tclvalue(this$png.height)))
    replayPlot(this$call.stack[[this$cursor]])
    dev.off()
    this$image1 = tclVar()
    tkimage.create('photo', this$image1, file = "test-plot.png")
    tkconfigure(this$plotlab,image=this$image1)
    tkconfigure(this$tkBackward,state='disabled')
    tkconfigure(this$tkStart,state='disabled')
    tkconfigure(this$tkForward,state='disabled')
    tkconfigure(this$tkEnd,state='disabled')
    if (this$cursor>1) {
        tkconfigure(this$tkBackward,state='active')
        tkconfigure(this$tkStart,state='active')
    }
    if (this$cursor<this$call.stack.index) {
        tkconfigure(this$tkForward,state='active')
        tkconfigure(this$tkEnd,state='active')
    }
    .Tcl("update idletasks")
}

#' * _RguiPlot$startPlot()_ a simple start plot giving version and time
RGuiPlot$startPlot = function (this) {
    plot(1,type='n',axes=FALSE,xlab='',ylab='',xlim=c(0.8,1.2),ylim=c(0.8,1.2))
    box()
    text(1,1.2,"RGuiPlot",cex=1.5)
    text(1,1.0,Sys.time(),cex=1.5)
}

if (sys.nframe() == 0L && !interactive()) {
    tt2=tcltk::tktoplevel()
    RGuiPlot$init()
    RGuiPlot$label(tt2)
    RGuiPlot$plotLabel(plot,1:10,pch=1:10,cex=4,col=3)
    tcltk::tkwait.window(tt2)
}

#' 
#' ## EXAMPLES
#' 
#' ```
#' tt=tcltk::tktoplevel()
#' gplot=RGuiPlot$new()
#' gplot$init()
#' gplot$label(tt)
#' gplot$plotLabel(plot,1:10,pch=1:10,cex=4,col=3)
#' tcltk::tkwait.window(tt2)
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
