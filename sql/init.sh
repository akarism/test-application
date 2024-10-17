#!/bin/bash
set -e

echo "Starting initialization script"

# Function to check if a database exists
database_exists() {
    local db=$1
    mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "USE $db;" 2>/dev/null
    return $?
}

# Function to check if a table exists
table_exists() {
    local db=$1
    local table=$2
    mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "USE $db; SHOW TABLES LIKE '$table';" | grep -q "$table"
    return $?
}

# Import SQL files only if the database is empty or doesn't exist
for db in sys-user sys-blog sys-log; do
    if ! database_exists $db || ! table_exists $db "user"; then
        echo "Importing data for $db"
        # Use sed to comment out the CREATE DATABASE and USE statements
        sed 's/^CREATE DATABASE/-- CREATE DATABASE/g; s/^use/-- use/g' "/docker-entrypoint-initdb.d/$db.sql" | mysql -u root -p"$MYSQL_ROOT_PASSWORD" $db
        echo "$db.sql executed"
    else
        echo "Skipping import for $db, database exists and is not empty"
    fi
done

echo "Initialization script completed"
