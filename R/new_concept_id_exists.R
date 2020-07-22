#' Does this concept_id already exist?
#' @description For new concepts to be added to the extension, make sure that it already does not exist in the 'hemonc_extension.concept' table before assigning it to a new concept.
#' @import pg13
#' @param new_concept_id integer of length 1.
#' @export

new_concept_id_exists <-
        function(conn,
                 new_concept_id) {


                sql_statement <-
                pg13::buildQuery(schema = "hemonc_extension",
                                 tableName = "concept",
                                 whereInField = "concept_id",
                                 whereInVector = new_concept_id,
                                 n = 1,
                                 n_type = "limit")

                resultset <-
                pg13::query(conn = conn,
                            sql_statement = sql_statement)

                if (nrow(resultset) == 1) {
                        TRUE
                } else {
                        FALSE
                }
        }
