import ComposableArchitecture
import XCTest
@testable import SocialLoginsFeature

@MainActor
final class SocialLoginsFeatureTests: XCTestCase {
    func testGoogleLogin_Success() async {
        let store = TestStore(
            initialState: SocialLoginsFeature.State(),
            reducer: { SocialLoginsFeature() }
        )

        store.dependencies.googleAuthService.login = {
            "mock_google_token"
        }

        await store.send(.loginWithGoogle)
        await store.receive(.setGoogleIdToken("mock_google_token")) {
            $0.googleIdToken = "mock_google_token"
        }
    }

    func testLoginWithGoogle_Failure() async {
        struct DummyError: Error, LocalizedError {
            var errorDescription: String? { "Dummy error occurred" }
        }

        let store = TestStore(
            initialState: SocialLoginsFeature.State(),
            reducer: { SocialLoginsFeature() }
        )

        store.dependencies.googleAuthService.login = {
            throw DummyError()
        }

        await store.send(.loginWithGoogle)
        await store.receive(.errorReceived(.googleLoginError("Dummy error occurred")))
    }

    func testLogoutGoogle() async {
        let store = TestStore(
            initialState: SocialLoginsFeature.State(googleIdToken: "existing_token"),
            reducer: { SocialLoginsFeature() }
        )

        var didLogout = false
        store.dependencies.googleAuthService.logout = {
            didLogout = true
        }

        await store.send(.logoutGoogle)
        await store.receive(.setGoogleIdToken(nil)) {
            $0.googleIdToken = nil
        }

        XCTAssertTrue(didLogout)
    }

    func testLoginWithFacebook_Success() async {
        let store = TestStore(
            initialState: SocialLoginsFeature.State(),
            reducer: { SocialLoginsFeature() }
        )

        store.dependencies.facebookAuthService.login = { _ in
            "facebook_token"
        }

        await store.send(.loginWithFacebook(FacebookAuthInput(nonce: "123")))
        await store.receive(.setFacebookIdToken("facebook_token")) {
            $0.facebookIdToken = "facebook_token"
        }
    }

    func testLoginWithApple_Success() async {
        let store = TestStore(
            initialState: SocialLoginsFeature.State(),
            reducer: { SocialLoginsFeature() }
        )

        store.dependencies.appleAuthService.login = { _ in
            "apple_token"
        }

        await store.send(.loginWithApple(AppleAuthInput()))
        await store.receive(.setAppleIdToken("apple_token")) {
            $0.appleIdToken = "apple_token"
        }
    }
}
