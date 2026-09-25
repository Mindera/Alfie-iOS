import Combine
import Foundation
import Model

public actor LocalCartService: CartServiceProtocol {
    private static let cartId = "local-cart"

    private let userDefaults: UserDefaultsProtocol
    private let storageKey: String
    private let cartSubject = CurrentValueSubject<Cart?, Never>(nil)

    public nonisolated var cart: Cart? { cartSubject.value }
    public nonisolated var cartPublisher: AnyPublisher<Cart?, Never> { cartSubject.eraseToAnyPublisher() }

    public init(userDefaults: UserDefaultsProtocol, storageKey: String) {
        self.userDefaults = userDefaults
        self.storageKey = storageKey
    }

    public func add(line: CartLineInput) async throws {
        var lines = storedLines
        if let index = lines.firstIndex(where: { $0.variantId == line.variantId }) {
            lines[index].quantity += line.quantity
        } else {
            lines.append(PersistedCartLineDTO(input: line))
        }
        save(lines)
    }

    public func fetch() async throws {
        publish(storedLines)
    }

    public func remove(lineId: String) async throws {
        var lines = storedLines
        guard let index = lines.firstIndex(where: { $0.id == lineId }) else {
            throw BFFRequestError(type: .generic)
        }
        lines.remove(at: index)
        save(lines)
    }

    public func setQuantity(lineId: String, to quantity: Int) async throws {
        guard quantity > 0 else {
            try await remove(lineId: lineId)
            return
        }

        var lines = storedLines
        guard let index = lines.firstIndex(where: { $0.id == lineId }) else {
            throw BFFRequestError(type: .generic)
        }
        lines[index].quantity = quantity
        save(lines)
    }

    public func discardCart() async {
        userDefaults.remove(for: storageKey)
        cartSubject.send(nil)
    }

    private var storedLines: [PersistedCartLineDTO] {
        guard
            let data: Data = userDefaults.value(for: storageKey),
            let lines = try? JSONDecoder().decode([PersistedCartLineDTO].self, from: data)
        else {
            return []
        }
        return lines
    }

    private func save(_ lines: [PersistedCartLineDTO]) {
        if let data = try? JSONEncoder().encode(lines) {
            userDefaults.set(data, for: storageKey)
        }
        publish(lines)
    }

    private func publish(_ lines: [PersistedCartLineDTO]) {
        guard !lines.isEmpty else {
            cartSubject.send(nil)
            return
        }

        let cartLines = lines.map(\.cartLine)
        let subtotal = Self.total(of: cartLines.map(\.lineTotal))
        cartSubject.send(Cart(id: Self.cartId, lines: cartLines, subtotal: subtotal, grandTotal: subtotal))
    }

    private static func total(of amounts: [Money?]) -> Money? {
        let known = amounts.compactMap { $0 }
        guard
            known.count == amounts.count,
            let currencyCode = known.first?.currencyCode,
            known.allSatisfy({ $0.currencyCode == currencyCode })
        else {
            return nil
        }
        return Money.local(minorUnits: known.reduce(0) { $0 + $1.amount }, currencyCode: currencyCode)
    }
}

struct PersistedCartLineDTO: Codable, Hashable {
    let productId: String
    let variantId: String
    let sku: String?
    let slug: String?
    let name: String?
    let imageURL: URL?
    let imageAltText: String?
    let unitPrice: PersistedMoneyDTO?
    var quantity: Int

    var id: String { variantId }

    init(input: CartLineInput) {
        productId = input.productId
        variantId = input.variantId
        sku = input.sku
        slug = input.slug
        name = input.name
        imageURL = input.imageURL
        imageAltText = input.imageAltText
        unitPrice = input.unitPrice.map(PersistedMoneyDTO.init(from:))
        quantity = input.quantity
    }

    var cartLine: CartLine {
        let unitPrice = unitPrice?.domain
        return CartLine(
            id: id,
            productId: productId,
            variantId: variantId,
            sku: sku,
            slug: slug,
            name: name,
            imageURL: imageURL,
            imageAltText: imageAltText,
            quantity: quantity,
            unitPrice: unitPrice,
            lineTotal: unitPrice.map { .local(minorUnits: $0.amount * quantity, currencyCode: $0.currencyCode) }
        )
    }
}

private extension Money {
    static func local(minorUnits: Int, currencyCode: String) -> Money {
        let digits = CurrencyFormatter.minorUnitDigits(for: currencyCode)
        let major = Decimal(minorUnits) / pow(Decimal(10), digits)
        return Money(
            currencyCode: currencyCode,
            amount: minorUnits,
            amountFormatted: CurrencyFormatter.string(amount: major, currencyCode: currencyCode)
        )
    }
}
