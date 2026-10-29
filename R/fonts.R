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
#' Fira Sans is bundled with the package, and is registered as the "Fira Sans"
#' family when it isn't installed, so `family = "Fira Sans"` works in plots
#' either way. Any other text font must be installed. Fira Sans covers Latin,
#' Greek and Cyrillic. A translation into a language in another script can use
#' an installed font that covers it, such as `text_font = "Noto Sans CJK SC"`.
#'
#' As BookMath's bold and italic faces are KaTeX fonts, bold or italic text
#' must use the text font's own family instead, e.g.
#' `geom_text(family = "Fira Sans", fontface = "bold")`.
#'
#' Cairo devices, such as [grDevices::cairo_pdf()] (used by the otexts PDF
#' format), find fonts with fontconfig rather than systemfonts. So BookMath is
#' also defined in a fontconfig file, which the `FONTCONFIG_FILE` environment
#' variable points to. It adds the fonts bundled with the package to the
#' system's fonts. Fontconfig reads it only once per R session, when it is
#' first used (by systemfonts or a cairo device), so call
#' `register_book_fonts()` before anything looks for a font, such as at the
#' start of each chapter with [setup_book()]. In those devices,
#' plotmath symbols use KaTeX_Main only if the device is told to, with
#' `symbolfamily = "KaTeX_Main_Plot"` (the otexts PDF format does this).
#'
#' @param text_font The family of the plain face of BookMath, and so of the text
#'   in plots. It must be installed, unless it is Fira Sans.
#' @returns The name of the maths family, `"BookMath"`, invisibly.
#' @seealso [tex()], [set_book_theme()].
#' @export
#' @examples
#' register_book_fonts()
#' "BookMath" %in% systemfonts::registry_fonts()$family
register_book_fonts <- function(text_font = "Fira Sans") {
  # Before systemfonts first looks for a font, which starts fontconfig
  register_fontconfig(text_font)
  if (identical(text_font, "Fira Sans") && !font_installed(text_font)) {
    systemfonts::register_font(
      name = "Fira Sans",
      plain = font_file("FiraSans-Regular"),
      bold = font_file("FiraSans-Bold"),
      italic = font_file("FiraSans-Italic"),
      bolditalic = font_file("FiraSans-BoldItalic")
    )
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

# The FONTCONFIG_FILE in place before the first call, which the otexts file
# includes in place of the system's configuration
fontconfig <- new.env(parent = emptyenv())

# Defines BookMath for fontconfig, with the same faces as in systemfonts
register_fontconfig <- function(text_font) {
  file <- file.path(tempdir(), "otexts-fonts.conf")
  if (is.null(fontconfig$base)) {
    current <- Sys.getenv("FONTCONFIG_FILE")
    # A relative name is looked up where fontconfig keeps its configuration
    fontconfig$base <- if (nzchar(current) && current != file) current else "fonts.conf"
  }
  writeLines(fontconfig_xml(text_font, fontconfig$base), file)
  Sys.setenv(FONTCONFIG_FILE = file)
  invisible(file)
}

fontconfig_xml <- function(text_font, base) {
  # Each rule renames a request for BookMath in a given face; the first that
  # matches wins, so bold italic (KaTeX_Math) comes before bold (KaTeX_Main)
  rule <- function(tests, family, extra = NULL) {
    c(
      "  <match target=\"pattern\">",
      "    <test name=\"family\"><string>BookMath</string></test>",
      tests,
      sprintf(
        "    <edit name=\"family\" mode=\"assign\" binding=\"strong\"><string>%s</string></edit>",
        xml_escape(family)
      ),
      extra,
      "  </match>"
    )
  }
  c(
    "<?xml version=\"1.0\"?>",
    "<!DOCTYPE fontconfig SYSTEM \"urn:fontconfig:fonts.dtd\">",
    "<!-- The BookMath family of the otexts R package, for cairo devices -->",
    "<fontconfig>",
    sprintf("  <include ignore_missing=\"yes\">%s</include>", xml_escape(base)),
    sprintf("  <dir>%s</dir>", xml_escape(system.file("fonts", package = "otexts"))),
    rule(
      "    <test name=\"slant\" compare=\"more\"><const>roman</const></test>",
      "KaTeX_Math_Plot"
    ),
    rule(
      "    <test name=\"weight\" compare=\"more\"><const>medium</const></test>",
      "KaTeX_Main_Plot",
      "    <edit name=\"weight\" mode=\"assign\"><const>regular</const></edit>"
    ),
    rule(NULL, text_font),
    "</fontconfig>"
  )
}

xml_escape <- function(x) {
  x <- gsub("&", "&amp;", x, fixed = TRUE)
  x <- gsub("<", "&lt;", x, fixed = TRUE)
  gsub(">", "&gt;", x, fixed = TRUE)
}

font_file <- function(file) {
  system.file("fonts", paste0(file, ".ttf"), package = "otexts", mustWork = TRUE)
}

# Whether a font family is installed (or registered), checking that the font
# found is that family: systemfonts falls back to a default font otherwise.
# The face index matters for font collections (.ttc), such as Noto Sans CJK,
# where face 0 is a different family
font_installed <- function(family) {
  font <- systemfonts::match_fonts(family)
  info <- systemfonts::font_info(path = font$path, index = font$index)
  identical(info$family, family)
}

# The regular face of an installed font family, as list(path, index) for
# systemfonts::register_font()
installed_font <- function(family, call = rlang::caller_env()) {
  if (!font_installed(family)) {
    rlang::abort(
      c(
        sprintf("Font family \"%s\" is not installed.", family),
        i = "It is needed for the text in plots. Install it, or choose another font with `text_font`."
      ),
      call = call
    )
  }
  font <- systemfonts::match_fonts(family)
  list(font$path, font$index)
}
