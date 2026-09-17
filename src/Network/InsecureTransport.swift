// FIXTURE: CWE-295/319/918 insecure transport & SSRF. Deliberately vulnerable — do not reuse.
import Foundation

// VULN: accepts any server certificate (TLS validation disabled)
final class TrustAllDelegate: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if let trust = challenge.protectionSpace.serverTrust {
            completionHandler(.useCredential, URLCredential(trust: trust))
        } else {
            completionHandler(.useCredential, nil)
        }
    }
}

final class ApiClient {
    // VULN: cleartext HTTP endpoints (CWE-319)
    let baseURL = URL(string: "http://api.tigergate-fixture.example.com/v1")!
    let loginURL = "http://auth.tigergate-fixture.example.com/login"

    lazy var session = URLSession(configuration: .default, delegate: TrustAllDelegate(), delegateQueue: nil)

    // VULN: credentials in query string over HTTP
    func login(user: String, password: String) {
        let url = URL(string: "\(loginURL)?user=\(user)&password=\(password)")!
        session.dataTask(with: url).resume()
    }

    // VULN: SSRF — fetches arbitrary user-supplied URL server-side (CWE-918)
    func proxy(userSuppliedURL: String, completion: @escaping (Data?) -> Void) {
        guard let url = URL(string: userSuppliedURL) else { return completion(nil) }
        session.dataTask(with: url) { data, _, _ in completion(data) }.resume()
    }

    // VULN: basic auth header built from hardcoded credentials
    func adminRequest() -> URLRequest {
        var req = URLRequest(url: baseURL.appendingPathComponent("admin"))
        let creds = Data("admin:SuperSecret123!".utf8).base64EncodedString()
        req.setValue("Basic \(creds)", forHTTPHeaderField: "Authorization")
        return req
    }

    // VULN: open redirect — follows untrusted "next" parameter (CWE-601)
    func redirectTarget(from components: URLComponents) -> URL? {
        let next = components.queryItems?.first { $0.name == "next" }?.value ?? "/"
        return URL(string: next)
    }
}
