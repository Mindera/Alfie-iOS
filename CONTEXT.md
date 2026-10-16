
### Failures

**Server error**:
The BFF failed to answer after the app retried. The shopper is told the problem is ours and can try again.

**Rate limited**:
The BFF asked the app to slow down. The shopper is told to wait a moment and try again.

**No connection**:
The device cannot reach the network. The shopper is told to check their connection.
_Avoid_: offline, no internet

**Timeout**:
The BFF did not answer in time. Not a kind of its own for the shopper: it shows the generic failure.
