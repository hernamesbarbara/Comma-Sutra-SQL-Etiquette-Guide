-- Example: Select Active Users
-- This query selects active users from the `user_account` table and shows some key columns.
-- BAD -> leading comma preferred vs. trailing comma

SELECT
    id
    , email
    , full_name
FROM
    user_account
WHERE
    is_active = TRUE
    AND _created_at > NOW() - INTERVAL '30 days';
