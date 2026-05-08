#' Title the function for caculate the count for every range.
#'
#' @param x the input should be a numeric vector
#' @param gap how many number which need to gap step
#' @param min_num the first number in scales which will breaks in gap
#' @param max_num the last number in scales which will breaks in gap
#'
#' @return a object
#' @export
#'
#' @examples
#' data = range_count(x = rnorm(100,5)*100,gap = 100,min_num = 0,max_num = 1000)
#' print(data)
#' xplot(data)
range_count <- function(x, gap, min_num, max_num){
  # set parameter
  input_value = x
  seq_value = gap
  scale_min = min_num
  scale_max = max_num
  # forloop for the count
  breaks_list = c(seq(scale_min,scale_max,seq_value),Inf)
  labels_list = vector()
  for(i in 1:floor((scale_max - scale_min)/seq_value)){
    labels_list[i] = paste(breaks_list[i],"-",breaks_list[i+1],sep = "")
  }
  # change into data
  freq_sata = as.data.frame(table(cut(input_value,breaks=breaks_list,labels=c(labels_list,paste(">",scale_max,sep = "")))))
  colnames(freq_sata) = c("Range","Freq")
  stat_obj = list(data = freq_sata)
  class(stat_obj) = "rangecount"
  return(stat_obj)
}
