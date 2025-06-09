#' get_gap_catch
#' @description This is a test function that downloads the catch table by species, survey, and year

#' @param survey_definition_id character that designates regional survey. EBS-98, NBS-143, EBS slope-78, GOA-47, AI-52. Default is 47.
#' @param species_code RACE species code for which biomass is calculated.
#' @param start_year first year in the time series, default 1990.
#' @param end_year last year in the time series, default to latest year,

get_gap_catch<-function(survey_definition_id=98,  species_code=21740, start_year=1990, end_year=3000) {
  start_time <- Sys.time()

  if(!exists("token")) {
    message("Please create a valid Oauth token, e.g. token <- create_token('your_token.txt')")
  }

  url <- "https://apex.psmfc.org/akfin/data_marts/gap_products/gap_catch?"

  query <- list(survey_definition_id=survey_definition_id, species_code=species_code, start_year=start_year, end_year=end_year)

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
    if(missing(start_year)) {
      message("No start_year provided, defaulting to 1990")
    }
    if(missing(end_year)) {
      message("No end_year provided, defaulting to latest year")
    }

  end_time <- Sys.time()
  message(paste("Time Elapsed:", round(end_time - start_time, 2),
                units(end_time - start_time)))
  return(data)

}

