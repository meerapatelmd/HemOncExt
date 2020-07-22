#' Constrain Standardized Vocabulary Tables
#' @description The Standardized Vocabulary section in the Postgres OMOP CDM Scripts.
#' @import pg13
#' @import SqlRender
#' @export


constrainHemOncExtSchema <-
        function(conn) {

                        base <- system.file(package = "hemOncExt")
                        path <- paste0(base, "/sql/constraints.sql")

                        sql_statement <- SqlRender::render(SqlRender::readSql(path),
                                                schema = "hemonc_extension")
                        pg13::send(conn = conn,
                                   sql_statement = sql_statement)

        }
