WITH target_concepts AS (
SELECT *
FROM @schema.concept
WHERE LOWER(vocabulary_id) IN  ('hemonc')
UNION
SELECT *
FROM @schema.concept
WHERE LOWER(vocabulary_id) IN ('rxnorm',
                                'rxnorm extension')
        AND LOWER(concept_class_id) IN ('ingredient',
                                        'precise ingredient')
)

SELECT a.*
FROM target_concepts c
INNER JOIN @schema.concept_relationship a
ON a.concept_id_1 = c.concept_id
UNION
SELECT b.*
FROM target_concepts c
INNER JOIN @schema.concept_relationship b
ON b.concept_id_2 = c.concept_id
;
