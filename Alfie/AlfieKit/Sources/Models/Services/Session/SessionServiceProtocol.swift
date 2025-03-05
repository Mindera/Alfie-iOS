import Combine
import Foundation

public protocol SessionServiceProtocol {
    var isUserLoggedPublisher: AnyPublisher<Bool, Never> { get }

    func loginUser()
    func logoutUser()
}
