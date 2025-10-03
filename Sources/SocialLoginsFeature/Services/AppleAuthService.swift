import AuthenticationServices
import ComposableArchitecture

public struct AppleAuthService: Sendable {
    var login: @Sendable (AppleAuthInput) async throws -> String
}

public extension DependencyValues {
    var appleAuthService: AppleAuthService {
        get { self[AppleAuthService.self] }
        set { self[AppleAuthService.self] = newValue }
    }
}

extension AppleAuthService: DependencyKey {
    /// For more info, please refer to https://developer.apple.com/documentation/AuthenticationServices/implementing-user-authentication-with-sign-in-with-apple
    public static let liveValue: AppleAuthService = .init(
        login: { input in
            let coordinator = AppleAuthCoordinator()
            return try await coordinator.startLogin(input: input)
        }
    )

    public static var testValue: AppleAuthService {
        Self(
            login: { _ in "" }
        )
    }
}

actor AppleAuthCoordinator {
    @MainActor
    private var handler: AppleAuthServiceHandler?

    @MainActor
    func startLogin(input: AppleAuthInput) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            let handler = AppleAuthServiceHandler(
                successBlock: { token in
                    continuation.resume(returning: token)
                    Task { @MainActor in await self.clear() }
                },
                errorBlock: { error in
                    continuation.resume(throwing: error)
                    Task { @MainActor in await self.clear() }
                }
            )
            self.handler = handler
            handler.showAppleLogin(input: input)
        }
    }

    @MainActor
    private func clear() async {
        handler = nil
    }
}

class AppleAuthServiceHandler: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    typealias SuccessBlock = (String) -> Void
    typealias ErrorBlock = (Error) -> Void

    private let successBlock: SuccessBlock
    private let errorBlock: ErrorBlock

    init(successBlock: @escaping SuccessBlock, errorBlock: @escaping ErrorBlock) {
        self.successBlock = successBlock
        self.errorBlock = errorBlock
        super.init()
    }

    fileprivate func showAppleLogin(input: AppleAuthInput) {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = input.scopes
        request.nonce = input.nonce
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self

        DispatchQueue.main.async {
            controller.performRequests()
        }
    }

    func presentationAnchor(for _: ASAuthorizationController) -> ASPresentationAnchor {
        guard let window = UIApplication.shared
            .connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)
        else {
            fatalError("No key window found for Apple Sign-In")
        }
        return window
    }

    func authorizationController(controller _: ASAuthorizationController, didCompleteWithError error: Error) {
        errorBlock(error)
    }

    func authorizationController(controller _: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIdCredential as ASAuthorizationAppleIDCredential:
            if let idTokenData = appleIdCredential.identityToken,
               let idToken = String(data: idTokenData, encoding: .utf8)
            {
                successBlock(idToken)
            } else {
                errorBlock(NSError(domain: "AppleAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to extract ID token"]))
            }
        case _ as ASPasswordCredential:
            break
        default:
            break
        }
    }
}
