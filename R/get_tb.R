#' Title
#'
#' @param data data.frame need to become a tibble objsct
#' @param head if TRUE, will display the data like head()
#' @param var the rownames col's names, the default is "id"
#' @return tibble object
#' @export
#' @import tibble
#' @examples
#' print("creat a example to test it")
get_tb <- function(data, var = "id",head = FALSE){
  # check matrix
  if(is.matrix(data)){
    data = as.data.frame(data)
    message("...","Finished:","the input data is a matrix",
            "have change to data.frame")
  }
  # check df or tb
  if(is.data.frame(data)){
    if(tibble::is_tibble(data)){
      data = data
      message("...","Finished:","the input data is a tibble\n")
    } else {
      message("...","Finished:","the input data is a data frame not a tibble\n")
      data = tibble::rownames_to_column(data, var = var)
      data = tibble::as_tibble(data)
    }
  }
  #output
  if(head == T){
    print(head(data))
  }
  return(data)
}
