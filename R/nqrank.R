#' Normal scores as qnorm of rank
#'
#' Copied from github.com/kbroman/broman package
#' @param x vector of measurements
#' @param jitter jitter values slightly if `TRUE`
#' @param standard standardize to mean 0, variance 1 if `TRUE`
#'
#' @return vector of normal scores
#' @export
#' @importFrom stats sd runif qnorm
#'
#' @examples
#' nqrank(1:10)
nqrank <- function (x, jitter = FALSE, standard = FALSE)
{
  ## qtl::nqrank(x, jitter)
  y <- x[!is.na(x)]
  themean <- mean(y, na.rm = TRUE)
  thesd <- stats::sd(y, na.rm = TRUE)
  y[y == Inf] <- max(y[y < Inf]) + 10
  y[y == -Inf] <- min(y[y > -Inf]) - 10
  if (jitter)
    y <- rank(y + stats::runif(length(y)) / (stats::sd(y) * 10^8))
  else y <- rank(y)
  x[!is.na(x)] <- stats::qnorm((y - 0.5)/length(y))
  if(!standard)
    x <- x * thesd / stats::sd(x, na.rm = TRUE) - mean(x, na.rm = TRUE) + themean
  x
}