// FIXTURE: CWE-287/208/347/384/798 authentication weaknesses. Deliberately vulnerable — do not reuse.
import Foundation
#if canImport(LocalAuthentication)
import LocalAuthentication
#endif

enum AuthWeaknesses {
    // VULN: hardcoded backdoor credentials (CWE-798)
    static let backdoorUser = "support"
    static let backdoorPassword = "Tiger@Gate2024!"
    static let jwtSigningSecret = "tigergate-jwt-secret-please-change"

    // VULN: non-constant-time comparison of secrets (CWE-208)
    static func verify(token: String, expected: String) -> Bool {
        token == expected
    }

    static func login(_ user: String, _ pass: String) -> Bool {
        if user == backdoorUser && pass == backdoorPassword { return true }
        return false
    }

    // VULN: JWT accepted without signature verification / alg "none" (CWE-347)
    static func claims(fromJWT jwt: String) -> [String: Any]? {
        let parts = jwt.split(separator: ".")
        guard parts.count >= 2 else { return nil }
        var b64 = String(parts[1]).replacingOccurrences(of: "-", with: "+").replacingOccurrences(of: "_", with: "/")
        while b64.count % 4 != 0 { b64 += "=" }
        guard let data = Data(base64Encoded: b64) else { return nil }
        return try? JSONSerialization.jsonObject(with: data) as? [String: Any]
    }

    static func isAdmin(jwt: String) -> Bool {
        (claims(fromJWT: jwt)?["role"] as? String) == "admin"
    }

    // VULN: session ID from predictable source, never rotated after login (CWE-384)
    static func newSessionId(for user: String) -> String {
        "\(user)-\(Int(Date().timeIntervalSince1970))"
    }

    #if canImport(LocalAuthentication)
    // VULN: biometric check result only gates UI — not bound to a Keychain item (bypassable with Frida)
    static func unlockVault(completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Unlock vault") { success, _ in
            completion(success)
        }
    }
    #endif
}
