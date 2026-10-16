#' Set the books' ggplot2 theme
#'
#' Updates the current ggplot2 theme so that plot text is in the BookMath family
#' (see [register_book_fonts()]), so [tex()] labels work in titles, axes,
#' legends and text layers, and tick labels are a little larger than the
#' default, so that maths in them isn't dwarfed by digits.
#'
#' The family is also set as the default for the text and label geoms, as a
#' complete theme such as [ggplot2::theme_void()] resets the theme's geom
#' settings, and for the text geoms of \pkg{ggrepel} and \pkg{ggraph} (when
#' installed), which ignore the theme.
#'
#' @param family Font family for plot text.
#' @param axis_text_size Size of tick labels, relative to the theme's base text
#'   size. ggplot2's default is 0.8.
#' @returns The previous theme, invisibly.
#' @seealso [theme_book_void()], [setup_book()], which calls this.
#' @export
#' @examples
#' register_book_fonts()
#' old <- set_book_theme()
#' ggplot2::theme_get()$text$family
#' ggplot2::theme_set(old)
set_book_theme <- function(family = "BookMath", axis_text_size = 0.9) {
  old <- ggplot2::theme_update(
    text = ggplot2::element_text(family = family),
    axis.text = ggplot2::element_text(size = ggplot2::rel(axis_text_size)),
    geom = ggplot2::element_geom(family = family)
  )
  ggplot2::update_geom_defaults("text", list(family = family))
  ggplot2::update_geom_defaults("label", list(family = family))
  # These text geoms ignore the theme, defaulting to family "", which ragg sets
  # in the system sans font
  if (rlang::is_installed("ggrepel")) {
    ggplot2::update_geom_defaults(ggrepel::GeomTextRepel, list(family = family))
    ggplot2::update_geom_defaults(ggrepel::GeomLabelRepel, list(family = family))
  }
  if (rlang::is_installed("ggraph")) {
    ggplot2::update_geom_defaults(ggraph::GeomEdgePath, list(family = family))
  }
  invisible(old)
}

#' A void theme in the books' font
#'
#' [ggplot2::theme_void()] with the BookMath font family, as
#' [ggplot2::theme_void()] sets text in the default family "", whatever the
#' current theme. [setup_book()] defines `theme_void()` as this function, so
#' book chunks can call `theme_void()` and readers can run the same code.
#'
#' @param ... Arguments passed to [ggplot2::theme_void()].
#' @param base_family Font family for plot text.
#' @returns A ggplot2 theme.
#' @seealso [set_book_theme()].
#' @export
#' @examples
#' theme_book_void()$text$family
theme_book_void <- function(..., base_family = "BookMath") {
  ggplot2::theme_void(..., base_family = base_family)
}
