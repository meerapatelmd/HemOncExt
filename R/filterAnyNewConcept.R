#' Filter New Concepts
#' @description This function filters for any row that contains at least 1 instance of a "NEW " string
#' @import rubix
#' @export

filterAnyNewConcept <-
        function(.input) {

                if (nrow(.input) == 0) {

                        stop("input is empty")

                }

                .input %>%
                        rubix::filter_all_grepl_any(grepl_phrase = "NEW ")
        }
