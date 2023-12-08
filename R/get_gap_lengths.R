#' get_gap_lengths
#' @description Doesn't work...
#' This function pulls data from the akfin_agecomp table in the gap_products schema on the AKFIN database.
#' This table is a copy of the biomass table produced by the groundfish assessment program (GAP)
#' These data are docuented here: https://github.com/afsc-gap-products/gap_products
#' get_gap_species() and get_gap_area() are related functions to look up species codes and area ids if necessary.

#' @param species RACE species code for which biomass is calculated.


get_gap_lengths<-function(species_code=21740) {

  # paste(... collapse=",") puts commas between vector elements
  species_code <- paste(species_code, collapse = ",")
  query <- list(species_code=species_code)
  url <- "https://apex.psmfc.org/akfin/data_marts/gap_products/gap_lengths?"

  httr::content(
    httr::GET(url=url, #query=query,
              add_headers(Authorization = token)),
    type = "application/json") %>%
    # convert to data frame
    dplyr::bind_rows() %>%
    dplyr::rename_with(tolower)
}


# Start<-Sys.time()
# test<- httr::content(
#   httr::GET(url="https://apex.psmfc.org/akfin/data_marts/gap_products/gap_lengths?species_code=21470",
#             add_headers(Authorization = token)),
#   type = "application/json") %>%
#   # convert to data frame
#   dplyr::bind_rows() %>%
#   dplyr::rename_with(tolower)
# End<-Sys.time()
# End-Start
#

