#' Title change the print method for range_count function result.
#'
#' @param obj objsct
#' @param ... Other parameters
#'
#' @return a s3 object
#' @export
#'
#' @examples # nothing
print.rangecount <- function(obj, ...){
  print(obj$data, ...)
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
xplot <- function(obj,...) {
  UseMethod("xplot")
}

#' Title the plot fucntion for rangecount
#'
#' @param obj object
#' @param ... Other parameters
#'
#' @importFrom ggplot2 ggplot aes geom_col geom_text theme_classic theme aes_string
#'
#' @return ggplot object
#' @export
#'
#' @examples # nothing
xplot.rangecount <- function(obj, ...){
  ggplot2::ggplot(data = obj$data,ggplot2::aes_string(x = 'Range', y = 'Freq', ...),...)+
    ggplot2::geom_col(width = 0.5, ...)+
    ggplot2::geom_text(aes(label = Freq),vjust = -0.5,...)+
    ggplot2::theme_classic(...)+
    ggplot2::theme(axis.text.x = element_text(angle = 45,hjust = 1,...))
}

#' Title
#'
#' @param data the input data for the function `heatpoint`.
#' @return a ggplot2 object
#' @export
#' @importFrom ggplot2 ggplot aes geom_point geom_smooth scale_color_viridis_c annotate theme_classic theme element_text element_line labs
#'
#' @examples points = 5000
#' x = c(rnorm(points/2))
#' y = x + rnorm(points/2,sd=0.8)
#' x = sign(x)*abs(x)^1.3
#' heatpoint(x,y) -> dat_result
#' xplot(dat_result)
xplot.heatpoint <- function(data){
  ggplot2::ggplot(data$plot.data,ggplot2::aes(data$plot.data$x, data$plot.data$y, color = data$plot.data$Density))+
    ggplot2::geom_point() +
    ggplot2::geom_smooth(method = "lm",se=FALSE, color="black", formula = data$lm.result$exp)+
    ggplot2::scale_color_viridis_c() +
    ggplot2::annotate("text",
                      x = min(data[["plot.data"]][[1]], na.rm = T),
                      y = max(data[["plot.data"]][[2]], na.rm = T),
                      label = substitute(italic(y) == a + b %.% italic(x)*","~~italic(r)^2~"="~r2*","~~Pvalue~"="~italic(pvalue),
                                         list(a = format(data[["lm.result"]][["formula"]][[1]], digits = 3),
                                              b = format(data[["lm.result"]][["formula"]][[2]], digits = 3),
                                              r2 = format(data[["cor.result"]][["cor"]], digits = 3),
                                              pvalue = format(data[["cor.result"]][["pvalue"]], digits = 3))),
                      hjust = -0.1
    ) +
    ggplot2::theme_classic() +
    ggplot2::theme(
      axis.ticks = ggplot2::element_line(size = 2),
      axis.text = ggplot2::element_text(size = 20),
      axis.line = ggplot2::element_line(size = 1),
      axis.title = ggplot2::element_text(size = 22),
      legend.position = "right",
      legend.title = ggplot2::element_text(size = 20)
    ) +
    ggplot2::labs(x = "The X expression", y = "The Y expression", color = "Density")
}
