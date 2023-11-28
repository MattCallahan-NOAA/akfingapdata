#' get_gap_biomass
#' @description This function pulls data from the akfin_biomass table in the gap_products schema on the AKFIN database.
#' This table is a copy of the biomass table produced by the groundfish assessment program (GAP)
#' These data are docuented here: https://github.com/afsc-gap-products/gap_products
#' get_gap_species() and get_gap_area() are related functions to look up species codes and area ids if necessary.

#' @param survey_definition_id character that designates regional survey. EBS-98, NBS-143, EBS slope-78, GOA-47, AI-52. Default is 47.
#' @param area_id This is the level at which biomass is calculated. Biomass may not be comparable accross areas.
#' @param species RACE species code for which biomass is calculated.
#' @param startyear first year in the time series, default 1990.
#' @param endyear last year in the time series, default to latest year,

get_gap_biomass<-function(survey_definition_id=98, area_id=1, species_code=21740, start_year=1990, end_year=3000) {
  # paste(... collapse=",") puts commas between vector elements
  area_id <- paste(area_id, collapse = ",")
  species_code <- paste(species_code, collapse = ",")
  survey_definition_id<-paste(survey_definition_id, collapse = ",")
  query <- list(survey_definition_id<-survey_definition_id, area_id=area_id, species_code=species_code, start_year=start_year, end_year=end_year)
  url <- "https://apex.psmfc.org/akfin/data_marts/akmp/gap_biomass?"

  httr::content(
    httr::GET(url=url, query=query),
    type = "application/json") %>%
    # convert to data frame
    dplyr::bind_rows() %>%
  dplyr::rename_with(tolower)
}




