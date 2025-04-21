import BFFGraph
import Model

extension BFFGraphApi.ColourFragment {
    func convertToColour() -> Product.Colour {
        Product.Colour(
            id: id,
            swatch: swatch?.fragments.imageFragment.convertToImage(),
            name: name,
            media: media?.compactMap { $0.fragments.mediaFragment.convertToMedia() }
        )
    }
}
