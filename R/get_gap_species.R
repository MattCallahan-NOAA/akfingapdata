#' get_gap_species
#'
#' @description This function pulls the akfin_taxonomics_worms table from the AKFIN database using a web service.
#' worms refers to World register of marine species, not actual worms like polychaetes and nemotodes, though they are in here too.


get_gap_species<-function() {
  url <- "https://apex.psmfc.org/akfin/data_marts/akmp/gap_taxonomics?"
  httr::content(
    httr::GET(url=url),
    type = "application/json") %>%
    # convert to data frame
    dplyr::bind_rows() %>%
    dplyr::rename_with(tolower)
}
