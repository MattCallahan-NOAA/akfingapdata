#' get_gap_cpue
#' @description This is a test function that downloads the cpue table by species

#' @param species RACE species code for which biomass is calculated.

get_gap_cpue<-function(species_code) {

  url <- "https://apex.psmfc.org/akfin/data_marts/gap_products/gap_cpue?"

  species_code <- paste(species_code, collapse = ",")
  query <- list(species_code=species_code)

  httr::content(
    httr::GET(url=url, query,
              add_headers(Authorization = token)),
    type = "application/json") %>%
    # convert to data frame
    dplyr::bind_rows() %>%
    dplyr::rename_with(tolower)

}



