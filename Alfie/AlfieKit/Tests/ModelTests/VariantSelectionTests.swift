import Mocks
import Model
import XCTest

/// The colour × size matrix. Every case here crosses both axes: a one-axis fixture passes while the
/// colour scoping is missing, which is how the defect this type exists to remove survived four
/// green colour tests.
final class VariantSelectionTests: XCTestCase {
    // MARK: - Seeding

    func test_colour_is_seeded_from_the_preferred_variant() {
        let selection = VariantSelection(variants: matrix(), preferredVariant: variant(navy, medium))

        XCTAssertEqual(selection.selectedColour?.id, navy.id)
    }

    func test_colour_falls_back_to_the_first_colour_when_the_preferred_variant_matches_none() {
        // The seeding defect: an unmatched colour used to leave the selection silently nil, so the
        // grid rendered with nothing highlighted while a variant was already chosen.
        let stranger = variant(Product.Colour.fixture(id: "teal", name: "Teal"), medium)

        let selection = VariantSelection(variants: matrix(), preferredVariant: stranger)

        XCTAssertEqual(selection.selectedColour?.id, sand.id)
    }

    func test_colour_is_seeded_when_there_is_no_preferred_variant() {
        // The `.deepLink` route builds no configuration up front and so passes nothing here.
        let selection = VariantSelection(variants: matrix(), preferredVariant: nil)

        XCTAssertEqual(selection.selectedColour?.id, sand.id)
    }

    func test_size_is_not_seeded_when_the_colour_offers_more_than_one() {
        let selection = VariantSelection(variants: matrix(), preferredVariant: nil)

        XCTAssertNil(selection.selectedSize)
    }

    func test_a_restored_variant_brings_back_its_size_not_the_first_in_its_colour() {
        // Re-entry from Bag/Wishlist: the saved Navy/M must come back as Navy/M, not as Navy/S.
        let selection = VariantSelection(variants: matrix(), restoring: variant(navy, medium))

        XCTAssertEqual(selection.selectedSize?.id, medium.id)
        XCTAssertEqual(selection.displayVariant?.sku, "navy-m")
    }

    func test_a_product_default_seeds_the_colour_but_never_the_size() {
        // The default is merchandising, not a choice — pre-selecting its size would put a size in
        // the shopper's basket that they never picked.
        let selection = VariantSelection(variants: matrix(), preferredVariant: variant(navy, medium))

        XCTAssertEqual(selection.selectedColour?.id, navy.id)
        XCTAssertNil(selection.selectedSize)
    }

    func test_a_restored_size_that_sold_out_is_still_seeded() {
        // Keeping the shopper's saved size lets the CTA say it sold out, rather than silently
        // moving them onto a size they never chose.
        let variants = [variant(navy, small), variant(navy, medium, stock: 0)]

        let selection = VariantSelection(variants: variants, restoring: variant(navy, medium, stock: 0))

        XCTAssertEqual(selection.selectedSize?.id, medium.id)
        XCTAssertEqual(selection.purchaseState, .outOfStock)
    }

    func test_a_restored_colour_that_sold_out_is_kept_rather_than_swapped() {
        // Opening on a different colour than the one they saved hides that it sold out.
        let variants = [variant(sand, medium), variant(navy, medium, stock: 0)]

        let selection = VariantSelection(variants: variants, restoring: variant(navy, medium, stock: 0))

        XCTAssertEqual(selection.selectedColour?.id, navy.id)
        XCTAssertEqual(selection.purchaseState, .outOfStock)
    }

    func test_a_sold_out_preferred_colour_gives_way_to_one_that_can_be_bought() {
        // Opening on a sold-out colour leaves every size chip disabled and the CTA dead, with
        // nothing saying another colour is buyable.
        let variants = [variant(sand, small, stock: 0), variant(sand, medium, stock: 0), variant(navy, medium)]

        let selection = VariantSelection(variants: variants, preferredVariant: variant(sand, small, stock: 0))

        XCTAssertEqual(selection.selectedColour?.id, navy.id)
    }

    func test_the_first_colour_is_seeded_when_no_colour_has_stock() {
        let variants = [variant(sand, medium, stock: 0), variant(navy, medium, stock: 0)]

        let selection = VariantSelection(variants: variants, preferredVariant: nil)

        XCTAssertEqual(selection.selectedColour?.id, sand.id)
    }

    func test_sole_size_is_auto_selected() {
        let variants = [variant(sand, medium)]

        let selection = VariantSelection(variants: variants, preferredVariant: nil)

        XCTAssertEqual(selection.selectedSize?.id, medium.id)
    }

    func test_sizeless_product_selects_no_size_and_offers_none() {
        let variants = [variant(sand, nil)]

        let selection = VariantSelection(variants: variants, preferredVariant: nil)

        XCTAssertNil(selection.selectedSize)
        XCTAssertTrue(selection.sizes.isEmpty)
    }

    // MARK: - Availability

    func test_size_is_out_of_stock_when_only_another_colour_stocks_it() {
        // The defect in one assertion: Sand/Medium is sold out, Navy/Medium is not. Availability
        // that ignores the colour reports Medium as buyable in Sand.
        let variants = [
            variant(sand, small, stock: 4),
            variant(sand, medium, stock: 0),
            variant(navy, medium, stock: 7),
        ]

        let selection = VariantSelection(variants: variants, preferredVariant: variant(sand, small))

        XCTAssertEqual(selection.sizes.map(\.isInStock), [true, false])
    }

    func test_size_is_in_stock_when_the_selected_colour_stocks_it() {
        let variants = [
            variant(sand, small, stock: 0),
            variant(sand, medium, stock: 3),
        ]

        let selection = VariantSelection(variants: variants, preferredVariant: variant(sand, small))

        XCTAssertEqual(selection.sizes.map(\.isInStock), [false, true])
    }

    func test_colour_is_unavailable_only_when_no_variant_of_it_has_any_stock() {
        let variants = [
            variant(sand, small, stock: 0),
            variant(sand, medium, stock: 2),
            variant(navy, small, stock: 0),
            variant(navy, medium, stock: 0),
        ]

        let selection = VariantSelection(variants: variants, preferredVariant: nil)

        XCTAssertEqual(selection.colours.map(\.isAvailable), [true, false])
    }

    func test_size_grid_lists_only_the_sizes_of_the_selected_colour() {
        let variants = [
            variant(sand, small),
            variant(sand, medium),
            variant(navy, large),
        ]

        let selection = VariantSelection(variants: variants, preferredVariant: variant(navy, large))

        XCTAssertEqual(selection.sizes.map(\.size.id), [large.id])
    }

    // MARK: - Changing colour

    func test_changing_colour_recomputes_size_availability() {
        // The stale-chips defect: the marks have to move with the colour, not stay as first drawn.
        let variants = [
            variant(sand, small, stock: 0),
            variant(sand, medium, stock: 5),
            variant(navy, small, stock: 5),
            variant(navy, medium, stock: 0),
        ]
        let selection = VariantSelection(variants: variants, preferredVariant: variant(sand, small))

        let afterChange = selection.selecting(colourID: navy.id)

        XCTAssertEqual(selection.sizes.map(\.isInStock), [false, true])
        XCTAssertEqual(afterChange.sizes.map(\.isInStock), [true, false])
    }

    func test_changing_colour_keeps_the_size_when_the_new_colour_stocks_it() {
        let selection = VariantSelection(variants: matrix(), preferredVariant: nil)
            .selecting(sizeID: medium.id)

        let afterChange = selection.selecting(colourID: navy.id)

        XCTAssertEqual(afterChange.selectedSize?.id, medium.id)
    }

    func test_changing_colour_clears_the_size_when_the_new_colour_does_not_stock_it() {
        // Never snap to a nearest size — that is how the wrong garment reaches a bag.
        let variants = [
            variant(sand, small),
            variant(sand, medium),
            variant(navy, small),
            variant(navy, medium, stock: 0),
        ]
        let selection = VariantSelection(variants: variants, preferredVariant: nil)
            .selecting(sizeID: medium.id)

        let afterChange = selection.selecting(colourID: navy.id)

        XCTAssertNil(afterChange.selectedSize)
    }

    func test_changing_colour_auto_selects_the_sole_size_of_the_new_colour() {
        let variants = [
            variant(sand, small),
            variant(sand, medium),
            variant(navy, large),
        ]
        let selection = VariantSelection(variants: variants, preferredVariant: nil)

        let afterChange = selection.selecting(colourID: navy.id)

        XCTAssertEqual(afterChange.selectedSize?.id, large.id)
    }

    func test_a_colour_with_no_variant_in_the_current_size_is_still_selectable() {
        // Colour is the axis shoppers browse; gating it behind an incidental size is a dead end.
        let variants = [
            variant(sand, small),
            variant(sand, medium),
            variant(navy, large),
        ]
        let selection = VariantSelection(variants: variants, preferredVariant: nil)
            .selecting(sizeID: medium.id)

        let afterChange = selection.selecting(colourID: navy.id)

        XCTAssertEqual(afterChange.selectedColour?.id, navy.id)
    }

    func test_selecting_an_unknown_colour_leaves_the_selection_unchanged() {
        let selection = VariantSelection(variants: matrix(), preferredVariant: nil)

        let afterChange = selection.selecting(colourID: "teal")

        XCTAssertEqual(afterChange, selection)
    }

    func test_selecting_a_size_the_selected_colour_does_not_offer_leaves_the_selection_unchanged() {
        let variants = [
            variant(sand, small),
            variant(navy, large),
        ]
        let selection = VariantSelection(variants: variants, preferredVariant: nil)

        let afterChange = selection.selecting(sizeID: large.id)

        XCTAssertEqual(afterChange, selection)
    }

    // MARK: - Purchase state

    func test_purchase_state_needs_a_size_until_one_is_chosen() {
        let selection = VariantSelection(variants: matrix(), preferredVariant: nil)

        XCTAssertEqual(selection.purchaseState, .needsSize)
    }

    func test_purchase_state_is_out_of_stock_rather_than_needs_size_when_every_size_is_sold_out() {
        // Asking for a size among chips that are all disabled tells the shopper nothing.
        let variants = [variant(sand, small, stock: 0), variant(sand, medium, stock: 0)]

        let selection = VariantSelection(variants: variants, preferredVariant: nil)

        XCTAssertEqual(selection.purchaseState, .outOfStock)
    }

    func test_purchase_state_is_ready_when_the_selection_resolves_to_one_variant_in_stock() {
        let target = variant(sand, medium, id: "v-sand-m", stock: 3)
        let variants = [variant(sand, small), target, variant(navy, medium)]
        let selection = VariantSelection(variants: variants, preferredVariant: nil)

        let afterChange = selection.selecting(sizeID: medium.id)

        XCTAssertEqual(afterChange.purchaseState, .ready(target))
    }

    func test_purchase_state_is_out_of_stock_when_the_chosen_combination_has_none() {
        let variants = [
            variant(sand, small, stock: 5),
            variant(sand, medium, stock: 0),
        ]
        let selection = VariantSelection(variants: variants, preferredVariant: nil)

        let afterChange = selection.selecting(sizeID: medium.id)

        XCTAssertEqual(afterChange.purchaseState, .outOfStock)
    }

    func test_purchase_state_is_not_ready_without_a_server_variant_id() {
        // A variant synthesised from product-level fields has no server counterpart, so no cart
        // write can name it.
        let variants = [variant(sand, medium, id: nil, stock: 3)]

        let selection = VariantSelection(variants: variants, preferredVariant: nil)

        XCTAssertEqual(selection.purchaseState, .outOfStock)
    }

    func test_purchase_state_is_not_ready_when_the_selection_matches_more_than_one_variant() {
        // No axis to choose on, several variants behind it: the derivation declines rather than
        // claiming a variant it has not determined.
        let variants = [
            variant(sand, nil, id: "a", stock: 3),
            variant(sand, nil, id: "b", stock: 3),
        ]

        let selection = VariantSelection(variants: variants, preferredVariant: nil)

        XCTAssertEqual(selection.purchaseState, .outOfStock)
    }

    // MARK: - Display variant

    func test_display_variant_follows_the_colour_before_a_size_is_chosen() {
        let selection = VariantSelection(variants: matrix(), preferredVariant: nil)

        let afterChange = selection.selecting(colourID: navy.id)

        XCTAssertEqual(afterChange.displayVariant?.colour?.id, navy.id)
    }

    func test_display_variant_is_the_exact_variant_once_a_size_is_chosen() {
        let target = variant(sand, medium, id: "v-sand-m")
        let variants = [variant(sand, small, id: "v-sand-s"), target]
        let selection = VariantSelection(variants: variants, preferredVariant: nil)

        let afterChange = selection.selecting(sizeID: medium.id)

        XCTAssertEqual(afterChange.displayVariant, target)
    }

    // MARK: - Helpers

    private let sand = Product.Colour.fixture(id: "sand", name: "Sand")
    private let navy = Product.Colour.fixture(id: "navy", name: "Navy")
    private let small = Product.ProductSize.fixture(id: "s", value: "S")
    private let medium = Product.ProductSize.fixture(id: "m", value: "M")
    private let large = Product.ProductSize.fixture(id: "l", value: "L")

    /// Sand and Navy, each in Small and Medium, everything in stock.
    private func matrix() -> [Product.Variant] {
        [
            variant(sand, small),
            variant(sand, medium),
            variant(navy, small),
            variant(navy, medium),
        ]
    }

    private func variant(
        _ colour: Product.Colour,
        _ size: Product.ProductSize?,
        id: String? = "variant-id",
        stock: Int = 1
    ) -> Product.Variant {
        .fixture(id: id, sku: "\(colour.id)-\(size?.id ?? "none")", size: size, colour: colour, stock: stock)
    }
}
