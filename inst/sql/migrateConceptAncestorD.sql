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

SELECT d.*
FROM target_concepts c
LEFT JOIN @schema.concept_ancestor d
ON d.descendant_concept_id = c.concept_id
;
