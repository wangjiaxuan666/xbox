#' Title color palettes created by douyin dadongsheji, I use colors package a R packages
#'
#' @aliases need_colours
#' @param colpal a valid color palette name(color number + id,such as 'two1',can see disco())
#' or a numberic vector that can select color randomly.
#' @param nrcol when set the colpal names, nrcol set how many color you need
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
need_colors = function(colpal, nrcol = NULL,style = "china")
{
  if(style == "china"){
    colornames = c("#758e61", "#998F8F", "#8CADA6", "#D19848", "#F1ABAD", 
                   "#ABA0CB", "#EB4B17", "#02786A", "#4C8045", "#D23918", 
                   "#8CADA6", "#DFADBB", "#EFB08A", "#FEF9EF", "#F1ABAD", 
                   "#ABA0CB", "#FEF9EF", "#EFB08A", "#EEC96B", "#466B39", 
                   "#9d2c32", "#494367", "#cb6922", "#a58475", "#b25c43", 
                   "#8c4356", "#b26c60", "#eb5934", "#c32a2c")
    #随机颜色不能出现白色
    random_colors = c("#998F8F", "#8CADA6", "#D19848", "#F1ABAD", 
                      "#ABA0CB", "#EB4B17", "#02786A", "#4C8045", 
                      "#DFADBB", "#F1ABAD", "#003E89", "#494367",
                      "#EFB08A", "#EEC96B", 
                      "#9d2c32", "#494367", "#cb6922", "#a58475", "#b25c43", 
                      "#8c4356", "#eb5934", "#c32a2c")
    # 简单设置数字出随机颜色
    if(is.numeric(colpal)){
      colpal = ceiling(colpal)
      palette = random_colors[sample(length(colornames),colpal)]
      nrcol = NULL
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
    if (!is.null(nrcol)){
      if(nrcol > length(palette)){
        message("the color number is more the all color number in this colpal")
        palette = palette
      } else {
        palette = palette[sample(length(palette),nrcol)]
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


# aliases #
need_colours = need_colors

### disco ###

#' Title display the color which you choose with the function 'need_color'
#'
#' @param colpal a valid color palette name(color number + id,such as 'two1',can see disco())
#' or a numberic vector that can select color randomly.
#' @param nrcol when set the colpal names, nrcol set how many color you need
#'
#' @return plot a plot display the color you choose
#' @export
#'
#' @examples # nothing
disco = function(colpal = NULL,nrcol = NULL)
{
  if (is.null(colpal)){
    if (is.null(nrcol)){nrcol = 9}
    # plot custom-made palettes #

    ownpals = c("two1", "two2", "two3", "two4", "two5", "three1", "three2", "four1", "nine1")
    pals = ownpals
    npal = length(ownpals)
    plot(1,1,xlim=c(0,nrcol),ylim=c(0,npal),type="n",axes=FALSE,bty="n",xlab="",ylab="",main="")
    suppressMessages(for (i in 1:npal){rect(xleft = 0:(nrcol - 1),ybottom = i - 1,xright = 1:nrcol,ytop = i - 0.2,col = need_colors(pals[i],nrcol),border = NA)})
    for (i in 1:npal){rect(xleft = 0,ybottom = i - 1,xright = nrcol,ytop = i - 0.2,col = "transparent",border = NA)}
    text(rep(-0.1,npal),(1:npal)-0.6,labels = pals,xpd = TRUE,adj = 1,cex=0.8)
    mtext(paste("palettes from the xbox package"),3,2,cex=1.25)
    mtext(paste("( character strings can be passed to xbox functions as 'need_colors' )"),3,0,col="darkgrey")
    # devAskNewPage(ask = TRUE)

    # plot palettes from the RColorBrewer package (part 1) #

  } else {
    # plot user-specified need_colors if 'colpal != NULL' #
    if (is.null(nrcol)){nrcol = length(need_colors(colpal,nrcol))}
    plot(1,1,xlim=c(0,nrcol),ylim=c(0,8),type="n",axes=FALSE,bty="n",xlab="",ylab="",main="")
    rect(xleft = 0:(nrcol - 1),ybottom = 3,xright = 1:nrcol,ytop = 5,col = need_colors(colpal,nrcol),border = NA)
    rect(xleft = 0,ybottom = 3,xright = nrcol,ytop = 5,col = "transparent",border = "darkgrey")
    if (length(colpal) > 1){mtext(paste("need_colors"),3,2,cex=1.25)} else {mtext(paste(colpal,"need_colors"),3,2,cex=1.25)}
    mtext(paste("( ",paste(need_colors(colpal,nrcol),collapse = "  ")," )"),3,0,col="darkgrey",cex=1 + ((1-0.25)*(nchar(paste("( ",paste(need_colors(colpal,nrcol),collapse = "  ")," )"))-50))/(50-185))
  }
}

