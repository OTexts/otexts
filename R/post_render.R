#' Tidy a book's rendered HTML and figures
#'
#' The post-render step for an OTexts book, run by Quarto after each render
#' from a script set with `project: post-render` in `_quarto.yml`:
#'
#' ```r
#' # post-render.R
#' otexts::post_render()
#' ```
#'
#' It does two things to the files from the render:
#'
#' 1. runs `htmlreplace.pl` from the otexts Quarto format on the HTML files,
#'    which tidies the bibliography links, the author line and cross-references
#'    to OTexts house style;
#' 2. reduces the figures (PNG files in each page's `_files/figure-html/`) to
#'    at most 256 colours with [pngquant](https://pngquant.org), which makes them
#'    much smaller without visible loss. A figure is left unchanged if the
#'    result would be larger, or below the quality floor. The figures are
#'    compressed in parallel, using `getOption("mc.cores", 8)` processes (one on
#'    Windows).
#'
#' Quarto runs the post-render script from the project directory, and lists the
#' files it rendered in the environment variable `QUARTO_PROJECT_OUTPUT_FILES`.
#'
#' @param files Paths of the rendered files. Only the HTML files are used.
#' @param pngquant Whether to compress the figures with pngquant, which must
#'   then be installed.
#' @param dir The project directory, where the otexts format is installed in
#'   `_extensions/`.
#' @returns The HTML files, invisibly.
#' @seealso The otexts Quarto format, <https://github.com/OTexts/quarto-otexts>.
#' @export
#' @examples
#' \dontrun{
#' # In post-render.R
#' otexts::post_render()
#' }
post_render <- function(
  files = quarto_output_files(),
  pngquant = TRUE,
  dir = "."
) {
  files <- files[endsWith(files, ".html")]
  if (pngquant) {
    pngquant_path <- find_program(
      "pngquant",
      "It compresses the figures. Install it, or use `pngquant = FALSE`."
    )
  }
  if (length(files) == 0) {
    return(invisible(files))
  }
  perl <- find_program("perl", "It runs htmlreplace.pl on the HTML files.")
  status <- system2(perl, c("-i", shQuote(find_htmlreplace(dir)), shQuote(files)))
  if (status != 0) {
    rlang::abort(sprintf("htmlreplace.pl failed with status %d.", status))
  }
  if (pngquant) {
    compress_figures(files, pngquant_path)
  }
  invisible(files)
}

#' @describeIn post_render The files from the current render, as listed by
#'   Quarto in the environment variable `QUARTO_PROJECT_OUTPUT_FILES`.
#' @export
quarto_output_files <- function() {
  files <- Sys.getenv("QUARTO_PROJECT_OUTPUT_FILES")
  if (files == "") character() else strsplit(files, "\n")[[1]]
}

# htmlreplace.pl in the otexts format: _extensions/OTexts/otexts/ when the
# format is installed from GitHub, _extensions/otexts/ when installed locally
find_htmlreplace <- function(dir = ".", call = rlang::caller_env()) {
  paths <- file.path(
    dir,
    c("_extensions/OTexts/otexts/htmlreplace.pl", "_extensions/otexts/htmlreplace.pl")
  )
  path <- paths[file.exists(paths)]
  if (length(path) == 0) {
    rlang::abort(
      c(
        "Can't find htmlreplace.pl from the otexts Quarto format.",
        i = "Install the format with `quarto add OTexts/quarto-otexts`."
      ),
      call = call
    )
  }
  path[1]
}

# Path of an installed program, or an error saying why it is needed
find_program <- function(name, why, call = rlang::caller_env()) {
  path <- Sys.which(name)
  if (path == "") {
    rlang::abort(c(sprintf("%s is not installed.", name), i = why), call = call)
  }
  unname(path)
}

# Reduce the figures of the HTML files to 256 colours. pngquant leaves a file
# unchanged (exit status 98 or 99) if the result would be larger or below the
# quality floor.
compress_figures <- function(files, pngquant, call = rlang::caller_env()) {
  fig_dirs <- file.path(sub("\\.html$", "_files", files), "figure-html")
  pngs <- list.files(fig_dirs, pattern = "\\.png$", full.names = TRUE)
  args <- "--force --ext .png --skip-if-larger --quality=80-100"
  cores <- if (.Platform$OS.type == "windows") 1L else getOption("mc.cores", 8L)
  status <- unlist(parallel::mclapply(
    pngs,
    function(png) system2(pngquant, c(args, shQuote(png))),
    mc.cores = cores
  ))
  failed <- pngs[!status %in% c(0, 98, 99)]
  if (length(failed) > 0) {
    rlang::abort(
      c("pngquant failed on some figures.", rlang::set_names(failed, "x")),
      call = call
    )
  }
  invisible(pngs)
}
