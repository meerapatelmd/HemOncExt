#' @title CONCEPT
#' @description HemOnc Extension Concepts in the format of a OMOP Vocabulary CONCEPT table
#' @format A data frame with 123 rows and 10 variables:
#' \describe{
#'   \item{\code{concept_id}}{character Local (non-Athena) Concept Id Number}
#'   \item{\code{concept_name}}{character Concept Name}
#'   \item{\code{domain_id}}{character Domain}
#'   \item{\code{vocabulary_id}}{character Vocabulary}
#'   \item{\code{concept_class_id}}{character Concept Class}
#'   \item{\code{standard_concept}}{character Concept Type}
#'   \item{\code{concept_code}}{character Concept Code}
#'   \item{\code{valid_start_date}}{character Start Date}
#'   \item{\code{valid_end_date}}{character End Date}
#'   \item{\code{invalid_reason}}{character Reason concept is no longer valid}
#'}
#' @source \url{http://athena.ohdsi.org/}
"concept"

#' @title CONCEPT_SYNONYM
#' @description Synonyms of HemOnc Extension Concepts in the format of a OMOP Vocabulary CONCEPT_SYNONYM table
#' @format A data frame with 0 rows and 3 variables:
#' \describe{
#'   \item{\code{concept_id}}{character Concept Id}
#'   \item{\code{concept_synonym_name}}{character Concept Synonyms, also known as Alternative Labels}
#'   \item{\code{language_concept_id}}{character Language Concept Id}
#'}
#' @source \url{http://athena.ohdsi.org/}
"concept_synonym"

#' @title CONCEPT_RELATIONSHIP
#' @description HemOnc Extension Concept relationshipsin the format of a OMOP Vocabulary CONCEPT_RELATIONSHIP table
#' @format A data frame with 586 rows and 6 variables:
#' \describe{
#'   \item{\code{concept_id_1}}{character Concept Id 1}
#'   \item{\code{concept_id_2}}{character Concept Id 2}
#'   \item{\code{relationship_id}}{character Relationship between Concept 1 and Concept 2}
#'   \item{\code{valid_start_date}}{character Start Date}
#'   \item{\code{valid_end_date}}{character End Date}
#'   \item{\code{invalid_reason}}{character Reason relationship id is no longer valid}
#'}
#' @source \url{http://athena.ohdsi.org/}
"concept_relationship"
