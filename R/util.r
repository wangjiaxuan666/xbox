#' Title cool but useless
#'
#' @return character
#' @export splitline
#'
#' @examples splitline()
splitline <- function() {
  width <- getOption("width")
  # 使用 paste0 和 collapse 将向量拼接为一个完整的字符串
  ws <- paste0(rep("=", floor(width)), collapse = "")
  return(paste0("\n", ws, "\n"))
}

#' Title nothing
#'
#' @param message you want say to user
#'
#' @return character
#' @export messageline
#'
#' @examples messageline("yesimola !")
messageline <- function(message) {
  width <- getOption("width")
  mid <- paste0("^_^   ", message, "   ^_^")

  # 增加 max(0, ...) 防止因控制台过窄或文字过长导致 rep() 报错
  space_count <- max(0, floor((width - nchar(mid)) / 2))
  ws <- paste0(rep(" ", space_count), collapse = "")

  return(paste0(ws, mid, "\n"))
}
