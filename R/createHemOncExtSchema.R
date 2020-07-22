#' Create the HemOnc Extension Schema
#' @import pg13
#' @param conn A Connection object.
#' @param drop If TRUE, will drop the `hemonc_extension` schema if it exists.
#' @export


createHemOncExtSchema <-
        function(conn,
                 drop = FALSE) {

                if (drop) {
                        pg13::send(conn = conn,
                                   sql_statement = pg13::renderDropSchema(schema = "hemonc_extension"))
                }

                pg13::send(conn = conn,
                            sql_statement = pg13::renderCreateSchema(schema = "hemonc_extension"))
        }
