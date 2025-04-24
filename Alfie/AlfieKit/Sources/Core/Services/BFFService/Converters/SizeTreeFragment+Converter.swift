import BFFGraphAPI
import Models

extension BFFGraphAPI.SizeTreeFragment {
    func convertToSize() -> Product.ProductSize {
        Product.ProductSize(
            id: id,
            value: value,
            scale: scale,
            description: description,
            sizeGuide: sizeGuide?.convertToSizeGuide()
        )
    }
}

extension BFFGraphAPI.SizeTreeFragment.SizeGuide {
    func convertToSizeGuide() -> Product.SizeGuide {
        Product.SizeGuide(
            id: id,
            name: name,
            description: description,
            sizes: sizes.map { $0.convertToSizeGuideSizes() }
        )
    }
}

extension BFFGraphAPI.SizeTreeFragment.SizeGuide.Size {
    func convertToSizeGuideSizes() -> Product.ProductSize {
        Product.ProductSize(
            id: id,
            value: value,
            scale: scale,
            description: description,
            sizeGuide: nil
        )
    }
}
