% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/migrateConceptRelationship.R
\name{migrateConceptRelationship}
\alias{migrateConceptRelationship}
\title{Migrate HemOnc and RxNorm Vocabularies Relationships}
\usage{
migrateConceptRelationship(conn, source_schema)
}
\arguments{
\item{source_schema}{The schema where the main OMOP vocabularies are loaded.}
}
\description{
This function executes on the condition that there are zero rows in the concept_ancestor table in the hemonc_extension schema.
}
