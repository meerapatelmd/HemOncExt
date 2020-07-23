#' Parse Datetime from a Local Identifier
#' @import stringr
#' @import lubridate
#' @export

parseIdentifier <-
        function(identifier) {

                paste0(format(Sys.Date(), "%Y"),
                        stringr::str_pad(identifier,
                                         width = 10,
                                         side = "left",
                                         pad = "0")) %>%
                        lubridate::ymd_hms(quiet = TRUE)

        }
