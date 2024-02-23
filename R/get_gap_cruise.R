#' get_gap_cruise
#' @description This function pulls data from the akfin_cruise table in the gap_products schema on the AKFIN database.


get_gap_cruise<-function() {
  start_time <- Sys.time()

  if(!exists("token")) {
    message("Please create a valid Oauth token, e.g. token <- create_token('your_token.txt')")
  }

  url <- "https://apex.psmfc.org/akfin/data_marts/gap_products/gap_cruise?"

  response <- httr::GET(url=url,
                        httr::add_headers(Authorization = token))

  if(httr::http_error(response) ) {
    stop(paste0("status code ",
                response$status_code,
                ". For a 401 error you may need to supply a valid Oauth token, e.g. token <- create_token('your_token.txt')"))
  }

  data <- jsonlite::fromJSON(
    httr::content(response, type = "text", encoding = "UTF-8")) |>
    dplyr::bind_rows()

  end_time <- Sys.time()
  message(paste("Time Elapsed:", round(end_time - start_time, 2),
                units(end_time - start_time)))
  return(data)

}



