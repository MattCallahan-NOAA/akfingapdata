#' get_gap_metadata_column
#' @description This function pulls the akfin_metadata_column table from the AKFIN database using a web service.

get_gap_metadata_column<-function() {

  url <- "https://apex.psmfc.org/akfin/data_marts/gap_products/gap_metadata_column?"
  httr::content(
    httr::GET(url=url,
              add_headers(Authorization = token)),
    type = "application/json") %>%
    # convert to data frame
    dplyr::bind_rows() %>%
    dplyr::rename_with(tolower)
}
