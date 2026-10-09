---
status: accepted
---

# A Cart has expired when the BFF answers 404

The app stores the cart id in `UserDefaults`, since it is a non-secret handle to a guest Cart, with
no timer of its own. The only signal that a **Cart** is gone is a BFF error carrying
`extensions.status == 404`, mapped to a cart-not-found error. Any other failure is a server
fault and the id is kept.

Carts expire after 30 days of inactivity, and inactivity is not something the app can measure: the
web or another device can touch the same Cart. A client timer would expire a live Cart or outlive a
dead one.

The Cart is created lazily by the first add. The BFF does not create one from an unknown id, so
the app owns creation, and the create call carries that first Line.

## Considered options

- **A client-side TTL.** Rejected, for the reason above.
- **A distinguishable error code for cart-not-found.** Asked for and declined by the BFF team; 404
  stays. The error code alone cannot tell not-found from a fault, because both arrive as
  `INTERNAL_SERVER_ERROR`; only the status differs.
- **Read `Cart.status`.** Rejected. Both commerce adapters hardcode `"active"`, so it can never
  signal expiry.

## Consequences

- A 404 on add is not shown to the shopper: discard the id, create a Cart with the same Line,
  report success. On Shopify the BFF currently answers an unknown Cart on add and update with a
  400, so this recovery is unreachable there until #155 is settled.
- A 404 on read discards the id, renders an empty Bag and creates nothing.
- A 404 on remove is shown to the shopper and the id is kept: that removal did not happen.
- A malformed id surfaces as a 500 and never self-heals. Unreachable in practice, since the only
  ids stored are ones the server issued.
- Sign-out drops the id so a shared device does not hand the next shopper the previous Bag. When
  user-owned Carts arrive with authentication, sign-in must drop it too.
