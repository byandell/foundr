#' Pivot pair of traits
#'
#' @param object data frame with specific columns
#' @param pair 2-vector of trait names
#'
#' @return data frame
#' @export
#' @importFrom dplyr filter full_join mutate select
#' @importFrom rlang .data
#'
pivot_pair <- function(object, pair) {
  if(!all(pair %in% object$datatraits)) {
    return(NULL)
  }
  if("cellmean" %in% names(object))
    object$cellmean <- NULL
  if("signal" %in% names(object))
    object$signal <- NULL
  
  # Reduce to pair of traits.
  object <- dplyr::filter(object, .data$datatraits %in% pair)
  
  nocond <- !("condition" %in% names(object))
  
  # Columns sex and condition present. Need to carefully address differences in condition.
  
  # split by datatraits
  object <- split(
    dplyr::select(
      object,
      -.data$datatraits, -.data$dataset, -.data$trait),
    object$datatraits)
  ntraits <- names(object)
  byvars <- names(object[[1]])
  byvars <- byvars[!(byvars %in% c("value"))]
  
  # Take care of special case of condition column with some or all NAs
  if(!nocond) {
    nocond <- sapply(object, function(x) all(is.na(x$condition)))
    if(any(nocond)) {
      byvars <- byvars[byvars != "condition"]
      for(i in names(nocond)) {
        if(nocond[i])
          object[[i]]$condition <- NULL
      }
    }
  }
  
  object <- dplyr::full_join(object[[1]], object[[2]],
                             by = byvars)
  if(!("condition" %in% names(object))) {
    object$condition <- NA
  }
  
  # Replace names of values with trait names
  names(object)[match(c("value.x","value.y"), names(object))] <- ntraits
  
  dplyr::filter(
    object,
    !(is.na(.data[[pair[1]]]) | is.na(.data[[pair[2]]])))
}
