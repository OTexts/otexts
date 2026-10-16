font_path <- function(file) {
  system.file("fonts", paste0(file, ".ttf"), package = "otexts")
}

bookmath <- function() {
  fonts <- systemfonts::registry_fonts()
  fonts <- fonts[fonts$family == "BookMath", ]
  stats::setNames(fonts$path, fonts$style)
}

test_that("register_book_fonts() registers BookMath with KaTeX maths faces", {
  skip_if_no_fira_sans()
  expect_equal(register_book_fonts(), "BookMath")
  paths <- bookmath()
  expect_setequal(names(paths), c("Regular", "Bold", "Italic", "Bold Italic"))
  expect_equal(paths[["Bold"]], font_path("KaTeX_Main_Plot-Regular"))
  expect_equal(paths[["Italic"]], font_path("KaTeX_Math_Plot-Italic"))
  expect_equal(paths[["Bold Italic"]], font_path("KaTeX_Math_Plot-BoldItalic"))
})

test_that("register_book_fonts() uses the installed Fira Sans for text", {
  skip_if_no_fira_sans()
  register_book_fonts()
  expect_equal(bookmath()[["Regular"]], systemfonts::match_fonts("Fira Sans")$path)
})

test_that("register_book_fonts() errors for a font that isn't installed", {
  expect_snapshot(
    register_book_fonts(text_font = "No Such Font Family"),
    error = TRUE
  )
})
