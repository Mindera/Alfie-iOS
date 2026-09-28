# Alfie

A native iOS shopping app: shoppers browse and search products, save them to a wishlist, and buy them through a bag.

## Language

### Product listing

**Page request**:
One fetch of one page of a product listing. Exactly three kinds: **Refresh**, **First page**, **Next page**.
_Avoid_: Load more, following page, pagination request

**Refresh**:
A page request for page 1 triggered by pull-to-refresh, usually over loaded products. A refresh over a blocking error that fails stays a blocking error.

**First page**:
A page request for page 1 made when there are no loaded products (screen open, filter or sort applied, retry).

**Next page**:
A page request for the page after the last one loaded, triggered by scrolling to the last product.
_Avoid_: Load more

**Loaded products**:
Real products currently on screen. Skeleton placeholders are not loaded products.
_Avoid_: Grid, products on screen

**No results**:
A first page or refresh that finds no products to show. On a first page it is a blocking error; on a refresh over loaded products, a transient error.
_Avoid_: Empty error

**Blocking error**:
A page request failure shown as a full-screen error that replaces the listing. Only raised when there are no loaded products.
_Avoid_: Error screen, full-screen error

**Transient error**:
A page request failure shown as a dismissible Snackbar over loaded products, which stay on screen.
_Avoid_: Refresh error
