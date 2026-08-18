CREATE OR REPLACE VIEW public.funding_vs_requirements AS

SELECT
    plan_id,
    year,
    sector,
    requirements,
    funding,

    CASE
        WHEN sector IN (
            'Not specified',
            'Multiple clusters/sectors (shared)'
        ) THEN 'Unallocated'

        WHEN sector = 'Multi-sector'
            THEN 'Cross-sector'

        WHEN sector = 'Other'
            THEN 'Other'

        ELSE 'Sector'
    END AS sector_type

FROM raw.requirements_funding_globalcluster

WHERE year >= 2022
  AND NOT (
      year = 2022
      AND plan_id = 1081
  );