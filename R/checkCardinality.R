#' Check Regimen Cardinality of 1:1
#' @description Does each observation have exactly 1 Regimen based on unique length?
#' @import dplyr
#' @export

checkCardinality <-
        function(.input) {

                # Stop if empty from a previous checkpoint
                if (nrow(.input)) {
                        stop('input is empty')
                }

                qa <-
                .input %>%
                        dplyr::group_by(ID) %>%
                        dplyr::summarize(regimen_count = length(unique(Regimen)), .groups = "drop") %>%
                        dplyr::filter(regimen_count != 1)

                if (nrow(qa)) {

                        qaCheckCardinality <<- .input[(.input$ID %in% qa$ID),]

                        stop('IDs not mapped to exactly 1 Regimen. See qaCheckCardinality.')


                }

                return(.input)

        }
