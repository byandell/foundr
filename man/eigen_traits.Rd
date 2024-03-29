% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/eigen_traits.R
\name{eigen_traits}
\alias{eigen_traits}
\title{Compare Eigen Traits with Original Traits}
\usage{
eigen_traits(
  object,
  sexname = sexnames,
  modulename,
  contr_object,
  eigen_object = eigen_contrast(object, contr_object)
)
}
\arguments{
\item{object}{module list object}

\item{sexname}{name of sex combination}

\item{modulename}{name of module to examine}

\item{contr_object}{contrast object from `conditionContrasts()`}
}
\value{
data frame
}
\description{
Compare Eigen Traits with Original Traits
}
