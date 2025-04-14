import Combine
import Foundation

public protocol SessionServiceProtocol {
    var isUserSignedInPublisher: AnyPublisher<Bool, Never> { get }

    func signInUser()
    func signOutUser()
}
