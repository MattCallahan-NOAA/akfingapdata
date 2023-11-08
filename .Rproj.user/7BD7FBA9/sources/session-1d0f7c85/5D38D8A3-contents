# get_gap_species
#
# This is an example function named 'hello'
# which prints 'Hello, world!'.
#
# You can learn more about package authoring with RStudio at:
#
#   http://r-pkgs.had.co.nz/
#
# Some useful keyboard shortcuts for package authoring:
#
#   Install Package:           'Ctrl + Shift + B'
#   Check Package:             'Ctrl + Shift + E'
#   Test Package:              'Ctrl + Shift + T'

get_gap_species<-function() {
  url <- "https://apex.psmfc.org/akfin/data_marts/akmp/gap_taxonomics?"
  httr::content(
    httr::GET(url=url),
    type = "application/json") %>%
    # convert to data frame
    dplyr::bind_rows() %>%
    dplyr::rename_with(tolower)
}
