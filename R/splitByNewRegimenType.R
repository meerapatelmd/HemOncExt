#' Split New Regimen by Type
#' @description All New Components would also require creating a New Regimen concept. For example a new Component Drug X would require creating a new Regimen Drug X monotherapy. Therefore, all new concepts submitted for processing can be classified at the New Regimen Level and as 1 of 2 of the following types:
#'     a) New Regimen only where all the components are present in HemOnc, but the combination of those Components into a Regimen is missing.
#'     b) New Regimen with at least 1 new Component
#'This function splits the input up based on whether there is a presence of a new Component in the Regimen makeup. A flag is thrown if the output is of length 1 while any other lengths other than 2 results in a brake.
#'@return List of length 1 or 2 based on type of new Regimen.
#'@import dplyr
#'@import rubix
#'@export

splitByNewRegimenType <-
        function(.input) {

                if (nrow(.input) == 0) {
                        stop("input is empty")
                }

                .output <-
                        .input %>%
                        dplyr::group_by(ID) %>%
                        dplyr::mutate(has_new_Component = any(grepl("NEW ", Component))) %>%
                        dplyr::ungroup() %>%
                        dplyr::mutate_at(vars(has_new_Component), ~ifelse(. == TRUE, "NewRegimenAndComponent", "NewRegimenOnly")) %>%
                        dplyr::mutate_at(vars(has_new_Component), as.character) %>%
                        rubix::split_deselect(has_new_Component)

                qa <- length(.output)

                if (qa == 1) {
                        flagSplitByNewRegimenType <<- .output
                        warning('output is of length 1. Only 1 new Regimen type may be present. See flagSplitByNewRegimenType.')
                } else if (qa > 2) {
                        qaSplitByNewRegimenType <<- .output
                        stop('output is of length greater than 2. Only 2 possible new Regimen types. See qaSplitByNewRegimenType.')
                } else if (qa != 2) {
                        qaSplitByNewRegimenType <<- .output
                        stop('output is null length. Only 2 possible new Regimen types. See qaSplitByNewRegimenType.')
                }

                return(.output)

        }
