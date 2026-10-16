# Restore the ggplot2 theme and geom defaults when the calling test ends
local_book_theme_reset <- function(env = parent.frame()) {
  old <- ggplot2::theme_get()
  withr::defer(
    {
      ggplot2::theme_set(old)
      ggplot2::update_geom_defaults("text", NULL)
      ggplot2::update_geom_defaults("label", NULL)
      if (rlang::is_installed("ggrepel")) {
        ggplot2::update_geom_defaults(ggrepel::GeomTextRepel, NULL)
        ggplot2::update_geom_defaults(ggrepel::GeomLabelRepel, NULL)
      }
      if (rlang::is_installed("ggraph")) {
        ggplot2::update_geom_defaults(ggraph::GeomEdgePath, NULL)
      }
    },
    envir = env
  )
}
