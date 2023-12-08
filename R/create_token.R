#' create_token
#' @description This function creates a token necessary for web service authentication
#' token<- create_token("Callahan_token.txt)

create_token<-function(file) {
  # Secret string text file needs to be in your working R directory
  secret <- jsonlite::base64_enc( readChar(file,nchars=1e6) )

  # Get token from API
  req <- httr::POST("https://apex.psmfc.org/akfin/data_marts/oauth/token",
                    httr::add_headers(
                      "Authorization" = paste("Basic", gsub("\n", "", secret)),
                      "Content-Type" = "application/x-www-form-urlencoded;charset=UTF-8"
                    ),
                    body = "grant_type=client_credentials");

  #  Create authentication error message
  httr::stop_for_status(req, "Something broke.")
  paste("Bearer", httr::content(req)$access_token)

}
