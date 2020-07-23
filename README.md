# HemOnc Extension (HemOncExt R Package) 
## Overview  
The HemOncExt, short for HemOnc Extension is an R Package that supports creating new Oncology treatment concepts in the OMOP CDM Vocabulary architecture. This is achieved by creating a separate set of OMOP Vocabulary tables in a `hemonc_extension` schema in the same Postgres database storing the main OMOP vocabularies. Initial setup also involves migrating a copy of all of the HemOnc concepts and the Ingredient/Precise Ingredient subset of the RxNorm/RxNorm Extension concepts from the main OMOP Vocabularies into this new schema to serve as building blocks for any new Regimens and Components that will be created.  

When a Regimen and/or a Component is not represented in the HemOnc proper, the new concept is populated into the hemonc_extension.concept table with the following: 
    1. A temporary Concept Id
    2. Concept Name following strict conventions
    3. `Drug` domain for new Components and the `Regimen` domain for new Regimens  
    4. `HemOnc Extension` as the Vocabulary Id
    5. `Component` concept class for new Component and `Regimen` concept class for new Regimen
    6. `Non-Standard` concept type
    7. Concept Code of 0  
    8. Valid Start Date as System Date  
    9. Valid End Date as 2099-12-31
    10. No Invalid Reason  
    

When the End User ingests new Regimen and their associated Component concepts into HemOncExt, the new concepts are assigned a temporary unique Concept Id along with all the necessary CONCEPT table fields. The appropriate relationship and inverse relationships within HemOnc and amongst HemOnc and RxNorm are recycled from those in the OMOP Vocabulary to ensure a seamless integration of these locally created concepts with the the main OMOP Vocabulary.

## Requirements  
1. Postgres database with a schema loaded with the OMOP Vocabulary tables  

## Installation  
```
library(devtools)  
devtools::install_github("patelm9/HemOncExt")
```
## Initial Setup
1. `createHemOncExtSchema()`: Create a HemOnc Extension (`hemonc_extension`) schema in a database
2. `ddlHemOncExtSchema()`: Instantiate OMOP Vocabulary Tables in the newly made `hemonc_extension` schema
3. Migrate HemOnc Concepts and RxNorm/RxNorm Extension Ingredients/Precise Ingredients to the `hemonc_extension` schema to create new relationships:  
```
                hemOncExt::migrateConcept(conn = conn, source_schema = "public")
                hemOncExt::migrateConceptAncestor(conn = conn, source_schema = "public")  
                hemOncExt::migrateConceptRelationship(conn = conn, source_schema = "public")  
                hemOncExt::migrateConceptSynonym(conn = conn, source_schema = "public")  
```
4. Recommended Maintenance: every time an update is done to the Athena HemOnc or RxNorm vocabulary, the `hemonc_extension` schema should be dropped and the above functions rerun on the newest instance of the vocabulary.  
  
## Notes on Concept Id Assignment to a New Concept  
Each new concept first and foremost needs a unique identifier to which all synonyms or duplicative representations can be normalized to. The in-house concept_id is generated using the `getIdentifier function`, and is a string of 10 characters that can be parsed to a timestamp in the format "YYYYmmddHHMMSS", with the "202" in the year 2020 removed, resuling in "Ymmddhhmmss". When converted to integer in the year 2020, timestamps from single digit months (Jan to September) will result in the loss of 2 leading zeros and 1 leading zero in all other cases. The best approach would be to make a single identifier as an anchor and subtracting by 1 incrementally for each new Concept. This identifier will be unique with the one caveat that identifier assignment may not occur at overlapping times. This is advantagous over adding incrementally because it could technically cause collisions should we have 10000 NEW concepts and the concept_ids may overlap with those that are made for another project immediately thereafter. 
  
### Steps  
#### Requirements: 
Source dataframe should have a unique identifier at the row level that represents an instance of a HemOnc Regimen along with its Hemonc Components. dataframe with a single unique identifier, NEW Regimen, any NEW Component, and Ingredient (RxNorm) column representing the Regimen-Component-Ingredient Axis in the HemOnc ontology. The contents will be in Label format "{concept_id|NEW} {concept_name}".  
1. Quality Rules: 1 Regimen per row, At least 1 Component per Regimen, Each Component has exactly 1 RxNorm Ingredient or RxNorm Precise Ingredient.  


4, Enumerate all NEW concepts with this batch into a single dataframe
5. Populate NEW Concepts by concept_class_id
1. Tables to downloadable data package
