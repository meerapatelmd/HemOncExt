#' Ingest New Concept
#' @description
#' An observation in the new concept relationship dataframe is not appended to the HemOnc Concept table if the same concept_name, is found. Such cases are returned as `qaIngestConceptTable` and `qaIngestConceptTable2` is the result of a followup qa where any of the rows in the input are not found in the refreshed Concept Table.
#' @import purrr
#' @import rubix
#' @import pg13
#' @import dplyr
#' @export


ingestConceptTable <-
        function(.input,
                 conn) {

                qaIngestConceptTable <- list()

                while (nrow(.input) > 0) {
                        new_concept <-
                                .input %>%
                                rubix::filter_first_row()

                        qa <-
                                pg13::query(conn = conn,
                                            pg13::buildQuery(schema = "hemonc_extension",
                                                             tableName = "concept",
                                                             whereInField = "concept_name",
                                                             whereInVector = new_concept$concept_name))

                        if (nrow(qa)) {

                                qaIngestConceptTable[[1+length(qaIngestConceptTable)]] <- list(Input = new_concept,
                                                                                         Existing = qa)

                                names(qaIngestConceptTable)[length(qaIngestConceptTable)] <- new_concept$concept_name


                        } else {

                                pg13::appendTable(conn = conn,
                                                  schema = "hemonc_extension",
                                                  tableName = "concept",
                                                  .data = new_concept %>%
                                                          chariot::ids_to_integer() %>%
                                                          as.data.frame())

                        }

                        .input <-
                                .input %>%
                                rubix::filter_first_row(invert = TRUE)

                }

                if (length(qaIngestConceptTable)) {

                        warning(length(qaIngestConceptTable), " duplicates found. See qaIngestConceptTable.")
                        qaIngestConceptTable <<- qaIngestConceptTable

                }

                qa <-
                        .input$concept_name %>%
                        rubix::map_names_set(function(x) pg13::query(conn = conn,
                                                                     pg13::buildQuery(schema = "hemonc_extension",
                                                                                      tableName = "concept",
                                                                                      whereInField = "concept_name",
                                                                                      whereInVector = x))) %>%
                        purrr::keep(~nrow(.)==0)

                if (length(qa)) {
                        qaIngestConceptTable2 <<- qa
                        warning(length(qa), " concepts where not found in hemonc_extension.concept. See qaIngestConceptTable2")

                }

        }
