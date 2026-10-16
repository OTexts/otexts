# otexts 0.1.0

* First version, with the setup shared by the OTexts books: `setup_book()`,
  `register_book_fonts()`, `set_book_options()`, `set_book_theme()`,
  `book_colours()`, `theme_book_void()`, `tex()`, `cache()` and `html_math()`.

* `post_render()` tidies a book's rendered HTML with the otexts Quarto format's
  `htmlreplace.pl`, and compresses its figures with pngquant.
