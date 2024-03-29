% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/traitTimes.R
\name{traitTimes}
\alias{traitTimes}
\alias{ggplot_traitTimes}
\alias{autoplot.traitTimes}
\alias{plot.traitTimes}
\title{Traits over Time}
\usage{
traitTimes(traitData, traitSignal, traitStats, ...)

ggplot_traitTimes(
  object,
  objectSum = NULL,
  ...,
  drop_xlab = TRUE,
  facet_strain = (timetype != "strain"),
  legend_position = "bottom"
)

\method{autoplot}{traitTimes}(object, ...)

\method{plot}{traitTimes}(x, ...)
}
\arguments{
\item{traitSignal}{data from with trait signals}

\item{...}{additional parameters}

\item{object}{data frame with trait data or trait stats from `strainstats`}

\item{drop_xlab}{drop xlab for all but last plot if `TRUE`}

\item{legend_position}{position of legend ("none" for none)}

\item{traitnames}{names of `dataset: trait`}

\item{response}{character string for type of response}

\item{timecol}{column to use for time}

\item{object, objectSum}{object of class `strain_time`}
}
\value{
object of class `traitTimes`

ggplot object
}
\description{
Traits over Time

GGplot of Strains over Time
}
