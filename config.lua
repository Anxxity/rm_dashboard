Config = {}

-- ACE Permission required to access the dashboard
-- Set this to your admin ACE permission (e.g., "admin", "group.admin", etc.)
Config.AdminPermission = "admin"

-- Database configuration
Config.Database = "oxmysql" -- or "mysql-async" or "ghmattimysql"

-- Economy framework (adjust based on your framework)
-- Options: "esx", "qb-core", "standalone"
Config.Framework = "esx"

-- SQL Editor Settings
Config.AllowSQL = true -- Set to false to disable SQL editor
Config.SQLMaxQueryLength = 10000 -- Maximum query length
Config.SQLBlockedKeywords = { -- Keywords that will be blocked in SQL queries
    "DROP DATABASE",
    "DROP TABLE",
    "TRUNCATE",
    "DELETE FROM",
    "ALTER TABLE",
    "CREATE TABLE",
    "CREATE DATABASE"
}

-- Dashboard Settings
Config.RefreshInterval = 5000 -- Refresh interval in milliseconds (5 seconds)

