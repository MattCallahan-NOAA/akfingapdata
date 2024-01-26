#' gap_taxonomic_classification
#' @description This function pulls the akfin_taxonomics_classification table from the AKFIN database using a web service.



get_gap_taxonomic_classification<-function() {
  url <- "https://apex.psmfc.org/akfin/data_marts/gap_products/gap_taxonomic_classification?"
  httr::content(
    httr::GET(url=url,
              add_headers(Authorization = token)),
    type = "application/json") %>%
    # convert to data frame
    dplyr::bind_rows() %>%
    dplyr::rename_with(tolower)
}
