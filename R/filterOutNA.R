#' Filter out Empty Rows
#' @description Filter out rows where both the Regimen and Component are NA. A flag is raised if IDs are filtered out and the missing values are saved to a flag object.
#' @import dplyr
#' @export

filterOutNA <-
        function(.input) {

                .output <-
                .input %>%
                        dplyr::filter_at(vars(!ID),
                                         all_vars(!is.na(.)))

                input_id <- unique(.input$ID)
                output_id <- unique(.output$ID)

                qa <- input_id[!(input_id %in% output_id)]

                if (length(qa)) {

                        flagFilterOutNA <<- .input[!(.input$ID %in% .output$ID),]
                        message(length(qa), " IDs were filtered out. See flagFilterOutNA.")

                }

                return(.output)

        }
