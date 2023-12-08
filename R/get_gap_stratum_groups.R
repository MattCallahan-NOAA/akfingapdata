#' get_gap_stratum_groups
#' @description This function pulls the akfin_stratum_groups table from the AKFIN database using a web service.

get_gap_stratum_groups<-function() {

  url <- "https://apex.psmfc.org/akfin/data_marts/gap_products/gap_stratum_groups?"
  httr::content(
    httr::GET(url=url,
              add_headers(Authorization = token)),
    type = "application/json") %>%
    # convert to data frame
    dplyr::bind_rows() %>%
    dplyr::rename_with(tolower)
}

