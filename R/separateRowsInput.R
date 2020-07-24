#' Separate Input Rows
#' @description
#' This function takes the input data and:
#'     1. Removes all carriage return symbols
#'     2. Separates all non-identifier rows based on a new line symbol
#'     3. Trims the whitespace on the resulting parsed rows, particularly important for cases when there are multiple new lines separating 2 Components, resulting in a blank Component entry
#'     4. Normalizes all blanks, "NA", and NA to NA_character_
#'     5. Filters for rows where both Regimen and Components are non-NA the non-NA Regimen and Components
#'@import dplyr
#'@import tidyr
#'@import rubix
#'@export

separateRowsInput <-
        function(.input) {
                # Separating all columns except Identifier for carriage returns
                .output <-
                        .input %>%
                        # Remove \r now so it does not create blank rows later
                        dplyr::mutate_at(vars(!ID), as.character) %>%
                        dplyr::mutate_at(vars(!ID), stringr::str_remove_all, "[\r]") %>%
                        tidyr::separate_rows(!ID,
                                             sep = "\n") %>%
                        #Remove \r relics from the separation
                        mutate_at(vars(!ID), trimws) %>%
                        #Normalize all Blanks, "NA", NA to NA_character_
                        dplyr::mutate_at(vars(!ID), function(x) na_if(x, "")) %>%
                        dplyr::mutate_at(vars(!ID), function(x) na_if(x, "NA"))

                input_id <- unique(.input$ID)
                output_id <- unique(.output$ID)

                qa1 <- input_id[!(input_id %in% output_id)]

                if (length(qa1)) {

                        qa2 <- .input[(.input$ID %in% qa1),]

                        # qa3 <- qa1[!(qa1 %in% qa2$ID)]
                        #
                        # if (nrow(qa2)) {

                                qaSeparateRowsInput <<- qa2
                                stop("IDs have been filtered out. See qaSeparateRowsInput object to view missing IDs")
                        #}
                }

                return(.output)
        }
