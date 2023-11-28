#' get_gap_catch
#' @description This is a test function that downloads the entire catch table

get_gap_catch<-function() {
  # paste(... collapse=",") puts commas between vector elements

  url <- "https://apex.psmfc.org/akfin/data_marts/akmp/gap_catch"
  httr::content(
    httr::GET(url=url),
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

