# Alfie

A shopping app for one fashion retailer. SCAYLE is the primary commerce platform; Shopify and
BigCommerce are also supported, and their terms are mapped onto SCAYLE's.

## Language

### Catalogue

**Master**:
An item in all its colours, e.g. "the Oxford shirt". Shoppers never buy a Master directly.
On Shopify and BigCommerce, what the platform calls a product is a Master.
_Avoid_: Style, parent product

**Product**:
One colour of a Master, e.g. "the Oxford shirt in blue". Other colours of the same Master are its siblings.
_Avoid_: Colourway, item

**Variant**:
One purchasable size of a Product, e.g. "the Oxford shirt in blue, size M".
_Avoid_: SKU, size option

### Media

**Gallery**:
The ordered photos shown for a Product. Every Variant of a Product shares its Gallery.
_Avoid_: Variant media, carousel

**Variant image**:
A photo a platform ties to one Variant. Most Variants have none; a Variant has at most one.
_Avoid_: Variant gallery
