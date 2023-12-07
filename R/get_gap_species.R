#' get_gap_species
#'
#' @description This function pulls the akfin_taxonomics_worms table from the AKFIN database using a web service.
#' worms refers to World register of marine species, not actual worms like polychaetes and nemotodes, though they are in here too.


get_gap_species<-function() {
  # Secret string text file needs to be in your working R directory
  secret <- jsonlite::base64_enc( readChar("Callahan_token.txt",nchars=1e6) )

  # Get token from API
  req <- httr::POST("https://apex.psmfc.org/akfin/data_marts/oauth/token",
                    httr::add_headers(
                      "Authorization" = paste("Basic", gsub("\n", "", secret)),
                      "Content-Type" = "application/x-www-form-urlencoded;charset=UTF-8"
                    ),
                    body = "grant_type=client_credentials"
  );

  #  Create authentication error message
  httr::stop_for_status(req, "Something broke.")
  token <- paste("Bearer", httr::content(req)$access_token)

  url <- "https://apex.psmfc.org/akfin/data_marts/akmp/gap_taxonomics?"
  httr::content(
    httr::GET(url=url,
              add_headers(Authorization = token)),
    type = "application/json") %>%
    # convert to data frame
    dplyr::bind_rows() %>%
    dplyr::rename_with(tolower)
}
