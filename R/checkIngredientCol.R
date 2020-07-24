#' Add Ingredient Column
#' @description This function adds an Ingredient column if it does not already exist and performs a QA check to make sure that all Component to Ingredient mappings are either non-existent or exactly 1.
#' @import dplyr
#' @import rubix
#' @import chariot
#' @import tidyr
#' @export

checkIngredientCol <-
        function(.input) {

                if (nrow(.input) == 0) {
                        stop("input is empty")
                }

                if (!("Ingredient" %in% colnames(.input))) {

                        .output_a <-
                                .input %>%
                                tidyr::extract(col = Component,
                                               into = c("component_id",
                                                        "component_name"),
                                               regex = "(^.*?) (.*$)",
                                               remove = FALSE) %>%
                                rubix::mutate_to_integer(component_id)

                        .output_b <-
                                .output_a %>%
                                chariot::pivot_concept2(column = "component_id",
                                                        names_from = "concept_class_id") %>%
                                dplyr::select(component_id = concept_id_1,
                                              contains("Ingredient"))


                        if ("Precise Ingredient" %in% colnames(.output_b)) {
                                .output_b <-
                                        .output_b %>%
                                        dplyr::mutate(Ingredient = coalesce(Ingredient, `Precise Ingredient`),
                                                      `Ingredient Count` = coalesce(`Ingredient Count`, `Precise Ingredient Count`)) %>%
                                        dplyr::select(-`Precise Ingredient`, -`Precise Ingredient Count`)
                        }

                        .output <-
                                .output_a %>%
                                dplyr::left_join(.output_b)


                        # Any component to ingredient mappings that are not exactly 1:1?
                        qa <-
                                .output %>%
                                dplyr::filter(`Ingredient Count` != 1)

                        if (nrow(qa)) {

                                qaCheckIngredientCol <<- qa

                                stop('Some Component to Ingredient mappings are not 1:1. See qaCheckIngredientCol object.')
                        }

                        #Convert the Ingredient Merge format into Label format
                        .output <-
                                .output %>%
                                dplyr::select(-`Ingredient Count`) %>%
                                chariot::stripToLabel(Ingredient,
                                                      into = Ingredient,
                                                      remove = TRUE) %>%
                                dplyr::select(ID,
                                              Regimen,
                                              Component,
                                              Ingredient)




                } else {
                        qa <-
                                .input %>%
                                dplyr::group_by(ID) %>%
                                dplyr::summarize(ingredient_length = length(Ingredient)) %>%
                                dplyr::filter(ingredient_length != 1)

                        if (nrow(qa)) {
                                qaCheckIngredientCol <<- qa
                                stop('Some Component to Ingredient mappings are not 1:1. See qaCheckIngredientCol object.')
                        }

                        return(.input)
                }


        }
