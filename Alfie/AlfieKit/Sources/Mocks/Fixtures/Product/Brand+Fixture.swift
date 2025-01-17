import Foundation
import Models

extension Brand {
    public static let fixtures: [Brand] = [
        Brand.fixture(name: "12 South", slug: "12-south"),
        Brand.fixture(name: "Academy Brand", slug: "academy-brand"),
        Brand.fixture(name: "Angelcare", slug: "angelcare"),
        Brand.fixture(name: "Chanel", slug: "chanel"),
        Brand.fixture(name: "Calvin Klein", slug: "calvin-klein"),
        Brand.fixture(name: "Camilla and Marc", slug: "camilla-and-marc"),
        Brand.fixture(name: "Cartier", slug: "cartier"),
        Brand.fixture(name: "Chiara Ferragni", slug: "chiara-ferragni"),
        Brand.fixture(name: "Madewell", slug: "madewell"),
        Brand.fixture(name: "Rado", slug: "rado"),
        Brand.fixture(name: "Ralph Lauren", slug: "ralph-lauren"),
        Brand.fixture(name: "Ray Ban", slug: "ray-ban"),
        Brand.fixture(name: "Revlon", slug: "revlon"),
        Brand.fixture(name: "Samsonite", slug: "samsonite"),
        Brand.fixture(name: "Samsung Electronics", slug: "samsung-electronics"),
    ]

    public static func fixture(id: String = UUID().uuidString,
                               name: String = "",
                               slug: String = "") -> Brand {
        .init(id: id,
              name: name,
              slug: slug)
    }
}
