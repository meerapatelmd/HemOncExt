#' Ingest New Concept Relationship
#' @description
#' An observation in the new concept relationship dataframe is not appended to the HemOnc Concept Relationship table if the same concept_id_1, concept_id_2, and relationship_id combination is found. Such cases are returned as `qaIngestRelationshipTable` and `qaIngestionRelationshipTable2` is the result of a followup qa where any of the rows in the input are not found in the refreshed Concept Relationship table.
#' @import purrr
#' @import rubix
#' @import pg13
#' @import dplyr
#' @export

ingestRelationshipTable <-
        function(.input,
                 conn) {

                qaIngestRelationshipTable <- list()

                while (nrow(.input) > 0) {
                        new_concept <-
                                .input %>%
                                rubix::filter_first_row()

                        qa <-
                                pg13::query(conn = conn,
                                            pg13::buildQuery(schema = "hemonc_extension",
                                                             tableName = "concept_relationship",
                                                             whereInField = "concept_id_1",
                                                             whereInVector = new_concept$concept_id_1,
                                                             caseInsensitive = FALSE)) %>%
                                dplyr::filter(concept_id_2 == new_concept$concept_id_2) %>%
                                dplyr::filter(relationship_id == new_concept$relationship_id)

                        if (nrow(qa)) {

                                qaIngestRelationshipTable[[1+length(qaIngestRelationshipTable)]] <- list(Input = new_concept,
                                                                                         Existing = qa)

                                names(qaIngestRelationshipTable)[length(qaIngestRelationshipTable)] <- new_concept$concept_name


                        } else {

                                pg13::appendTable(conn = conn,
                                                  schema = "hemonc_extension",
                                                  tableName = "concept_relationship",
                                                  .data = new_concept %>%
                                                          chariot::ids_to_integer() %>%
                                                          as.data.frame())

                        }

                        .input <-
                                .input %>%
                                rubix::filter_first_row(invert = TRUE)

                }

                if (length(qaIngestRelationshipTable)) {

                        warning(length(qaIngestRelationshipTable), " duplicates found. See qaIngestRelationshipTable.")
                        qaIngestRelationshipTable <<- qaIngestRelationshipTable

                }

                qa <-
                        .input$concept_id_1 %>%
                        purrr::map2(.input$concept_id_2,
                                    function(x, y) pg13::query(conn = conn,
                                                                     pg13::buildQuery(schema = "hemonc_extension",
                                                                                      tableName = "concept_relationship",
                                                                                      whereInField = "concept_id_1",
                                                                                      whereInVector = x)) %>%
                                                     dplyr::filter(concept_id_2 == y)) %>%
                        purrr::keep(~nrow(.)==0)

                if (length(qa)) {
                        qaIngestRelationshipTable2 <<- qa
                        warning(length(qa), " concepts where not found in hemonc_extension.concept_relationship. See qaIngestRelationshipTable2")

                }

        }
