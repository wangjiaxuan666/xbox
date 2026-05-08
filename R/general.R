#' Change workdir more fast
#'
#' @param outdir where workdir you wang change to.
#'
#' @return None
#' @export
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
#' @export
#' @importFrom utils loadhistory
clearhistory <- function() {
  write("", file=".blank")
  utils::loadhistory(".blank")
  unlink(".blank")
}

#' Clear R command history (Alias)
#'
#' @return None
#' @export
clh <- function() {
  clearhistory()
}
