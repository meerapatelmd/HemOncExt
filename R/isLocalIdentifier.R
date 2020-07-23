#' Check if an Identifier was Locally Created
#' @description Returns TRUE if the identifier parses to a Datetime, FALSE if is NA, and the actual parsed output for all other data types.
#' @export

isLocalIdentifier <-
        function(identifier) {

                x <- parseIdentifier(identifier)
                if (is.na(x)) {
                        FALSE
                } else if ("POSIXt" %in% class(x)) {
                        TRUE
                } else {
                        return(x)
                }

        }
