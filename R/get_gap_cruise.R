#' get_gap_cruise
#' @description This function pulls data from the akfin_agecomp table in the gap_products schema on the AKFIN database.
#' This table is a copy of the biomass table produced by the groundfish assessment program (GAP)
#' These data are docuented here: https://github.com/afsc-gap-products/gap_products
#' get_gap_species() and get_gap_area() are related functions to look up species codes and area ids if necessary.

#' @param survey_definition_id character that designates regional survey. EBS-98, NBS-143, EBS slope-78, GOA-47, AI-52. Default is 47.
#' @param startyear first year in the time series, default 1990.
#' @param endyear last year in the time series, default to latest year,

get_gap_cruise<-function(survey_definition_id=98, start_year=1990, end_year=3000) {

  # paste(... collapse=",") puts commas between vector elements
  survey_definition_id<-paste(survey_definition_id, collapse = ",")
  query <- list(survey_definition_id=survey_definition_id, start_year=start_year, end_year=end_year)
  url <- "https://apex.psmfc.org/akfin/data_marts/gap_products/gap_cruise?"

  httr::content(
    httr::GET(url=url, #query=query,
              add_headers(Authorization = token)),
    type = "application/json") %>%
    # convert to data frame
    dplyr::bind_rows() %>%
    dplyr::rename_with(tolower)
}

