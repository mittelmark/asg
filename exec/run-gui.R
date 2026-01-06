#!/usr/bin/env Rscript
pwd=getwd()
setwd(file.path(system.file(package='asg'),"exec")

if (file.exists(file.path(R.home(),"bin","Rscript"))) {
    rscript=file.path(R.home(),"bin","Rscript")
} else if (file.exists(file.path(R.home(),"bin","Rscript"))) {
    rscript=file.path(R.home(),"bin","Rscript.exe")
} else {
   stop("Error: Rscript binary not found!")
}
if (!file.exists("snha-gui.Rz")) {
    download.file("https://","snha-gui.Rz")
}
system2(rscript,"snha-gui.Rz")
setwd(pwd)
