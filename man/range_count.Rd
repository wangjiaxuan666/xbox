% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/range_count.R
\name{range_count}
\alias{range_count}
\title{Title the function for caculate the count for every range.}
\usage{
range_count(x, gap, min_num, max_num)
}
\arguments{
\item{x}{the input should be a numeric vector}

\item{gap}{how many number which need to gap step}

\item{min_num}{the first number in scales which will breaks in gap}

\item{max_num}{the last number in scales which will breaks in gap}
}
\value{
a object
}
\description{
Title the function for caculate the count for every range.
}
\examples{
data = range_count(x = rnorm(100,5)*100,gap = 100,min_num = 0,max_num = 1000)
print(data)
xplot(data)
}
