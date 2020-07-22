#' Migrate HemOnc and RxNorm Vocabularies
#' @description This function executes on the condition that there are zero rows in the concept table.
#' @import SqlRender
#' @import pg13
#' @param source_schema The schema where the main OMOP vocabularies are loaded.
#' @export

migrateConcept <-
        function(conn,
                 source_schema) {

                # Get distinct row counts for the 'hemonc_extension.concept' table
                extension_concept_nrow <-
                        pg13::query(conn = conn,
                                    sql_statement = pg13::renderRowCount(distinct = TRUE,
                                                                         schema = "hemonc_extension",
                                                                         tableName = "concept"))
                # Nrow is 0, it means that the HemOnc and RxNorm concepts have not been migrated and will be migrated now

                if (extension_concept_nrow == 0) {

                        base <- system.file(package = "hemOncExt")
                        path <- paste0(base, "/sql/migrateConcept.sql")

                        sql_statement <- SqlRender::render(SqlRender::readSql(path),
                                                           schema = source_schema)

                        source_concepts <-
                                pg13::query(conn = conn,
                                            sql_statement = sql_statement)

                        pg13::appendTable(conn = conn,
                                          schema = "hemonc_extension",
                                          tableName = "concept",
                                          .data = source_concepts)
                }

        }
