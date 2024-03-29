% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/area_under_curve.R
\name{area_under_curve}
\alias{area_under_curve}
\title{Calculate area under curve over time}
\usage{
area_under_curve(object, timecol = c("minutes", "minute", "week"))
}
\arguments{
\item{object}{data frame with `value` and other columns}

\item{timecol}{column containing time values}
}
\value{
object collapsed over time with summaries
}
\description{
Calculate area under curve over time
}
