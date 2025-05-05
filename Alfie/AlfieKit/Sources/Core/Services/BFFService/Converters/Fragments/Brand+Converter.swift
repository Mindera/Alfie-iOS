import BFFGraph
import Model

extension BFFGraphAPI.BrandFragment {
    func convertToBrand() -> Brand {
        Brand(id: id, name: name, slug: slug)
    }
}
