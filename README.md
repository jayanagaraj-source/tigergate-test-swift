# tigergate-test-swift

Deliberately vulnerable Swift/iOS fixture for validating TigerGate SAST, SCA, secrets, IaC, and SBOM
detection. See [SECURITY_FIXTURES.md](SECURITY_FIXTURES.md) for what is planted where and the expected results.

```bash
docker run --rm -e TIGERGATE_API_KEY -v "$PWD":/src -w /src \
  tigergate/tigergate-cli:latest scan --type all --scan-scope full
```
