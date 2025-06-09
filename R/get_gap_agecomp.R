#' get_gap_agecomp
#' get_gap_agecomp
#' @description This function pulls data from the akfin_agecomp table in the gap_products schema on the AKFIN database.
#' This table is a copy of the biomass table produced by the groundfish assessment program (GAP)
#' These data are docuented here: https://github.com/afsc-gap-products/gap_products
#' get_gap_taxonomic_classification() and get_gap_area() are related functions to look up species codes and area ids if necessary.

#' @param survey_definition_id character that designates regional survey. EBS-98, NBS-143, EBS slope-78, GOA-47, AI-52. Default is 47.
#' @param area_id This is the level at which biomass is calculated. Biomass may not be comparable accross areas.
#' @param species_code RACE species code for which biomass is calculated.
#' @param start_year first year in the time series, default 1990.
#' @param end_year last year in the time series, default to latest year,
#' @param area_id_footprint Eastern Bering Sea only. Optional parameter specifying whether to use the "EBS STANDARD PLUS NW" (Default) or "EBS STANDARD" area_id_footprint.

get_gap_agecomp<-function(survey_definition_id=98, area_id=99900, species_code=21740, start_year=1990, end_year=3000, area_id_footprint=NA) {
  start_time <- Sys.time()

  if(!exists("token")) {
    message("Please create a valid Oauth token, e.g. token <- create_token('your_token.txt')")
  }

  query <- list(survey_definition_id=survey_definition_id, area_id=area_id, species_code=species_code, start_year=start_year, end_year=end_year)
  url <- "https://apex.psmfc.org/akfin/data_marts/gap_products/gap_agecomp?"

  response <- httr::GET(url=url, query=query,
                        httr::add_headers(Authorization = token))

  if(httr::http_error(response) ) {
    stop(paste0("status code ",
                response$status_code,
                ". For a 401 error you may need to supply a valid Oauth token, e.g. token <- create_token('your_token.txt')"))
  }

  data <- jsonlite::fromJSON(
    httr::content(response, type = "text", encoding = "UTF-8")) |>
    dplyr::bind_rows()

  if(missing(survey_definition_id)) {
    message("No survey_definition_id provided, defaulting to 98 (Bering Sea)")
  }
  if(missing(species_code)) {
    message("No species_code provided, defaulting to 21740 (Pollock)")
  }
  if(missing(area_id)) {
    message("No area_id provided, defaulting to 99900 (EBS Standard Plus NW Region: All Strata)")
  }
  if(missing(start_year)) {
    message("No start_year provided, defaulting to 1990")
  }
  if(missing(end_year)) {
    message("No end_year provided, defaulting to latest year")
  }

  footprint_options <- c("EBS STANDARD PLUS NW", "EBS STANDARD")
  aif <- area_id_footprint

  if(survey_definition_id == 98 & aif %in% footprint_options) {
    data <- data |>
      filter(area_id_footprint == aif)
    message(paste0("Agecomps calculated using ", aif, " area_id_footprint"))
  }

  if(survey_definition_id == 98 & !(aif %in% footprint_options)) {
    data <- data |>
      filter(area_id_footprint == "EBS STANDARD PLUS NW")
    message(paste0("Defaulting to EBS STANDARD PLUS NW area_id_footprint"))
  }

  end_time <- Sys.time()
  message(paste("Time Elapsed:", round(end_time - start_time, 2),
                units(end_time - start_time)))
  return(data)

}


