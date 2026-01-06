#' @title Emil object prototype
#'
#' @description This prototype is used to create objects for a minimal OO system.
#'
#' @usage Emil$new()
#' 
#' @format Object of class \code{Emil} which can be extended with functions and properties using *prototype based programming*.
#' 
#' @section Details:
#' \describe{
#'   \item{Emil$new()}{create new objects}
#' }
#' @seealso \link{dutils}, \link[dgtools:dutils_self]{dutils$self}.
#'
#' @examples
#' obj=Emil$new()
#' obj$test <- function (self,x) { self$x=x }
#' obj$getX <- function (self) { return(self$x) }
#' obj$test(5)
#' obj$getX()
#' # inheritance
#' obj2=obj$new()
#' ls(obj2)
#' obj2$test(2)
#' obj2$x
#' obj$x
#' @author Detlef Groth <email: dgroth@uni-potsdam.de>
#' @name Emil-class
#'
#' @aliases Emil
#' @export

Emil <- new.env()

Emil$new <- function (self,...) {
    
    t=new.env()
    # new addition
    dots <- list(...)
    names <- names(dots)
    for (nm in names) {
        t[[nm]] = dots[[nm]]
    }
    # end of new addition
    for (o in ls(self)) {
        t[[o]]=self[[o]]
    }
    class(t)="Emil"
    return(t)
    #return(as.environment(self))
}
Emil$.new = Emil$new # in case we overwrite new
class(Emil)="Emil"
##' @export
"$<-.Emil" <- function(self,s,value) {
  if (is.function(value))
    environment(value) <- self
  self[[as.character(substitute(s))]] <- value
  return(self)
}


##' @export
"$.Emil" <- function(x, name) {
  inherits <- substr(name, 1, 2) != ".."

  res <- get(name, envir = x, inherits = inherits)
  if (!is.function(res))
    return(res)

  structure(
    function(...) res(x, ...),
    method = res
  )
}
