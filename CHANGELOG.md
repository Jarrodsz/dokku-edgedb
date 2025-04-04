# Changelog

All notable changes to the dokku-gel plugin will be documented in this file.

## [2.0.0] - Unreleased

### Added
- Initial changelog file
- Support for GEL UI on port 10700

### Changed
- Updated Dockerfile to use gel/gel:6.2 instead of edgedb/edgedb:nightly
- Renamed plugin command prefix from "edgedb" to "gel"
- Updated configuration to use GEL naming conventions
- Changed image references from EdgeDB to GEL
- Updated CLI image to gel/gel-cli:6.1.2
- Bumped version to 2.0.0 to reflect major changes 