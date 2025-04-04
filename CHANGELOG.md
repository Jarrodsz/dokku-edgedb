# Changelog

All notable changes to this project will be documented in this file.

## 2.0.1 (2024-04-04)

### Changes

- Simplified plugin by removing S3 backup functionality
- Removed complex backup features (backup-auth, backup-schedule, backup-encryption, etc.)
- Updated README with focus on essential functionality
- Improved clarity and organization of documentation
- Maintained all core functionality for Gel/EdgeDB database usage

## 2.0.0 (2023-08-02)

### Changes

- Rename plugin from EdgeDB to Gel
- Update image to gel/gel:6.2

### Added
- Initial changelog file
- Support for GEL UI on port 10700
- Added service_ui_url function to get the UI URL
- Added UI URL information to service_info output
- Added test for UI URL in service_info.bats
- Added GEL UI section to README.md

### Changed
- Updated Dockerfile to use gel/gel:6.2 instead of edgedb/edgedb:nightly
- Renamed plugin command prefix from "edgedb" to "gel"
- Updated configuration to use GEL naming conventions
- Changed image references from EdgeDB to GEL
- Updated CLI image to gel/gel-cli:6.1.2
- Bumped version to 2.0.0 to reflect major changes
- Updated service_create_container to enable GEL UI
- Updated service_export and service_import to use GEL config paths
- Modified service_url to use gel:// scheme instead of edgedb://
- Updated service_link to use GEL_CREDENTIALS_FILE instead of EDGEDB_CREDENTIALS_FILE
- Updated service_unlink to use GEL_CREDENTIALS_FILE
- Updated all test files to use GEL references
- Updated README.md with GEL branding and URL information
- Updated the example application to use GEL instead of EdgeDB
- Fixed volume paths in functions file to use GEL config 