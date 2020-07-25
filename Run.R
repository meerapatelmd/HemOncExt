# input <- broca::read_full_excel("~/Memorial Sloan Kettering Cancer Center/Esophagogastric REDCap Standardization - KMI Only - KMI Only/2020-08-07/Esophagus Treatment Mappings v7.xlsx")
# input <- input$Final_02
# id_col_name <- "Row Number"
# regimen_col_name <- "Regimen"
# component_col_name <- "Component"
# ingredient_col_name <- NULL
#
# input2 <-
# HemOncExt::configureInput(.input = input,
#                id_col_name = id_col_name,
#                regimen_col_name = regimen_col_name,
#                component_col_name = component_col_name,
#                ingredient_col_name = ingredient_col_name)
#
# input3 <-
#         input2 %>%
#         HemOncExt::separateRowsInput()
#
# input4 <-
#         input3 %>%
#         HemOncExt::filterOutNA()
#
# # Checkpoint: if that particular checkpoint is passed, the function returns the argument unchanged, otherwise a respective QA object is created in the Global Environment summarizing the error
# # Does each observation have exactly 1 Regimen based on unique length?
# staged <-
#         input4 %>%
#         HemOncExt::checkCardinality() %>%
#         HemOncExt::checkFormat() %>%
#         checkIngredientCol()
#
#
# # Filtering for any NEW values in the non-ID Fields and adding a new concept id in place of NEW in the label. The NEW demarcation is offloaded onto `New R` and `New C` columns
# output <-
#         staged %>%
#         HemOncExt::filterAnyNewConcept() %>%
#         HemOncExt::addConceptIds(conn = conn)
#
# # Add all NEW concepts to the concept table
# new_concept_table <-
#         convertConceptTable(output)
#
# ingestConceptTable(new_concept_table,
#                    conn = conn)
#
#
# new_concept_relationship_table <-
#         convertRelationshipTable(output)
#
# ingestRelationshipTable(new_concept_relationship_table,
#                         conn = conn)
#
#
# # For New Drug/Components, looking for synonyms from CancerGov
# cancergov <-
#         new_concept_table %>%
#         dplyr::filter(concept_class_id == "Component") %>%
#         dplyr::select(concept_name) %>%
#         unlist() %>%
#         rubix::map_names_set(function(x) chariot::query_athena(pg13::buildQueryString(schema = "cancergov",
#                                                                 tableName = "concept",
#                                                                 whereLikeField = "concept_name",
#                                                                 string = x,
#                                                                 split = " |[[:punct:]]")))
#
#
#
#
# chariot::dc_athena(conn = conn)
