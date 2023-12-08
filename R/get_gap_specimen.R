#' get_gap_specimens
#' @description This function pulls data from the akfin_specimen table in the gap_products schema on the AKFIN database.
#' This table is a copy of the specimen table produced by the groundfish assessment program (GAP)
#' These data are docuented here: https://github.com/afsc-gap-products/gap_products
#' get_gap_species() is a related functions to look up species codes and area ids if necessary.

#' @param species_code RACE species code .
#' @param region region specimens came from: BS, HWC, WC, HG, AI, GOA, HBS

get_gap_specimen<-function(species_code=21740, region="BS") {

  # paste(... collapse=",") puts commas between vector elements
  region<- paste(region, collapse = ",")
  species_code <- paste(species_code, collapse = ",")
  query <- list(species_code=species_code, region=region)
  url <- "https://apex.psmfc.org/akfin/data_marts/gap_products/gap_specimen?"

  httr::content(
    httr::GET(url=url, query=query,
              add_headers(Authorization = token)),
    type = "application/json") %>%
    # convert to data frame
    dplyr::bind_rows() %>%
    dplyr::rename_with(tolower)
}


Start<-Sys.time()
test<- get_gap_specimen()
End<-Sys.time()
End-Start

token<-create_token("Callahan_token.txt")
