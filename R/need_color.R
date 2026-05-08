#' Title color palettes created by douyin dadongsheji, I use colors package a R packages
#'
#' @param colpal a valid color palette name(color number + id,such as 'two1',can see disco())
#' or a numberic vector that can select color randomly.
#' @param ncol when set the colpal names, ncol set how many color you need
#' @param style default parameter, Ancient Chinese style is can't change
#' @importFrom graphics mtext rect text
#'
#' @return a vector of color code
#' @export
#'
#' @examples
#' need_colors(9)
#' need_colors("nine1",8)
#' need_colors("two2",2)
need_colors = function(colpal, ncol = NULL,style = "china")
{
  if(style == "china"){
    colornames = c("#758e61", "#998F8F", "#8CADA6", "#D19848", "#F1ABAD",
                   "#ABA0CB", "#EB4B17", "#02786A", "#4C8045", "#D23918",
                   "#8CADA6", "#DFADBB", "#EFB08A", "#FEF9EF", "#F1ABAD",
                   "#ABA0CB", "#FEF9EF", "#EFB08A", "#EEC96B", "#466B39",
                   "#9d2c32", "#494367", "#cb6922", "#a58475", "#b25c43",
                   "#8c4356", "#b26c60", "#eb5934", "#c32a2c")
    # 简单设置数字出随机颜色
    if(is.numeric(colpal)){
      colpal = ceiling(colpal)
      palette = random_colors(colpal)
      ncol = NULL
      cat(sprintf("Randomly select %d colors from all the colors.\n", length(palette)))
    } else {
      # 根据数字加编号设置颜色
      if (length(colpal) > 1){
        stop("the 'colpal' must single" )
      } else {
        palette = switch(
          colpal,
          # custom-made palettes #
          two1 = colornames[c(1:2)],
          two2 = colornames[c(3:4)],
          two3 = colornames[c(5:6)],
          two4 = colornames[c(7:8)],
          two5 = colornames[c(9:10)],
          three1 = colornames[c(11:13)],
          three2 = colornames[c(14:16)],
          four1 = colornames[c(17:20)],
          nine1 = colornames[c(21:29)]
          # need select colors from all
        )
      }
    }
    # 设置颜色的数目
    if (!is.null(ncol)){
      if(ncol > length(palette)){
        message("the color number is more the all color number in this colpal")
        palette = palette
      } else {
        palette = palette[sample(length(palette),ncol)]
      }
    }
    # 检查
    if (is.null(palette)){
      stop("'colpal' should be a valid color palette name (see 'disco()') or a number vector which you need")
    }
  } else {
    message("Why not try a Chinese traditional style with style = 'china' !")
    palette = NULL
  }
  return(palette)
}

#' random_colors
#'
#' @param n The number of colors.
#'
#' @return A vector of colors.
#' @export
#'
random_colors <- function(n){
  if(n <= 8){
    colors <- c("#66C2A5", "#FC8D62", "#8DA0CB", "#E78AC3",
                "#A6D854", "#FFD92F", "#E5C494", "#B3B3B3")
  }else if(n <= 14){
    colors <- c("#437BFE", "#FEC643", "#43FE69", "#FE6943", "#C643FE",
                "#43D9FE", "#B87A3D", "#679966", "#993333", "#7F6699",
                "#E78AC3", "#333399", "#A6D854", "#E5C494")
  }
  else if(n <= 20){
    colors <- c("#87b3d4", "#d5492f", "#6bd155", "#683ec2", "#c9d754",
                "#d04dc7", "#81d8ae", "#d34a76", "#607d3a", "#6d76cb",
                "#ce9d3f", "#81357a", "#d3c3a4", "#3c2f5a", "#b96f49",
                "#4e857e", "#6e282c", "#d293c8", "#393a2a", "#997579")
  }else if(n <= 30){
    colors <- c("#628bac", "#ceda3f", "#7e39c9", "#72d852", "#d849cc",
                "#5e8f37", "#5956c8", "#cfa53f", "#392766", "#c7da8b",
                "#8d378c", "#68d9a3", "#dd3e34", "#8ed4d5", "#d84787",
                "#498770", "#c581d3", "#d27333", "#6680cb", "#83662e",
                "#cab7da", "#364627", "#d16263", "#2d384d", "#e0b495",
                "#4b272a", "#919071", "#7b3860", "#843028", "#bb7d91")
  }else{
    colors <- c("#982f29", "#5ddb53", "#8b35d6", "#a9e047", "#4836be",
                "#e0dc33", "#d248d5", "#61a338", "#9765e5", "#69df96",
                "#7f3095", "#d0d56a", "#371c6b", "#cfa738", "#5066d1",
                "#e08930", "#6a8bd3", "#da4f1e", "#83e6d6", "#df4341",
                "#6ebad4", "#e34c75", "#50975f", "#d548a4", "#badb97",
                "#b377cf", "#899140", "#564d8b", "#ddb67f", "#292344",
                "#d0cdb8", "#421b28", "#5eae99", "#a03259", "#406024",
                "#e598d7", "#343b20", "#bbb5d9", "#975223", "#576e8b",
                "#d97f5e", "#253e44", "#de959b", "#417265", "#712b5b",
                "#8c6d30", "#a56c95", "#5f3121", "#8f846e", "#8f5b5c")
  }
  if(!is.null(n)){
    if(n <= length(colors)){
      colors <- colors[1:n]
    }else{
      step <- 16777200 %/% (n - length(colors)) - 2
      add.colors <- paste0("#", as.hexmode(seq(from = sample(1:step, 1),
                                               by = step, length.out = (n-length(colors)))))
      colors <- c(colors, add.colors)
    }
  }
  return(colors)
}

### disco ###

#' Title display the color which you choose with the function 'need_color'
#'
#' @param colpal a valid color palette name(color number + id,such as 'two1',can see disco())
#' or a numberic vector that can select color randomly.
#' @param ncol when set the colpal names, ncol set how many color you need
#'
#' @return plot a plot display the color you choose
#' @export
#'
#' @examples # nothing
#'
disco = function(colpal = NULL,ncol = NULL)
{
  if (is.null(colpal)){
    if (is.null(ncol)){ncol = 9}
    # plot custom-made palettes #

    ownpals = c("two1", "two2", "two3", "two4", "two5", "three1", "three2", "four1", "nine1")
    pals = ownpals
    npal = length(ownpals)
    plot(1,1,xlim=c(0,ncol),ylim=c(0,npal),type="n",axes=FALSE,bty="n",xlab="",ylab="",main="")
    suppressMessages(for (i in 1:npal){rect(xleft = 0:(ncol - 1),ybottom = i - 1,xright = 1:ncol,ytop = i - 0.2,col = need_colors(pals[i],ncol),border = NA)})
    for (i in 1:npal){rect(xleft = 0,ybottom = i - 1,xright = ncol,ytop = i - 0.2,col = "transparent",border = NA)}
    text(rep(-0.1,npal),(1:npal)-0.6,labels = pals,xpd = TRUE,adj = 1,cex=0.8)
    mtext(paste("palettes from the xbox package"),3,2,cex=1.25)
    mtext(paste("( character strings can be passed to xbox functions as 'need_colors' )"),3,0,col="darkgrey")
    # devAskNewPage(ask = TRUE)

    # plot palettes from the RColorBrewer package (part 1) #

  } else {
    # plot user-specified need_colors if 'colpal != NULL' #
    if (is.null(ncol)){ncol = length(need_colors(colpal,ncol))}
    plot(1,1,xlim=c(0,ncol),ylim=c(0,8),type="n",axes=FALSE,bty="n",xlab="",ylab="",main="")
    rect(xleft = 0:(ncol - 1),ybottom = 3,xright = 1:ncol,ytop = 5,col = need_colors(colpal,ncol),border = NA)
    rect(xleft = 0,ybottom = 3,xright = ncol,ytop = 5,col = "transparent",border = "darkgrey")
    if (length(colpal) > 1){mtext(paste("need_colors"),3,2,cex=1.25)} else {mtext(paste(colpal,"need_colors"),3,2,cex=1.25)}
    mtext(paste("( ",paste(need_colors(colpal,ncol),collapse = "  ")," )"),3,0,col="darkgrey",cex=1 + ((1-0.25)*(nchar(paste("( ",paste(need_colors(colpal,ncol),collapse = "  ")," )"))-50))/(50-185))
  }
}

