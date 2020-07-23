#' Configure Input
#' @import dplyr
#' @return input dataframe with the columns renamed to standardized column names
#' @description This function creates the settings for pointers to the correct input dataframe columns.
#' @export

configureInput <-
        function(.input,
                id_col_name = "identifier",
                regimen_col_name = "CurrentRegimen",
                component_col_name = "CurrentComponent",
                ingredient_col_name = NULL) {

                if (is.null(ingredient_col_name)) {


                                .input %>%
                                dplyr::select(ID = !!id_col_name,
                                              Regimen = !!regimen_col_name,
                                              Component = !!component_col_name)
                } else {

                                .input %>%
                                dplyr::select(ID = !!id_col_name,
                                              Regimen = !!regimen_col_name,
                                              Component = !!component_col_name,
                                              Ingredient = !!ingredient_col_name)
                }
        }

