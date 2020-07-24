#' Check Format of Data Contents
#' @description Do all non-ID columns have contents in Label format?
#' @import rubix
#' @export

checkFormat <-
        function(.input) {
                # Stop if empty from a previous checkpoint
                if (nrow(.input)) {
                        stop('input is empty')
                }


                qa <-
                        .input %>%
                        rubix::filter_at_grepl_any(!ID,
                                                   grepl_phrase = "[0-9]{1,} .*$|NEW .*$",
                                                   evaluates_to = FALSE)

                if (nrow(qa)) {

                        qaCheckFormat <<- qa
                        stop("Some non-ID columns not in Label format. See qaCheckFormat object.")

                }

                return(.input)
        }
