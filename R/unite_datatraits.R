#' Unite Dataset and Trait
#'
#' This operates in different ways based on `undo`.
#' Need to use both `dataset` and `trait` to identify data for a `trait`.
#' 
#' @param object data frame
#' @param traitnames names as `dataset: trait` for subsetting (when `undo` = `TRUE`)
#' @param undo logical flag on function use
#' @param sep separator for `dataset: trait` (default ": ")
#' @param filters optional list of columns to filter on (when `undo` = `FALSE`)
#' @param key get key traits if `TRUE`
#'
#' @return either a subset `object` based on `traitnames` = `dataset: trait` (if `undo` = `TRUE`)
#'         or vector of `dataset: trait` names (if `undo` = `FALSE`, default)
#' @export
#' @importFrom tidyr separate_wider_delim unite
#' @importFrom dplyr distinct filter rename select
#' @importFrom rlang .data
#'
unite_datatraits <- function(object, traitnames, undo = FALSE, sep = ": ",
                             filters = NULL, key = FALSE) {
  if(undo) {
    # object = data frame to subset based on datatraits = `dataset: trait` names
    # result = data frame with only entries matching datatraits
    tidyr::separate_wider_delim(
      dplyr::filter(
        tidyr::unite(
          object,
          datatraits,
          .data$dataset, .data$trait,
          sep = sep),
        .data$datatraits %in% traitnames),
      .data$datatraits,
      delim = sep,
      names = c("dataset", "trait"))    
  } else {
    # If key_dataset, key_trait present and key=TRUE, replace dataset and trait.
    if(key && all(c("key_dataset", "key_trait") %in% names(object))) {
      object <-
        dplyr::distinct(
          dplyr::rename(
            dplyr::select(
              object,
              -dataset, -trait),
            dataset = "key_dataset",
            trait = "key_trait"),
          dataset, trait, .keep_all = TRUE)
    }
    
    # object = data frame with dataset and trait columns
    # result = vector of `dataset: trait` names optionally filtered.
    # currently only filter is `timetrait`.
    if(!is.null(filters)) {
      for(item in names(filters))
      object <-
        dplyr::filter(
          object,
          .data[[item]] == filters[[item]])
    }
    
    tidyr::unite(
      object,
      datatraits,
      .data$dataset, .data$trait,
      sep = sep)$datatraits
  }
}
