#' Title
#'
#' @param data tibble need to become a data.frame objsct
#' @param head if TRUE, will display the data like head()
#' @param var which colume will be rownames,the default is the first column
#' @import tibble
#' @importFrom utils head
#' @return a data.frame
#' @export
#' @examples
#' print("creat a example to test it")
get_df <- function(data,var = NULL,head = FALSE){
  if(is.data.frame(data)){
    if(tibble::is_tibble(data)){
      var = colnames(data)[[1]]
      data = tibble::column_to_rownames(data, var = var)
      message("...","Finished:","the input data is a tibble","have change to data.frame by",var)
    } else {
        message("...","Finished:","the input data is a data.frame\n","have no change")
        data = data
    }
  } else{
    message("the input is not matrix,data.frame or tibble")
  }
  # check is matrix or not
  if(is.matrix(data)){
    data = as.data.frame(data)
    message("...","Finished:","the input data is a matrix\n",
        "have change to data.frame")
  }
  #output
  if(head == T){
    print(head(data))
  }
  return(data)
}
