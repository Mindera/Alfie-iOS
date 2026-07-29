import XCTest
import ApolloTestSupport
@testable import BFFGraph
import Core
import Model

final class MainMenuConverterTests: XCTestCase {
    func test_empty_menu_yields_no_items() {
        let items = makeMenu(items: []).convertToNavigationItems()
        XCTAssertTrue(items.isEmpty)
    }

    func test_leaf_maps_to_listing_with_handle_url() throws {
        let items = makeMenu(items: [Mock<MenuItem>(id: "1", title: "Women", url: "/women")])
            .convertToNavigationItems()

        let item = try XCTUnwrap(items.first)
        XCTAssertEqual(item.type, .listing)
        XCTAssertEqual(item.title, "Women")
        XCTAssertEqual(item.url, "/women")
        XCTAssertNil(item.items)
    }

    func test_collections_link_maps_to_listing_with_handle() throws {
        let items = makeMenu(items: [Mock<MenuItem>(id: "1", title: "Tops", url: "/collections/womens-tops")])
            .convertToNavigationItems()

        let item = try XCTUnwrap(items.first)
        XCTAssertEqual(item.type, .listing)
        XCTAssertEqual(item.url, "/womens-tops")
    }

    func test_absolute_collections_url_uses_handle_and_drops_host() throws {
        // Real Shopify menu urls are absolute; a collection only needs its handle, so the host is
        // correctly dropped here.
        let items = makeMenu(items: [
            Mock<MenuItem>(id: "1", title: "Home", url: "https://mindera-test-store.myshopify.com/collections/frontpage")
        ]).convertToNavigationItems()

        let item = try XCTUnwrap(items.first)
        XCTAssertEqual(item.type, .listing)
        XCTAssertEqual(item.url, "/frontpage")
    }

    func test_collections_tag_url_uses_handle_not_tag() throws {
        // Tag-filtered collection link — the handle is the segment after `collections`, not the tag.
        let items = makeMenu(items: [Mock<MenuItem>(id: "1", title: "Sale", url: "/collections/all/sale")])
            .convertToNavigationItems()
        XCTAssertEqual(try XCTUnwrap(items.first).url, "/all")
    }

    func test_bare_collections_url_is_dropped() {
        let items = makeMenu(items: [Mock<MenuItem>(id: "1", title: "Collections", url: "/collections")])
            .convertToNavigationItems()
        XCTAssertTrue(items.isEmpty)
    }

    func test_absolute_page_url_is_kept_verbatim_with_host() throws {
        // Page/blog links open in a webview and must hit the real host, so the absolute url is kept
        // intact (host included) rather than reduced to a path.
        let url = "https://mindera-test-store.myshopify.com/pages/contact"
        let items = makeMenu(items: [Mock<MenuItem>(id: "1", title: "Contact", url: url)])
            .convertToNavigationItems()

        let item = try XCTUnwrap(items.first)
        XCTAssertEqual(item.type, .page)
        XCTAssertEqual(item.url, url)
    }

    func test_pages_link_maps_to_page_type_keeping_full_path() throws {
        let items = makeMenu(items: [Mock<MenuItem>(id: "1", title: "Store Locator", url: "/pages/store-locator")])
            .convertToNavigationItems()

        let item = try XCTUnwrap(items.first)
        XCTAssertEqual(item.type, .page)
        XCTAssertEqual(item.url, "/pages/store-locator")
    }

    func test_blogs_link_maps_to_page_type_keeping_full_path() throws {
        let items = makeMenu(items: [Mock<MenuItem>(id: "1", title: "News", url: "/blogs/news")])
            .convertToNavigationItems()

        let item = try XCTUnwrap(items.first)
        XCTAssertEqual(item.type, .page)
        XCTAssertEqual(item.url, "/blogs/news")
    }

    func test_products_link_maps_to_product_type_keeping_full_path() throws {
        let items = makeMenu(items: [Mock<MenuItem>(id: "1", title: "Shirt", url: "/products/some-shirt")])
            .convertToNavigationItems()

        let item = try XCTUnwrap(items.first)
        XCTAssertEqual(item.type, .product)
        XCTAssertEqual(item.url, "/products/some-shirt")
    }

    func test_unknown_multi_segment_url_is_dropped() {
        // Not a recognized Shopify route (collections/pages/blogs/products) — dropped rather than
        // guessed into a bogus collection handle.
        let items = makeMenu(items: [Mock<MenuItem>(id: "1", title: "Deep", url: "/shop/new/dresses")])
            .convertToNavigationItems()
        XCTAssertTrue(items.isEmpty)
    }

    func test_nested_children_are_preserved() throws {
        let child = Mock<MenuItem>(id: "1.1", title: "Tops", url: "/womens-tops")
        let parent = Mock<MenuItem>(id: "1", items: [child], title: "Women", url: "/women")
        let items = makeMenu(items: [parent]).convertToNavigationItems()

        let parentItem = try XCTUnwrap(items.first)
        XCTAssertEqual(parentItem.title, "Women")
        let children = try XCTUnwrap(parentItem.items)
        XCTAssertEqual(children.count, 1)
        XCTAssertEqual(children.first?.url, "/womens-tops")
        XCTAssertEqual(children.first?.type, .listing)
    }

    func test_three_levels_of_nesting_are_preserved() throws {
        let grandChild = Mock<MenuItem>(id: "1.1.1", title: "Mini", url: "/mini-dresses")
        let child = Mock<MenuItem>(id: "1.1", items: [grandChild], title: "Dresses", url: "/dresses")
        let parent = Mock<MenuItem>(id: "1", items: [child], title: "Women", url: "/women")

        let items = makeMenu(items: [parent]).convertToNavigationItems()

        let level3 = try XCTUnwrap(items.first?.items?.first?.items?.first)
        XCTAssertEqual(level3.url, "/mini-dresses")
        XCTAssertNil(level3.items)
    }

    func test_leaf_without_url_is_dropped() {
        let items = makeMenu(items: [Mock<MenuItem>(id: "1", title: "Orphan", url: nil)])
            .convertToNavigationItems()
        XCTAssertTrue(items.isEmpty)
    }

    func test_parent_without_url_survives_when_it_has_children() throws {
        let child = Mock<MenuItem>(id: "1.1", title: "Tops", url: "/womens-tops")
        let parent = Mock<MenuItem>(id: "1", items: [child], title: "Women", url: nil)
        let items = makeMenu(items: [parent]).convertToNavigationItems()

        let parentItem = try XCTUnwrap(items.first)
        XCTAssertNil(parentItem.url)
        XCTAssertEqual(parentItem.items?.count, 1)
    }

    func test_type_is_derived_from_the_route_prefix() {
        // The converter maps each link to a type by its Shopify route so non-collection links don't
        // become broken PLPs.
        let items = makeMenu(items: [
            Mock<MenuItem>(id: "1", title: "Women", url: "/women"),
            Mock<MenuItem>(id: "2", title: "Sale", url: "/collections/sale"),
            Mock<MenuItem>(id: "3", title: "Store Locator", url: "/pages/store-locator"),
            Mock<MenuItem>(id: "4", title: "News", url: "/blogs/news"),
            Mock<MenuItem>(id: "5", title: "Shirt", url: "/products/some-shirt")
        ]).convertToNavigationItems()

        XCTAssertEqual(items.map(\.type), [.listing, .listing, .page, .page, .product])
    }

    func test_root_url_leaf_is_dropped() {
        // "/" has no last path component → no collection handle → not actionable as a leaf.
        let items = makeMenu(items: [Mock<MenuItem>(id: "1", title: "Home", url: "/")])
            .convertToNavigationItems()
        XCTAssertTrue(items.isEmpty)
    }

    func test_query_string_and_fragment_are_stripped_from_handle() throws {
        let items = makeMenu(items: [
            Mock<MenuItem>(id: "1", title: "Sale", url: "/collections/sale?filter=color"),
            Mock<MenuItem>(id: "2", title: "Top", url: "/dresses#top")
        ]).convertToNavigationItems()

        XCTAssertEqual(items.count, 2)
        XCTAssertEqual(items.first?.url, "/sale")
        XCTAssertEqual(items.last?.url, "/dresses")
    }

    func test_empty_string_url_leaf_is_dropped() {
        let items = makeMenu(items: [Mock<MenuItem>(id: "1", title: "Empty", url: "")])
            .convertToNavigationItems()
        XCTAssertTrue(items.isEmpty)
    }

    func test_whitespace_only_url_leaf_is_dropped() {
        let items = makeMenu(items: [Mock<MenuItem>(id: "1", title: "Blank", url: "   ")])
            .convertToNavigationItems()
        XCTAssertTrue(items.isEmpty)
    }

    func test_trailing_slash_is_stripped_to_last_segment() throws {
        let items = makeMenu(items: [Mock<MenuItem>(id: "1", title: "Dresses", url: "/dresses/")])
            .convertToNavigationItems()
        XCTAssertEqual(try XCTUnwrap(items.first).url, "/dresses")
    }

    func test_absolute_host_only_url_is_dropped() {
        // The host must never be read as a collection handle (would yield a bogus "/example.com").
        let items = makeMenu(items: [Mock<MenuItem>(id: "1", title: "Home", url: "https://example.com")])
            .convertToNavigationItems()
        XCTAssertTrue(items.isEmpty)
    }

    func test_absolute_root_path_url_is_dropped() {
        let items = makeMenu(items: [Mock<MenuItem>(id: "1", title: "Home", url: "https://example.com/")])
            .convertToNavigationItems()
        XCTAssertTrue(items.isEmpty)
    }

    func test_handle_is_lowercased() throws {
        let items = makeMenu(items: [Mock<MenuItem>(id: "1", title: "Women", url: "/Womens-Tops")])
            .convertToNavigationItems()
        XCTAssertEqual(try XCTUnwrap(items.first).url, "/womens-tops")
    }

    func test_hyphenated_single_segment_url_is_preserved_as_handle() throws {
        // A hyphenated single-segment path is a valid collection handle — preserved verbatim (lowercased).
        let items = makeMenu(items: [Mock<MenuItem>(id: "1", title: "Services", url: "/store-services")])
            .convertToNavigationItems()
        XCTAssertEqual(try XCTUnwrap(items.first).url, "/store-services")
    }

    func test_parent_degrades_to_leaf_when_all_children_are_dropped() throws {
        // Parent has a valid url but its only child has no url (dropped) → parent keeps its url and
        // becomes a chevron-less leaf (items == nil), which the chevron predicate relies on.
        let child = Mock<MenuItem>(id: "1.1", title: "Orphan", url: nil)
        let parent = Mock<MenuItem>(id: "1", items: [child], title: "Women", url: "/women")
        let items = makeMenu(items: [parent]).convertToNavigationItems()

        let parentItem = try XCTUnwrap(items.first)
        XCTAssertEqual(parentItem.url, "/women")
        XCTAssertNil(parentItem.items)
    }
}

// MARK: - Test factory

private extension MainMenuConverterTests {
    func makeMenu(items: [Mock<MenuItem>]) -> BFFGraphAPI.MainMenuQuery.Data.MainMenu {
        BFFGraphAPI.MainMenuQuery.Data.MainMenu.from(Mock<Menu>(handle: "main-menu", items: items, title: "Main"))
    }
}
