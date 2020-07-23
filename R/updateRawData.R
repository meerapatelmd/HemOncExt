#' Update HemOnc Extension Data in raw-data
#' @description This function overwrites the concept.csv, concept_relationship.csv, and concept_synonym.csv with what is currently in the database for open source distribution.
#' @keywords internal
#' @import glitter
#' @import pg13
#' @import broca
#' @import dplyr
#' @export

updateRawData <-
        function(conn) {
                schema <- "hemonc_extension"
                source_tables <- c("concept_relationship",
                                   "concept_synonym")
                sql_statement <-
                pg13::buildQuery(schema = schema,
                                 tableName = "concept",
                                 whereInField = "vocabulary_id",
                                 whereInVector = "HemOnc Extension")

                concept <-
                        pg13::query(conn = conn,
                                    sql_statement = sql_statement) %>%
                        dplyr::distinct()

                broca::simply_write_csv(concept,
                                        "data-raw/concept.csv")
                glitter::add_commit_all(commit_message = "update raw-data/concept.csv")


                sql_statement <-
                        pg13::buildQuery(schema = schema,
                                         tableName = "concept_relationship",
                                         whereInField = "concept_id_1",
                                         caseInsensitive = FALSE,
                                         whereInVector = concept$concept_id)

                cr1 <-
                        pg13::query(conn = conn,
                                    sql_statement = sql_statement) %>%
                        dplyr::distinct()

                sql_statement <-
                        pg13::buildQuery(schema = schema,
                                         tableName = "concept_relationship",
                                         whereInField = "concept_id_2",
                                         caseInsensitive = FALSE,
                                         whereInVector = concept$concept_id)

                cr2 <-
                        pg13::query(conn = conn,
                                    sql_statement = sql_statement) %>%
                        dplyr::distinct()

                cr <-
                        dplyr::bind_rows(cr1,
                                         cr2) %>%
                        dplyr::distinct()

                broca::simply_write_csv(cr,
                                        "data-raw/concept_relationship.csv")
                glitter::add_commit_all(commit_message = "update raw-data/concept_relationship.csv")


                sql_statement <-
                        pg13::buildQuery(schema = schema,
                                         tableName = "concept_synonym",
                                         whereInField = "concept_id",
                                         caseInsensitive = FALSE,
                                         whereInVector = concept$concept_id)

                synonyms <-
                        pg13::query(conn = conn,
                                    sql_statement = sql_statement) %>%
                        dplyr::distinct()

                broca::simply_write_csv(synonyms,
                                        "data-raw/concept_synonym.csv")
                glitter::add_commit_all(commit_message = "update raw-data/concept_synonym.csv")

        }
