public struct FacebookAuthInput: Hashable, Sendable {
    var permissions: [String]
    var nonce: String

    public init(nonce: String, permissions: [String] = ["public_profile", "email"]) {
        self.permissions = permissions
        self.nonce = nonce
    }
}
