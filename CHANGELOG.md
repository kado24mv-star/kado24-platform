# Changelog

All notable changes to the Kado24 platform will be documented in this file.

## [2.0.1] - 2025-11-20

### Changed
- **Database Schema**: Updated `voucher_schema.vouchers.image_url` column from `VARCHAR(500)` to `TEXT`
  - **Reason**: Base64 image data URLs can exceed 500 characters
  - **Impact**: Supports unlimited-length image URLs for voucher images
  - **Migration**: See `backend/services/voucher-service/migrations/`

### Fixed
- **Voucher Creation**: Fixed "value too long" error when uploading base64 images
- **CORS Configuration**: Updated APISIX Route 3 to properly handle POST requests with CORS
- **UI/UX**: Improved image upload experience in merchant app
  - Base64 strings hidden from user view
  - Friendly status messages
  - Image preview functionality

### Updated
- **Database Initialization**: `scripts/init-database-schemas.sql` now creates `image_url` as TEXT
- **Documentation**: Updated voucher service README with image upload details
- **Migration Scripts**: Added migration documentation in `backend/services/voucher-service/migrations/README.md`

### Technical Details
- **Backend**: Voucher entity updated to use `@Column(columnDefinition = "TEXT")`
- **Frontend**: Image picker integrated with base64 encoding
- **Database**: Migration script available for existing databases

---

## [2.0.0] - 2025-11-19

### Initial Release
- Complete three-sided marketplace platform
- 13 backend microservices
- 3 frontend applications
- Multi-schema database architecture
- Production-ready infrastructure

