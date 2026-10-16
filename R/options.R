#' The books' colour palette
#'
#' The Okabe-Ito palette, which is distinguishable with the common forms of
#' colour blindness, in the order used for discrete scales in the books.
#'
#' @returns A character vector of seven hex colours.
#' @seealso [set_book_options()], which makes these the default discrete
#'   colours in ggplot2.
#' @export
#' @examples
#' book_colours()
book_colours <- function() {
  c("#D55E00", "#0072B2", "#009E73", "#CC79A7", "#E69F00", "#56B4E9", "#F0E442")
}

#' Set the books' printing and colour options
#'
#' Sets [options()] for printed output and ggplot2 colour scales:
#'
#' * `digits`, the number of significant digits printed;
#' * `width` and `pillar.width`, the width of printed output and tibbles, in
#'   characters;
#' * viridis colour and fill scales for continuous variables, and
#'   [book_colours()] for discrete variables.
#'
#' @param digits Number of significant digits to print.
#' @param width Width of printed output, in characters. The default, 88, suits
#'   the text column of the HTML books.
#' @returns The previous values of the options, invisibly, so they can be
#'   restored with [options()].
#' @seealso [setup_book()], which calls this.
#' @export
#' @examples
#' old <- set_book_options()
#' getOption("width")
#' options(old)
set_book_options <- function(digits = 4, width = 88) {
  options(
    digits = digits,
    width = width,
    pillar.width = width,
    ggplot2.continuous.colour = "viridis",
    ggplot2.continuous.fill = "viridis",
    ggplot2.discrete.colour = book_colours(),
    ggplot2.discrete.fill = book_colours()
  )
}
