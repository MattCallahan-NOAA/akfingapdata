#' get_gap_catch
#' @description This is a test function that downloads the entire catch table

get_gap_catch<-function() {
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
  # paste(... collapse=",") puts commas between vector elements

  url <- "https://apex.psmfc.org/akfin/data_marts/gap_products/gap_catch"
  httr::content(
    httr::GET(url=url,
              add_headers(Authorization = token)),
    type = "application/json") %>%
    # convert to data frame
    dplyr::bind_rows() %>%
    dplyr::rename_with(tolower)
}

# 4.4 minutes
# Start<-Sys.time()
# test<-get_gap_catch()
# End<-Sys.time()
# End-Start
#

