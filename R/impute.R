#' @title Missing value imputation using mean, rpart or knn methods.
#' 
#' @description Replaces missing values with a reasonable guess by different imputation methods such as 
#'   the simple and not recommended methods mean and median, where NA's are replaced with the 
#'   mean or median for this variable or the more recommended methods using rpart decision trees
#'   or knn using a correlation distance based k-nearest neighbor approach. 
#'   The rpart method can be as well used to replace missing values for categorical variables.
#'   In case of median and mean imputations for categorical variables the modus is used, 
#'   so missing values are replaced with the most often category. This is rarely reasonable.
#'
#' @param x either a matrix or data frame
#' @param method method used for replacing missing values, either mean, median, rpart or knn, default 'rpart'
#' @param k number of neighbors for imputation if using 'knn', default: 5
#' @param cor.method correlation method for calcuting distance if using 'knn', default: 'spearman'
#' @return  depending on the input either a data frame or matrix with NA's replaced by imputed values.
#' @import rpart stats
#' @export
#' 
#' @examples
#' data(iris)
#' ir=as.matrix(iris[,1:4])
#' irc=ir
#' idx=sample(1:length(irc),50)
#' irc[idx]=NA
#' summary(irc)
#' irp=asg.impute(irc,method="rpart")
#' irk=asg.impute(irc,method="knn")
#' irm=asg.impute(irc,method="mean")
#' idx=which(is.na(irc))
#' M=data.frame(orig=ir[idx],rpart=irp[idx],knn=irk[idx],mean=irm[idx])
#' round(cor(M),2)
#'

asg.impute <- function (x,method="knn",k=5,cor.method="spearman")  {   
    if (method %in% c("mean","median")) {
        for (i in 1:ncol(x)) {
            # integer is as well numeric :) so 
            if (is.numeric(x[,i])) {
                idx=which(is.na(x[,i]))
                if (method == "mean") {
                    x[idx,i]=mean(x[,i],na.rm=TRUE)
                } else if (method == "median") {
                    x[idx,i]=median(x[,i],na.rm=TRUE)
                }  
            } else {
                # TODO: modus (?)
                warning(paste("Only numerical columns can be imputed with mean and median! Column",colnames(x)[i], "is however non-numeric!"))
            }
        }
    } else if (method == "rpart") {
        m=FALSE
        if (is.matrix(x)) {
            x=as.data.frame(x)
            m=TRUE
        }
        # TODO: refinement for many variables, 
        # take only variables with high absolute correlation
        # into account if more than 10 variables take top 10
        for (i in 1:ncol(x)) {
            idx = which(!is.na(x[,i]))
            if (length(idx) == nrow(x)) {
                next
            }
            if (is.factor(x[,i])) { 
                model=rpart(formula(paste(colnames(x)[i],"~.")), 
                            data=as.data.frame(x[idx,]),
                            method="class")
                x2 = predict(model,newdata=as.data.frame(x[-idx,]),
                             type="class")
            } else {
                model=rpart(formula(paste(colnames(x)[i],"~.")), 
                            data=as.data.frame(x[idx,]))
                x2 = predict(model,newdata=as.data.frame(x[-idx,]))
            }

            x[-idx,i]=x2
        }
        if (m) {
            x=as.matrix(x)
        }
    } else if (method == "knn") {
        if (ncol(x) < 4) {
            stop("knn needs at least 4 variables / columns")
        }
        data.imp=x
        #D=as.matrix(1-((cor(t(data.imp),use="pairwise.complete.obs")+1)/2))
        D=as.matrix(dist(scale(data.imp)))
        for (i in 1:ncol(x)) {
            idx=which(is.na(x[,i]))
            idxd=which(!is.na(x[,i]))
            for (j in idx) {
                idxo=order(D[j,])
                idxo=intersect(idxo,idxd)
                mn=mean(x[idxo[1:k],i])
                data.imp[j,i]=mn
            }
        }
        return(data.imp)
    } else {
        stop("Unknown method, choose either mean, median, knn or rpart")
    } 
    return(x)
}
