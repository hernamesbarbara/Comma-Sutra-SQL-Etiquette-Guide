# Comma Sutra: SQL Etiquette Guide

A simple, practical style guide for writing readable and consistent SQL for PostgreSQL.  
Designed for humans and AI tools alike.

---

## 🧠 What Is This?

This repository includes a complete SQL style guide, a matching SQLFluff configuration, and example SQL files. Use this guide to write clean, consistent PostgreSQL queries.

---

## 🚀 Quickstart

### 1. Install SQLFluff

Install via pip:

```bash
pip install sqlfluff
```

### 2. Lint Your SQL Files

Lint all example SQL files:

```bash
sqlfluff lint examples/
```

### 3. Preview SQL formatting fix without saving

*NOTE:* The `--stdout` flag sends the fixed SQL to stdout instead of overwriting the file.


```bash 
sqlfluff fix examples/ --disable_progress_bar --force --nocolor --noqa --stdout
```

### 4. Auto-fix Violations

Fix issues automatically with:

```bash
sqlfluff fix examples/
```

---

## 📁 Project Structure

```
.
├── .gitignore         # Git ignore settings (e.g. editor files, caches, etc.)
├── .sqlfluff          # SQLFluff config for PostgreSQL (comma-first, 4-space indent, etc.)
├── README.md          # This file — the SQL style guide and project documentation
└── examples/          # Example SQL queries following this guide
    ├── joins_with_ctes.sql
    └── select_active_users.sql
```

---

## ✅ SQL Style Guide

### Keywords

- Always **uppercase** all SQL keywords.

```sql
SELECT id, name FROM users WHERE active = TRUE;
```

---

### Identifiers

- Use **snake_case** for table and column names.
- Use **singular** table names (e.g., `user`, not `users`).
- Use **lowercase** for all identifiers.

```sql
CREATE TABLE user_account (
    id SERIAL PRIMARY KEY
  , full_name TEXT NOT NULL
);
```

---

### Naming Conventions

- Be consistent and descriptive in naming.
- Avoid short, ambiguous names.

#### General Rules

| Type                   | Format         | Example                |
|------------------------|----------------|------------------------|
| Table Name             | `snake_case`   | `user_account`         |
| Column Name            | `snake_case`   | `created_at`           |
| Alias                  | `lowercase`    | `u`, `p`               |
| CTE                    | `snake_case`   | `recent_users`         |
| View                   | `vw_` prefix   | `vw_active_users`      |
| Materialized View      | `mvw_` prefix  | `mvw_monthly_revenue`  |
| User-Defined Function  | `f_` prefix    | `f_fibonacci`          |
| Temporary Resources    | `tmp_` prefix  | `tmp_recent_logins`    |

#### UDF Naming

- Prefix all UDFs with `f_`.
- Names should be **descriptive** and explain what the function does.

```sql
-- ❌ bad
CREATE FUNCTION fib(n INT) RETURNS INT ...

-- ⚠️ better
CREATE FUNCTION f_fib(n INT) RETURNS INT ...

-- ✅ best
CREATE FUNCTION f_fibonacci(n INT) RETURNS INT ...
```

#### View Naming

- Prefix standard views with `vw_`.

```sql
CREATE VIEW vw_active_users AS
SELECT
    id
  , email
FROM
    user_account
WHERE
    is_active = TRUE;
```

- Prefix materialized views with `mvw_`.

```sql
CREATE MATERIALIZED VIEW mvw_monthly_revenue AS
SELECT
    date_trunc('month', created_at) AS month
  , SUM(amount)
FROM
    payments
GROUP BY
    1;
```

---

### Timestamp Columns

- All tables must include both `_created_at` and `_updated_at` columns.
- These fields must follow the naming convention with a **leading underscore**.
- Use type `TIMESTAMPTZ` (or `TIMESTAMP WITH TIME ZONE`).
- `_created_at` is set on insert; `_updated_at` is updated on every write.

```sql
CREATE TABLE user_account (
    id SERIAL PRIMARY KEY
  , email TEXT NOT NULL UNIQUE
  , full_name TEXT
  , _created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
  , _updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);
```

```sql
CREATE OR REPLACE FUNCTION f_set_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        NEW._created_at := NOW();
        NEW._updated_at := NOW();
    ELSIF TG_OP = 'UPDATE' THEN
        NEW._updated_at := NOW();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_set_timestamp
BEFORE INSERT OR UPDATE ON user_account
FOR EACH ROW EXECUTE FUNCTION f_set_timestamp();
```

---

### Temporary Tables and Resources

- Prefix all temporary tables and inline table expressions with `tmp_`.

```sql
CREATE TEMP TABLE tmp_recent_logins AS
SELECT
    user_id
  , login_at
FROM
    user_login
WHERE
    login_at > NOW() - INTERVAL '1 day';

WITH tmp_active_subscribers AS (
    SELECT
        user_id
    FROM
        subscriptions
    WHERE
        status = 'active'
)
SELECT
    u.id
  , u.email
FROM
    user_account AS u
JOIN
    tmp_active_subscribers AS s ON u.id = s.user_id;
```

---

### Indentation and Formatting

- Use **4 spaces** for indentation (no tabs).
- Each clause (`SELECT`, `FROM`, `WHERE`, etc.) should be on its **own line**.
- Align columns under `SELECT`.

```sql
SELECT
    id
  , first_name
  , last_name
FROM
    user_account
WHERE
    is_active = TRUE;
```

---

### Commas

- Place commas at the **beginning** of lines in `SELECT`, `GROUP BY`, and `ORDER BY` clauses.
- Do **not** leave a trailing comma on the last line.

```sql
SELECT
    id
  , first_name
  , last_name
FROM
    user_account;
```

---

### Aliases

- Use **short, lowercase aliases**.
- Use the `AS` keyword for clarity.

```sql
SELECT
    u.id
  , u.email
FROM
    user_account AS u;
```

---

### Joins

- Use **explicit JOIN** syntax only.
- Place `JOIN` and `ON` on separate lines.

```sql
SELECT
    u.id
  , p.plan_name
FROM
    user_account AS u
JOIN
    subscription_plan AS p ON u.plan_id = p.id;
```

---

### CTEs (Common Table Expressions)

- Use CTEs to improve readability.
- For temporary CTEs, prefix the name with `tmp_`.

```sql
WITH tmp_recent_users AS (
    SELECT
        id
      , created_at
    FROM
        user_account
    WHERE
        created_at > NOW() - INTERVAL '7 days'
)
SELECT
    COUNT(*)
FROM
    tmp_recent_users;
```

---

### Boolean Logic

- Use `TRUE` and `FALSE` literals.
- Avoid using text or numeric substitutes.

```sql
WHERE is_active = TRUE
```

---

### NULL Handling

- Use `IS NULL` and `IS NOT NULL`.

```sql
WHERE deleted_at IS NULL
```

---

### Comments

- Use `--` for inline comments.
- Keep them concise and helpful.

```sql
-- Get active users created in the last 30 days
SELECT
    id
FROM
    user_account
WHERE
    is_active = TRUE
  AND created_at > NOW() - INTERVAL '30 days';
```

---

### File Formatting

- End SQL files with a **newline**.
- Prefer one statement per file when applying migrations.

---

## License

Add a license (for example, MIT) if you plan to share or reuse this guide.

Happy SQL linting and formatting!