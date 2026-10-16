# A project with an otexts format whose htmlreplace.pl makes a visible change
local_project <- function(
  layout = "_extensions/OTexts/otexts",
  script = "s/before/after/g;",
  env = parent.frame()
) {
  dir <- withr::local_tempdir(.local_envir = env)
  ext <- file.path(dir, layout)
  dir.create(ext, recursive = TRUE)
  writeLines(c("while (<>) {", script, "print; }"), file.path(ext, "htmlreplace.pl"))
  dir
}

local_page <- function(dir, name = "page", figure = FALSE) {
  html <- file.path(dir, "_book", paste0(name, ".html"))
  dir.create(dirname(html), showWarnings = FALSE)
  writeLines("<p>before</p>", html)
  if (figure) {
    figs <- file.path(dir, "_book", paste0(name, "_files"), "figure-html")
    dir.create(figs, recursive = TRUE)
    grDevices::png(file.path(figs, "fig-1.png"), width = 600, height = 400)
    graphics::plot(stats::rnorm(500), col = grDevices::rainbow(500))
    grDevices::dev.off()
  }
  html
}

skip_if_no_perl <- function() skip_if(Sys.which("perl") == "", "perl not installed")

test_that("quarto_output_files() splits Quarto's list of files", {
  withr::local_envvar(QUARTO_PROJECT_OUTPUT_FILES = "_book/a.html\n_book/b.html")
  expect_equal(quarto_output_files(), c("_book/a.html", "_book/b.html"))
  withr::local_envvar(QUARTO_PROJECT_OUTPUT_FILES = "")
  expect_equal(quarto_output_files(), character())
})

test_that("post_render() runs htmlreplace.pl on the HTML files only", {
  skip_if_no_perl()
  dir <- local_project()
  html <- local_page(dir)
  other <- file.path(dir, "_book", "search.json")
  writeLines("before", other)
  result <- post_render(c(html, other), pngquant = FALSE, dir = dir)
  expect_equal(result, html)
  expect_equal(readLines(html), "<p>after</p>")
  expect_equal(readLines(other), "before")
})

test_that("post_render() finds a locally installed format", {
  skip_if_no_perl()
  dir <- local_project(layout = "_extensions/otexts")
  html <- local_page(dir)
  post_render(html, pngquant = FALSE, dir = dir)
  expect_equal(readLines(html), "<p>after</p>")
})

test_that("post_render() does nothing without HTML files", {
  dir <- withr::local_tempdir()
  expect_equal(post_render(character(), pngquant = FALSE, dir = dir), character())
})

test_that("post_render() errors without the otexts format", {
  dir <- withr::local_tempdir()
  html <- local_page(dir)
  expect_snapshot(post_render(html, pngquant = FALSE, dir = dir), error = TRUE)
})

test_that("post_render() errors if htmlreplace.pl fails", {
  skip_if_no_perl()
  dir <- local_project(script = "exit 3;")
  html <- local_page(dir)
  expect_snapshot(post_render(html, pngquant = FALSE, dir = dir), error = TRUE)
})

test_that("post_render() errors if pngquant isn't installed", {
  local_mocked_bindings(Sys.which = function(names) c(pngquant = ""), .package = "base")
  expect_snapshot(post_render(character()), error = TRUE)
})

test_that("post_render() compresses the figures with pngquant", {
  skip_if_no_perl()
  skip_if(Sys.which("pngquant") == "", "pngquant not installed")
  withr::local_options(mc.cores = 1)
  dir <- local_project()
  html <- local_page(dir, figure = TRUE)
  png <- file.path(dir, "_book", "page_files", "figure-html", "fig-1.png")
  before <- file.size(png)
  post_render(html, dir = dir)
  expect_lt(file.size(png), before)
  expect_equal(
    readBin(png, "raw", 8),
    as.raw(c(0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a))
  )
})
