# BlitzFlash Monetization Setup

## App Store Connect Products

Create these in-app purchase products in App Store Connect.

| Product | Type | Product ID |
| --- | --- | --- |
| Weekly Plus | Auto-renewable subscription | `com.blitzhanlabs.BlitzFlash.premium.weekly` |
| Monthly Plus | Auto-renewable subscription | `com.blitzhanlabs.BlitzFlash.premium.monthly` |
| Lifetime Plus | Non-consumable | `com.blitzhanlabs.BlitzFlash.premium.lifetime` |

The app reads these IDs from `MonetizationStore.swift`. Users with any active entitlement are treated as premium and do not see ad placements.

## Recommended Pricing

- Weekly: low entry price for casual users.
- Monthly: best default offer.
- Lifetime: priced high enough to protect subscription value.

Avoid making lifetime too cheap because it can reduce subscription upside.

## Ad Integration

`AdSlotView` is the shared ad placement component. It currently shows a branded placeholder and automatically hides for Plus users.

When ready to serve real ads:

1. Create an AdMob app for the iOS bundle ID `com.blitzhanlabs.BlitzFlash`.
2. Add the Google Mobile Ads SDK to the Xcode project.
3. Replace the placeholder body in `AdSlotView` with the native banner view.
4. Keep the existing `if !monetization.isPremium` gate so paid users remain ad-free.

Suggested initial placements:

- Home screen: one banner below Plus card.
- Each mode: one banner near the top.

Do not add interstitial ads until retention is healthy; they can hurt learning flow.
