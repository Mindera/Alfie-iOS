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

    func test_multi_segment_url_reduces_to_last_path_component() throws {
        let items = makeMenu(items: [Mock<MenuItem>(id: "1", title: "Dresses", url: "/shop/new/dresses")])
            .convertToNavigationItems()

        XCTAssertEqual(try XCTUnwrap(items.first).url, "/dresses")
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

    func test_all_items_map_to_listing_type() throws {
        // Every leaf routes through the PLP flow; the converter doesn't infer other nav types.
        let items = makeMenu(items: [
            Mock<MenuItem>(id: "1", title: "Women", url: "/women"),
            Mock<MenuItem>(id: "2", title: "Sale", url: "/collections/sale")
        ]).convertToNavigationItems()

        XCTAssertEqual(items.map(\.type), [.listing, .listing])
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

    func test_absolute_url_reduces_to_last_path_segment() throws {
        let items = makeMenu(items: [
            Mock<MenuItem>(id: "1", title: "Dresses", url: "https://shop.example.com/collections/dresses")
        ]).convertToNavigationItems()
        XCTAssertEqual(try XCTUnwrap(items.first).url, "/dresses")
    }

    func test_handle_is_lowercased() throws {
        let items = makeMenu(items: [Mock<MenuItem>(id: "1", title: "Women", url: "/Womens-Tops")])
            .convertToNavigationItems()
        XCTAssertEqual(try XCTUnwrap(items.first).url, "/womens-tops")
    }

    func test_special_category_url_is_preserved_for_matching() throws {
        // `/store-services` and `/brands` are single-segment lowercase, so the handle rule preserves
        // them exactly, keeping SpecialCategories matching in didSelectCategory intact.
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
