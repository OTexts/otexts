#' Register the fonts used in plots
#'
#' Registers the "BookMath" font family with \pkg{systemfonts}, so that graphics
#' devices built on it (such as [ragg::agg_png()], used by the otexts Quarto
#' format) can find it. [tex()] labels need this family: its plain face is the
#' text font, Fira Sans by default, and its other faces are KaTeX fonts bundled
#' with the package (see [tex()]).
#'
#' The KaTeX fonts are copies scaled up by 1.2, so that their x-height matches
#' that of Fira Sans.
#'
#' It also registers KaTeX_Main as the "symbol" family, which plotmath uses for
#' operators and symbols such as `+`, `=`, `<=` and `infinity`, so that they
#' match the maths in the text rather than the system's symbol font. KaTeX_Main
#' has no lower-case Greek, so write Greek letters with [tex()], which sets them
#' in KaTeX_Math, rather than as plotmath symbols such as `alpha`.
#'
#' The text font must be installed. Fira Sans covers Latin, Greek and Cyrillic.
#' A translation into a language in another script can use an installed font
#' that covers it, such as `text_font = "Noto Sans CJK SC"`.
#'
#' As BookMath's bold and italic faces are KaTeX fonts, bold or italic text
#' must use the text font's own family instead, e.g.
#' `geom_text(family = "Fira Sans", fontface = "bold")`.
#'
#' @param text_font The family of the plain face of BookMath, and so of the text
#'   in plots. It must be installed.
#' @returns The name of the maths family, `"BookMath"`, invisibly.
#' @seealso [tex()], [set_book_theme()].
#' @export
#' @examplesIf "Fira Sans" %in% systemfonts::system_fonts()$family
#' register_book_fonts()
#' "BookMath" %in% systemfonts::registry_fonts()$family
register_book_fonts <- function(text_font = "Fira Sans") {
  font_file <- function(file) {
    system.file("fonts", paste0(file, ".ttf"), package = "otexts", mustWork = TRUE)
  }
  # Registered afresh each time, so a change to the font files is picked up
  systemfonts::register_font(
    name = "BookMath",
    plain = installed_font(text_font),
    bold = font_file("KaTeX_Main_Plot-Regular"),
    italic = font_file("KaTeX_Math_Plot-Italic"),
    bolditalic = font_file("KaTeX_Math_Plot-BoldItalic")
  )
  # Plotmath draws operators and symbols in the "symbol" family
  systemfonts::register_font(
    name = "symbol",
    plain = font_file("KaTeX_Main_Plot-Regular")
  )
  invisible("BookMath")
}

# Path of the regular face of an installed font family, checking that the font
# found is that family: systemfonts falls back to a default font otherwise
installed_font <- function(family, call = rlang::caller_env()) {
  path <- systemfonts::match_fonts(family)$path
  found <- systemfonts::font_info(path = path)$family
  if (!identical(found, family)) {
    rlang::abort(
      c(
        sprintf("Font family \"%s\" is not installed.", family),
        i = "It is needed for the text in plots. Install it, or choose another font with `text_font`."
      ),
      call = call
    )
  }
  path
}
