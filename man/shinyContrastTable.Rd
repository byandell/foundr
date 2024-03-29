% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/shinyContrastTable.R
\name{shinyContrastTableInput}
\alias{shinyContrastTableInput}
\alias{shinyContrastTable}
\title{Shiny Module Input for Trait Panel}
\usage{
shinyContrastTableInput(id)

shinyContrastTable(
  id,
  panel_par,
  main_par,
  traitSignal,
  traitStats,
  customSettings = NULL,
  allDatasets = FALSE
)
}
\arguments{
\item{id}{identifier for shiny reactive}

\item{panel_par, main_par}{parameters from calling modules}

\item{traitSignal, traitStats}{static data frames}

\item{customSettings}{list of custom settings}

\item{allDatasets}{initially select all datasets if `TRUE`}
}
\value{
nothing returned

reactive object
}
\description{
Shiny Module Input for Trait Panel

Shiny Module Server for Contrast Panel
}
