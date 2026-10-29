# otexts 0.1.0

* First version, with the setup shared by the OTexts books: `setup_book()`,
  `register_book_fonts()`, `set_book_options()`, `set_book_theme()`,
  `book_colours()`, `theme_book_void()`, `tex()`, `cache()` and `html_math()`.

* Fira Sans is bundled, and `register_book_fonts()` registers it when it isn't
  installed, so plots no longer need Fira Sans on the system.

* `register_book_fonts()` also defines BookMath for fontconfig, in a file that
  `FONTCONFIG_FILE` points to, so cairo devices such as `cairo_pdf()` (used by
  the otexts PDF format) set plot text in the same fonts as ragg does, rather
  than falling back to the system's default font.

* `post_render()` tidies a book's rendered HTML with the otexts Quarto format's
  `htmlreplace.pl`, and compresses its figures with pngquant.
