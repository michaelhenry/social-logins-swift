import ComposableArchitecture
import GoogleSignIn

public struct GoogleAuthService {
    var login: @Sendable () async throws -> String
    var logout: @Sendable () async -> Void
}

public extension DependencyValues {
    var googleAuthService: GoogleAuthService {
        get { self[GoogleAuthService.self] }
        set { self[GoogleAuthService.self] = newValue }
    }
}

extension GoogleAuthService: DependencyKey {
    /// For more info, please refer to https://developers.google.com/identity/sign-in/ios/start-integrating#swift-package-manager
    public static var liveValue: GoogleAuthService = .init(
        login: {
            try await withCheckedThrowingContinuation { continuation in
                DispatchQueue.main.async {
                    guard
                        let rootVC = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController
                    else { return }
                    GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { signInResult, error in
                        if let error {
                            continuation.resume(throwing: error)
                            return
                        }
                        guard let signInResult else { return }

                        signInResult.user.refreshTokensIfNeeded { user, error in
                            guard error == nil else { return }
                            guard let user = user else { return }
                            let idToken = user.idToken?.tokenString
                            print(user.accessToken.tokenString)
                            continuation.resume(returning: idToken ?? "")
                        }
                    }
                }
            }

        },
        logout: {
            GIDSignIn.sharedInstance.signOut()
        }
    )

    public static var testValue: GoogleAuthService {
        Self(
            login: { "" },
            logout: {}
        )
    }
}
