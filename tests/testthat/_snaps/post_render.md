# post_render() errors without the otexts format

    Code
      post_render(html, pngquant = FALSE, dir = dir)
    Condition
      Error in `post_render()`:
      ! Can't find htmlreplace.pl from the otexts Quarto format.
      i Install the format with `quarto add OTexts/quarto-otexts`.

# post_render() errors if htmlreplace.pl fails

    Code
      post_render(html, pngquant = FALSE, dir = dir)
    Condition
      Error in `post_render()`:
      ! htmlreplace.pl failed with status 3.

# post_render() errors if pngquant isn't installed

    Code
      post_render(character())
    Condition
      Error in `post_render()`:
      ! pngquant is not installed.
      i It compresses the figures. Install it, or use `pngquant = FALSE`.

