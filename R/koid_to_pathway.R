#' Title
#'
#' @param koid the list or vctor of ko id like "ko00010"
#' @return a data.frame with three column:"KEEG_A","KEGG_B","desc"
#' @export
#' @importFrom tidyr separate
#' @importFrom KEGGREST keggGet
#' @examples
#' #koid_to_pathway("ko00010")
koid_to_pathway <- function(koid){

  query = KEGGREST::keggGet(koid)

  li_pathway = vector()
  li_class = vector()
  for(i in seq_along(koid)){
    description = query[[i]]$NAME
    if(!is.null(query[[i]]$CLASS)){
      desc_class = query[[i]]$CLASS
    } else {
      desc_class = "unkown"
    }
    li_pathway[[i]] =  description
    li_class[[i]] = desc_class
  }

  data = data.frame(koid,"kegg_AB" = li_class, "desc" = li_pathway)

  return(data)
}
