#!/bin/bash
set -e

# Update test files to use GEL instead of EdgeDB
echo "Updating test files to use GEL references..."

# Replace edgedb:// with gel://
find tests -name "*.bats" -type f -exec sed -i '' 's/edgedb:\/\//gel:\/\//g' {} \;

# Replace edgedb: with gel:
find tests -name "*.bats" -type f -exec sed -i '' 's/edgedb:/gel:/g' {} \;

# Replace dokku-edgedb with dokku-gel
find tests -name "*.bats" -type f -exec sed -i '' 's/dokku-edgedb/dokku-gel/g' {} \;

# Replace EDGEDB_DATABASE_SCHEME with GEL_DATABASE_SCHEME
find tests -name "*.bats" -type f -exec sed -i '' 's/EDGEDB_DATABASE_SCHEME/GEL_DATABASE_SCHEME/g' {} \;

# Replace DOKKU_EDGEDB with DOKKU_GEL
find tests -name "*.bats" -type f -exec sed -i '' 's/DOKKU_EDGEDB/DOKKU_GEL/g' {} \;

# Replace EDGEDB_CREDENTIALS_FILE with GEL_CREDENTIALS_FILE
find tests -name "*.bats" -type f -exec sed -i '' 's/EDGEDB_CREDENTIALS_FILE/GEL_CREDENTIALS_FILE/g' {} \;

# Replace port 5432 with 5656 (the correct GEL port)
find tests -name "*.bats" -type f -exec sed -i '' 's/:5432\//:5656\//g' {} \;

echo "Test files have been updated successfully!" 