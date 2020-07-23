# hemOncExt  
## Overview  
* This package creates NEW oncology drug concepts with the appropriate OMOP relationship with any of the HemOnc, RxNorm Ingredient Concept Class, and/or RxNorm Extension Precise Ingredient Concept Class. 

## Requirements  
1. Postgres database that has a schema with Athena vocabulary tables to migrate the HemOnc and RxNorm vocabularies to the extension and will also be the location of the `hemonc_extension` schema.  
  
## Initial Setup
1. Create a HemOnc Extension Schema in a database and instantiate the OMOP Vocabulary Tables `createHemOncExtSchema.R`
2. Instantiate OMOP Vocabulary Tables `ddlHemOncExtSchema.R`
3. Migrate HemOnc Concepts and RxNorm/RxNorm Ingredients and Precise Ingredients to the new HemOnc Extension Schema to create new relationships: 
        ```hemOncExt::createHemOncExtSchema(conn = conn)
        hemOncExt::ddlHemOncExtSchema(conn = conn)
        hemOncExt::migrateConcept(conn = conn,
                                  source_schema = "public")
        hemOncExt::migrateConceptAncestor(conn = conn,
                                          source_schema = "public")
        hemOncExt::migrateConceptRelationship(conn = conn,
                                              source_schema = "public")
        hemOncExt::migrateConceptSynonym(conn = conn,
                                         source_schema = "public")```  
                                 
3. Apply constraints `constrainHemOncExtSchema(conn = conn)`: needs to be modified because affects ability to write data to tables 
4. Recommended Maintenance: every time an update is done to the HemOnc or RxNorm vocabulary the schema should be dropped and refreshed with the updated set. 

## Creating a NEW Concept  
*NEW Concepts should occur in batches. The in-house concept_id is generated using the rubix::make_identifier function, and is the timestamp in the format "YYYYmmddhhmmss", with the "202" in the year 2020 removed to be "Ymmddhhmmss". For the next decade, this identifier should be unique as long as a identifier assignment has not occurred at overlapping times. The best approach would be to make a single identifier as an anchor and subtracting by 1 incrementally for each NEW Concept. This is advantagous over adding incrementally because it could technically cause collisions should we have 10000 NEW concepts and the concept_ids may overlap with those that are made for another project immediately thereafter. Since it is currently the year 2020, the final 0 is also cut-off in the current concept_ids and they may need to be left-padded back in certain circumstances.  
  
### Steps  
#### Requirements: dataframe with a single unique identifier, NEW Regimen, any NEW Component, and Ingredient (RxNorm) column representing the Regimen-Component-Ingredient Axis in the HemOnc ontology. The contents will be in Label format "{concept_id|NEW} {concept_name}".  
1. Quality Rules: 1 Regimen per row, At least 1 Component per Regimen, Each Component has exactly 1 RxNorm Ingredient or RxNorm Precise Ingredient.  


4, Enumerate all NEW concepts with this batch into a single dataframe
5. Populate NEW Concepts by concept_class_id:  
    a) Regimen:  
        i. Concept Table Fields
            *

1. Tables to downloadable data package
