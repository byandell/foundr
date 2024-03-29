% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/shinyContrastModule.R
\name{shinyContrastModuleOutput}
\alias{shinyContrastModuleOutput}
\alias{shinyContrastModule}
\title{Shiny Module Output for Modules of Contrasts}
\usage{
shinyContrastModuleOutput(id)

shinyContrastModule(
  id,
  panel_par,
  main_par,
  traitContrast,
  contrastModule,
  customSettings = NULL
)
}
\arguments{
\item{id}{identifier for shiny reactive}

\item{panel_par, main_par}{reactive arguments}

\item{traitContrast}{reactive data frames}

\item{contrastModule}{static data frames}

\item{customSettings}{list of custom settings}
}
\value{
nothing returned

reactive object
}
\description{
Shiny Module Output for Modules of Contrasts

Shiny Module Server for Modules of Contrasts
}
