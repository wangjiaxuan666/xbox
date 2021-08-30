#' heatpoint packages is created for the desity plot, It can caculate the point density in 2-dimension coordinate or 1D coordinate by the parameter `only`.
#'
#' @param x the input data need vector or list number, if the dataframe colunm should use `$` or `[]`.
#' @param y the other input data caculate for the density for x input.
#' @param xlim input must be a vctor,the limit of the x input number for caculate desity.
#' @param ylim input must be a vctor,the limit of the y input number for caculate desity.
#' @param log a character string which contains "x" if the x axis is to be logarithmic, "y" if the y axis is to be logarithmic and "xy" or "yx" if both axes are to be logarithmic.
#' @param grid the input number will be cut for several zones for caculate the desity, the grid parameter more small ,the desity will be more slight and more time need.
#' @param only a character string which contains 'x' if the density should only be computed for the x axis, 'y' for the y axis (defaults to 'none' for the two-dimensional case).
#' @param method a character specifying the correlation method to use ('pearson' (default), 'kendall' or 'spearman').
#' @param formula the lm formula,the defult is `y ~ x`
#' @param ... additional parameters to be passed to points and plot.
#' @author Jiaxuan Wang
#' @seealso The LSD packages, the wonderful R packages created by Achim Tresch and Bjoern Schwalb
#' @note Two-Dimensional Kernel Density Estimation adapted and modified from Venables and Ripley's MASS package (see reference).
#' @references Venables, W. N. and Ripley, B. D. (2002) \emph{Modern Applied Statistics with S.} Fourth edition. Springer.
#' @return the list object including the plot data and the result of the correlation adn lm.
#' @export heatpoint
#' @importFrom stats cor dnorm median quantile rnorm sd var t.test lm cor.test
#'
#' @examples points = 5000
#' x = c(rnorm(points/2))
#' y = x + rnorm(points/2,sd=0.8)
#' x = sign(x)*abs(x)^1.3
#' heatpoint(x,y) -> dat_result

heatpoint <- function(x,
                      y,
                      xlim = NULL,
                      ylim = NULL,
                      log = "",
                      grid = 100,
                      only = "none",
                      method = "pearson",
                      formula = y ~ x,
                      ...){
  # Data check #
  if (!is.vector(x) | !is.vector(y)) stop("First two argument must be numeric vectors!")
  if (length(x) != length(y)) stop("Data vectors must be of the same length!")
  valid = which((!(is.na(x)|is.nan(x)|(x==Inf)|(x==-Inf))) & (!(is.na(y)|is.nan(y)|(y==Inf)|(y==-Inf))))
  if (length(valid)==0) stop("There are no valid point pairs to plot!")
  x = x[valid]
  y = y[valid]
  if (!is.null(xlim)){cut = x >= xlim[1] & x <= xlim[2]
  x = x[cut]
  y = y[cut]
  }
  if (!is.null(ylim)){cut = y >= ylim[1] & y <= ylim[2]
  y = y[cut]
  x = x[cut]
  }

  # creat a discrete number list in range of the bins
  # The function cut the input list into bins numbers grid, a gird have a same value.
  # such as c(1:10) when bins is 5, then become 1 1 2 2 3 3 4 4 5 5.
  # todiscrete(1:10,1,10,bins = 5)
  todiscrete = function(t,tmin,tmax,bins){
    erg = round((t-tmin)/(tmax-tmin)*bins+0.5)
    erg = pmin(pmax(erg,1),bins)
    return(erg)
  }

  # The core code in this R scirpt----------------------------------------
  # kde2d.adj function: adapted and modified from Venables and Ripley's MASS package #
  bandwidth.nrd.adj = function(x){
    r = quantile(x,c(0.25,0.75))
    h = (r[2] - r[1])/1.34
    return(4*1.06*min(sqrt(var(x)),h)*length(x)^(-1/5))
  }

  kde2d.adj = function(x,y,h,n = 25,lims = c(range(x),range(y)),only = "none"){
    nx = length(x)
    gx = seq.int(lims[1],lims[2],length.out = n)
    gy = seq.int(lims[3],lims[4],length.out = n)
    if (missing(h)) {
      bx = bandwidth.nrd.adj(x)
      by = bandwidth.nrd.adj(y)
      if (all(c(bx,by) == 0)){h = rep(0.01,2)} else if (any(c(bx,by) == 0)){h = rep(max(bx,by),2)} else {h = c(bx,by)}
    } else h = rep(h,length.out = 2)
    h = h/4
    ax = outer(gx,x,"-")/h[1]
    ay = outer(gy,y,"-")/h[2]
    norm.ax = dnorm(ax)
    norm.ay = dnorm(ay)
    if (only == "x"){norm.ay = rep(1,length(ay))}
    if (only == "y"){norm.ax = rep(1,length(ax))}
    z = tcrossprod(matrix(norm.ax,,nx),matrix(norm.ay,,nx))/(nx*h[1]*h[2])
    list(x = gx,y = gy,z = z)
  }
  #--------------------------------------------------------------

  # handle 'log' option
  # if you use the ggplot2 should use the log10() with the native data

  if (log == ""){
    xlog = x
    ylog = y
  } else if (log == "x"){
    xlog = log(x + 1,10)
    ylog = y
    message("The x value with log10()")
  } else if (log == "y"){
    xlog = x
    ylog = log(x + 1,10)
    message("The y value with log10()")
  } else if (log %in% c("xy","yx")){
    xlog = log(x + 1,10)
    ylog = log(x + 1,10)
    message("The x&y value with log10()")
  }

  # calclute the density of the point
  d = kde2d.adj(xlog,ylog,n=grid,only=only)

  # binning #

  xdiscrete = todiscrete(xlog,min(xlog),max(xlog),bins=grid)
  ydiscrete = todiscrete(ylog,min(ylog),max(ylog),bins=grid)

  # color assignment #

  getfrommat = function(a){d$z[a[1],a[2]]}
  heatvec = unlist(apply(cbind(xdiscrete,ydiscrete),1,getfrommat))
  cor.res = cor.test(y, x, method = method)
  formula = formula
  lm.res = lm(formula)
  res = list(plot.data = data.frame(x = x,y = y,Density = heatvec),
             cor.result = list(cor = re[["estimate"]][[names(re[["estimate"]])]],
                               pvalue = cor.res[["p.value"]],
                               method = cor.res["method"]),
             lm.result = list(formula = lm.res[["coefficients"]],
                              method = lm.res[["call"]][[1]],
                              exp = formula))
  class(res) <- "heatpoint"
  return(res)
}
