# hemOncExt  
## Overview  
* This package creates NEW oncology drug concepts with the appropriate OMOP relationship with any of the HemOnc, RxNorm Ingredient Concept Class, and/or RxNorm Extension Precise Ingredient Concept Class. 

## Requirements  
1. Postgres database that has a schema with Athena vocabulary tables to migrate the HemOnc and RxNorm vocabularies to the extension and will also be the location of the `hemonc_extension` schema.  
  
## Initial Setup
1. Create a HemOnc Extension Schema in a database and instantiate the OMOP Vocabulary Tables (createHemOncExtSchema.R)
2. Instantiate OMOP Vocabulary Tables (ddlHemOncExtSchema.R)
3. Migrate HemOnc Concepts and RxNorm/RxNorm Ingredients and Precise Ingredients to the new HemOnc Extension Schema to create new relationships  
4. Recommended Maintenance: every time an update is done to the HemOnc or RxNorm vocabulary, the 

4, Enumerate all NEW concepts with this batch into a single dataframe
5. Populate NEW Concepts by concept_class_id:  
    a) Regimen:  
        i. Concept Table Fields
            *

1. Tables to downloadable data package
