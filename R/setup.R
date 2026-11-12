#' Set up a chapter of a book
#'
#' Does the setup shared by the OTexts books, at the start of each chapter:
#'
#' 1. registers the plot fonts with [register_book_fonts()];
#' 2. sets printing and colour options with [set_book_options()];
#' 3. sets the ggplot2 theme with [set_book_theme()];
#' 4. defines the functions in `prefer` in `env`, so they mask functions of the
#'    same names in any attached package (knitr re-attaches cached packages
#'    before the first chunk);
#' 5. defines `TeX()` as [tex()] and `theme_void()` as [theme_book_void()] in
#'    `env`, so chunks can call `TeX()` and `theme_void()`, and readers can run
#'    the same code with [latex2exp::TeX()] and [ggplot2::theme_void()].
#'
#' Figure sizes and other chunk options are set by the otexts Quarto format,
#' not here.
#'
#' @inheritParams register_book_fonts
#' @inheritParams set_book_options
#' @param prefer A named character vector of conflicts to resolve: each name is
#'   a function, and each value the package whose version is preferred.
#' @param env Environment in which to define `TeX()`, `theme_void()` and the
#'   functions in `prefer`. The default is the calling environment, which is the global environment when
#'   `setup_book()` is called from a script run with [source()].
#' @returns `NULL`, invisibly.
#' @export
#' @examples
#' \dontrun{
#' # In before-each-chapter.R, sourced at the start of each chapter
#' library(otexts)
#' setup_book()
#' }
setup_book <- function(
  text_font = "Fira Sans",
  digits = 4,
  width = 88,
  prefer = c(select = "dplyr", filter = "dplyr", count = "dplyr"),
  env = rlang::caller_env()
) {
  register_book_fonts(text_font)
  set_book_options(digits = digits, width = width)
  set_book_theme()
  for (fn in names(prefer)) {
    assign(fn, getExportedValue(prefer[[fn]], fn), envir = env)
  }
  assign("TeX", tex, envir = env)
  assign("theme_void", theme_book_void, envir = env)
  invisible()
}
