#' Title
#'
#' @param data a data.frame need to transpose the columns and rows
#' @return data.frame with the pvalue and qvalue
#' @export
#' @importFrom hablar retype
#' @importFrom stats wilcox.test
#' @examples
#' test = matrix(rnorm(200), 20, 10)
#' test[1:10, seq(1, 10, 2)] = test[1:10, seq(1, 10, 2)] + 3
#' test[11:20, seq(2, 10, 2)] = test[11:20, seq(2, 10, 2)] + 2
#' test[15:20, seq(2, 10, 2)] = test[15:20, seq(2, 10, 2)] + 4
#' colnames(test) = paste("Test", 1:10, sep = "")
#' rownames(test) = paste("Gene", 1:20, sep = "")
#' t_dat(test)
t_dat <- function(data){
  data_t<- (t(as.matrix(data)))
  data_t_df = as.data.frame(data_t)
  data_new <- hablar::retype(data_t_df)
  suppressWarnings(rownames(data_new) <- attr(data_t,"dimnames")[[1]])
  colnames(data_new) <- attr(data_t,"dimnames")[[2]]
  cat("...","Notice:","Use`retype` function in `hablar` packages\n",
      "Should be better to check it again")
  return(data_new)
}

