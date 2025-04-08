-- Example: Join with CTE
-- This query demonstrates the use of a Common Table Expression (CTE)
-- and an explicit JOIN between temporary and persistent resources.

WITH tmp_recent_logins AS (
    SELECT
        user_id
      , login_at
    FROM
        user_login
    WHERE
        login_at > NOW() - INTERVAL '1 day'
)
SELECT
    u.id
  , u.email
  , l.login_at
FROM
    user_account AS u
JOIN
    tmp_recent_logins AS l ON u.id = l.user_id
WHERE
    u.is_active = TRUE;
