# AlfieCodeGen

Generates **Alfie codes** — the QR codes we print and attach to swing tags for the in-store scan
demo. Each code carries a Product's Handle, so scanning it opens that Product's details page with no
catalogue lookup. See `Docs/adr/0001-print-our-own-alfie-code.md` for why we print our own code
instead of reading the manufacturer's barcode, and `Docs/Specs/Features/InStoreScanToPDP.md` for the
feature this feeds.

## Run it

```bash
cp Tools/AlfieCodeGen/handles.example.txt my-handles.txt   # then put real handles in it
./Alfie/scripts/generate-alfie-codes.sh my-handles.txt     # → build/AlfieCodes
./Alfie/scripts/generate-alfie-codes.sh my-handles.txt out/
```

The script runs the generator's tests first, then writes one PNG per line of the list. Output lands
in `build/AlfieCodes` by default, which is git-ignored — nothing generated here is committed.

The handle list is required rather than defaulted: which Products get printed changes per demo, and
a default list would quietly print codes for Products that are not in the catalogue.

There are no flags. The link host and the printed size are both fixed, because both have exactly one
right answer (below), and a flag that can be typed wrong is a sheet of codes that can come out
wrong. To skip the script's test gate and run the tool directly:

```bash
swift run --package-path Tools/AlfieCodeGen AlfieCodeGen my-handles.txt out/
```

## The handle list

Plain text. One Product Handle per line, an optional SKU after a comma. `#` comments and blank
lines are ignored.

```
# Demo products
mens-jeans-slim-indigo
womens-coat-wool-camel, SKU-8842
mens/outerwear/wool-blend-peacoat
```

A Handle may contain `/` — BigCommerce Handles are route paths — and it becomes path segments in the
link. Anything else that is not URL-path-safe is rejected with the line number, because a typo'd
Handle prints a code that fails silently in the meeting room.

The tool stops, having written nothing, when a line is malformed, when the list holds no handles at
all, or when two entries would produce the same file name.

## What comes out

`mens-jeans-slim-indigo.png`, one per entry, captioned with the handle (and SKU) so you can tell the
tags apart after cutting up the sheet. Each image encodes:

```
https://localhost:4000/product/<handle>?sku=<sku>
```

`localhost:4000` is the host `LinkConfiguration` already accepts, so a scan needs no app config
change — and it is not configurable for the same reason: a code carrying any other host is a code
the app refuses to route. The consequence is that these links do **not** resolve in a browser, and
the iOS Camera app will not open Alfie from one — scan from inside the app.

The PNGs are greyscale, with a 5-module quiet zone (the QR spec's minimum is four; CoreImage
contributes one of them), scaled by whole modules so the print stays crisp. Each carries the DPI
(300 or better) that makes the code come out **exactly 30mm square at 100% scale**, whatever QR
version the link needs, plus about 5mm of caption below it. Print at 100% — "fit to page" will
resize them and the measurements stop meaning anything.

## Before a demo

- Pick five to eight Products, at least two with an out-of-stock size and one with an unavailable
  colour, or the availability story shows nothing. `handles.example.txt` is laid out in that shape.
- Check stock against the running BFF on the day: the catalogue is a real store.
- Scan one printed tag with the app before the meeting.

## Why it is not in AlfieKit

Like `Tools/DesignTokenGen`, this package sits outside the app's dependency graph: the app never
runs it, CI never builds it, and `verify.sh` does not cover it. Its tests are gated in
`Alfie/scripts/generate-alfie-codes.sh` instead, so they run every time codes are generated.

```bash
swift test --package-path Tools/AlfieCodeGen
```
