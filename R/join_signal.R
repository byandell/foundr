#' Join trait data and signal
#'
#' @param traitData data frame with harmonized data
#' @param traitSignal data frame with `signal` and `cellmean`
#' @param response name of response to create through joining
#'
#' @return data frame with `value` as `rest` or `noise` column
#' @export
#' @importFrom dplyr left_join mutate select
#' @importFrom rlang .data
#'
join_signal <- function(traitData, traitSignal, response = c("rest", "noise")) {
  response <- match.arg(response)
  
  if("condition" %in% names(traitData)) {
    bys <- c("strain","sex","condition","trait")
  } else {
    bys <- c("strain","sex","trait")
  }
  if("dataset" %in% names(traitData))
    bys <- c("dataset", bys)
  
  out <-
    dplyr::left_join(
      traitData,
      traitSignal,
      by = bys)
  
  switch(response,
         rest = {
           dplyr::select(
             dplyr::mutate(
               out,
               value = .data$value - .data$signal),
             -.data$cellmean, -.data$signal)
         },
         noise = {
           dplyr::select(
             dplyr::mutate(
               out,
               value = .data$value - .data$cellmean),
             -.data$cellmean, -.data$signal)
         })
}
