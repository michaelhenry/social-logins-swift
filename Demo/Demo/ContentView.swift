import ComposableArchitecture
import Foundation
import Perception
import SocialLoginsFeature
import SwiftUI

struct ContentView: View {
    @Perception.Bindable
    private var store: StoreOf<SocialLoginsFeature>

    init(store: StoreOf<SocialLoginsFeature>) {
        self.store = store
    }

    var body: some View {
        WithPerceptionTracking {
            List {
                if let _ = store.googleIdToken {
                    Button("Google Logout") {
                        store.send(.logoutGoogle)
                    }
                } else {
                    Button("Google Login") {
                        store.send(.loginWithGoogle)
                    }
                }

                if let _ = store.facebookIdToken {
                    Button("Facebook Logout") {
                        store.send(.logoutFacebook)
                    }
                } else {
                    Button("Facebook Login") {
                        store.send(.loginWithFacebook(.init(nonce: "123")))
                    }
                }

                if let _ = store.appleIdToken {
                    Button("Apple Logout") {
                        store.send(.logoutApple)
                    }
                } else {
                    Button("Apple Login") {
                        store.send(.loginWithApple(.init(nonce: "123")))
                    }
                }
            }
        }
    }
}
