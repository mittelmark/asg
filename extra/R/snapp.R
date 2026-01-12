#!/usr/bin/env Rscript
modified ="File stamp: <20260112.1026>"

# TODO:
#   - side by side layout select columns and plot
#   - saving last file and options
#   - auto-reload last file and sheet
#   - circular layout as option, default: stays at sam
#   - circular layout where each component / cluster / PC forms it's
#     own circle (1,2,3, 4) PC's 

library(tcltk)
#system2(file.path(R.home("bin"), "Rterm.exe"),args=c("--vanilla","-e","5+5"),invisible=FALSE,wait=FALSE)
#system2(file.path(R.home("bin"), "Rterm.exe"),args=c("--vanilla","-e","install.packages('Rcpp',repos='https://cran.uni-muenster.de/');Sys.sleep(100)"),invisible=FALSE,stdout=FALSE,wait=FALSE)
if (!exists("Emil")) {
    .calls=sys.calls()
    srx=grep("^source",.calls)
    idx=srx[length(srx)]
    dir = dirname(gsub("source\\(.(.+).\\)","\\1",.calls[idx]))
    source(file.path("out.R"))  
}
if (!require("Rcpp",quietly=TRUE)) {
    tryCatch( {    
             tkpkginstall("Rcpp")
         },
         error=function (e) { 
             tkmessageBox(
                          title="Error!",
                          message = paste("R error:",geterrmessage())
                          )},
         finally = {}
    )          
}
if (packageVersion("Rcpp")<"1.0.6") {
    detach("package:Rcpp")  
    remove.packages("Rcpp")
    tkpkginstall("Rcpp")
}
tkhyperhelp <- function (parent,...) {
    res <- tclRequire("dgw::hyperhelp")
    if (inherits(res, "tclObj")) {
        w=tkwidget(parent,"dgw::hyperhelp",...)
    } else {
        stop("cannot find tcl package 'dgw::hyperhelp'")
    }
    return(invisible(w))
}
Rsnapp = RGui$new()
thisFile <- function() {
    cmdArgs <- commandArgs(trailingOnly = FALSE)
    needle <- "--file="
    match <- grep(needle, cmdArgs)
    if (length(match) > 0) {
        # Rscript
        return(normalizePath(sub(needle, "", cmdArgs[match])))
    } else {
        # 'source'd via R console
        return(normalizePath(sys.frames()[[1]]$ofile))
    }
}
if (exists("SCRIPTPATH")) {
    # wrapped
    Rsnapp$FILENAME=SCRIPTPATH
} else {
    # sourced or Rscripted
    Rsnapp$FILENAME = thisFile()
}
Rsnapp$asg_version = "0.10.1"
Rsnapp$version="0.8.2"
Rsnapp$about = function (this) {
    tkmessageBox(
                 message = paste("snha - gui - St. Nicolas Application\n     @ 2026 Detlef Groth\n   University of Potsdam\n",R.version.string,
                                 "\n GUI    Version:",this$version,
                                 "\n ASG    Version:",this$asg_version,
                                 "\n  ",modified), 
                 icon = "info", type = "ok")
}

Rsnapp$gui = function (this) {
    this$imageRun=tclVar()
    this$bootstrap=tclVar("0")    
    this$corplot=tclVar(FALSE)        
    this$correlations=tclVar(FALSE)
    this$method=tclVar("SNHA")
    this$colorset=tclVar("salmon")    
    this$singlecheck=tclVar(FALSE)    
    tkimage.create("photo",this$imageRun,data="
                   R0lGODlhEAAQAIMAAPwCBAQCBPz+/ISChKSipMTCxLS2tLy+vMzOzMTGxNTS
                   1AAAAAAAAAAAAAAAAAAAACH5BAEAAAAALAAAAAAQABAAAARlEMgJQqDYyiDG
                   rR8oWJxnCcQXDMU4GEYqFN4UEHB+FEhtv7EBIYEohkjBkwJBqggEMB+ncHha
                   BsDUZmbAXq67EecQ02x2CMWzkAs504gCO3qcDZjkl11FMJVIN0cqHSpuGYYS
                   fhEAIf5oQ3JlYXRlZCBieSBCTVBUb0dJRiBQcm8gdmVyc2lvbiAyLjUNCqkg
                   RGV2ZWxDb3IgMTk5NywxOTk4LiBBbGwgcmlnaHRzIHJlc2VydmVkLg0KaHR0
                   cDovL3d3dy5kZXZlbGNvci5jb20AOw==")
    this$imageReload=tclVar()
    tkimage.create("photo",this$imageReload,data="
                   R0lGODlhEAAQAIUAAPwCBCRaJBxWJBxOHBRGBCxeLLTatCSKFCymJBQ6BAwm
                   BNzu3AQCBAQOBCRSJKzWrGy+ZDy+NBxSHFSmTBxWHLTWtCyaHCSSFCx6PETK
                   NBQ+FBwaHCRKJMTixLy6vExOTKyqrFxaXDQyNDw+PBQSFHx6fCwuLJyenDQ2
                   NISChLSytJSSlFxeXAwODCQmJBweHAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
                   AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAAAALAAAAAAQABAAAAaB
                   QIBQGBAMBALCcCksGA4IQkJBUDIDC6gVwGhshY5HlMn9DiCRL1MyYE8iiapa
                   SKlALBdMRiPckDkdeXt9HgxkGhWDXB4fH4ZMGnxcICEiI45kQiQkDCUmJZsk
                   mUIiJyiPQgyoQwwpH35LqqgMKiEjq5obqh8rLCMtowAkLqovuH5BACH+aENy
                   ZWF0ZWQgYnkgQk1QVG9HSUYgUHJvIHZlcnNpb24gMi41DQqpIERldmVsQ29y
                   IDE5OTcsMTk5OC4gQWxsIHJpZ2h0cyByZXNlcnZlZC4NCmh0dHA6Ly93d3cu
                   ZGV2ZWxjb3IuY29tADs=")
    dir=dirname(this$FILENAME)
    if (dir==".") {
        .Tcl("source snha.tapp")
    } else {
        cmd=paste("source {",file.path(dir,"snha.tapp"),"}",sep="")
        .Tcl(cmd)
    }
    #.Tcl("package require azure")
    #.Tcl("azure::set_theme light")
    if (Sys.info()["sysname"]=="Darwin") {
        .Tcl("ttk::style theme use clam")
    } else if (Sys.info()["sysname"]=="Windows") {
        .Tcl("ttk::style theme use xpnative")
    } else {
        .Tcl("ttk::style theme use clam")
        .Tcl("ttk::style configure TProgressbar -foreground blue -background skyblue")
    }
    .Tcl("package require dgw::tvmixins")
    this$init()
    this$startGui()
    #tkconfigure(this$progress, style="TProgressbar")
    mnuFile=this$getMenu("File")
    tkinsert(mnuFile,1,"command",label="Save Report",command=this$saveReport)
    tkdelete(mnuFile,3)
    tkdelete(mnuFile,3)
    tkdelete(mnuFile,3)
    tkdelete(mnuFile,3)
    tkdelete(mnuFile,3)
    mnuHelp=this$getMenu("Help")
    tkinsert(mnuHelp,1,"command",label="Help",command=this$Help,underline=0)
    tkinsert(mnuHelp,2,"command",label="Data preparation",command=function () {this$Help("Data Preparation") },underline=0)
    tkinsert(mnuHelp,2,"command",label="Demo data",command=function () {this$Help("Demo Data") },underline=0)
    frame=this$getCenterFrame()
    tknb=ttknotebook(frame)
    tf1=ttkframe(tknb)
    tf2=ttkframe(tknb)
    tf3=ttkframe(tknb)
    tkadd(tknb,tf1,text=' 1 Data    ',underline=1)
    argv=commandArgs(trailingOnly=TRUE)
    RGuiColSelect$columnSelect(tf1,filename=NULL,dismiss=FALSE)
    this$rgs=RGuiColSelect
    this$iniRead(file.path(Sys.getenv("HOME"),"snha.ini"))
    if (length(argv) == 1) {
        if (file.exists(argv[1])) {
            this$openfile(argv[1])
        }
    } else if (!is.null(this$iniGet("RECENT","FILE"))) {
        # Done: autoloading last sheet
        filename=this$iniGet("RECENT","FILE")
        if (file.exists(filename)) {
            this$openfile(filename)
        } else if (grepl(".+birth.+tab",filename)) {
            this$demoBirthwt()
        } else if (grepl(".*environ.+tab",filename)) {
            this$demoEnvironment()
        } else if (grepl(".*boston.+tab",filename)) {
            this$demoBoston()
        } else {
            this$demoSwiss()
        }
    } else {
         this$demoSwiss()
    }

    tfee=RGuiColSelect$getButtonFrame()
    tfh=ttkbutton(tfee,text="Help",command=function () {this$Help("Data Preparation") },width=20)
    tkpack(tfh,side="left",padx=5)
    tkadd(tknb,tf2,text=' 2 Analysis',underline=1)
    gplot=RGuiPlot$new()
    gplot$init()
    tf4=ttkframe(tf2)
    tklaba=ttklabel(tf4,text="Analyze: ")
    tkbrun=ttkbutton(tf4,image=this$imageRun,command=this$asgRun)
    tkrelo=ttkbutton(tf4,image=this$imageReload,command=function () { this$lay=NULL; this$asgRun() })
    tkmeth=ttkcombobox(tf4,values=c("pearson","spearman","kendall"),width=14)
    tkset(tkmeth,"pearson")
    tkbind(tkmeth,"<<ComboboxSelected>>",this$asgChange)
    tklay=ttkcombobox(tf4,values=c("sam","samd","mds","mdsd","circle"),width=6)
    this$cblay=tklay
    tkset(tklay,"sam")
    tkbind(tklay,"<<ComboboxSelected>>",function () { this$lay = tclvalue(tkget(this$cblay)); this$asgChange() })
    tkvsize=ttkcombobox(tf4,values=3:10,width=6)
    tkbind(tkvsize,"<<ComboboxSelected>>",this$asgChange)
    tkset(tkvsize,7)
    tktsize=ttkcombobox(tf4,values=c("0.8","1.0","1.2","1.4","1.6"),width=6)
    tkset(tktsize,"1.0")
    tkbind(tktsize,"<<ComboboxSelected>>",this$asgChange)        
    tkalpha=ttkcombobox(tf4,values=c("0.001","0.01","0.05","0.10"),width=6)
    tkbind(tkalpha,"<<ComboboxSelected>>",this$asgChange)
    tkset(tkalpha,"0.05")
    tkpack(tf4,side="top",padx=5,pady=5)
    tklbt=ttklabel(tf4,text="Bootstrap:")
    #tkbbt=ttkcheckbutton(tf4,variable=this$bootstrap,command=this$asgChange)
    tkbbt=ttkcombobox(tf4,textvariable=this$bootstrap,values=c("0","25","50","100","200","500","1000"),width=4)
    tkmethod=ttkcombobox(tf4,textvariable=this$method,values=c("SNHA","Cor","MDScor1","MDScor2","PCAsam","PCAvar","Cluster"),width=8)
    tkbind(tkbbt,"<<ComboboxSelected>>",this$asgChange)
    #tkset(tkmethod)="SNHA"
    tkbind(tkmethod,"<<ComboboxSelected>>",this$asgChange)
    tkcolor=ttkcombobox(tf4,textvariable=this$colorset,values=c("salmon","skyblue","harmonic","harmleg"),width=8)
    #tkset(tkmethod)="SNHA"
    tkbind(tkcolor,"<<ComboboxSelected>>",this$asgChange)        

    tklcp=ttklabel(tf4,text="Corplot:")
    tkbcp=ttkcheckbutton(tf4,variable=this$corplot,command=this$asgChange)
    tklcr=ttklabel(tf4,text="Correlations:")
    tkbcr=ttkcheckbutton(tf4,variable=this$correlations,command=this$asgChange)
    tklsg=ttklabel(tf4,text="Singlecheck:")
    tkbsg=ttkcheckbutton(tf4,variable=this$singlecheck,command=this$asgChange)
    tkpack(tklaba,side="left",padx=5,pady=5)    
    tkpack(tkbrun,side="left",padx=5,pady=5)
    #tkpack(tkrelo,side="left",padx=5,pady=5)    
    tkpack(tkmeth,side="left",padx=5,pady=5)
    tkpack(tkalpha,side="left",padx=5,pady=5)    
    tkpack(tklbt,side="left",padx=5,pady=5)    
    tkpack(tkbbt,side="left",padx=2,pady=5)        
    tkpack(tklay,side="left",padx=5,pady=5)
    tkpack(tkmethod,side="left",padx=5,pady=5)    
    tkpack(tkcolor,side="left",padx=5,pady=5)        
    #tkpack(tkbcp,side="left",padx=2,pady=5)        
    tkpack(tklcr,side="left",padx=5,pady=5)    
    tkpack(tkbcr,side="left",padx=2,pady=5)        
    tkpack(tklsg,side="left",padx=5,pady=5)    
    tkpack(tkbsg,side="left",padx=2,pady=5)        
    tkpack(tkvsize,side="left",padx=5,pady=5)
    tkpack(tktsize,side="left",padx=5,pady=5)    
    gplot$label(tf2)

    tkadd(tknb,tf3,text=' 3 Help    ',underline=1)
    helpfile=file.path(dirname(this$FILENAME),"Readme.md")
    tkt=tkhyperhelp(tf3,helpfile=helpfile)
    this$hyperhelp=tkt
    #tkt=text(tf3)
    #tktag.configure(tkt,"heading",foreground="blue")
    #tkinsert(tkt,'end',"## Manual\n\n")
    #tktag.add(tkt,'heading','1.0','1.end')
    
    #tkinsert(tkt,'end',"The following workings steps are usually required\n")
    #tkinsert(tkt,'end',"\n * load data and optional select some columns in the data tab")
    #tkinsert(tkt,'end',"\n * call the SNHA algorithm in the Analysis tab")
    #tkinsert(tkt,'end',"\n * save the analysis in an Excel file")
    tkpack(tkt,side="top",fill="both",expand=TRUE)
    tknotetraverse(tknb)
    # tips
    tktip(tkmeth,"select correlation method")
    tktip(tkmethod,"select graph type")    
    tktip(tkcolor,"select coloring method")    
    tktip(tklay,"select plotting layout for graph")    
    tktip(tkvsize,"set vertex circle size")   
    tktip(tktsize,"set vertex text size")       
    tktip(tkalpha,"select p-value threshold")
    tktip(tkbrun,"(re)analyse the data")   
    tktip(tkbbt,"number of resamplings to check edges")
    tktip(tkbsg,"check single nodes for pairwise correlations")
    this$cbvsize=tkvsize
    this$cbtsize=tktsize    
    this$cbmeth=tkmeth
    this$cbalpha=tkalpha
    this$gplot=gplot
    this$nbook=tknb
    this$setStatus("snha gui - St. Nicolas Application started! Open a Excel or a Tab file to analyze your data!")
    this$setProgress(90)
    this$setTitle("snha gui - St. Nicolas application, 2026")
    tkpack(tknb,side='top',fill='both',expand=TRUE)
    tkwm.geometry(this$tt,"800x600+20+20")
}

Rsnapp$Help = function (this,topic="") {
    tkselect(this$nbook,2)
    if (topic != "") {
        tcl(this$hyperhelp,"help",topic)
    }
}
Rsnapp$asgChange = function (this) {    
    as.boolean = function (x) {
        return(x==1)
    }
    t1=Sys.time()
    tryCatch( {
             data=this$rgs$getData()
             idx=which(apply(data,2,var,na.rm=TRUE)!=0)
             data=data[,idx]
             cnames=substr(colnames(data),1,5)
             if (any(table(cnames)>1)) {  
                 cnames=abbreviate(colnames(data),minlength=5)
             }
             colnames(data)=cnames
             method=tclvalue(tkget(this$cbmeth))
             if (nrow(data)*ncol(data)>10000 & method=="kendall") {
                 if (!require("pcaPP",quietly=TRUE)) {
                     anw=tclvalue(tkmessageBox(title="Question!",icon="question", message = "Kendall is slow for larger data sets! Do you like to install the package pcaPP\nwhich has as faster Kendall implementation?",type="yesno"))
                     if (anw=="yes") {
                         tkpkginstall("pcaPP")
                         require("pcaPP",quietly=TRUE)
                     }
                 }
             }
             if (method == "kendall" & require("pcaPP",quietly=TRUE)) {
                 method="cor.fk"
             }
             vsize=as.numeric(tclvalue(tkget(this$cbvsize)))
             tsize=as.numeric(tclvalue(tkget(this$cbtsize)))             
             alpha=as.numeric(tclvalue(tkget(this$cbalpha)))
             btrap=as.numeric(tclvalue(this$bootstrap))
             if (btrap>0) {
                 as=asg.new(data,method=method,alpha=alpha,threshold=0.01,
                            prob=TRUE,prob.n=btrap,
                            check.singles=as.boolean(tclvalue(this$singlecheck)))
             } else {
                 as=asg.new(data,method=method,alpha=alpha,threshold=0.01,
                            check.singles=as.boolean(tclvalue(this$singlecheck)))
             }
             if (!("lay" %in% names(this))) { # | !all(colnames(as$sigma) %in% colnames(data))) {
                 laym=tclvalue(tkget(this$cblay))
                 this$lay=asg.layout(as,mode=laym)
             }
             this$asg=as
             if (tclvalue(this$method) %in% c("PCAsam","PCAvar")) {
                 pca.data=asg.impute(as$data,method="rpart")
                 idc=which(apply(pca.data,2,var) != 0)
                 pca.data=pca.data[,idc]
                 pca.data=scale(pca.data)
             }
             if (tclvalue(this$method)=="Cor") {
                 this$gplot$plotLabel(plot,as,cex=tsize,type="cor",main=method)
             } else if (tclvalue(this$method)=="MDScor1") {
                 this$gplot$plotLabel(asg.mdsplot,as,cex=tsize,cex.lab=tsize,cex.main=tsize,cex.axis=tsize, main=paste("MDS on",method, "distance: : 1-abs(r)"))
             } else if (tclvalue(this$method)=="MDScor2") {
                 this$gplot$plotLabel(asg.mdsplot,as,cex=tsize,cex.lab=tsize,cex.main=tsize,cex.axis=tsize, dist.method=function(x) { (1-x)/2 },main=paste("MDS on",method, "distance: (1-r)/2"))
             } else if (tclvalue(this$method)=="PCAsam") {
                 this$gplot$plotLabel(asg.pcaplot,prcomp(pca.data),cex=tsize)
             } else if (tclvalue(this$method)=="PCAvar") {
                 this$gplot$plotLabel(asg.pcaplot,prcomp(t(pca.data)),cex=tsize)
             } else if (tclvalue(this$method)=="Cluster") {
                 D=1-abs(as$sigma)
                 hcl=hclust(as.dist(D))
                 this$gplot$plotLabel(plot,hcl,cex=tsize)
             } else {
                 if (as.numeric(tclvalue(this$correlations)) == 1) {
                     edge.text=round(as$sigma,2)
                 } else {
                     edge.text=NULL
                 }
                 filter=this$rgs$getFilter()
                 if (filter != "") {
                     filter=paste(" - filter:",filter)
                 }
                 btrap=tclvalue(this$bootstrap)
                 if (btrap != "") {
                     btrap=paste(" - bootstrap:",btrap)
                 }
                 col="salmon"
                 lg=NULL
                 if (tclvalue(this$colorset)=="skyblue") {
                     col="skyblue"
                 } else if (tclvalue(this$colorset)=="harmonic") {
                     h=mgraph.harmonic_centrality(as)
                     vsize=vsize-2+6*h
                     col=mgraph.nodeColors(as,type="harmonic")
                 } else if (tclvalue(this$colorset)=="harmleg") {
                     h=mgraph.harmonic_centrality(as)
                     vsize=vsize-2+6*h
                     col=mgraph.nodeColors(as,type="harmonic")
                     lg=mgraph.nodeColors(as,type="harmonic",legend=TRUE)
                 }
                 this$gplot$plotLabel(plot,as,layout=this$lay,cex=tsize,vertex.size=vsize,edge.width=3,edge.cex=0.8*tsize,vertex.color=col,
                                      edge.text=edge.text,edge.pch=15,legend=lg,
                                      main=paste("method:",method,"- alpha:",alpha, btrap, filter)) 
             }
         },
         error=function (e) { this$terror() },
         finally = {}
         )
    t2=difftime(Sys.time(),t1,units="secs")
    t=format(t2,nsmall=1,digits=2)
    this$setStatus(sprintf("Graph computed with %i nodes and %i edges in %s seconds!",ncol(as$theta),sum(as$theta)/2,t))
}    
Rsnapp$asgRun = function (this) {
    as.boolean = function (x) {
        return(x==1)
    }
    t1=Sys.time()
    tryCatch({
             data=RGuiColSelect$getData()
             idx=which(apply(data,2,var,na.rm=TRUE)!=0)
             data=data[,idx]

    cnames=substr(colnames(data),1,5)
    if (any(table(cnames)>1)) {  
        cnames=abbreviate(colnames(data),minlength=5)
    }
    colnames(data)=cnames
    method=tclvalue(tkget(this$cbmeth))
    if (nrow(data)*ncol(data)>10000 & method=="kendall") {
        if (!require("pcaPP",quietly=TRUE)) {
            anw=tclvalue(tkmessageBox(title="Question!",icon="question", message = "Kendall is slow for larger data sets! Do you like to install the package pcaPP\nwhich has as faster Kendall implementation?",type="yesno"))
            if (anw=="yes") {
                tkpkginstall("pcaPP")
                require("pcaPP",quietly=TRUE)
            }
        }
    }
    if (method == "kendall" & require("pcaPP",quietly=TRUE)) {
        method="cor.fk"
    }
    vsize=as.numeric(tclvalue(tkget(this$cbvsize)))
    tsize=as.numeric(tclvalue(tkget(this$cbtsize)))    
    alpha=as.numeric(tclvalue(tkget(this$cbalpha))) 
    btrap=as.numeric(tclvalue(this$bootstrap))
    if (btrap>0) {
        as=asg.new(data,method=method,alpha=alpha,threshold=0.01,
                   prob=TRUE,prob.n=btrap,
                   check.singles=as.boolean(tclvalue(this$singlecheck)))
    } else {
        as=asg.new(data,method=method,alpha=alpha,threshold=0.01,
                   check.singles=as.boolean(tclvalue(this$singlecheck)))
    }
    laym=tclvalue(tkget(this$cblay))
    this$lay=asg.layout(as,mode=laym)
    this$asg=as
    if (tclvalue(this$method) %in% c("PCAsam","PCAvar")) {
        pca.data=asg.impute(as$data,method="rpart")
        idc=which(apply(pca.data,2,var) != 0)
        pca.data=pca.data[,idc]
        pca.data=scale(pca.data)
    }
    if (tclvalue(this$method)=="Cor") {
        this$gplot$plotLabel(plot,as,cex=tsize,type="cor",main=method)
    } else if (tclvalue(this$method)=="MDScor1") {
        this$gplot$plotLabel(asg.mdsplot,as,cex=tsize,cex.lab=tsize,cex.main=tsize,cex.axis=tsize, main=paste("MDS on",method, "distance: 1-abs(r)"))
    } else if (tclvalue(this$method)=="MDScor2") {
        this$gplot$plotLabel(asg.mdsplot,as,cex=tsize,cex.lab=tsize,cex.main=tsize,cex.axis=tsize, dist.method=function(x) { (1-x)/2 },main=paste("MDS on",method, "distance: (1-r)/2"))
    } else if (tclvalue(this$method)=="PCAsam") {
        this$gplot$plotLabel(asg.pcaplot,prcomp(pca.data),cex=tsize)
    } else if (tclvalue(this$method)=="PCAvar") {
        this$gplot$plotLabel(asg.pcaplot,prcomp(t(pca.data)),cex=tsize)
    } else if (tclvalue(this$method)=="Cluster") {
        D=1-abs(as$sigma)
        hcl=hclust(as.dist(D))
        this$gplot$plotLabel(plot,hcl,cex=tsize)
    } else {
        if (as.numeric(tclvalue(this$correlations)) == 1) {
            edge.text=round(as$sigma,2)
        } else {
            edge.text=NULL
        }
        filter=this$rgs$getFilter()
        if (filter != "") {
            filter=paste(" - filter:",filter)
        }
        col="salmon"
        lg=NULL
        if (tclvalue(this$colorset)=="skyblue") {
            col="skyblue"
        } else if (tclvalue(this$colorset)=="harmonic") {
            h=mgraph.harmonic_centrality(as)
            vsize=vsize-2+6*h
            col=mgraph.nodeColors(as,type="harmonic")
        } else if (tclvalue(this$colorset)=="harmleg") {
            h=mgraph.harmonic_centrality(as)
            vsize=vsize-2+6*h
            col=mgraph.nodeColors(as,type="harmonic")
            lg=mgraph.nodeColors(as,type="harmonic",legend=TRUE)
        }
        
        this$gplot$plotLabel(plot,as,layout=this$lay,cex=tsize,vertex.color=col,legend=lg,
                             vertex.size=vsize,edge.width=3,edge.text=edge.text,edge.pch=15,edge.cex=0.8*tsize,
                             main=paste("method:",method,"- alpha:",alpha,filter))
    }
    },
    error=function (e) { this$terror() },
    finally = {})
    t2=difftime(Sys.time(),t1,units="secs")
    t=format(t2,nsmall=1,digits=2)
    this$setStatus(sprintf("Graph computed with %i nodes and %i edges in %s seconds!",ncol(as$theta),sum(as$theta)/2,t))
}
                           
Rsnapp$saveReport = function (this) {
    filename=tclvalue(tkgetSaveFile(title = 'Save Excel File',
                                    filetypes = "{ {Excel Files} {.xlsx} } { {All Files} * }"))
    if (!grepl("[xX][lL][sS][xX]$",filename)) {
        filename=paste(filename,".xlsx",sep="")
    }
    if (filename != "") {
        tkpkginstall("openxlsx")
        wb <- openxlsx::createWorkbook("Results")
        openxlsx::addWorksheet(wb, "Adjacency Matrix")        
        theta=this$asg$theta
        writeData(wb,theta,sheet="Adjacency Matrix",rowNames=TRUE)
        if ("probabilities" %in% names(this$asg)) {
            openxlsx::addWorksheet(wb, "Prob")        
            df=as.data.frame(this$asg$probabilities)
            writeData(wb,df,sheet="Prob",rowNames=TRUE)         
        }
        
        openxlsx::addWorksheet(wb, paste("Cor",this$asg$method))        
        sigma=this$asg$sigma
        writeData(wb,sigma,sheet=paste("Cor",this$asg$method),rowNames=TRUE)
        
        openxlsx::addWorksheet(wb, "Cor p-values")        
        pval=this$asg$p.values
        writeData(wb,pval,sheet="Cor p-values",rowNames=TRUE)
        
        openxlsx::addWorksheet(wb, "Chains")        
        chains=asg.getChains(this$asg)
        writeData(wb,chains,sheet="Chains",rowNames=TRUE)
        
        openxlsx::addWorksheet(wb, "Settings")        
        df=data.frame(Setting=c("R threshold", "alpha", "method","bootstrap","filter"),Values=c(as.character(this$asg$threshold),as.character(this$asg$alpha),this$asg$method,tclvalue(this$bootstrap),RGuiColSelect$getFilter()))
        writeData(wb,df,sheet="Settings",rowNames=FALSE)
        
        openxlsx::addWorksheet(wb, "Data")        
        df=as.data.frame(this$asg$data)
        writeData(wb,df,sheet="Data",rowNames=TRUE)         
        openxlsx::addWorksheet(wb, "Centrality")        
        df=data.frame(nodes=colnames(this$asg$theta),harmonic=mgraph.harmonic_centrality(this$asg),degree=mgraph.degree(this$asg))
        writeData(wb,df,sheet="Centrality")         
        #X11()
        corimg=file.path(dirname(filename),"cor.png")
        asgimg=file.path(dirname(filename),"asg.png")        
        harimg=file.path(dirname(filename),"har.png")                
        pcaimg=file.path(dirname(filename),"pca.png")

        png(corimg,width=1000,height=1000)
        plot(this$asg,type="cor",cex=1.2) 
        dev.off()
        png(asgimg,width=1000,height=800)
        vsize=as.numeric(tclvalue(tkget(this$cbvsize))) ;       
        plot(this$asg,layout=this$lay,vertex.size=vsize,edge.width=2)  
        dev.off()
        png(harimg,width=1000,height=800)
        par(mar=c(5,1,2,1))
        h=mgraph.harmonic_centrality(this$asg)
        col=mgraph.nodeColors(this$asg,type="harmonic")
        plot(this$asg,layout=this$lay,vertex.color=col,
             vertex.size=vsize-2+5*h,edge.width=2)  
        lg=mgraph.nodeColors(this$asg,type="harmonic",legend=TRUE)
        legend("top",inset=c(1.0,1.0),fill=lg$col,legend=lg$legend)
        dev.off()
        pca.data=this$asg$data
        pca.data=asg.impute(pca.data)
        idc=which(apply(pca.data,2,var) != 0)
        pca.data=pca.data[,idc]
        pca.data=scale(pca.data)
        png(pcaimg,width=600,height=600)
        asg.pcaplot(prcomp(t(pca.data)))
        dev.off()
        
        openxlsx::addWorksheet(wb, "Cor Plot",gridLines=FALSE)        
        openxlsx::insertImage(wb,"Cor Plot",corimg,startRow=1,width=10,height=10, units = "in")
        openxlsx::addWorksheet(wb, "Asg Plot",gridLines=FALSE)        
        openxlsx::insertImage(wb,"Asg Plot",asgimg,startRow=1,startCol=1,width=10,height=8, units = "in")
        openxlsx::addWorksheet(wb, "Harmonic Plot",gridLines=FALSE)        
        openxlsx::insertImage(wb,"Harmonic Plot",harimg,startRow=1,startCol=1,width=10,height=8, units = "in")
        openxlsx::addWorksheet(wb, "PCA Plot",gridLines=FALSE)        
        openxlsx::insertImage(wb,"PCA Plot",pcaimg,startRow=1,startCol=1,width=10,height=8, units = "in")
        pca=prcomp(pca.data)
        openxlsx::addWorksheet(wb, "PCAImportance")        
        writeData(wb,as.data.frame(summary(pca)$importance),
                  sheet="PCAImportance",rowNames=TRUE)
        openxlsx::addWorksheet(wb, "PCARotation")        
        writeData(wb,as.data.frame(pca$rotation),sheet="PCARotation",rowNames=TRUE)
        # we need a better pcaplot function
        #plot.asg(pca$rotation,type="cor")
        #openxlsx::insertPlot(wb,"Plots",startRow=34,startCol=1,width=6,height=6)
        #mtext("pca loadings",side=3,line=3,cex=1)
        #plotmcg.corrplot(pca$rotation^2,text.lower=FALSE,
        #             cex=as.numeric(tclvalue(this$entCorrplotPchSize)),
        #             cex.names=as.numeric(tclvalue(this$entCorrplotTextSize)),
        #    cex.coeff=as.numeric(tclvalue(this$entCorrplotCoeffSize)))
        #openxlsx::insertPlot(wb,"Plots",startRow=34,startCol=12,width=6,height=6)
        
        openxlsx::addWorksheet(wb, "PCAData")        
        writeData(wb,as.data.frame(scale(pca.data)),sheet="PCAData",rowNames=TRUE)

        saveWorkbook(wb, filename, overwrite = TRUE)
        tkmessageBox(
                     message = paste("Saved ",filename,"!",sep=""), 
                 icon = "info", type = "ok")

    }
}
Rsnapp$demoSwiss = function (this) {
    fname=tempfile(pattern = "swiss", tmpdir = tempdir(), fileext = ".tab")
    set.seed(124)
    data(swiss)
    rnd1=round(rnorm(nrow(swiss),mean=10,sd=3),3)
    swiss=cbind(swiss,Rand=rnd1)
    write.table(swiss,file=fname,sep="\t",quote=TRUE)
    this$openfile(fname)
}
Rsnapp$demoEnvironment = function (this) {
    fname=tempfile(pattern = "environ", tmpdir = tempdir(), fileext = ".tab")
    set.seed(124)
    library(lattice)
    data(environmental)
    rnd1=round(rnorm(nrow(environmental),mean=10,sd=3),3)
    envir=cbind(environmental,Rand=rnd1)
    write.table(envir,file=fname,sep="\t",quote=TRUE)
    this$openfile(fname)
}

Rsnapp$demoBirthwt = function (this) {
    set.seed(125)
    library(MASS)
    rnd1=round(rnorm(nrow(birthwt),mean=10,sd=3),3)
    birthwt=cbind(birthwt,rand=rnd1)
    birthwt$low=NULL
    colnames(birthwt)=gsub("race","ethn",colnames(birthwt))
    fname=tempfile(pattern = "birthwt", tmpdir = tempdir(), fileext = ".tab")
        
    write.table(birthwt,file=fname,sep="\t",quote=TRUE)
    this$openfile(fname)
}
Rsnapp$demoBoston = function (this) {
    set.seed(125)
    library(MASS)
    rnd1=round(rnorm(nrow(Boston),mean=10,sd=3),3)
    bost=cbind(Boston,rand=rnd1)
    fname=tempfile(pattern = "boston", tmpdir = tempdir(), fileext = ".tab")
    write.table(bost,file=fname,sep="\t",quote=TRUE)
    this$openfile(fname)
}

Rsnapp$NhanesData = function (this) {
    library(NHANES) 
    chr2ord = function (x,map) {
    return(unlist(lapply(as.character(x),function(x) {
          if (is.na(x)) { return(NA) }
          return(map[[x]])
      }
      )))
    }
    data(NHANES)
        
    NHANES=unique(NHANES)
    nha=NHANES[,c(1,3,4,7,9,10,13,14:17,20:21,24:26,33:35,40,42,46,50:52)]
    nha[,2]=as.numeric(nha[,2])
    edu=c('8th Grade', '9 - 11th Grade', 'High School',
          'Some College', 'College Grad')
    nha$Education=unlist(lapply(nha$Education,function (x) { if (is.na(x)) {
                                return(NA) }; return(which(x==edu)) }))
    ethn=c('White','Hispanic|Mexican', 'Black')
    nha$Race1=unlist(lapply(nha$Race1,function (x) { if (is.na(x) | x=="Other") {
                            return(NA) }; return(grep(x,ethn)[1]) }))
    nha$Race1[NHANES$Race1=="Other"]=NA
    colnames(nha)[4]="Ethnicity"
    colnames(nha)[7]="Wealth"
    marr=list(Divorced=3,LivePartner=2,Married=3,NeverMarried=1,Separated=3,Widowed=3)
    nha$MaritalStatus=chr2ord(nha$MaritalStatus,marr)
    hown=list(Rent=1,Own=2,Other=NA)
    nha$HomeOwn=chr2ord(nha$HomeOwn,hown)
    work=list(NotWorking=1,Looking=2,Working=3)
    nha$Work=chr2ord(nha$Work,work)
    nha$Diabetes=as.numeric(nha$Diabetes)-1
    nha$HealthGen=chr2ord(nha$HealthGen,list(Excellent=5,Vgood=4,Good=3,Fair=2,Poor=1))
    nha$Depressed=chr2ord(nha$Depressed,list(None=1,Several=2,Most=3))
    nha$SleepTrouble=as.numeric(nha$SleepTrouble)-1
    nha$PhysActive=as.numeric(nha$PhysActive)-1
    #colnames(nha)=gsub("Sleep","Slp",colnames(nha))
    return(nha)
}
Rsnapp$demoNHANES = function (this) {
    fname=file.path(dirname(this$FILENAME),"nhanes.tab")
    if (!file.exists(fname)) {
        tkpkginstall("NHANES")
        if (require("NHANES")) {
            print("Creating NHANES table!")
            data=this$NhanesData()
            write.table(data,file=fname,sep="\t",quote=FALSE)
        } else {
            tkmessageBox(title="Error!",icon="error",
                         message = "Package NHANES is not installed!\nYou need this package to analyze the NHANES data!")
            return()
        }
    }
    # extract relevant columns
    # write them down to nhanes.tab
    this$openfile(fname)
}
Rsnapp$openfile = function (this,filename="") {
    filename=RGuiColSelect$openFile(filename=filename)
    this$iniSet("RECENT","FILE",filename)
}
snapp=Rsnapp$new()
r=snapp$gui()
r=mnuDemo=snapp$getMenu("Demo",underline=1)
r=tkadd(mnuDemo, "command",
          label="swiss (datasets)",
          command=snapp$demoSwiss ,underline=0)
r=tkadd(mnuDemo, "command",
          label="birthwt data (MASS)",
          command=snapp$demoBirthwt ,underline=0)
r=tkadd(mnuDemo, "command",
          label="Boston (MASS)",
          command=snapp$demoBoston ,underline=0)
r=tkadd(mnuDemo, "command",
          label="environmental (lattice)",
          command=snapp$demoEnvironment ,underline=0)
r=tkadd(mnuDemo, "command",
          label="NHANES data",
          command=snapp$demoNHANES ,underline=0)
r=tkadd(mnuDemo, "separator")
r=tkadd(mnuDemo, "command",
        label="Help on demo data",
        command=function () {snapp$Help("Demo Data") },underline=0)
#tcl("dgw::tvmixin",RGuiColSelect$tlist,"dgw::tvband")
#tcl(RGuiColSelect$tlist,"band")
argv=commandArgs(trailingOnly=TRUE)
if (length(argv)>0) {
    if (file.exists(argv[1])) {
        r=snapp$openfile(argv[1])
    }
}
r=snapp$mainloop()


