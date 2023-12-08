#' get_gap_haul
#' @description This function pulls the akfin_area table from the AKFIN database using a web service.

get_gap_haul<-function() {

  url <- "https://apex.psmfc.org/akfin/data_marts/gap_products/gap_haul?"
  httr::content(
    httr::GET(url=url,
              add_headers(Authorization = token)),
    type = "application/json") %>%
    # convert to data frame
    dplyr::bind_rows() %>%
    dplyr::rename_with(tolower)
}


