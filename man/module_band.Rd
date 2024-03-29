% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/module_band.R
\name{module_band}
\alias{module_band}
\alias{ggplot_module_band}
\alias{autoplot.module_band}
\title{Module Band Object}
\usage{
module_band(traitModule, response = responses[1], solo = FALSE)

ggplot_module_band(object, ...)

\method{autoplot}{module_band}(object, ...)
}
\arguments{
\item{traitModule}{object of class `listof_wgcnaModules`}

\item{response}{name of response for top row}

\item{solo}{do one response if `TRUE`}

\item{object}{object of class `module_band`}

\item{...}{additional parameters}
}
\value{
data frame of class `module_band`

ggplot object
}
\description{
Module Band Object

GGplot of module bands
}
