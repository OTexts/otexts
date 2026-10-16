test_that("set_book_theme() sets the theme's font and tick label size", {
  local_book_theme_reset()
  set_book_theme(family = "Test Family", axis_text_size = 0.7)
  theme <- ggplot2::theme_get()
  expect_equal(theme$text$family, "Test Family")
  expect_equal(theme$axis.text$size, ggplot2::rel(0.7))
  expect_equal(theme$geom$family, "Test Family")
})

test_that("set_book_theme() sets the font of text geoms", {
  local_book_theme_reset()
  set_book_theme(family = "Test Family")
  expect_equal(ggplot2::get_geom_defaults("text")$family, "Test Family")
  expect_equal(ggplot2::get_geom_defaults("label")$family, "Test Family")
})

test_that("set_book_theme() sets the font of ggrepel geoms", {
  skip_if_not_installed("ggrepel")
  local_book_theme_reset()
  set_book_theme(family = "Test Family")
  expect_equal(
    ggplot2::get_geom_defaults(ggrepel::GeomTextRepel)$family,
    "Test Family"
  )
  expect_equal(
    ggplot2::get_geom_defaults(ggrepel::GeomLabelRepel)$family,
    "Test Family"
  )
})

test_that("set_book_theme() returns the previous theme", {
  local_book_theme_reset()
  before <- ggplot2::theme_get()
  expect_equal(set_book_theme(), before)
})

test_that("theme_book_void() keeps the book's font", {
  expect_equal(theme_book_void()$text$family, "BookMath")
  expect_equal(theme_book_void(base_family = "Other")$text$family, "Other")
})
