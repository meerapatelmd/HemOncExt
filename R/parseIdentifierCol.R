#' Parse a Column of Identifiers
#' @import dplyr
#' @import stringr
#' @import lubridate
#' @export

parseIdentifierCol <-
        function(.data,
                 identifier_col) {

                identifier_col <- enquo(identifier_col)

                .data %>%
                        dplyr::mutate_at(vars(!!identifier_col),
                                         ~stringr::str_pad(., width = 10, side = "left", pad = "0")
                                         ) %>%
                        dplyr::mutate_at(vars(!!identifier_col),
                                         ~lubridate::ymd_hms(.))
        }

