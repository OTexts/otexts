#' Maths in plot labels, in the book's fonts
#'
#' A drop-in replacement for [latex2exp::TeX()] that sets maths in the same
#' fonts that KaTeX uses for maths in the text of a book: variables and
#' lower-case Greek in KaTeX_Math italic, and digits, brackets and upper-case
#' Greek in KaTeX_Main. Ordinary text in a label stays in the plot's text font.
#'
#' Plotmath can't switch font family within a label, but it can switch face, so
#' the labels need the "BookMath" family set up by [register_book_fonts()], which
#' has a different font for each face:
#'
#' | Face       | Font                 | Used for                              |
#' |------------|----------------------|---------------------------------------|
#' | plain      | Fira Sans            | text, e.g. "Contours of"              |
#' | bold       | KaTeX_Main Regular   | digits, brackets, upper-case Greek    |
#' | italic     | KaTeX_Math Italic    | variables and lower-case Greek        |
#' | bolditalic | KaTeX_Math BoldItalic | vectors, as `\bm{v}` in the text     |
#'
#' [setup_book()] defines `TeX()` as `tex()`, so book chunks can call `TeX()`
#' and readers can run the same code with [latex2exp::TeX()], getting the same
#' labels in default fonts. Write vectors as `\textbf{v}`, which
#' [latex2exp::TeX()] sets in bold and `tex()` sets in bold italic, as `\bm{v}`
#' is in the text.
#'
#' Unlike [latex2exp::TeX()], the result is unnamed, as ggplot2 matches named
#' scale labels to breaks by name.
#'
#' @param input A character vector of LaTeX strings, with maths between `$`
#'   signs.
#' @param output `"expression"` (the default) for plot labels, or `"character"`
#'   for strings to use in text layers with `parse = TRUE`.
#' @returns An expression vector, or a character vector of plotmath strings, the
#'   same length as `input`.
#' @seealso [register_book_fonts()] for the fonts, [latex2exp::TeX()].
#' @export
#' @examples
#' tex("Sample size ($n$)")
#' tex(c("$\\alpha = 0.05$", "$\\textbf{y}_t$"))
#' tex("$\\hat{f}(y)$", output = "character")
#'
#' library(ggplot2)
#' ggplot(mtcars, aes(wt, mpg)) +
#'   geom_point() +
#'   labs(x = tex("Weight ($w$)"), y = tex("$\\hat{y}_i$"))
tex <- function(input, output = c("expression", "character")) {
  output <- rlang::arg_match(output)
  plotmath <- unname(latex2exp::TeX(
    input,
    user_defined = list(
      "\\bm" = "bolditalic($arg1)",
      "\\textbf" = "bolditalic($arg1)"
    ),
    output = "character"
  ))
  exprs <- lapply(plotmath, function(s) {
    tex_restyle(str2lang(tex_quote_numbers(s)))
  })
  if (output == "character") {
    vapply(exprs, deparse1, character(1))
  } else {
    as.expression(exprs)
  }
}

tex_greek <- c(
  alpha = "\u03b1",
  beta = "\u03b2",
  gamma = "\u03b3",
  delta = "\u03b4",
  epsilon = "\u03b5",
  zeta = "\u03b6",
  eta = "\u03b7",
  theta = "\u03b8",
  iota = "\u03b9",
  kappa = "\u03ba",
  lambda = "\u03bb",
  mu = "\u03bc",
  nu = "\u03bd",
  xi = "\u03be",
  pi = "\u03c0",
  rho = "\u03c1",
  sigma = "\u03c3",
  tau = "\u03c4",
  upsilon = "\u03c5",
  phi = "\u03c6",
  chi = "\u03c7",
  psi = "\u03c8",
  omega = "\u03c9",
  Gamma = "\u0393",
  Delta = "\u0394",
  Theta = "\u0398",
  Lambda = "\u039b",
  Xi = "\u039e",
  Pi = "\u03a0",
  Sigma = "\u03a3",
  Phi = "\u03a6",
  Psi = "\u03a8",
  Omega = "\u03a9"
)

# Plotmath functions, which are kept with only their arguments restyled
tex_plotmath_fns <- c(
  "[",
  "^",
  "*",
  "~",
  "{",
  "(",
  "paste",
  "hat",
  "widehat",
  "bar",
  "tilde",
  "widetilde",
  "dot",
  "ring",
  "phantom",
  "frac",
  "over",
  "sqrt",
  "group",
  "bgroup",
  "==",
  "!=",
  "<",
  ">",
  "<=",
  ">=",
  "+",
  "-",
  "/",
  "%+-%",
  "%*%",
  "%.%",
  "%~~%",
  "%==%",
  "%prop%",
  "%->%",
  "%in%",
  "plain",
  "bold",
  "italic",
  "bolditalic",
  "textstyle",
  "displaystyle",
  "scriptstyle",
  "underline",
  "atop",
  "symbol"
)

# Plotmath symbols, which are left as they are
tex_plotmath_symbols <- c(
  "infinity",
  "partialdiff",
  "nabla",
  "cdots",
  "ldots",
  "degree",
  "minute",
  "second",
  "aleph",
  "varepsilon",
  "vartheta",
  "varphi",
  "varsigma",
  "Upsilon1",
  "omega1",
  "theta1",
  "phi1",
  "sigma1"
)

tex_restyle <- function(e) {
  # Join terms with commas set in KaTeX_Main
  commas <- function(args) {
    Reduce(function(a, b) call("*", call("*", a, quote(bold(","))), b), args)
  }
  if (is.character(e)) {
    e # text
  } else if (is.numeric(e)) {
    call("bold", format(e))
  } else if (is.name(e)) {
    nm <- as.character(e)
    if (nm %in% names(tex_greek)) {
      # KaTeX sets lower-case Greek in italic and capitals upright
      call(
        if (nm == tolower(nm)) "italic" else "bold",
        unname(tex_greek[nm])
      )
    } else if (grepl("^[A-Za-z]+$", nm) && !nm %in% tex_plotmath_symbols) {
      # Letters, including runs such as the ij in beta[ij]
      call("italic", nm)
    } else {
      e
    }
  } else if (is.call(e)) {
    # The function may itself be a call, as in hat(g)(s)
    fn <- if (is.name(e[[1]])) as.character(e[[1]]) else ""
    args <- as.list(e)[-1]
    empty <- vapply(args, \(a) identical(a, quote(expr = )), logical(1))
    args <- lapply(args[!empty], tex_restyle)
    if (fn == "bolditalic") {
      e # a vector, from \bm{}: leave its letters in bold italic
    } else if (fn == "list") {
      # latex2exp writes the comma in y_{1,5} as list(,)
      if (length(args) == 0) quote(bold(",")) else call("{", commas(args))
    } else if (fn %in% tex_plotmath_fns) {
      as.call(c(e[[1]], args))
    } else {
      # A function such as f(y): brackets in KaTeX_Main. Products are grouped
      # with invisible braces, as plotmath otherwise shows a product on the
      # right of another product in brackets.
      call(
        "{",
        call(
          "*",
          call(
            "*",
            call("*", tex_restyle(e[[1]]), quote(bold("("))),
            call("{", commas(args))
          ),
          quote(bold(")"))
        )
      )
    }
  } else {
    e
  }
}

# Numbers in the maths (outside quoted text) as strings in KaTeX_Main, so they
# are shown as written: parsing 0.50 as a number would show it as 0.5
tex_quote_numbers <- function(s) {
  # Split at quoted strings; the odd-numbered pieces are maths
  parts <- regmatches(s, gregexpr("'[^']*'|\"[^\"]*\"", s), invert = NA)[[1]]
  maths <- seq(1, length(parts), by = 2)
  parts[maths] <- gsub(
    "(?<![A-Za-z0-9_.])([0-9]+(\\.[0-9]+)?)",
    "bold('\\1')",
    parts[maths],
    perl = TRUE
  )
  paste(parts, collapse = "")
}
