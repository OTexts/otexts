test_that("setup_book() defines TeX() and theme_void() in env", {
  skip_if_no_fira_sans()
  local_book_theme_reset()
  withr::local_options(digits = 7)
  env <- new.env()
  setup_book(prefer = character(), env = env)
  expect_identical(env$TeX, tex)
  expect_identical(env$theme_void, theme_book_void)
})

test_that("setup_book() sets the fonts, options and theme", {
  skip_if_no_fira_sans()
  local_book_theme_reset()
  withr::local_options(digits = 7, width = 80)
  setup_book(prefer = character(), width = 60, env = new.env())
  expect_true("BookMath" %in% systemfonts::registry_fonts()$family)
  expect_equal(getOption("width"), 60)
  expect_equal(ggplot2::theme_get()$text$family, "BookMath")
})
