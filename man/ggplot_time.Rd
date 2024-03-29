% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ggplot_time.R
\name{ggplot_time}
\alias{ggplot_time}
\title{GGplot of object over time}
\usage{
ggplot_time(
  object,
  facet_strain = FALSE,
  xlab = "time",
  facet_time = NULL,
  ...
)
}
\arguments{
\item{object}{of class `strain_time`}

\item{facet_strain}{facet by strain if `TRUE`}

\item{xlab}{label for X axis}

\item{facet_time}{name of column to facet on if not `NULL`}

\item{...}{additional parameters}
}
\value{
object of class ggplot2
}
\description{
GGplot of object over time
}
