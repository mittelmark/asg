#!/usr/bin/env Rscript
if (!require("base64",quietly=TRUE)) {
    cat("Package base64 missing, trying to install it:\n")
    install.packages("base64",repos=c("https://cran.uni-muenster.de/","https://www.stats.bris.ac.uk/R/"))
}
if (!require("base64",quietly=TRUE)) {
    cat("Error: Package base64 can't be installed automatically!\n")
    cat("       Try to install it manually within R using `install.packages('base64')`!\n")
}
getTempDir <- function() {
  tm <- Sys.getenv(c('TMPDIR', 'TMP', 'TEMP'))
  d <- which(file.info(tm)$isdir & file.access(tm, 2) == 0)
  if (length(d) > 0) {
    return(tm[[d[1]]])
  } else if (.Platform$OS.type == 'windows') {
    return(Sys.getenv('R_USER'))
  } else {
      return('/tmp')
  }
}

loadZip = function (fname) {
    fin = file(fname,'r')
    flag=FALSE
    bname=gsub("\\.Rz?","",basename(fname))
    bname=gsub("-osx","",bname)
    bname=gsub("-linux","",bname)
    dirname=file.path(getTempDir(),paste("R",bname,sep=""))
    if (dir.exists(dirname) && file.mtime(dirname)<file.mtime(fname)) {
        unlink(dirname,recursive=TRUE)
    } 
    b64file=tempfile()
    zipfile=tempfile()
    while(length((line = readLines(fin,n=1)))>0) {
        if (flag) {
            cat(line,"\n",file=fout,sep="")
        }
        if (grepl("^q\\(\\)",line)) {
           fout = file(b64file,'w')
           flag=TRUE
        }
    }
    if (flag) {
        close(fout)
    }
    close(fin)
    base64::decode(b64file,zipfile)
    unzip(zipfile,exdir=dirname)
    SCRIPTPATH <<- file.path(dirname,paste(bname,".vfs",sep=""),"main.r")
    
    source(SCRIPTPATH)
    #main()
}
if (sys.nframe() == 0L && !interactive()) {
    args = commandArgs()
    fidx=grep("--file=",args)
    fname=gsub("--file=","",args[fidx])
    idx=grep("--compile",args) 
    if (length(idx) > 0) {
        folder=args[idx+1]
        bname=gsub(".vfs","",folder)
        zipfile=paste(bname,".zip",sep="")
        b64file=paste(bname,".b64",sep="")
        Rzfile=paste(bname,".Rz",sep="")
        if (file.exists(zipfile)) {
            file.remove(zipfile)
        }
        zip(zipfile,folder)
        base64::encode(zipfile,b64file)
        fout = file(Rzfile,'w')
        fin  = file(fname, "r")
        while(length((line = readLines(fin,n=1)))>0) {
            cat(line,"\n",file=fout,sep="")
            if (grepl('^>q\\(\\)',line)) {
                break
            }
        }
        close(fin)
        fin  = file(b64file, "r")
        while(length((line = readLines(fin,n=1)))>0) {
            cat(line,"\n",file=fout,sep="")
        }
        close(fin)
        close(fout)

    } else {
        loadZip(fname)
    }
}
q()
