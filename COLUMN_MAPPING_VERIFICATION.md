# Voucher Entity Column Mapping Verification

## Database Column Names (from error logs)
Based on the latest error, the database expects these exact column names:

### Critical Columns (Mixed Format):
- `merchant_id` (WITH underscore) ✅
- `createdat` (NO underscore) ✅
- `updatedat` (NO underscore) ✅
- `min_value` (WITH underscore) ✅
- `max_value` (WITH underscore) ✅

### All Other Columns (snake_case with underscores):
- `category_id`
- `terms_conditions`
- `denominations`
- `discount_percentage`
- `image_url`
- `additional_images`
- `status`
- `stock_quantity`
- `unlimited_stock`
- `valid_from`
- `valid_until`
- `redemption_locations`
- `min_purchase_amount`
- `max_purchase_per_user`
- `usage_instructions`
- `total_sold`
- `total_redeemed`
- `rating`
- `total_reviews`
- `view_count`
- `meta_title`
- `meta_description`
- `published_at`
- `metadata`

## Entity Code Verification

### Current Entity Mappings (Voucher.java):
```java
@Column(name = "merchant_id", nullable = false)          // ✅ CORRECT
@Column(name = "category_id")                            // ✅ CORRECT
@Column(name = "createdat", nullable = false)            // ✅ CORRECT
@Column(name = "updatedat", nullable = false)            // ✅ CORRECT
@Column(name = "min_value", nullable = false)            // ✅ CORRECT
@Column(name = "max_value", nullable = false)            // ✅ CORRECT
```

## Status
✅ All column names in the entity match the database schema
✅ Container has been rebuilt with latest code
✅ Service has been restarted

## Next Steps
If errors persist, check:
1. Container is using the latest JAR (check build timestamp)
2. Hibernate is generating correct SQL (check logs)
3. Database schema matches expectations

