test_that("tex() returns an unnamed expression, one element per input", {
  x <- tex(c(a = "$x$", b = "$y$"))
  expect_type(x, "expression")
  expect_length(x, 2)
  expect_null(names(x))
})

test_that("tex() character output matches the expressions", {
  input <- c("$\\alpha + \\beta_1$", "Text ($x$)")
  expect_equal(
    tex(input, output = "character"),
    vapply(tex(input), deparse1, character(1))
  )
})

test_that("tex() puts variables in italic and digits in bold", {
  expect_equal(tex("$n$")[[1]], quote(italic("n")))
  expect_equal(
    tex("$y_{1,5}$")[[1]],
    quote(italic("y")[bold("1") * bold(",") * bold("5")])
  )
})

test_that("tex() keeps numbers as written", {
  expect_match(tex("$x = 0.50$", output = "character"), 'bold("0.50")', fixed = TRUE)
})

test_that("tex() leaves numbers in text alone", {
  expect_equal(tex("Size 10 ($n$)")[[1]], quote("Size 10 (" * italic("n") * ")"))
})

test_that("tex() sets lower-case Greek in italic and capitals upright", {
  expect_equal(tex("$\\alpha$")[[1]], quote(italic("α")))
  expect_equal(tex("$\\Sigma$")[[1]], quote(bold("Σ")))
})

test_that("tex() sets \\textbf and \\bm vectors in bold italic", {
  expect_equal(tex("$\\textbf{y}$")[[1]], quote(bolditalic(y)))
  expect_equal(tex("$\\bm{y}$")[[1]], quote(bolditalic(y)))
})

test_that("tex() sets function brackets in KaTeX_Main", {
  expect_equal(
    tex("$f(y)$")[[1]],
    quote({
      italic("f") *
        bold("(") *
        {
          italic("y")
        } *
        bold(")")
    })
  )
})

test_that("tex() leaves plotmath symbols alone", {
  expect_match(tex("$\\infty$", output = "character"), "infinity", fixed = TRUE)
})

test_that("tex() output is stable", {
  expect_snapshot(
    tex(
      c(
        "Sample size ($n$)",
        "$\\hat{f}(y)$",
        "$P(Y > y \\, | \\, \\textbf{x})$",
        "$\\bar{y} \\pm 2s$",
        "$\\sigma^2 = 1$",
        "$\\log(\\hat{f}(y_i))$",
        "$\\textbf{x}_{ij}$"
      ),
      output = "character"
    )
  )
})

test_that("tex() rejects an unknown output", {
  expect_snapshot(tex("$x$", output = "plotmath"), error = TRUE)
})

test_that("tex() labels can be drawn in the book fonts", {
  skip_if_not_installed("ragg")
  skip_if_no_fira_sans()
  register_book_fonts()
  file <- withr::local_tempfile(fileext = ".png")
  p <- ggplot2::ggplot(data.frame(x = 1, y = 1), ggplot2::aes(x, y)) +
    ggplot2::geom_point() +
    ggplot2::labs(x = tex("Sample size ($n$)"), y = tex("$\\hat{f}(y)$")) +
    ggplot2::theme_grey(base_family = "BookMath")
  ragg::agg_png(file, width = 400, height = 300)
  expect_no_warning(print(p))
  grDevices::dev.off()
  expect_gt(file.size(file), 0)
})
