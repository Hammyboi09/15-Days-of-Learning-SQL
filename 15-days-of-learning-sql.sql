SELECT
    table1.submission_date,
    table1.total_hardworking_hackers,
    table2.hacker_id,
    hackers.name
FROM (
    SELECT 
        sub2.submission_date, 
        COUNT(sub2.hacker_id) AS total_hardworking_hackers
    FROM (
        SELECT 
            s3.submission_date,
            s3.hacker_id,
            COUNT(DISTINCT s4.submission_date)
        FROM submissions s3
        JOIN submissions s4
            ON s4.hacker_id = s3.hacker_id
            AND s4.submission_date <= s3.submission_date
        GROUP BY s3.submission_date, s3.hacker_id
        HAVING COUNT(DISTINCT s4.submission_date) = DATEDIFF(s3.submission_date, '2016-03-01') + 1
    ) AS sub2
    GROUP BY sub2.submission_date
) AS table1
JOIN (
    SELECT 
        sub1.submission_date, 
        MIN(sub1.hacker_id) AS hacker_id
    FROM (
        SELECT
            s1.submission_date,
            s1.hacker_id,
            COUNT(s1.submission_id)
        FROM submissions s1
        GROUP BY s1.submission_date, s1.hacker_id
        HAVING COUNT(s1.submission_id) = (
            SELECT COUNT(s2.submission_id)
            FROM submissions s2
            WHERE s2.submission_date = s1.submission_date
            GROUP BY s2.hacker_id
            ORDER BY COUNT(s2.submission_id) DESC
            LIMIT 1
        )
    ) AS sub1
    GROUP BY sub1.submission_date
) AS table2
ON table1.submission_date = table2.submission_date
JOIN hackers
ON hackers.hacker_id = table2.hacker_id
ORDER BY table1.submission_date