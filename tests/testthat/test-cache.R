test_that("cache() saves a value and reuses it without recomputing", {
  dir <- withr::local_tempdir()
  n <- 0
  compute <- function() {
    n <<- n + 1
    "value"
  }
  expect_equal(cache(compute(), "x", dir = dir), "value")
  expect_true(file.exists(file.path(dir, "x.rds")))
  expect_equal(cache(compute(), "x", dir = dir), "value")
  expect_equal(n, 1)
})
