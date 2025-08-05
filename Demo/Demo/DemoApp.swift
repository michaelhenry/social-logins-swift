import FacebookCore
import GoogleSignIn
import SocialLoginsFeature
import SwiftUI

@main
struct DemoApp: App {
    init() {
        /// Facebook Login - Configs
        FacebookCore.Settings.shared.appID = "$(FB_APP_ID)"
        FacebookCore.Settings.shared.clientToken = "$(FB_CLIENT_TOKEN)"
        FacebookCore.Settings.shared.displayName = "$(FB_APP_DISPLAY_NAME)"

        /// Google Login - Configs
        let config = GIDConfiguration(clientID: "GOOGLE_CLIENT_ID", serverClientID: "GOOGLE_SERVER_CLIENT_ID")
        GIDSignIn.sharedInstance.configuration = config
    }

    var body: some Scene {
        WindowGroup {
            ContentView(store: .init(initialState: .init()) { SocialLoginsFeature()._printChanges() })
                .onOpenURL { url in
                    ApplicationDelegate.shared.application(
                        UIApplication.shared,
                        open: url,
                        sourceApplication: nil,
                        annotation: [UIApplication.OpenURLOptionsKey.annotation]
                    )
                    GIDSignIn.sharedInstance.handle(url)
                }
                .onAppear {
                    ApplicationDelegate.shared.application(UIApplication.shared, didFinishLaunchingWithOptions: nil)
                    GIDSignIn.sharedInstance.restorePreviousSignIn { _, _ in }
                }
        }
    }
}
