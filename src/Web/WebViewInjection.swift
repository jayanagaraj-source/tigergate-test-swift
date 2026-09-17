// FIXTURE: CWE-79/749 WebView XSS & JS bridge exposure. Deliberately vulnerable — do not reuse.
#if canImport(WebKit)
import Foundation
import WebKit

final class WebViewFactory: NSObject, WKScriptMessageHandler {
    func makeWebView() -> WKWebView {
        let prefs = WKPreferences()
        // VULN: JS may open windows without user interaction.
        // Capitalised form matches the semgrep registry rule's pattern verbatim.
        prefs.JavaScriptCanOpenWindowsAutomatically = true
        prefs.javaScriptEnabled = true

        let config = WKWebViewConfiguration()
        config.preferences = prefs
        // VULN: file:// pages may read other local files
        config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        config.setValue(true, forKey: "allowUniversalAccessFromFileURLs")
        // VULN: native bridge exposed to any loaded page
        config.userContentController.add(self, name: "nativeBridge")
        return WKWebView(frame: .zero, configuration: config)
    }

    // VULN: reflected XSS — untrusted input into HTML
    func renderProfile(in webView: WKWebView, displayName: String) {
        let html = "<html><body><h1>Welcome \(displayName)</h1></body></html>"
        webView.loadHTMLString(html, baseURL: nil)
    }

    // VULN: JS injection via evaluateJavaScript with untrusted data
    func search(in webView: WKWebView, query: String) {
        webView.evaluateJavaScript("runSearch('\(query)')", completionHandler: nil)
    }

    // VULN: loads arbitrary deep-link URL, including file:// and javascript:
    func open(deepLink: URL, in webView: WKWebView) {
        let target = URLComponents(url: deepLink, resolvingAgainstBaseURL: false)?
            .queryItems?.first { $0.name == "url" }?.value ?? ""
        webView.load(URLRequest(url: URL(string: target)!))
    }

    // VULN: bridge executes whatever the page sends
    func userContentController(_ controller: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let body = message.body as? [String: String], let cmd = body["exec"] else { return }
        _ = NSExpression(format: cmd).expressionValue(with: nil, context: nil)
    }
}
#endif
