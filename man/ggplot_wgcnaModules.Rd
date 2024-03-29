% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ggplot_wgcna.R
\name{ggplot_wgcnaModules}
\alias{ggplot_wgcnaModules}
\alias{autoplot.wgcnaModules}
\alias{ggplot_listof_wgcnaModules}
\alias{autoplot.listof_wgcnaModules}
\title{GGplot of WGCNA Modules}
\usage{
ggplot_wgcnaModules(
  object,
  response = names(object),
  main = paste("Dendrogram for", response, "with module colors"),
  ...
)

\method{autoplot}{wgcnaModules}(object, ...)

ggplot_listof_wgcnaModules(
  object,
  response = names(object),
  main = paste("Dendrogram for", response, "with module colors"),
  ...
)

\method{autoplot}{listof_wgcnaModules}(object, ...)
}
\arguments{
\item{object}{}

\item{response}{response for dendrogram and primary color band}

\item{main}{title of plot}

\item{...}{}
}
\value{
ggplot2 object

ggplot2 object

ggplot2 object

ggplot2 object
}
\description{
GGplot of WGCNA Modules

Autoplot of wgcnaModules

GGplot of List of WGCNA Modules

Autoplot of wgcnaModules
}
