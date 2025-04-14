import Common
import SharedUI
import SwiftUI

struct DeepLinkDemoView: View {
    @State private var customWebPath: String = "sale"
    private let baseUrl = URL.fromString("alfie://\(ThemedURL.hostWithPortComponent)/")
    private var webViewUrl: URL {
        baseUrl.appending(path: customWebPath)
    }

    private enum TabLinks: String, CaseIterable {
        case home
        case shop
        case bag
        case wishlist
        case account

        var label: String {
            switch self {
            case .home:
                return "Home"
            case .shop:
                return "Shop"
            case .bag:
                return "Bag"
            case .wishlist:
                return "Wishlist"
            case .account:
                return "Account"
            }
        }
    }

    private enum CategoriesLinks: String, CaseIterable {
        case designer
        case women
        case men
        case shoes
        case bagsAndAccessories = "bags-and-accessories"
        case beauty
        case kids
        case homeAndFood = "home-and-food"
        case electrical
        case sale

        var label: String {
            switch self {
            case .designer:
                return "Designer"
            case .women:
                return "Women"
            case .men:
                return "Men"
            case .shoes:
                return "Shoes"
            case .bagsAndAccessories:
                return "Bags & Accessories"
            case .beauty:
                return "Beauty"
            case .kids:
                return "Kids"
            case .homeAndFood:
                return "Home & Food"
            case .electrical:
                return "Electrical"
            case .sale:
                return "Sale"
            }
        }

        var subCategories: [SubCategoriesLinks] {
            // swiftlint:disable vertical_whitespace_between_cases
            switch self {
            case .women:
                return [.dresses]
            default:
                return []
            }
            // swiftlint:enable vertical_whitespace_between_cases
        }
    }

    private enum SubCategoriesLinks: String {
        case dresses

        var label: String {
            switch self {
            case .dresses:
                return "Dresses"
            }
        }

        var prefix: String {
            switch self {
            case .dresses:
                return "clothing"
            }
        }

        var subSubCategories: [SubSubCategoriesLinks] {
            switch self {
            case .dresses:
                return [.maxiDresses]
            }
        }
    }

    private enum SubSubCategoriesLinks: String {
        case maxiDresses = "maxi-dresses"

        var label: String {
            switch self {
            case .maxiDresses:
                return "Maxi Dresses"
            }
        }
    }

    private enum ProductLinks: String, CaseIterable {
        case earthPolo = "polo-ralph-lauren-the-earth-polo-23837841"
        case sleeveTshirt = "polo-ralph-lauren-ao-short-sleeve-t-shirt-26146503"

        var label: String {
            switch self {
            case .earthPolo:
                return "The Earth Polo"
            case .sleeveTshirt:
                return "Ao Short Sleeve T-shirt"
            }
        }

        var parameters: [URLQueryItem] {
            // swiftlint:disable vertical_whitespace_between_cases
            switch self {
            case .earthPolo:
                return [URLQueryItem(name: "nav", value: "885035")]
            case .sleeveTshirt:
                return []
            }
            // swiftlint:enable vertical_whitespace_between_cases
        }
    }

    private enum ShopLinks: String, CaseIterable {
        case shop = "shop"
        case brands = "brand"
        case services = "services/store-services"

        var label: String {
            switch self {
            case .shop:
                return "Shop"
            case .brands:
                return "Brands"
            case .services:
                return "Services"
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.space200) {
            mainTabsOptions
            categoriesOptions
            shopOptions
            productOptions
            customDeeplinkOption
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Spacing.space200)
    }

    // MARK: - Private

    @ViewBuilder private var mainTabsOptions: some View {
        DemoHelper.demoSectionHeader(title: "Main Tabs")
            .padding(.bottom, Spacing.space200)

        ForEach(TabLinks.allCases, id: \.self) { link in
            ThemedButton(text: link.label, style: .underline) {
                open(url: baseUrl.appending(component: link.rawValue))
            }
        }
    }

    @ViewBuilder private var categoriesOptions: some View {
        DemoHelper.demoSectionHeader(title: "Categories")
            .padding(.vertical, Spacing.space200)

        ForEach(CategoriesLinks.allCases, id: \.self) { category in
            categoryView(category)
        }
    }

    @ViewBuilder private var shopOptions: some View {
        DemoHelper.demoSectionHeader(title: "Shop")
            .padding(.vertical, Spacing.space200)

        ForEach(ShopLinks.allCases, id: \.self) { shopLink in
            ThemedButton(text: shopLink.label, style: .underline) {
                open(url: buildShopUrl(shopLink: shopLink))
            }
        }
    }

    @ViewBuilder private var productOptions: some View {
        DemoHelper.demoSectionHeader(title: "Product Details")
            .padding(.vertical, Spacing.space200)

        ForEach(ProductLinks.allCases, id: \.self) { product in
            ThemedButton(text: product.label, style: .underline) {
                open(url: buildUrl(product: product))
            }
        }
    }

    @ViewBuilder private var customDeeplinkOption: some View {
        DemoHelper.demoSectionHeader(title: "Custom")
            .padding(.vertical, Spacing.space200)

        HStack(alignment: .center, spacing: Spacing.space200) {
            VStack(alignment: .leading) {
                ThemedInput($customWebPath, title: "Path")
                    .textInputAutocapitalization(.never)

                HStack(spacing: Spacing.space050) {
                    Text.build(theme.font.small.normal("URL:"))
                        .foregroundStyle(Colors.primary.mono400)
                    Text.build(theme.font.small.normal(webViewUrl.absoluteString))
                        .foregroundStyle(Colors.primary.mono900)
                }
            }

            ThemedButton(text: "Open") {
                open(url: webViewUrl)
            }
        }
    }

    // MARK: - Categories

    @ViewBuilder
    private func categoryView(_ category: CategoriesLinks) -> some View {
        VStack(alignment: .leading, spacing: Spacing.space200) {
            ThemedButton(text: category.label, style: .underline) {
                open(url: buildUrl(category: category))
            }

            ForEach(category.subCategories, id: \.self) { subCategory in
                subCategoryView(subCategory, parentCategory: category)
            }
        }
    }

    @ViewBuilder
    private func subCategoryView(
        _ subCategory: SubCategoriesLinks,
        parentCategory: CategoriesLinks
    ) -> some View {
        VStack(alignment: .leading, spacing: Spacing.space200) {
            ThemedButton(text: subCategory.label, style: .underline) {
                open(url: buildUrl(category: parentCategory, subCategory: subCategory))
            }

            ForEach(subCategory.subSubCategories, id: \.self) { subSubCategory in
                subSubCategoryView(subSubCategory, parentSubCategory: subCategory, parentCategory: parentCategory)
            }
        }
        .padding(.leading, Spacing.space300)
    }

    @ViewBuilder
    private func subSubCategoryView(
        _ subSubCategory: SubSubCategoriesLinks,
        parentSubCategory: SubCategoriesLinks,
        parentCategory: CategoriesLinks
    ) -> some View {
        VStack(alignment: .leading, spacing: Spacing.space200) {
            ThemedButton(text: subSubCategory.label, style: .underline) {
                open(
                    url: buildUrl(
                        category: parentCategory,
                        subCategory: parentSubCategory,
                        subSubCategory: subSubCategory
                    )
                )
            }
        }
        .padding(.leading, Spacing.space300)
    }

    private func buildUrl(
        category: CategoriesLinks,
        subCategory: SubCategoriesLinks? = nil,
        subSubCategory: SubSubCategoriesLinks? = nil
    ) -> URL {
        var url = baseUrl.appending(component: category.rawValue)

        if let subCategory {
            let prefix = subCategory.prefix
            if !prefix.isEmpty {
                url = url.appending(component: prefix)
            }
            url = url.appending(component: subCategory.rawValue)
        }

        if let subSubCategory {
            url = url.appending(component: subSubCategory.rawValue)
        }

        return url
    }

    // MARK: - Products

    private func buildUrl(product: ProductLinks) -> URL {
        baseUrl
            .appending(component: "product")
            .appending(component: product.rawValue)
            .appending(queryItems: product.parameters)
    }

    // MARK: - Shop

    private func buildShopUrl(shopLink: ShopLinks) -> URL {
        baseUrl
            .appending(path: shopLink.rawValue)
    }

    // MARK: - Helper

    private func open(url: URL) {
        UIApplication.shared.open(url)
    }
}

#Preview {
    ScrollView {
        DeepLinkDemoView()
    }
}
