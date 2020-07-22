#' Migrate HemOnc and RxNorm Vocabularies
#' @import SqlRender
#' @param source_schema The schema where the main OMOP vocabularies are loaded.



migrateConcept <-
        function(conn,
                 source_schema) {

                base <- system.file(package = "hemOncExt")
                path <- paste0(base, "/sql/migrateConcept.sql")

                SqlRender::render(SqlRender::readSql(path),
                                                   schema = source_schema)



        }
