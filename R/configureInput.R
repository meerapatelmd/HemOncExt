#' Configure Input
#' @import dplyr
#' @param .input Input dataframe of new concepts
#' @param regimen_col_name Name of the input column that contains the new Regimen mapping
#' @param component_col_name Name of the input column that contains the new Component mapping
#' @param ingredient_col_name Optional argument that provides the Name of the input column that contains the Ingredient mapping. Defaults to NULL if it is not provided.
#' @return input dataframe with the columns renamed to standardized column names
#' @description This function configures the input to normalized column names of "ID", "Regimen", "Component", and if an Ingredient column is present, "Ingredient" for pointers to the correct input dataframe columns. 2 QA checkpoints stop the function: 1. That the identifier column in the input contains values that are unique to the number of rows in the input and 2. The the output contains all the identifiers that were in the input.
#' @export

configureInput <-
        function(.input,
                id_col_name = "identifier",
                regimen_col_name = "CurrentRegimen",
                component_col_name = "CurrentComponent",
                ingredient_col_name = NULL) {

                input_id <-
                        .input %>%
                        dplyr::select(!!id_col_name) %>%
                        unlist() %>%
                        unique()

                if (length(input_id) != nrow(.input)) {

                        stop("column '", id_col_name, "' is not an unique identifer per row.")
                }


                if (is.null(ingredient_col_name)) {

                        .output <-
                                .input %>%
                                dplyr::select(ID = !!id_col_name,
                                              Regimen = !!regimen_col_name,
                                              Component = !!component_col_name)
                } else {

                        .output <-
                                .input %>%
                                dplyr::select(ID = !!id_col_name,
                                              Regimen = !!regimen_col_name,
                                              Component = !!component_col_name,
                                              Ingredient = !!ingredient_col_name)
                }


                output_id <- unique(.output$ID)
                qa <- input_id[!(input_id %in% output_id)]
                if (length(qa)) {
                        qa2_configureInput <<- qa

                        stop("Unique values in input column '",  id_col_name, "' not found in output. See qa2_configureInput object for list of missing values.")

                }

                return(.output)


        }

