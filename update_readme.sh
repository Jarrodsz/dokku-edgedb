#!/bin/bash
set -e

echo "Updating README.md with GEL references..."

# Update title and description
sed -i '' 's/# dokku edgedb/# dokku gel/g' README.md
sed -i '' 's/Unofficial edgedb plugin for dokku. Currently defaults to installing \[edgedb\/edgedb nightly\]/Unofficial gel plugin for dokku. Currently defaults to installing \[gel\/gel:6.2\]/g' README.md
sed -i '' 's/\[edgedb\/edgedb nightly\](https:\/\/hub.docker.com\/r\/edgedb\/edgedb\/)/\[gel\/gel:6.2\](https:\/\/hub.docker.com\/r\/gel\/gel\/)/g' README.md

# Update how it works
sed -i '' 's/Since edgedb can be connected only by an authenticated client/Since gel can be connected only by an authenticated client/g' README.md
sed -i '' 's/this plugin will create an edgedb credentials file/this plugin will create a gel credentials file/g' README.md
sed -i '' 's/`EDGEDB_CREDENTIALS_FILE`/`GEL_CREDENTIALS_FILE`/g' README.md
sed -i '' 's/All edgedb clients can automatically/All gel clients can automatically/g' README.md
sed -i '' 's/use this to connect to the edgedb server/use this to connect to the gel server/g' README.md

# Update important notes
sed -i '' 's/The edgedb server usually requires/The gel server usually requires/g' README.md

# Update installation
sed -i '' 's/https:\/\/github.com\/ignisda\/dokku-edgedb.git edgedb/https:\/\/github.com\/ignisda\/dokku-gel.git gel/g' README.md

# Update commands
sed -i '' 's/edgedb:/gel:/g' README.md

# Update usage examples
sed -i '' 's/edgedb:help/gel:help/g' README.md
sed -i '' 's/dokku edgedb:/dokku gel:/g' README.md
sed -i '' 's/export EDGEDB_/export GEL_/g' README.md
sed -i '' 's/override shared memory size for edgedb/override shared memory size for gel/g' README.md

# Capitalize service references
sed -i '' 's/edgedb service/Gel service/g' README.md
sed -i '' 's/gel service/Gel service/g' README.md

# Add UI URL information to the info section
sed -i '' '/- `--version`: show the service image version/a\
- `--ui-url`: show the service UI URL' README.md

echo "README.md has been updated successfully!" 