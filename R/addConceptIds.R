#' Replace the "NEW" in the label with a Concept Id
#' @import tidyr
#' @import rubix
#' @import dplyr
#' @import chariot
#' @import pg13
#' @import tidyr
#' @export

addConceptIds <-
        function(.input,
                 subtract = TRUE,
                 conn) {

                if (nrow(.input) == 0) {
                        stop("input is empty")
                }

                .output_a <-
                        .input %>%
                        tidyr::pivot_longer(cols = !ID,
                                            names_to = "Variable",
                                            values_to = "Value") %>%
                                chariot::parseLabel(Value)

                .output_b <-
                        .output_a %>%
                        dplyr::filter(concept_id == "NEW") %>%
                        dplyr::select(concept_id,
                                      concept_name) %>%
                        dplyr::distinct() %>%
                        dplyr::mutate(NEW = "X")

                startingid <- make_identifier()
                if (subtract) {

                        new_ids <-
                                startingid-(1:nrow(.output_b))

                } else {

                        new_ids <-
                                startingid+(1:nrow(.output_b))

                }


                qa <-
                pg13::query(conn = conn,
                            pg13::buildQuery(distinct = TRUE,
                                             schema = "hemonc_extension",
                                             tableName = "concept",
                                             whereInField = "concept_id",
                                             whereInVector = new_ids,
                                             caseInsensitive = FALSE)
                            )

                if (nrow(qa)) {

                        qaCreateConceptIds <<- qa
                        stop('New Concept Ids are already present in HemOnc Extension CONCEPT table. See qaCreateConceptIds.')


                }

                .output <-
                .output_a %>%
                        dplyr::left_join(.output_b %>%
                                                dplyr::mutate(new_concept_id = paste0("X", new_ids))) %>%
                        dplyr::distinct() %>%
                        dplyr::mutate(concept_id = coalesce(new_concept_id, concept_id))

                qa <- .output %>%
                        dplyr::filter(is.na(concept_id))

                if (nrow(qa)) {

                        flagCreateConceptIds <<- qa
                        warning(nrow(qa), " rows have NA concept_id. See flagCreateConceptIds.")

                }


                .output <-
                        .output %>%
                        tidyr::unite(col = NewValue,
                                     concept_id,
                                     concept_name,
                                     sep = " ") %>%
                        dplyr::mutate_at(vars(NewValue), ~na_if(.,"NA NA")) %>%
                        dplyr::select(ID,
                                      NEW,
                                      Variable,
                                      Value = NewValue) %>%
                        tidyr::pivot_wider(id_cols = ID,
                                           names_from = Variable,
                                           values_from = Value,
                                           values_fn = list(Value = function(x) paste(x, collapse = "\n"))) %>%
                        tidyr::separate_rows(Component, Ingredient, sep = "\n") %>%
                        tidyr::extract(col = Regimen,
                                       into = c("New R", "New Regimen"),
                                       regex = "(X)(.*$)",
                                       remove = FALSE) %>%
                        dplyr::mutate(Regimen = coalesce(`New Regimen`, Regimen)) %>%
                        dplyr::select(-`New Regimen`) %>%
                        tidyr::extract(col = Component,
                                       into = c("New C", "New Component"),
                                       regex = "(X)(.*$)",
                                       remove = FALSE) %>%
                        dplyr::mutate(Component = coalesce(`New Component`, Component)) %>%
                        dplyr::select(-`New Component`)

        }
