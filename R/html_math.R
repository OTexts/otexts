#' Maths in raw HTML
#'
#' Wraps maths written between `$` signs in the spans that KaTeX renders. Quarto
#' only processes maths in Markdown, so maths in raw HTML (such as a table built
#' with HTML in a chunk) needs this.
#'
#' @param x A character vector.
#' @returns `x`, with each `$...$` replaced by
#'   `<span class="math inline">...</span>`.
#' @export
#' @examples
#' html_math("The mean is $\\bar{y}$.")
html_math <- function(x) {
  gsub("\\$([^$]+)\\$", "<span class=\"math inline\">\\1</span>", x)
}
