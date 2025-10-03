import ComposableArchitecture
import SwiftUI
import WebKit

@Reducer
public struct SocialLoginsFeature: Sendable {
    @Dependency(\.googleAuthService) var googleAuthService: GoogleAuthService
    @Dependency(\.facebookAuthService) var facebookAuthService: FacebookAuthService
    @Dependency(\.appleAuthService) var appleAuthService: AppleAuthService

    @ObservableState
    public struct State: Equatable {
        public var googleIdToken: String?
        public var facebookIdToken: String?
        public var appleIdToken: String?

        public init(googleIdToken: String? = nil, facebookIdToken: String? = nil, appleIdToken: String? = nil) {
            self.googleIdToken = googleIdToken
            self.facebookIdToken = facebookIdToken
            self.appleIdToken = appleIdToken
        }
    }

    public enum Action: Equatable {
        case loginWithGoogle
        case logoutGoogle
        case setGoogleIdToken(String?)
        case loginWithFacebook(FacebookAuthInput)
        case setFacebookIdToken(String?)
        case logoutFacebook
        case loginWithApple(AppleAuthInput)
        case setAppleIdToken(String?)
        case logoutApple
        case errorReceived(SocialLoginError)
    }

    public enum SocialLoginError: Error, Equatable {
        case facebooLoginError(String)
        case appleLoginError(String)
        case googleLoginError(String)
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .loginWithGoogle:
                return .run { send in
                    do {
                        let idToken = try await googleAuthService.login()
                        await send(.setGoogleIdToken(idToken))
                    } catch {
                        await send(.errorReceived(.googleLoginError(error.localizedDescription)))
                    }
                }
            case .logoutGoogle:
                return .run { send in
                    await googleAuthService.logout()
                    await send(.setGoogleIdToken(nil))
                }
            case let .setGoogleIdToken(token):
                state.googleIdToken = token
            case let .loginWithFacebook(nonce):
                return .run { send in
                    do {
                        let token = try await facebookAuthService.login(nonce)
                        await send(.setFacebookIdToken(token))
                    } catch {
                        await send(.errorReceived(.facebooLoginError(error.localizedDescription)))
                    }
                }
            case let .setFacebookIdToken(token):
                state.facebookIdToken = token
            case .logoutFacebook:
                return .run { send in
                    await facebookAuthService.logout()
                    await send(.setFacebookIdToken(nil))
                }
            case let .loginWithApple(nonce):
                return .run { send in
                    do {
                        let token = try await appleAuthService.login(nonce)
                        await send(.setAppleIdToken(token))
                    } catch {
                        await send(.errorReceived(.appleLoginError(error.localizedDescription)))
                    }
                }
            case let .setAppleIdToken(token):
                state.appleIdToken = token
            case .logoutApple:
                state.appleIdToken = nil
            default:
                break
            }

            return .none
        }
    }

    public init() {}
}
