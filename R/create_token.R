#' create_token
#' @description This function creates a token necessary for web service authentication
#' The output must be defined as token for the other functions to work
#' Define your authentication string or copy into the function
#' x<-"12345..:abcd.."
#' token <- create_token(x)
#' Otherwise, this function accepts keyring and text file input
#' token<- create_token("akfin_secret") # keyring service storing secret string
#' token<- create_token("Callahan_token.txt") # text file storing your secret string

create_token<-function(x) {

  # Check if x exists in the global environment
  if (is.character(x)) {
    secret <- jsonlite::base64_enc(x)

  #check key_list for input
  } else if (x %in% keyring::key_list()$service) {
    secret <- jsonlite::base64_enc( keyring::key_get(x))
  }
# If not found, assume it's a file and load it.
  else {
    secret <- jsonlite::base64_enc(readChar(x,nchars=1e6) )
  }

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

