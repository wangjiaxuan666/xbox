#' Change workdir more fast
#'
#' @param outdir where workdir you wang change to.
#'
#' @return None
#' @export chdir
#'
#' @examples getwd()
#' outdir = "../"
#' chdir(outdir)
#' getwd()
chdir <- function(outdir){
  if(dir.exists(outdir)){
    setwd(outdir)
  } else {
    dir.create(outdir)
    setwd(outdir)
  }
}

#' Clear R command history
#'
#' @return None
#' @export clearhistory
#' @importFrom utils loadhistory
#'
#' @examples #
clearhistory <- function() {
  write("", file=".blank")
  loadhistory(".blank")
  unlink(".blank")
}

#' Clear R command history
#'
#' @return None
#' @export clh
#' @importFrom  utils loadhistory
#'
#' @examples #
clh <- function() {
  write("", file=".blank")
  loadhistory(".blank")
  unlink(".blank")
}
