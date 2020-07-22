#' DDL Standardized Vocabulary Tables
#' @description The ddl will only execute on the condition that there are 0 tables current in the `hemonc_extension` schema.
#' @import pg13
#' @import SqlRender
#' @export


ddlHemOncExtSchema <-
        function(conn) {

                hemOncExtTables <-
                pg13::lsTables(conn = conn,
                               schema = "hemonc_extension")

                if (length(hemOncExtTables) == 0) {

                        base <- system.file(package = "hemOncExt")
                        path <- paste0(base, "/sql/postgresqlddl.sql")

                        sql_statement <- SqlRender::render(SqlRender::readSql(path),
                                                schema = "hemonc_extension")
                        pg13::send(conn = conn,
                                   sql_statement = sql_statement)

                }
        }
