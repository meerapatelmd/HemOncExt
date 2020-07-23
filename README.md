# HemOnc Extension (HemOncExt R Package) 
## Overview  
The HemOncExt, short for HemOnc Extension is an R Package serves 2 purposes:  
1. Data:  
Access to the latest release of new Regimen and Component concepts following the conventions of the HemOnc ontology in the same format as the OMOP CDM Vocabulary CONCEPT, CONCEPT_RELATIONSHIP, and CONCEPT_SYNONYM tables for distribution as dataframes.  
1. Implementation:  
Create new Oncology treatment concepts that follows the conventions of the OMOP CDM Vocabulary architecture. This is achieved by creating a separate set of OMOP Vocabulary tables in a `hemonc_extension` schema in the same Postgres database storing the main OMOP vocabularies. Initial setup involves migrating a copy of all of the HemOnc concepts and the Ingredient/Precise Ingredient subset of the RxNorm/RxNorm Extension concepts from the main OMOP Vocabularies into this new schema to serve as building blocks for any new Regimens and Components that will be created.  

## Installation  
```
library(devtools)  
devtools::install_github("patelm9/HemOncExt")
library(HemOncExt)
```  

## Data  
The latest release of the bundled HemOnc Extension CONCEPT, CONCEPT_RELATIONSHIP, and CONCEPT_SYNONYM tables can be accessed by `HemOncExt::concept`, `HemOncExt::concept_relationship`, `HemOncExt::concept_synonym`. Release history can be viewed in the Changelog.  

## HemOnc Implementation  
## Benefits  
* The output of this process is a HemOnc Extension vocabulary that can seamlessly integrate with the main OMOP Vocabulary while remaining siloed in a separate schema as it awaits further vetting by key stakeholders involved in the HemOnc proper ontology and Athena/OMOP Vocabulary lifecycle.  
* The same functions in R packages that support standardization processes such as the Chariot R Package (https://patelm9.github.io/chariot/) can be used on these tables by setting the `schema` argument to `hemonc_extension`.  
* With the exception of HemOnc Extension Components such as investigational drugs that do not map to an Ingredient, all HemOnc Extension concepts can be reused once loaded into this schema, allowing all ongoing mappings to be normalized to a temporary Concept Id while it awaits the vetting process.  

## Requirements  
1. Postgres database with a schema loaded with the OMOP Vocabulary tables  

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
### Maintenance  
Every time an update is made to HemOnc or RxNorm/RxNorm Extension main OMOP vocabulary, the `hemonc_extension` schema should be dropped and the above functions rerun on the newest instance of the vocabulary.  

## Details  
### Parameters  
When a Regimen and/or a Component is not represented in the HemOnc proper, the new concept is populated into the CONCEPT table in the hemonc_extension schema with the following parameters:  

1. A temporary Concept Id  
1. Concept Name following strict conventions  
1. `Drug` domain for new Components and the `Regimen` domain for new Regimens  
1. `HemOnc Extension` as the Vocabulary Id  
1. `Component` concept class for new Component and `Regimen` concept class for new Regimen  
1. `Non-Standard` concept type  
1. Concept Code of 0  
1. Valid Start Date as System Date  
1. Valid End Date as 2099-12-31  
1. No Invalid Reason  
   
Once the new concept, called a new HemOnc Extension concept from this point onwards, is introduced into the HemOnc Extension CONCEPT table, the concept relationships in the Regimen-Component-Ingredient axis of the HemOnc proper ontology are introduced into the CONCEPT_RELATIONSHIP table in the hemonc_extension schema in accordance to the following scenarios:  
A. New HemOnc Extension Regimen: can be composed of entirely HemOnc proper Components or have at least one new HemOnc Extension Component  
1. `Has antineoplastic` relationship between HemOnc Extension Regimen and each Component  
1. `Antineoplastic of` relationship between each Component and HemOnc Extension Regimen  
1. Valid Start Date as current date  
1. Valid End Date as 2099-12-31   
1. No Invalid Reason  

B. New HemOnc Extension Component  
1. `Has antineoplastic` relationship between HemOnc Extension Regimen and HemOnc Extension Component  
1. `Antineoplastic of` relationship between the HemOnc Extension Component and HemOnc Extension Regimen  
1. _If a corresponding RxNorm/RxNorm Ingredient/Precise Ingedient is present in the OMOP Vocabulary proper_, `Maps to` relationship between the HemOnc Extension Component and the RxNorm/RxNorm Extension Ingredient/Precise Ingredient  
1. Valid Start Date as current date 
1. Valid End Date as 2099-12-31  
1. `Has antineoplastic` relationship between HemOnc Extension Regimen and HemOnc Extension Component  
1. No Invalid Reason  
  
### Notes on Temporary Concept Id Assignment    
Prior to being loaded into the HemOnc Extension CONCEPT table, every new concept requires a unique identifier, a temporary Concept Id, to which all synonyms or duplicative representations can be normalized to. The temporary Concept Id is generated using the `getIdentifier()` function found in this package, which takes all the digits in the timestamp returned by the base `Sys.time()` as a string, removes the starting digits "202" from the year value "2020", and converts the string to an integer. Therefore, a the native base timestamp that returns as "YYYY-mm-dd HH:MM:SS" is converted to a character string in the format of "YYYYmmddHHMMSS", truncated to "Ymmddhhmmss" by removing "202", and converted to the integer class to match the DDL of all concept_ids in the OMOP CDM proper.  

## Why?  
This was a quick fix to the identifier generation issue I was faced with when figuring out how to manage the new concepts. I always defer to timestamps since a timestamp conceptually represents a unique value that has never occurred before. However, simply using all the digits in a timestamp as "YYYYmmddHHMMSS" and converting it to an integer to align with the OMOP CDM proper DDL of all Concept Ids is not straightforward because "YYYYmmddHHMMSS" represents a value too large for base R to process. Packages such as the gmp R package, allows for the integer representation of "YYYYmmddHHMMSS", but involves assigning a separate data class `bigz` that does not align with the integer data type in the OMOP CDM. Therefore, for the 2020-2029 time period, I began truncating the string version of a timestamp by removing the starting "202" digits of the year "2020", still rendering a unique identifier as long as all the identifiers generated in this project will be made in this decade.  

## Approach and Major Caveats  
The best approach to use generate an identifier as described is to process new concepts into the HemOnc Extension schema in batches. For each batch, the `getIdentifier()` function is called once, returning a single integer value that serves as an anchor point from which a vector of new identifiers can be made by adding or subtracting the integer vector of 1 to the number of new concepts in that batch. Subtracting the vector is preferred over adding because the assumption made in this operation is that each of these identifiers occurred at a moment of time in the past or the future. For example if 5000 unique identifiers were made at midnight on January 01, 2020 and a second batch of 5000 additional unique identifiers are made 30 at 1:00 am, the integers generated in the 2 batches may not be unique.  

## Minor Caveats  
For the year 2020 and as well as any case of a single digit month regardless of year, leading zeros are removed once the string is converted to an integer. For example, an original timestamp of 2020-07-23 13:41:31 EDT, rendered as a string "20200723134131", truncated to "00723134131", and when converted to an integer, the leading zeros are lost and the final value returned is 723134106. Though this is still a unique identifier in these circumstances, it is important to note that under some conditions, the leading zeros may need to padded back, such as would be the case if one were interested in ever parsing the timestamp from the identifier (thought this may not always work since time and integer are 2 completely different representations).  

## SECTIONS IN DEVELOPMENT
### Steps 
#### Input Requirements: 
Source dataframe should have a unique identifier at the row level that represents an instance of a new Regimen along with its new and HemOnc proper Components, with the values represented in a Label format "{concept_id|NEW} {concept_name}".  
The following data quality rules on the source dataframe and failure to meet these benchmarks will return an error and further processing will stop.  
    1. 1 Regimen per row. 
    2. At least 1 Component per Regimen  
    3. Each Component has exactly 1 or less RxNorm Ingredient or RxNorm Precise Ingredient.  
    4. Values in Label format "{concept_id|NEW} {concept_name}"
