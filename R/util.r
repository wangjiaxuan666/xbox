#' Title cool but useless
#'
#' @return charater
#' @export splitline
#'
#' @examples splitline()
splitline <- function() {
  width <- getOption("width")
  ws <- rep("=", floor(width))
  cat("\n",ws, sep = "")
}

#' Title nothing
#'
#' @param message you want say to user
#'
#' @return charater
#' @export messageline
#'
#' @examples messageline("yesimola !")
messageline <- function(message) {
  width <- getOption("width")
  mid <- paste("^_^   ",message,"   ^_^\n",sep = "")
  ws <- rep(" ", floor((width - nchar(mid))/2))
  cat(
    ws,
    mid,
    ws,
    sep = "")
}
