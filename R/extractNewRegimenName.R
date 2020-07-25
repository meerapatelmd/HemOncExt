#' Extract the New Regimen Name from Regimen Column
#' @description This function extracts the content following the "NEW " prefix in the Regimen column, with the ultimate destination set to be the concept_name column in the HemOnc Extension Concept table.
#' @import tidyr
#' @import dplyr
#' @export


extractNewRegimenName <-
        function(.input) {

                if (nrow(.input) == 0) {
                        stop("input is empty")
                }

                .output <-
                        .input %>%
                        tidyr::extract(col = Regimen,
                                       into = c("regimen_concept_id", "regimen_concept_name"),
                                       regex = "(^.*?) (.*$)",
                                       remove = FALSE)

                qa <- .output %>%
                                dplyr::filter(regimen_concept_id != "NEW")
                if (nrow(qa)) {
                        qaExtractRegimen <<- qa
                        stop(nrow(qa), " Regimen column extracted to regimen_concept_id != 'NEW'. See qaExtractRegimen.")
                }

                return(.output %>%
                               dplyr::select(-regimen_concept_id))

        }
