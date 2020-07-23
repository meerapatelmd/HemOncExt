# input <- broca::read_full_excel("~/Memorial Sloan Kettering Cancer Center/Esophagogastric REDCap Standardization - KMI Only - KMI Only/Mapping Files/Esophagus Treatment Mappings v5.xlsx")
# input <- input$Final_02
# id_col_name <- "identifier"
# regimen_col_name <- "CurrentRegimen"
# component_col_name <- "CurrentComponent"
# ingredient_col_name <- NULL
#
# input2 <-
# configureInput(.input = input,
#                id_col_name = id_col_name,
#                regimen_col_name = regimen_col_name,
#                component_col_name = component_col_name,
#                ingredient_col_name = ingredient_col_name)
#

#
# # Separating all columns except Identifier for carriage returns
# input3 <-
#         input2 %>%
#         # Remove \r now so it does not create blank rows later
#         dplyr::mutate_at(vars(!ID), stringr::str_remove_all, "[\r]") %>%
#         tidyr::separate_rows(!ID,
#                              sep = "\n") %>%
#         #Remove \r relics from the separation
#         mutate_at(vars(!ID), trimws) %>%
#         #Normalize all Blanks, "NA", NA to NA_character_
#         rubix::normalize_all_to_na() %>%
#         #Remove empty Regimens
#         dplyr::filter(!is.na(Regimen), !is.na(Component))
#
# # QA1: After filtering out Regimen with NA values, have any Identifiers been filtered out, meaning that they have not been mapped?
# qa1 <- all(!(unique(input2$ID) %in% unique(input3$ID)))
# if (qa1) {
#         qa1 <- unique(input2$ID)[!(unique(input2$ID) %in% unique(input3$ID))]
#         stop("IDs have been filtered out. See qa1 object to view missing values")
# }
#
# # QA2: Stop if the Identifiers do not have exactly 1 Regimen based on unique length?
# qa2 <-
#         input3 %>%
#         group_by(ID) %>%
#         summarize(regimen_count = length(unique(Regimen)), .groups = "drop") %>%
#         dplyr::filter(regimen_count != 1)
#
# if (nrow(qa2)) {
#         stop("IDs not mapped to exactly 1 regimen. See qa2 object.")
# }
#
# #QA3: Do all non-ID columns have contents in Label format?
# qa3 <-
#         input3 %>%
#         rubix::filter_at_grepl_any(!ID,
#                                    grepl_phrase = "[0-9]{1,} .*$|NEW .*$",
#                                    evaluates_to = FALSE)
#
# if (nrow(qa3)) {
#
#         stop("Some non-ID columns not in Label format. See qa3 object.")
# }
#
# # If there isn't an Ingredient column in the source data, need to map the Component to the RxNorm/RxNorm Extension Ingredient
# if (is.null(ingredient_col_name)) {
#
#         # Parsing Label Format to isolate concept_id to join with Ancestor or Relationship Table
#         input4a <-
#                 input3 %>%
#                 tidyr::extract(col = Component,
#                                 into = c("component_id",
#                                          "component_name"),
#                                 regex = "(^.*?) (.*$)",
#                                 remove = FALSE) %>%
#                 rubix::mutate_to_integer(component_id)
#
#         input4b <-
#                 input4a %>%
#                 chariot::pivot_concept2(column = "component_id",
#                                         names_from = "concept_class_id") %>%
#                 dplyr::select(component_id = concept_id_1,
#                               contains("Ingredient"))
#
#         # If some components map to Precise Ingredient as part of the RxNorm Extension, coalesce it into the Ingredient fields and remove the Precise Ingredient Fields
#         if ("Precise Ingredient" %in% colnames(input4b)) {
#
#                 input4b <-
#                         input4b %>%
#                         dplyr::mutate(Ingredient = coalesce(Ingredient, `Precise Ingredient`),
#                                       `Ingredient Count` = coalesce(`Ingredient Count`, `Precise Ingredient Count`)) %>%
#                         dplyr::select(-`Precise Ingredient`, -`Precise Ingredient Count`)
#         }
#
#         input5 <-
#                 input4a %>%
#                 dplyr::left_join(input4b)
#
#         # QA4: Any component to ingredient mappings that are not exactly 1:1?
#         qa4 <-
#                 input5 %>%
#                 dplyr::filter(`Ingredient Count` != 1)
#
#         if (nrow(qa4)) {
#
#                 stop('Some Component to Ingredient mappings are not 1:1. See qa4 object.')
#         }
#
#         #Convert the Ingredient Merge format into Label format
#         input6 <-
#                 input5 %>%
#                 dplyr::select(-`Ingredient Count`) %>%
#                 chariot::mergeToLabel(Ingredient,
#                                       into = Ingredient,
#                                       remove = TRUE) %>%
#                 dplyr::select(ID,
#                               Regimen,
#                               Component,
#                               Ingredient)
#
# } else {
#         secretary::typewrite_note("This section still needs to be coded. If the Ingredient is already present in the input data, it needs to be 1) QA'd for exactly a 1:1 relationship and after passing returned into a `input6` object.")
# }
#
# # Filtering for any NEW values in the non-ID Fields
# output <-
#         input6 %>%
#         rubix::filter_all_grepl_any(grepl_phrase = "NEW ")
#
# # Possible Scenarios
# # A. NEW Regimen only: 1. Concept Table entry, 2. Concept Relationship: Has antineoplastic relationship_id to Component then do inverse relationship. 3. No Synonyms for NEW Regimens expected
# # B. NEW Regimen because there is at least 1 NEW Component
#         # Enumerate both Regimens and Components at once
#         # Add NEW Concepts to Concept Table,
#         # Concept Relationship:  Antineoplastic of Regimen, + inverse (all concepts including the non-new ones!)
#         # Add Component Synonyms to synonym table
#
# output2 <-
#         output %>%
#         group_by(ID) %>%
#         mutate(has_new_Component = any(grepl("NEW ", Component))) %>%
#         ungroup()
#
# # NEW Regimens Only
# output3a <-
#         output2 %>%
#         dplyr::filter(has_new_Component == FALSE) %>%
#         select(-has_new_Component) %>%
#         tidyr::extract(col = Regimen,
#                        into = c("regimen_concept_id", "regimen_concept_name"),
#                        regex = "(^.*?) (.*$)",
#                        remove = FALSE)
#
# ## Assigning NEW concept_ids by first making a starting identifier
# starting_identifier <- rubix::make_identifier()
#
# output3a_2 <-
#         output3a %>%
#         dplyr::select(-regimen_concept_id) %>%
#         dplyr::left_join(output3a %>%
#                                  dplyr::select(regimen_concept_name) %>%
#                                  dplyr::distinct() %>%
#                                  tibble::rowid_to_column("rownum") %>%
#                                  dplyr::mutate(regimen_concept_id = starting_identifier-rownum) %>%
#                                  dplyr::select(-rownum),
#                          by = c("regimen_concept_name"))
#
# # Refresh starting_identifier
# starting_identifier <- min(output3a_2$regimen_concept_id)-1
#
#
# # Output A: Adding New Regimens to the Concept Table by first populating the other fields
# output3a_3 <-
#         output3a_2 %>%
#         dplyr::mutate(concept_id = regimen_concept_id,
#                       concept_name = regimen_concept_name,
#                       domain_id = "Regimen",
#                       vocabulary_id = "HemOnc Extension",
#                       concept_class_id = "Regimen",
#                       standard_concept = NA,
#                       concept_code = 0,
#                       valid_start_date = Sys.Date(),
#                       valid_end_date = as.Date("2099-12-31"),
#                       invalid_reason = NA)
#
# final_concepts <-
#         output3a_3 %>%
#         dplyr::select(concept_id,
#                       concept_name,
#                       domain_id,
#                       vocabulary_id,
#                       concept_class_id,
#                       standard_concept,
#                       concept_code,
#                       valid_start_date,
#                       valid_end_date) %>%
#         dplyr::distinct()
#
# pg13::appendTable(conn = conn,
#                   schema = "hemonc_extension",
#                   tableName = "concept",
#                   .data = final_concepts %>%
#                                 as.data.frame())
#
# # Adding to concept_relationship table
# output3a_4 <-
# output3a_3 %>%
#         dplyr::select(-Regimen) %>%
#         chariot::merge_concepts(into = Regimen) %>%
#         dplyr::select(-concept_id) %>%
#         # Unmerge Component to get concept id
#         tidyr::extract(Component,
#                        into = c("component_concept_id",
#                                 "component_concept_name"),
#                        regex = "(^.*?) (.*$)")
#
# # Regimen to Component Relationship
# final_relationship_i <-
#         output3a_4 %>%
#         dplyr::transmute(concept_id_1 = regimen_concept_id,
#                          concept_id_2 = component_concept_id,
#                          relationship_id = "Has antineoplastic",
#                          valid_start_date = Sys.Date(),
#                          valid_end_date = as.Date("2099-12-31"),
#                          invalid_reason = NA)
#
# final_relationship_ii <-
#         output3a_4 %>%
#         dplyr::transmute(concept_id_1 = component_concept_id,
#                          concept_id_2 = regimen_concept_id,
#                          relationship_id = "Antineoplastic of",
#                          valid_start_date = Sys.Date(),
#                          valid_end_date = as.Date("2099-12-31"),
#                          invalid_reason = NA)
#
# final_relationship <-
#         list(final_relationship_i,
#                          final_relationship_ii) %>%
#         purrr::map(chariot::ids_to_integer) %>%
#         dplyr::bind_rows()
#
# pg13::appendTable(conn = conn,
#                   schema = "hemonc_extension",
#                   tableName = "concept_relationship",
#                   .data = final_relationship %>%
#                           as.data.frame())
#
#
# output3b <-
#         output2 %>%
#         dplyr::filter(has_new_Component != FALSE) %>%
#         select(-has_new_Component) %>%
#         tidyr::extract(col = Regimen,
#                        into = c("regimen_id", "regimen_name"),
#                        regex = "(^.*?) (.*$)",
#                        remove = FALSE)
#
#
# # Enumerate both Regimens and Components at once
# # Add NEW Concepts to Concept Table,
# # Concept Relationship:  Antineoplastic of Regimen, + inverse (all concepts including the non-new ones!)
# # Add Component Synonyms to synonym table
# starting_identifier <- rubix::make_identifier()
#
# # QA5: stop if the new starting identifier already exists in the extension
# qa5 <-
# conceptIdExists(conn = conn,
#                 starting_identifier)
#
# if (qa5) {
#         stop('concept_id already exists in hemonc_extension.concept')
# }
#
# # Pivot longer at Regimen and Component to filter for NEW of either class for concept_id assignment
# # Regimens first
# output3b_i <-
#         output3b %>%
#        dplyr::left_join(output3b %>%
#                                 dplyr::select(regimen_name) %>%
#                                 dplyr::distinct() %>%
#                                 rowid_to_column("rownum") %>%
#                                 dplyr::mutate(regimen_concept_id = starting_identifier+rownum) %>%
#                                 dplyr::select(-rownum))
#
#
# final_concepts <-
#         output3b_i %>%
#         dplyr::transmute(concept_id = regimen_concept_id,
#                       concept_name = regimen_name,
#                       domain_id = "Regimen",
#                       vocabulary_id = "HemOnc Extension",
#                       concept_class_id = "Regimen",
#                       standard_concept = NA,
#                       concept_code = 0,
#                       valid_start_date = Sys.Date(),
#                       valid_end_date = as.Date("2099-12-31"),
#                       invalid_reason = NA)
#
# # QA6: Making sure none of the concept_ids already exist
# qa6 <-
# final_concepts$concept_id %>%
#        rubix::map_names_set(function(x) conceptIdExists(conn = conn,
#                                                         new_concept_id = x)) %>%
#         purrr::keep(~.==TRUE)
#
# if (length(qa6)) {
#         qa6 <- names(qa6)
#         stop('concept_ids in data are already assigned to a concept in hemonc_extension.concept')
# }
#
# pg13::appendTable(conn = conn,
#                   schema = "hemonc_extension",
#                   tableName = "concept",
#                   .data = final_concepts %>%
#                           as.data.frame())
#
# # Refreshing original output3b with Regimen with new concept_ids and merge into a Regimen strip
# output3b2 <-
#         dplyr::left_join(output3b_i,
#                          final_concepts,
#                          by = c("regimen_concept_id" = "concept_id")) %>%
#         dplyr::distinct() %>%
#         dplyr::rename(concept_id = regimen_concept_id) %>%
#         dplyr::select(-regimen_id,
#                       -regimen_name,
#                       -Regimen) %>%
#         chariot::merge_concepts(into = "Regimen") %>%
#         dplyr::rename(regimen_concept_id = concept_id)
#
# # Parse Component in Label Format to assign concept_ids to new Components
# output3b3 <-
#         output3b2 %>%
#         tidyr::extract(Component,
#                        into = c("component_id",
#                                 "component_concept_name"),
#                        regex = "(^.*?) (.*$)",
#                        remove = TRUE)
#
# # Append a new_concept_id column for the new concepts
# # Refresh starting_identifier
# starting_identifier <- 1+final_concepts$concept_id %>% max()
# qa7 <- conceptIdExists(conn = conn,
#                        new_concept_id = starting_identifier)
#
# if (qa7) {
#
#         stop('starting_identifier already exists in hemonc_extension.concept table')
#
# }
#
# output3b4 <-
#         output3b3 %>%
#         dplyr::left_join(output3b3 %>%
#                                  dplyr::filter(component_id == "NEW") %>%
#                                  dplyr::select(component_concept_name) %>%
#                                  dplyr::distinct() %>%
#                                  rowid_to_column("rownum") %>%
#                                  dplyr::mutate(component_concept_id = paste0(rownum+starting_identifier)) %>%
#                                  dplyr::select(-rownum))
#
# final_concepts <-
#         output3b4 %>%
#         dplyr::filter(component_id == "NEW") %>%
#         dplyr::distinct() %>%
#         dplyr::transmute(concept_id = component_concept_id,
#                                       concept_name = component_concept_name,
#                                       domain_id = "Drug",
#                                       vocabulary_id = "HemOnc Extension",
#                                       concept_class_id = "Component",
#                                       standard_concept = NA,
#                                       concept_code = 0,
#                                       valid_start_date = Sys.Date(),
#                                       valid_end_date = as.Date("2099-12-31"),
#                                       invalid_reason = NA) %>%
#         dplyr::distinct()
#
# # QA8: do any of these concept_ids exist already?
# qa8 <-
#         final_concepts$concept_id %>%
#         rubix::map_names_set(function(x) conceptIdExists(conn = conn,
#                                                          new_concept_id = x)) %>%
#         purrr::keep(~.==TRUE)
#
# if (length(qa8)) {
#         qa8 <- names(qa8)
#         stop('concept_ids in data are already assigned to a concept in hemonc_extension.concept')
# }
#
# pg13::appendTable(conn = conn,
#                   schema = "hemonc_extension",
#                   tableName = "concept",
#                   .data = final_concepts %>%
#                           chariot::ids_to_integer() %>%
#                           as.data.frame())
#
# # Refreshing with the new concept ids
# output3b5 <-
#         dplyr::left_join(output3b4,
#                          final_concepts,
#                          by = c("component_concept_id" = "concept_id")) %>%
#         dplyr::mutate(component_concept_id = coalesce(component_concept_id,
#                                                       component_id))
#
# # Regimen to Component Relationship
# final_relationship_i <-
# output3b5 %>%
# dplyr::transmute(concept_id_1 = regimen_concept_id,
#                  concept_id_2 = component_concept_id,
#                  relationship_id = "Has antineoplastic",
#                  valid_start_date = Sys.Date(),
#                  valid_end_date = as.Date("2099-12-31"),
#                  invalid_reason = NA)
#
# final_relationship_ii <-
#         output3b5 %>%
#         dplyr::transmute(concept_id_1 = component_concept_id,
#                          concept_id_2 = regimen_concept_id,
#                          relationship_id = "Antineoplastic of",
#                          valid_start_date = Sys.Date(),
#                          valid_end_date = as.Date("2099-12-31"),
#                          invalid_reason = NA)
#
# final_relationship <-
#         list(final_relationship_i,
#              final_relationship_ii) %>%
#         purrr::map(chariot::ids_to_integer) %>%
#         dplyr::bind_rows()
#
# pg13::appendTable(conn = conn,
#                   schema = "hemonc_extension",
#                   tableName = "concept_relationship",
#                   .data = final_relationship %>%
#                           as.data.frame())
#
# # Unique to components - adding to component synonyms table
# output3b_synonyms <-
#         output3b5 %>%
#         dplyr::select(component_concept_id,
#                       concept_name) %>%
#         dplyr::filter(!is.na(concept_name)) %>%
#         dplyr::distinct()
#
# output3b_synonyms2a <-
#         output3b_synonyms$concept_name %>%
#         rubix::map_names_set(function(x) chariot::query_athena(pg13::buildQueryString(schema = "cancergov",
#                                                                 tableName = "concept",
#                                                                 whereLikeField = "concept_name",
#                                                                 string = x,
#                                                                 split = " |[[:punct:]]")))
#
#
# chariot::dc_athena(conn = conn)
