#' Title
#'
#' @param data the data.frame colume has the two group need to test by t.test
#' @param g1 the number range for group1 like "`1:3`"
#' @param g2 the number range for group2 like "`4:6`"
#' @param adjust TRUE/FALSE add/ or not add the qvalue by qvalue packsages.
#' @param p TRUE/FALSE add/ or not add the pvalue by ttest.
#' @param method the test method like t.test or wlicox.test
#' @return the qvalue and pvalue
#' @export
#' @importFrom qvalue qvalue
#' @importFrom stats t.test
#' @import dplyr
#' @examples
#' test = matrix(rnorm(200), 20, 10)
#' test[1:10, seq(1, 10, 2)] = test[1:10, seq(1, 10, 2)] + 3
#' test[11:20, seq(2, 10, 2)] = test[11:20, seq(2, 10, 2)] + 2
#' test[15:20, seq(2, 10, 2)] = test[15:20, seq(2, 10, 2)] + 4
#' colnames(test) = paste("Test", 1:10, sep = "")
#' rownames(test) = paste("Gene", 1:20, sep = "")
#' col_ttest(data = test,g1 = 1:5,g2 = 6:10)

col_ttest <- function (data, g1, g2, adjust = TRUE, p = TRUE, method = "t.test"){
    log2fc = (apply(data, 1, function(x) log2(mean(x[g1])/mean(x[g2]))))
    if(p){
      if(method == "t.test"){
        pv = (apply(data, 1, function(x) unlist(t.test(x[g1], x[g2])["p.value"])))
      }
      if(method == "wilcox.test"){
        pv = (apply(data, 1, function(x) unlist(wilcox.test(x[g1], x[g2])["p.value"])))
      }
      new_data = cbind(data, pv)
    } else {
      new_data = data
    }
    new_data = cbind(new_data, log2fc)
    new_data = as.data.frame(new_data)
    if (adjust) {
      if (nrow(new_data) > 5000) {
        new_data <- cbind(new_data, qvalue = qvalue::qvalue(new_data$pvalue)[["qvalues"]])
      }
      else {
        message("The number is less than 5000, and adjust pvalue is not recommended")
      }
    }
    return(new_data)
}
