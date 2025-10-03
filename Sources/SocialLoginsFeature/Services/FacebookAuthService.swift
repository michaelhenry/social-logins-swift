import ComposableArchitecture
import FacebookCore
import FacebookLogin

public struct FacebookAuthService: Sendable {
    var login: @Sendable (FacebookAuthInput) async throws -> String
    var logout: @Sendable () async -> Void
}

public extension DependencyValues {
    var facebookAuthService: FacebookAuthService {
        get { self[FacebookAuthService.self] }
        set { self[FacebookAuthService.self] = newValue }
    }
}

extension FacebookAuthService: DependencyKey {
    /// For more info, please refer to https://developers.facebook.com/docs/facebook-login/limited-login/ios
    public static let liveValue: FacebookAuthService = .init(
        login: { input in
            try await withCheckedThrowingContinuation { continuation in
                DispatchQueue.main.async {
                    let loginManager = LoginManager()

                    // Ensure the configuration object is valid
                    guard let configuration = LoginConfiguration(
                        permissions: input.permissions,
                        tracking: .limited,
                        nonce: input.nonce
                    )
                    else {
                        return
                    }
                    loginManager.logIn(configuration: configuration) { result in
                        switch result {
                        case .cancelled, .failed:
                            // Handle error
                            break
                        case .success:
                            let tokenString = AuthenticationToken.current?.tokenString
                            continuation.resume(returning: tokenString ?? "")
                        }
                    }
                }
            }
        },
        logout: {
            LoginManager().logOut()
        }
    )
    public static var testValue: FacebookAuthService {
        Self(
            login: { _ in "" },
            logout: {}
        )
    }
}
