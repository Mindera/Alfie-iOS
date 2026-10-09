---
status: accepted
---

# The server Cart is the only source of truth for the Bag

The **Bag** renders the BFF's **Cart** and nothing else. The app keeps only a cart id; one
observable Cart feeds both the Bag screen and the **Bag badge**, and every write waits for the
server and replaces that Cart wholesale with the response. There is no local copy of the Lines, no
optimistic update and no offline Bag.

Every cart mutation returns the complete Cart, so the response is the new truth and there is
nothing to merge. Another device or the web can change the same Cart, so any local copy would go
stale against it.

## Considered options

- **Optimistic writes.** Rejected. They hide latency at the price of a rollback path and a second
  source of truth in the view.
- **A persisted mirror for offline reads.** Rejected. It brings back the local source of truth this
  design removes, and goes stale against a Cart other surfaces can change.
- **Each caller fetches its own Cart.** Rejected. Two client-side copies drifting apart is the
  failure a server-side quantity field would not have fixed.
- **Migrate the old local bag.** Rejected. The app was unreleased, so no shopper had one.

## Consequences

- Offline, the Bag is an error with retry and a write is refused with a snackbar. Within a session
  the last good Cart stays on screen through a failed write.
- Controls disable while a write is in flight. Cart writes queue behind each other, because an
  update sends the whole Line list and two in flight would clobber each other.
- A failed quantity update re-reads the Cart: BigCommerce applies an update Line by Line and can
  fail with earlier Lines committed.
- Mutations are excluded from the retry interceptor and the Apollo cache. A retried add would add
  the Line twice.
- The Bag badge is summed on the client from the Cart's Lines; the BFF has no total-quantity field
  and needs none.
- An empty Bag is a loaded Cart with no Lines, not a separate state.
- Analytics fire only after a write succeeds.
