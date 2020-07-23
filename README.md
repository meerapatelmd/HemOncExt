# HemOnc Extension (HemOncExt R Package) 
## Overview  
The HemOncExt, short for HemOnc Extension is an R Package that supports creating new Oncology treatment concepts that follows the conventions of the OMOP CDM Vocabulary architecture. This is achieved by creating a separate set of OMOP Vocabulary tables in a `hemonc_extension` schema in the same Postgres database storing the main OMOP vocabularies. Initial setup involves migrating a copy of all of the HemOnc concepts and the Ingredient/Precise Ingredient subset of the RxNorm/RxNorm Extension concepts from the main OMOP Vocabularies into this new schema to serve as building blocks for any new Regimens and Components that will be created. 

## Benefits  
The output of this process is a HemOnc Extension vocabulary that can seamlessly integrate with the main OMOP Vocabulary while remaining siloed in a separate schema as it awaits further vetting by key stakeholders involved in the HemOnc proper ontology and Athena/OMOP Vocabulary lifecycle.  
The same functions in R packages that support standardization processes such as the Chariot R Package (https://patelm9.github.io/chariot/) can be used on these tables by setting the `schema` argument to `hemonc_extension`.  
With the exception of HemOnc Extension Components such as investigational drugs that do not map to an Ingredient, all HemOnc Extension concepts can be reused once loaded into this schema, allowing all ongoing mappings to be normalized to a temporary Concept Id while it awaits the vetting process.  

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

## Set Parameters  
When a Regimen and/or a Component is not represented in the HemOnc proper, the new concept is populated into the CONCEPT table in the hemonc_extension schema with the following: 
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
    
Once the new concept, called a new HemOnc Extension concept from this point onwards, is introduced into the HemOnc Extension CONCEPT table, the concept relationships in the Regimen-Component-Ingredient axis of the HemOnc proper ontology are introduced into the CONCEPT_RELATIONSHIP table in the hemonc_extension schema in accordance to the following scenarios:  
a) New HemOnc Extension Regimen: can be composed of entirely HemOnc proper Components or have at least one new HemOnc Extension Component
    1. `Has antineoplastic` relationship between HemOnc Extension Regimen and each Component 
    1. `Antineoplastic of` relationship between each Component and HemOnc Extension Regimen  
    1. Valid Start Date as current date  
    1. Valid End Date as 2099-12-31  
    1. No Invalid Reason  
b) New HemOnc Extension Component  
    1. `Has antineoplastic` relationship between HemOnc Extension Regimen and HemOnc Extension Component 
    1. `Antineoplastic of` relationship between the HemOnc Extension Component and HemOnc Extension Regimen  
    1. _If a corresponding RxNorm/RxNorm Ingredient/Precise Ingedient is present in the OMOP Vocabulary proper_, `Maps to` relationship between the HemOnc Extension Component and the RxNorm/RxNorm Extension Ingredient/Precise Ingredient  
    1. Valid Start Date as current date
    1. Valid End Date as 2099-12-31  
    1. No Invalid Reason  
  
## Notes on Concept Id Assignment to a New Concept  
Each new concept first and foremost needs a unique identifier to which all synonyms or duplicative representations can be normalized to. The in-house concept_id is generated using the `getIdentifier function`, and is a string of 10 characters that can be parsed to a timestamp in the format "YYYYmmddHHMMSS", with the "202" in the year 2020 removed, resuling in "Ymmddhhmmss". When converted to integer in the year 2020, timestamps from single digit months (Jan to September) will result in the loss of 2 leading zeros and 1 leading zero in all other cases. The best approach would be to make a single identifier as an anchor and subtracting by 1 incrementally for each new Concept. This identifier will be unique with the one caveat that identifier assignment may not occur at overlapping times. This is advantagous over adding incrementally because it could technically cause collisions should we have 10000 NEW concepts and the concept_ids may overlap with those that are made for another project immediately thereafter. 
  
### Steps  
#### Requirements: 
Source dataframe should have a unique identifier at the row level that represents an instance of a HemOnc Regimen along with its Hemonc Components. dataframe with a single unique identifier, NEW Regimen, any NEW Component, and Ingredient (RxNorm) column representing the Regimen-Component-Ingredient Axis in the HemOnc ontology. The contents will be in Label format "{concept_id|NEW} {concept_name}".  
1. Quality Rules: 1 Regimen per row, At least 1 Component per Regimen, Each Component has exactly 1 RxNorm Ingredient or RxNorm Precise Ingredient.  


4, Enumerate all NEW concepts with this batch into a single dataframe
5. Populate NEW Concepts by concept_class_id
1. Tables to downloadable data package
