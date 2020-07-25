#' Convert the Processed New Concepts to a Concept Relationship Table
#' @import tidyr
#' @import rubix
#' @import purrr
#' @import dplyr
#' @import chariot
#' @export

convertRelationshipTable <-
        function(.input) {


                # Regimen to Component Relationship
                final_relationship_i <-
                        .input %>%
                        chariot::parseLabel(Regimen, remove = TRUE) %>%
                        rubix::rename_at_prefix(concept_id, concept_name, prefix = "regimen_") %>%
                        chariot::parseLabel(Component, remove = TRUE) %>%
                        rubix::rename_at_prefix(concept_id, concept_name, prefix = "component_") %>%
                        dplyr::transmute(concept_id_1 = regimen_concept_id,
                                         concept_id_2 = component_concept_id,
                                         relationship_id = "Has antineoplastic",
                                         valid_start_date = Sys.Date(),
                                         valid_end_date = as.Date("2099-12-31"),
                                         invalid_reason = NA)

                final_relationship_ii <-
                        .input %>%
                        chariot::parseLabel(Regimen, remove = TRUE) %>%
                        rubix::rename_at_prefix(concept_id, concept_name, prefix = "regimen_") %>%
                        chariot::parseLabel(Component, remove = TRUE) %>%
                        rubix::rename_at_prefix(concept_id, concept_name, prefix = "component_") %>%
                        dplyr::transmute(concept_id_1 = component_concept_id,
                                         concept_id_2 = regimen_concept_id,
                                         relationship_id = "Antineoplastic of",
                                         valid_start_date = Sys.Date(),
                                         valid_end_date = as.Date("2099-12-31"),
                                         invalid_reason = NA)

                .output <-
                        list(final_relationship_i,
                             final_relationship_ii) %>%
                        purrr::map(chariot::ids_to_integer) %>%
                        dplyr::bind_rows() %>%
                        dplyr::distinct()


                return(.output)
        }
