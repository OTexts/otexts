test_that("html_math() wraps each inline maths in a KaTeX span", {
  expect_equal(
    html_math("$a$ and $b_1$"),
    '<span class="math inline">a</span> and <span class="math inline">b_1</span>'
  )
  expect_equal(html_math("no maths"), "no maths")
})
