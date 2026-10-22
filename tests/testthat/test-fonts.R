font_path <- function(file) {
  system.file("fonts", paste0(file, ".ttf"), package = "otexts")
}

bookmath <- function() {
  fonts <- systemfonts::registry_fonts()
  fonts <- fonts[fonts$family == "BookMath", ]
  stats::setNames(fonts$path, fonts$style)
}

test_that("register_book_fonts() registers BookMath with KaTeX maths faces", {
  expect_equal(register_book_fonts(), "BookMath")
  paths <- bookmath()
  expect_setequal(names(paths), c("Regular", "Bold", "Italic", "Bold Italic"))
  expect_equal(paths[["Bold"]], font_path("KaTeX_Main_Plot-Regular"))
  expect_equal(paths[["Italic"]], font_path("KaTeX_Math_Plot-Italic"))
  expect_equal(paths[["Bold Italic"]], font_path("KaTeX_Math_Plot-BoldItalic"))
})

test_that("register_book_fonts() sets plotmath symbols in KaTeX_Main", {
  register_book_fonts()
  expect_equal(
    systemfonts::match_fonts("symbol")$path,
    font_path("KaTeX_Main_Plot-Regular")
  )
})

test_that("register_book_fonts() uses the installed Fira Sans for text", {
  skip_if_no_fira_sans()
  register_book_fonts()
  expect_equal(bookmath()[["Regular"]], systemfonts::match_fonts("Fira Sans")$path)
})

test_that("register_book_fonts() uses the bundled Fira Sans if it isn't installed", {
  # systemfonts won't register a family that is installed, so this can't be faked
  skip_if("Fira Sans" %in% systemfonts::system_fonts()$family, "Fira Sans is installed")
  systemfonts::clear_registry()
  withr::defer(systemfonts::clear_registry())
  register_book_fonts()
  fonts <- systemfonts::registry_fonts()
  fira <- fonts[fonts$family == "Fira Sans", ]
  expect_equal(
    stats::setNames(fira$path, fira$style)[c("Regular", "Bold", "Italic", "Bold Italic")],
    c(
      Regular = font_path("FiraSans-Regular"),
      Bold = font_path("FiraSans-Bold"),
      Italic = font_path("FiraSans-Italic"),
      `Bold Italic` = font_path("FiraSans-BoldItalic")
    )
  )
  expect_equal(bookmath()[["Regular"]], font_path("FiraSans-Regular"))
})

test_that("register_book_fonts() doesn't register Fira Sans if it is installed", {
  skip_if_no_fira_sans()
  systemfonts::clear_registry()
  withr::defer(systemfonts::clear_registry())
  register_book_fonts()
  expect_false("Fira Sans" %in% systemfonts::registry_fonts()$family)
})

test_that("register_book_fonts() errors for a font that isn't installed", {
  expect_snapshot(
    register_book_fonts(text_font = "No Such Font Family"),
    error = TRUE
  )
})
