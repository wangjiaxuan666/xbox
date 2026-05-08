# 声明全局变量消除 CRAN check Note
utils::globalVariables(c("Freq", "Range", "x", "y", "Density"))

#' Title change the print method for range_count function result.
#'
#' @param x object
#' @param ... Other parameters
#'
#' @return a s3 object
#' @export
#'
#' @examples # nothing
print.rangecount <- function(x, ...){
  print(x$data, ...)
}
#' Title add the new function for plot the result from other function.
#'
#' @param obj object
#' @param ... other parameter
#'
#' @return s3 methods
#' @export
#'
#' @examples # nothing
xplot <- function(obj, ...) {
  UseMethod("xplot")
}

#' Title the plot fucntion for rangecount
#'
#' @param obj object
#' @param ... Other parameters
#'
#' @importFrom ggplot2 ggplot aes geom_col geom_text theme_classic theme element_text
#'
#' @return ggplot object
#' @export
#'
#' @examples # nothing
xplot.rangecount <- function(obj, ...){
  ggplot2::ggplot(data = obj$data, ggplot2::aes(x = Range, y = Freq, ...), ...) +
    ggplot2::geom_col(width = 0.5, ...) +
    ggplot2::geom_text(ggplot2::aes(label = Freq), vjust = -0.5, ...) +
    ggplot2::theme_classic(...) +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1, ...))
}

#' Title
#'
#' @param obj the input data for the function `heatpoint`.
#' @param ... Other parameters
#' @return a ggplot2 object
#' @export
#' @importFrom ggplot2 ggplot aes geom_point geom_smooth scale_color_viridis_c annotate theme_classic theme element_text element_line labs
#'
#' @examples
#' \dontrun{
#' points = 5000
#' x = c(rnorm(points/2))
#' y = x + rnorm(points/2,sd=0.8)
#' x = sign(x)*abs(x)^1.3
#' heatpoint(x,y) -> dat_result
#' xplot(dat_result)
#' }
xplot.heatpoint <- function(obj, ...){
  # 修复了 label 表达式解析问题和 linewidth 弃用警告
  ggplot2::ggplot(obj$plot.data, ggplot2::aes(x = x, y = y, color = Density)) +
    ggplot2::geom_point() +
    ggplot2::geom_smooth(method = "lm", se = FALSE, color = "black", formula = obj$lm.result$exp) +
    ggplot2::scale_color_viridis_c() +
    ggplot2::annotate("text",
                      x = min(obj$plot.data[[1]], na.rm = TRUE),
                      y = max(obj$plot.data[[2]], na.rm = TRUE),
                      label = as.character(as.expression(substitute(
                        italic(y) == a + b %.% italic(x)*","~~italic(r)^2~"="~r2*","~~Pvalue~"="~pvalue,
                        list(a = format(obj$lm.result$formula[[1]], digits = 3),
                             b = format(obj$lm.result$formula[[2]], digits = 3),
                             r2 = format(obj$cor.result$cor, digits = 3),
                             pvalue = format(obj$cor.result$pvalue, digits = 3))))),
                      parse = TRUE,
                      hjust = -0.1
    ) +
    ggplot2::theme_classic() +
    ggplot2::theme(
      axis.ticks = ggplot2::element_line(linewidth = 2),
      axis.text = ggplot2::element_text(size = 20),
      axis.line = ggplot2::element_line(linewidth = 1),
      axis.title = ggplot2::element_text(size = 22),
      legend.position = "right",
      legend.title = ggplot2::element_text(size = 20)
    ) +
    ggplot2::labs(x = "The X expression", y = "The Y expression", color = "Density")
}
