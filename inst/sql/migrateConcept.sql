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
;
