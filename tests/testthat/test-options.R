test_that("book_colours() is the Okabe-Ito palette", {
  expect_equal(
    book_colours(),
    c("#D55E00", "#0072B2", "#009E73", "#CC79A7", "#E69F00", "#56B4E9", "#F0E442")
  )
})

test_that("set_book_options() sets printing and colour options", {
  withr::local_options(digits = 7, width = 80)
  set_book_options(digits = 3, width = 70)
  expect_equal(getOption("digits"), 3)
  expect_equal(getOption("width"), 70)
  expect_equal(getOption("pillar.width"), 70)
  expect_equal(getOption("ggplot2.continuous.colour"), "viridis")
  expect_equal(getOption("ggplot2.continuous.fill"), "viridis")
  expect_equal(getOption("ggplot2.discrete.colour"), book_colours())
  expect_equal(getOption("ggplot2.discrete.fill"), book_colours())
})

test_that("set_book_options() returns the previous values", {
  withr::local_options(digits = 7, width = 80)
  old <- set_book_options()
  expect_equal(old$digits, 7)
  expect_equal(old$width, 80)
})
