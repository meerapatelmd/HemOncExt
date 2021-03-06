#' Migrate HemOnc and RxNorm Vocabularies Synonyms
#' @description This function executes on the condition that there are zero rows in the concept_ancestor table in the hemonc_extension schema.
#' @import SqlRender
#' @import pg13
#' @import dplyr
#' @param source_schema The schema where the main OMOP vocabularies are loaded.
#' @export

migrateConceptSynonym <-
        function(conn,
                 source_schema) {

                tableName <- "concept_synonym"

                # Get distinct row counts for the 'hemonc_extension.concept' table
                extension_nrow <-
                        pg13::query(conn = conn,
                                    sql_statement = pg13::renderRowCount(distinct = TRUE,
                                                                         schema = "hemonc_extension",
                                                                         tableName = tableName))

                # Nrow is 0, it means that the HemOnc and RxNorm concepts have not been migrated and will be migrated now

                if (extension_nrow$count == 0) {

                        base <- system.file(package = "HemOncExt")
                        path <- paste0(base, "/sql/migrateConceptSynonym.sql")

                        sql_statement <- SqlRender::render(SqlRender::readSql(path),
                                                           schema = source_schema)

                        source <-
                                pg13::query(conn = conn,
                                            sql_statement = sql_statement)


                        pg13::appendTable(conn = conn,
                                          schema = "hemonc_extension",
                                          tableName = tableName,
                                          .data = source)
                }

        }
