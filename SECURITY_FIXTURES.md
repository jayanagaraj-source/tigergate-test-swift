# Deliberately insecure test fixtures

This repository exists to validate TigerGate's SCA, SAST, secret, IaC, and SBOM detection.
It deliberately contains outdated dependencies, unsafe code, fake credentials, and insecure
infrastructure. **Do not deploy, build for release, or copy these patterns.**

All secret values are randomly generated and have never been valid for any service.
Expect GitHub push protection to flag them on push; mark them as "used in tests".

The Swift code targets iOS/macOS frameworks (UIKit, WebKit, CommonCrypto) and is written to be
scanned, not compiled on Linux.

## Where each fixture lives

| Scan | Files |
|---|---|
| SAST | `src/**/*.swift`, `src/Resources/Info.plist`, rules in `semgrep-rules/swift-security.yml` |
| Secrets | `src/Secrets/`, `.env.production`, `src/Resources/fixture_apns_key.pem`, `src/Resources/Info.plist` |
| SCA | `Package.resolved` (SwiftPM), `Podfile.lock` (CocoaPods), `Cartfile.resolved` (Carthage), `terraform/versions.tf` |
| SBOM | same manifests as SCA |
| IaC | `terraform/`, `kubernetes/`, `Dockerfile`, `docker-compose.yml` |

## SAST coverage (`src/`)

| File | Vulnerabilities |
|---|---|
| `Database/SQLInjection.swift` | CWE-89 SQL injection via `sqlite3_exec` / `sqlite3_prepare_v2` |
| `System/CommandInjection.swift` | CWE-78 command injection, CWE-22 path traversal, CWE-134 format string, CWE-917 NSPredicate/NSExpression injection, CWE-1333 ReDoS, CWE-377 predictable temp file |
| `Crypto/WeakCrypto.swift` | CWE-328 MD5/SHA-1, CWE-327 DES/ECB, CWE-329 static IV, CWE-916 weak PBKDF2, CWE-338 insecure RNG, CWE-321 hardcoded key |
| `Network/InsecureTransport.swift` | CWE-295 trust-all TLS, CWE-319 cleartext HTTP, CWE-918 SSRF, CWE-601 open redirect, CWE-798 hardcoded Basic auth |
| `Web/WebViewInjection.swift` | CWE-79 XSS via `loadHTMLString` / `evaluateJavaScript`, file-URL access, open JS windows, JS-bridge expression evaluation |
| `Storage/InsecureStorage.swift` | Secrets in UserDefaults, `kSecAttrAccessibleAlways`, no file protection / 0o777, CWE-532 sensitive logging |
| `Serialization/InsecureDeserialization.swift` | CWE-502 `NSKeyedUnarchiver` without secure coding, CWE-611 XXE |
| `Auth/AuthWeaknesses.swift` | CWE-798 backdoor credentials, CWE-208 timing-unsafe compare, CWE-347 unverified JWT, biometric auth not bound to Keychain |
| `Resources/Info.plist` | ATS disabled (`NSAllowsArbitraryLoads`, TLS 1.0 exception) |

TigerGate's default SAST rulesets (`p/default`, `p/owasp-top-ten`, `p/security-audit`) include only
2 Swift rules, so most of the above is detected **only** through the custom ruleset enabled by
`sast.custom_rules_dir` in `.tigergate.yml`.

## Expected baseline

Measured with the engines bundled in `tigergate/tigergate-cli:latest`
(semgrep 1.176.1, trivy 0.74.0, gitleaks 8.21.2, syft 1.51.1, grype 0.118.0). Counts drift as
rulesets and advisory databases update — treat a **large drop** as a detection regression.

| Scan | Engine | Expected |
|---|---|---|
| SAST | semgrep, default rulesets + `semgrep-rules/` | ~126 findings; 68 from the 28 custom Swift rules (all 28 fire) |
| Secrets | gitleaks | ~24 findings across 13 rule types (AWS, GitHub, Slack, Stripe, SendGrid, GCP, npm, JWT, private key…) |
| Secrets | trivy | ~20 findings |
| SCA | trivy (`Package.resolved`) | ~27 vulns: 2 critical, 13 high, 11 medium, 1 low across 8 packages |
| SCA | grype | ~4 matches (grype's Swift advisory coverage is thinner than trivy's) |
| SBOM | syft CycloneDX | ~35 components: 12 SwiftPM, 17 CocoaPods, GitHub Actions |
| IaC | trivy misconfig | ~101 failures: 9 critical, 33 high |

Known limits:
- CocoaPods and Carthage dependencies appear in the SBOM but produce **no** vulnerabilities: the advisory databases have no CocoaPods data.
- `docker-compose.yml` is not evaluated by trivy's misconfiguration scanner.
- The quality gate is **expected to fail**. A passing gate on this repo means something stopped detecting.
