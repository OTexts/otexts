# otexts

Shared R setup for the [OTexts](https://otexts.com) books written with Quarto,
such as *Forecasting: Principles and Practice* and *That's Weird!*. It is the
R companion to the [otexts Quarto format](https://github.com/OTexts/quarto-otexts),
which sets the books' HTML styling and figure sizes.

## Installation

```r
# install.packages("pak")
pak::pak("OTexts/otexts")
```

## Usage

Each chapter of a book sources a setup script, `before-each-chapter.R`, which
calls `setup_book()`:

```r
library(otexts)
setup_book()
```

This

* registers a "BookMath" font family for maths in plot labels;
* sets printing options, and the Okabe-Ito and viridis palettes as ggplot2's
  default colour scales;
* sets the ggplot2 theme, so plot text is in the book's font;
* prefers `dplyr::select()` and `dplyr::filter()` when **conflicted** is
  installed;
* defines `TeX()` as `tex()` and `theme_void()` as `theme_book_void()`, so the
  code shown in the book runs unchanged for readers, using
  `latex2exp::TeX()` and `ggplot2::theme_void()`.

`tex()` sets the maths in plot labels in the same fonts that KaTeX uses for
maths in the text:

```r
library(ggplot2)
ggplot(mtcars, aes(wt, mpg)) +
  geom_point() +
  labs(x = TeX("Weight ($w$)"), y = TeX("$\\hat{y}_i$"))
```

After each render, `post_render()` tidies the HTML with the otexts Quarto
format's `htmlreplace.pl` and compresses the figures with
[pngquant](https://pngquant.org), which must be installed. A book runs it from
`post-render.R`, set with `project: post-render` in `_quarto.yml`:

```r
otexts::post_render()
```

Other helpers: `cache()` saves long computations in `rds/`, and `html_math()`
marks up maths in raw HTML for KaTeX.

A translation in a script that Fira Sans doesn't cover can use another
installed font for plot text, e.g. `setup_book(text_font = "Noto Sans CJK SC")`.

## Fonts

Plot text is in [Fira Sans](https://fonts.google.com/specimen/Fira+Sans), which
must be installed. The fonts in `inst/fonts/` are copies of KaTeX's maths fonts
(MIT licence), scaled up by 1.2 to match Fira Sans by
`data-raw/make_plot_fonts.py`.
