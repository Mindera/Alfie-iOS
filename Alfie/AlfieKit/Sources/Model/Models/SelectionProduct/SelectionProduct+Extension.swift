import Foundation

<<<<<<<< HEAD:Alfie/Alfie/Extensions/SelectedProduct+Extension.swift
extension SelectedProduct {
========
public extension SelectionProduct {
>>>>>>>> 6b296b6 (ALFMOB-184: Refactor iOS Application to Feature-Based Modular Architecture):Alfie/AlfieKit/Sources/Model/Models/SelectionProduct/SelectionProduct+Extension.swift
    var sizeText: String {
        var sizeValue: String = ""
        if let size {
            sizeValue = size.value
            if let scale = size.scale {
                sizeValue += " \(scale)"
            }
        }

        return sizeValue
    }

    var priceType: PriceType {
        guard let salePreviousPrice = price.was else {
            return .default(price: price.amount.amountFormatted)
        }
        return .sale(
            fullPrice: salePreviousPrice.amountFormatted,
            finalPrice: price.amount.amountFormatted
        )
    }
}
