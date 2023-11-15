#' get_gap_area
#'
#' @description This function pulls the akfin_area table from the AKFIN database using a web service.

get_gap_area<-function() {
  url <- "https://apex.psmfc.org/akfin/data_marts/akmp/gap_area?"
  httr::content(
    httr::GET(url=url),
    type = "application/json") %>%
    # convert to data frame
    dplyr::bind_rows() %>%
    dplyr::rename_with(tolower)
}




