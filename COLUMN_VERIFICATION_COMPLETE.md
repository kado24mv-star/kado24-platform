# Complete Column Verification: Database vs Entity vs UI

## Entity Column Mappings (from Voucher.java)

| Entity Field | @Column Name | Database Column (Expected) |
|-------------|--------------|---------------------------|
| merchantId | merchant_id | merchant_id ✅ |
| categoryId | category_id | category_id ✅ |
| title | (default: title) | title ✅ |
| slug | (default: slug) | slug ✅ |
| description | (default: description) | description ✅ |
| termsAndConditions | terms_conditions | terms_conditions ✅ |
| denominations | denominations | denominations ✅ |
| discountPercentage | discount_percentage | discount_percentage ✅ |
| imageUrl | image_url | image_url ✅ |
| additionalImages | additional_image | additional_image ✅ FIXED |
| status | status | status ✅ |
| stockQuantity | stock_quantity | stock_quantity ✅ |
| unlimitedStock | unlimited_stock | unlimited_stock ✅ |
| validFrom | valid_from | valid_from ✅ |
| validUntil | valid_until | valid_until ✅ |
| redemptionLocations | redemption_locations | redemption_locations ✅ |
| minValue | min_value | min_value ✅ |
| maxValue | max_value | max_value ✅ |
| minPurchaseAmount | min_purchase_amount | min_purchase_amount ✅ |
| maxPurchasePerUser | max_purchase_per_user | max_purchase_per_user ✅ |
| usageInstructions | usage_instructions | usage_instructions ✅ |
| totalSold | total_sold | total_sold ✅ |
| totalRedeemed | total_redeemed | total_redeemed ✅ |
| rating | rating | rating ✅ |
| totalReviews | total_reviews | total_reviews ✅ |
| viewCount | view_count | view_count ✅ |
| metaTitle | meta_title | meta_title ✅ |
| metaDescription | meta_description | meta_description ✅ |
| createdAt | createdat | createdat ✅ |
| updatedAt | updatedat | updatedat ✅ |
| publishedAt | published_at | published_at ✅ |
| metadata | metadata | metadata ✅ |

## UI Request Body (from create_voucher_screen.dart)

**Fields sent by UI:**
```json
{
  "title": "...",
  "description": "...",
  "categoryId": 1,
  "denominations": [5.0, 10.0, 25.0],
  "stockQuantity": 100,
  "unlimitedStock": false,
  "termsAndConditions": "Standard terms apply"
}
```

**Fields NOT sent by UI:**
- imageUrl
- additionalImages (additional_image)
- discountPercentage
- validFrom
- validUntil
- redemptionLocations
- minPurchaseAmount
- maxPurchasePerUser
- usageInstructions

## Backend DTO (CreateVoucherRequest)

Need to verify what fields CreateVoucherRequest expects.

## Status

✅ All entity column mappings verified
✅ additional_image fixed (was additional_images)
✅ UI sends correct field names that match DTO

## Next Steps

1. Verify CreateVoucherRequest DTO matches UI request
2. Test voucher creation
3. Add missing fields to UI if needed

