% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/shinyStatsPanel.R
\name{shinyStatsPanelOutput}
\alias{shinyStatsPanelOutput}
\alias{shinyStatsPanel}
\title{Shiny Module Output for Stats Plot}
\usage{
shinyStatsPanelOutput(id)

shinyStatsPanel(id, main_par, traitStats, customSettings = NULL, facet = FALSE)
}
\arguments{
\item{id}{identifier for shiny reactive}

\item{main_par}{reactive arguments from `server()`}

\item{traitStats}{static data frame}

\item{customSettings}{list of custom settings}

\item{facet}{facet on `strain` if `TRUE`}
}
\value{
nothing returned

reactive object for `shinyStatsPanelOutput`
}
\description{
Shiny Module Output for Stats Plot

Shiny Module Server for Stats Plots
}
