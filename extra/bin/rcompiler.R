main <- function (argv) {
    cat("#!/usr/bin/env Rscript\n")
    for (file in argv) {
        fin  = file(file, "r")
        flag = TRUE
        while(length((line = readLines(fin,n=1)))>0) {
            if (!grepl("^\\s*#",line)) {
                if (grepl("^if.+sys.nframe.+!interactive",line)) {
                    flag=FALSE
                } else if (!flag & grepl("^\\}",line)) {
                    flag=TRUE
                } else if (flag) {
                    line=gsub("^\\s+","",line)
                    if (!grepl("^NULL",line)) {
                        cat(line,"\n")
                    }
                }
            }
            
        }
        close(fin)
    }
}
if (sys.nframe() == 0L && !interactive()) {
    main(commandArgs(trailingOnly=TRUE))
}
