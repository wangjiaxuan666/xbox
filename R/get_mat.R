#' Title the function data 2 matrix
#'
#' @param df the the input must be a data.frame, tibble or matrix
#' @param ... inhert parameter
#'
#' @return a matrix
#' @export
#' @importFrom tibble is_tibble
#' @examples
#' test = matrix(rnorm(200), 20, 10)
#' colnames(test) = paste("Test", 1:10, sep = "")
#' rownames(test) = paste("Gene", 1:20, sep = "")
#' df = as.data.frame(test)
#' str(df)
#' mat = get_mat(df)
#' str(mat)
get_mat <- function(df,...){
  # check the data.frame
  if(tibble::is_tibble(df)){
    mat = get_df(df,...)
  }
  # change
  if(is.data.frame(df)){
    cn = colnames(df)
    rn = rownames(df)
    mat = as.matrix(df)
    colnames(mat) = cn
    rownames(mat) = rn
  } else {
    if(is.matrix(df)){
      mat = as.matrix(df)
    } else {
      stop("the input must be a data.frame, tibble or matrix")
    }
  }
  return(mat)
}
