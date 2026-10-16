skip_if_no_fira_sans <- function() {
  skip_if_not(
    "Fira Sans" %in% systemfonts::system_fonts()$family,
    "Fira Sans is not installed"
  )
}
