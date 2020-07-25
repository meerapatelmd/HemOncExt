#' Convert the Processed New Concepts to a CONCEPT Table
#' @import tidyr
#' @import dplyr
#' @import chariot
#' @export

convertConceptTable <-
        function(.input) {

                .input %>%
                        tidyr::pivot_longer(cols = starts_with("New "),
                                            names_to = "Type",
                                            values_to = "New") %>%
                        dplyr::mutate(Type = ifelse(Type == "New R", "Regimen", "Component")) %>%
                        tidyr::pivot_longer(cols = c(Regimen, Component),
                                            names_to = "concept_class_id",
                                            values_to = "Concept") %>%
                        dplyr::filter(Type == concept_class_id,
                                      !is.na(New)) %>%
                        dplyr::select(Concept,
                                      concept_class_id) %>%
                        chariot::parseLabel(Concept, remove = TRUE) %>%
                        dplyr::mutate(domain_id = ifelse(concept_class_id == "Regimen", "Regimen", "Drug"),
                                      vocabulary_id = "HemOnc Extension",
                                      standard_concept = NA,
                                      concept_code = 0,
                                      valid_start_date = Sys.Date(),
                                      valid_end_date = as.Date("2099-12-31"),
                                      invalid_reason = NA) %>%
                        dplyr::select(concept_id,
                                      concept_name,
                                      domain_id,
                                      vocabulary_id,
                                      concept_class_id,
                                      standard_concept,
                                      concept_code,
                                      valid_start_date,
                                      valid_end_date) %>%
                        dplyr::distinct() %>%
                        chariot::ids_to_integer()

        }
