#' Cache the result of a long computation
#'
#' Returns the value of `command`, computing it only if it hasn't been saved
#' before. The value is saved in `<dir>/<name>.rds`, and later calls with the
#' same `name` read it from there without evaluating `command`.
#'
#' Unlike knitr's chunk cache, the saved value survives a change to the chunk,
#' and is shared between chapters. Delete the file to recompute it, e.g. after
#' changing `command` or updating packages.
#'
#' @param command An expression whose value is to be cached. It is evaluated
#'   only if there is no saved value.
#' @param name Name of the cache file, without the `.rds` extension.
#' @param dir Directory for cache files. The default is `rds/` in the project
#'   root (found with [here::here()]). It must exist.
#' @returns The value of `command`.
#' @export
#' @examples
#' dir <- tempfile()
#' dir.create(dir)
#' x <- cache(sqrt(2), "root2", dir = dir)
#' list.files(dir)
#' unlink(dir, recursive = TRUE)
cache <- function(command, name, dir = here::here("rds")) {
  file <- file.path(dir, paste0(name, ".rds"))
  if (file.exists(file)) {
    readRDS(file)
  } else {
    object <- command
    saveRDS(object, file)
    object
  }
}
