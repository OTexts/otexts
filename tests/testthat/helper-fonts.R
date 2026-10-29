skip_if_no_fira_sans <- function() {
  skip_if_not(
    "Fira Sans" %in% systemfonts::system_fonts()$family,
    "Fira Sans is not installed"
  )
}

# Forget the FONTCONFIG_FILE that register_book_fonts() found first
local_fontconfig_reset <- function(env = parent.frame()) {
  old <- fontconfig$base
  fontconfig$base <- NULL
  withr::defer(fontconfig$base <- old, envir = env)
}
