// FIXTURE: CWE-312/313/532 insecure data storage & logging. Deliberately vulnerable — do not reuse.
import Foundation
import Security
import os.log
#if canImport(UIKit)
import UIKit
#endif

final class CredentialStore {
    // VULN: secrets in UserDefaults (plaintext plist)
    func save(password: String, apiKey: String, secretToken: String, privateKey: String) {
        UserDefaults.standard.set(password, forKey: "password")
        UserDefaults.standard.set(apiKey, forKey: "api_key")
        UserDefaults.standard.set(secretToken, forKey: "secret_token")
        UserDefaults.standard.set(privateKey, forKey: "private_key")
    }

    // VULN: Keychain item accessible always, not device-bound, synchronizable
    func saveToKeychain(token: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "auth_token",
            kSecValueData as String: Data(token.utf8),
            kSecAttrAccessible as String: kSecAttrAccessibleAlways,
            kSecAttrSynchronizable as String: kCFBooleanTrue as Any,
        ]
        SecItemAdd(query as CFDictionary, nil)
    }

    // VULN: plaintext credentials written to disk without data protection
    func dumpToDisk(username: String, password: String) throws {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("credentials.txt")
        try "\(username):\(password)".write(to: url, atomically: true, encoding: .utf8)
        try FileManager.default.setAttributes([.protectionKey: FileProtectionType.none,
                                               .posixPermissions: 0o777], ofItemAtPath: url.path)
    }

    // VULN: sensitive data in logs (CWE-532)
    func login(username: String, password: String, cardNumber: String) {
        NSLog("Login attempt user=%@ password=%@", username, password)
        print("DEBUG password: \(password) card: \(cardNumber)")
        os_log("auth token %{public}@", log: .default, type: .info, password)
    }

    // VULN: sensitive responses cached on disk
    func cachingSession() -> URLSession {
        let config = URLSessionConfiguration.default
        config.urlCache = URLCache(memoryCapacity: 0, diskCapacity: 100_000_000)
        config.requestCachePolicy = .returnCacheDataElseLoad
        return URLSession(configuration: config)
    }

    // VULN: sensitive data on general pasteboard
    #if canImport(UIKit)
    func copyOTP(_ otp: String) { UIPasteboard.general.string = otp }
    #endif
}
