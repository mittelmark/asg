#' @title `tktip` R wrapper for tklib tooltip widget
#' @description `tktip` R wrapper for tooltip widget from tklib library.
#' @return Nothing
#' @param widget widget for which to display the tooltip
#' @param message character string to be displayed when the mouse is over the widget.
#' @importFrom tcltk tclRequire tktoplevel
#' @author Detlef Groth <email: dgroth@uni-potsdam.de>
#' @examples
#' \dontrun{
#' tt=tktoplevel()
#' tkbtn=tkbutton(tt,text="Hover Me")
#' tktip(tkbtn, "Yes, I am now hovered!")
#' tkpack(tkbtn)
#' }
#' @export

tktip <- function (widget, message="") {
	res <- tclRequire("tooltip")
	if (inherits(res, "tclObj")) {
            res <- tcl("tooltip::tooltip", widget, message)
            widget$env$tip <- message
	} else stop("cannot find tcl package 'tooltip'")
	return(invisible(res))
}
