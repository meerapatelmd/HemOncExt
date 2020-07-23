## code to prepare `extension-data` dataset goes here
library(devtools)
devtools::install_github("patelm9/broca", force = TRUE)
library(broca)
concept <- broca::simply_read_csv("data-raw/concept.csv", log = FALSE)
concept_relationship <- broca::simply_read_csv("data-raw/concept_relationship.csv", log = FALSE)
concept_synonym <- broca::simply_read_csv("data-raw/concept_synonym.csv", log = FALSE)

usethis::use_data(concept, concept_relationship, concept_synonym, overwrite = T)
