#' get_gap_split_fractions
#' @description This function pulls the akfin_split_fractions table from the AKFIN database using a web service.

get_gap_split_fractions<-function() {

  url <- "https://apex.psmfc.org/akfin/data_marts/gap_products/gap_split_fractions?"
  httr::content(
    httr::GET(url=url,
              add_headers(Authorization = token)),
    type = "application/json") %>%
    # convert to data frame
    dplyr::bind_rows() %>%
    dplyr::rename_with(tolower)
}




