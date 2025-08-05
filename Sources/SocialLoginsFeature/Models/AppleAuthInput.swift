import AuthenticationServices

public struct AppleAuthInput: Hashable {
    var scopes: [ASAuthorization.Scope]
    var nonce: String?

    public init(nonce: String? = nil, scopes: [ASAuthorization.Scope] = [.email, .fullName]) {
        self.nonce = nonce
        self.scopes = scopes
    }
}
