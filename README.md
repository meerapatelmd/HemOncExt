# HemOnc Extension (HemOncExt Package)  
## Overview  
The HemOncExt, short for HemOnc Extension is an R Package that supports creating new Oncology treatment concepts in the OMOP CDM Vocabulary architecture. This is achieved by creating a separate set of OMOP Vocabulary tables in a `hemonc_extension` schema in the same database storing the vocabularies and migrating a copy of the HemOnc and RxNorm/RxNorm Extension Ingredient subset of the Athena Vocabularies to this new schema to form the building blocks for new HemOnc relationships. 

When the End User ingests new Regimen and their associated Component concepts into HemOncExt, the new concepts are assigned a temporary unique identifier concept_id along with all the necessary CONCEPT table fields. The appropriate relationship and inverse relationships within HemOnc and amongst HemOnc and RxNorm are recycled from those in the OMOP Vocabulary to ensure a seamless integration of these locally created concepts with the rest of the OMOP Vocabulary. 

## Requirements  
1. Postgres database with a schema loaded with the OMOP Vocabulary tables 
  
## Initial Setup
1. `createHemOncExtSchema()`: Create a HemOnc Extension (`hemonc_extension`) schema in a database
2. `ddlHemOncExtSchema()`: Instantiate OMOP Vocabulary Tables in the newly made `hemonc_extension` schema
3. Migrate HemOnc Concepts and RxNorm/RxNorm Extension Ingredients/Precise Ingredients to the `hemonc_extension` cchema to create new relationships:    
        `hemOncExt::migrateConcept(conn = conn, source_schema = "public")`  
        `hemOncExt::migrateConceptAncestor(conn = conn, source_schema = "public")`  
        `hemOncExt::migrateConceptRelationship(conn = conn, source_schema = "public")`
        `hemOncExt::migrateConceptSynonym(conn = conn, source_schema = "public")`  
                                 
4. Recommended Maintenance: every time an update is done to the Athena HemOnc or RxNorm vocabulary, this schema should be dropped and the above functions rerun on the newest instance of the vocabulary.  

## Creating a NEW Concept  
*NEW Concepts should occur in batches. The in-house concept_id is generated using the getIdentifier function, and is the timestamp in the format "YYYYmmddhhmmss", with the "202" in the year 2020 removed to be "Ymmddhhmmss". When converted to integer in the year 2020, timestamps from single digit months (Jan to September) will result in the loss of 2 leading zeros and 1 leading zero in all other cases. For the next decade, this identifier should be unique as long as a identifier assignment has not occurred at overlapping times. The best approach would be to make a single identifier as an anchor and subtracting by 1 incrementally for each NEW Concept. This is advantagous over adding incrementally because it could technically cause collisions should we have 10000 NEW concepts and the concept_ids may overlap with those that are made for another project immediately thereafter. 
  
### Steps  
#### Requirements: dataframe with a single unique identifier, NEW Regimen, any NEW Component, and Ingredient (RxNorm) column representing the Regimen-Component-Ingredient Axis in the HemOnc ontology. The contents will be in Label format "{concept_id|NEW} {concept_name}".  
1. Quality Rules: 1 Regimen per row, At least 1 Component per Regimen, Each Component has exactly 1 RxNorm Ingredient or RxNorm Precise Ingredient.  


4, Enumerate all NEW concepts with this batch into a single dataframe
5. Populate NEW Concepts by concept_class_id
1. Tables to downloadable data package
