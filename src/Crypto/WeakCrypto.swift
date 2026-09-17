// FIXTURE: CWE-327/328/329/330/338 weak cryptography. Deliberately vulnerable — do not reuse.
import Foundation
import CommonCrypto
import CryptoKit

enum WeakCrypto {
    // VULN: hardcoded symmetric key and static IV (CWE-321, CWE-329)
    static let hardcodedKey = "0123456789abcdef"
    static let staticIV: [UInt8] = [UInt8](repeating: 0, count: kCCBlockSizeAES128)

    // VULN: MD5 for password hashing (CWE-328)
    static func md5(_ input: String) -> String {
        let data = Data(input.utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        data.withUnsafeBytes { _ = CC_MD5($0.baseAddress, CC_LONG(data.count), &digest) }
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    // VULN: SHA-1 (CWE-328)
    static func sha1(_ input: String) -> String {
        let data = Data(input.utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes { _ = CC_SHA1($0.baseAddress, CC_LONG(data.count), &digest) }
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    // VULN: CryptoKit's explicitly-insecure hashes
    static func insecureDigests(_ data: Data) -> (String, String) {
        (Insecure.MD5.hash(data: data).description, Insecure.SHA1.hash(data: data).description)
    }

    // VULN: DES in ECB mode with hardcoded key (CWE-327)
    static func desECBEncrypt(_ plaintext: Data) -> Data {
        var out = Data(count: plaintext.count + kCCBlockSizeDES)
        var moved = 0
        let outCount = out.count
        _ = out.withUnsafeMutableBytes { outPtr in
            plaintext.withUnsafeBytes { inPtr in
                CCCrypt(CCOperation(kCCEncrypt), CCAlgorithm(kCCAlgorithmDES),
                        CCOptions(kCCOptionECBMode | kCCOptionPKCS7Padding),
                        hardcodedKey, kCCKeySizeDES, nil,
                        inPtr.baseAddress, plaintext.count,
                        outPtr.baseAddress, outCount, &moved)
            }
        }
        return out.prefix(moved)
    }

    // VULN: AES with zero IV and hardcoded key
    static func aesStaticIV(_ plaintext: Data) -> Data {
        var out = Data(count: plaintext.count + kCCBlockSizeAES128)
        var moved = 0
        let outCount = out.count
        _ = out.withUnsafeMutableBytes { outPtr in
            plaintext.withUnsafeBytes { inPtr in
                CCCrypt(CCOperation(kCCEncrypt), CCAlgorithm(kCCAlgorithmAES),
                        CCOptions(kCCOptionPKCS7Padding),
                        hardcodedKey, kCCKeySizeAES128, staticIV,
                        inPtr.baseAddress, plaintext.count,
                        outPtr.baseAddress, outCount, &moved)
            }
        }
        return out.prefix(moved)
    }

    // VULN: PBKDF2 with 1 iteration and static salt (CWE-916)
    static func weakKDF(password: String) -> [UInt8] {
        var derived = [UInt8](repeating: 0, count: 32)
        let salt: [UInt8] = Array("static-salt".utf8)
        CCKeyDerivationPBKDF(CCPBKDFAlgorithm(kCCPBKDF2), password, password.utf8.count,
                             salt, salt.count, CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA1),
                             1, &derived, derived.count)
        return derived
    }

    // VULN: non-CSPRNG used for security tokens (CWE-338)
    static func sessionToken() -> String {
        let n = arc4random()
        let m = Int.random(in: 0..<Int.max)
        return "\(n)-\(m)-\(rand())"
    }

    static func resetCode() -> Int {
        Int(arc4random_uniform(999_999))
    }

    static func otpSeed() -> UInt32 {
        srand48(Int(Date().timeIntervalSince1970))
        return UInt32(random())
    }
}
