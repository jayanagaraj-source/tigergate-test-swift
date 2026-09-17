// FIXTURE: CWE-798 hardcoded secrets for secret-scanner validation.
// Every value below is RANDOMLY GENERATED and has never been valid for any service.
import Foundation

enum HardcodedSecrets {
    // AWS
    static let awsAccessKeyId = "AKIA2XZTOUKDQGNZB7E0"
    static let awsSecretAccessKey = "jHKvykE9lUceTXFKmPeCAX5psDAhLmdQlOFBW0lj"

    // GitHub
    static let githubToken = "ghp_k7n8RBLGfj7hTwYdbNJ2QoHEv8yDA8cErTxe"
    static let githubFineGrainedToken = "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"

    // Slack
    static let slackBotToken = "xoxb-774658367489-9503862409814-aOO5NCnsytiGv9ry2bkFBJZY"
    static let slackWebhookURL = "https://hooks.slack.com/services/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"

    // Payments / messaging / cloud
    static let stripeSecretKey = "sk_live_Z3L9X77jaEKs9QoTStUcOEcg"
    static let googleMapsAPIKey = "AIzaMQen8STjh1mK7wPTxPEq2SjU26HiDEx0jVc"
    static let sendgridAPIKey = "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"
    static let twilioAccountSid = "ACeae88fc3e0e5cf16700614da055edd7c"
    static let twilioAuthToken = "5b2bd5ff12d0e304f1a1703fe78dd3ad"
    static let npmToken = "npm_d1WKWpXCWcxFqMepxZflu8zk2Lwtbdo8su03"
    static let openAIKey = "sk-proj-m96mA0aWO1RYUzAjYx0ysOlvMtft3MN793DKO8H4X1NAdKyB"

    // Tokens & connection strings
    static let adminJWT = "eyJhbGciOiAiSFMyNTYiLCAidHlwIjogIkpXVCJ9.eyJzdWIiOiAiZml4dHVyZS11c2VyIiwgInJvbGUiOiAiYWRtaW4iLCAiaWF0IjogMTcwMDAwMDAwMH0.m1vgKGayWg5slSMtUBM-NhbANwq0EHIDuJRkozyXsHh"
    static let databaseURL = "postgres://tg_admin:Pr0dDbP4ssw0rd!@db.tigergate-fixture.example.com:5432/app"
    static let mongoURI = "mongodb+srv://root:M0ng0R00tPass@cluster0.tigergate-fixture.example.net/prod"

    // Private key
    static let apnsSigningKey = """
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEAlUiJFzH2o8aIbM2NYDMcD5l1V5MY57LdVi64spA9nZekxWu6
7Sl88oLNrdpUiQKt+Ei6fX9vXjpBkmiwz9Gt6uUO/pbs0vYrxXpES1IOowYXiH65
GIJ/YhZgcu7b+nnLTZBvcshPVmYdjDdrBT/jYPoSsObP1u9aeqg1HdTLmHoUoMSF
SOZgp+S13T7KQZDm5p4VqwFF1RaMNGYCKKt3W6Yx18lZjC/mo2ZZQQ0U7055jTXC
AYPdQGpobE4atKp8KBhk0uCFHYRw9xIP+wLzrZewkGy+UGO9GDMAwwHlZH7f/Tnp
KMG9JUBdfRmp9JsMEfzCX5JI4HJ3XOtzltRPuQIDAQABAoIBABYrTfSMXnDG6Haj
9fVN0cJ9SyBEv4OVG+qTCKm34vaW0QjibUGQEjafdzT0we4Q4E4JWuyNMrg/FYLN
GkjafiXue1ISjrvrg+eRNzgqSPMr0e3ax9kcdBdYdF1NHIzvbmIn620T0zhk9Mlg
Z3vBl55MtN7hgAcOx5SEi1LRSaTsbjgux4ngqRcHN7pytCS7vguDtTA5Rs371+0s
p2phczXVNceMRIbEBIfCmldK8u3mAyxu+L2WH2qVT32ozbD/9ImaLbuzOxI6Sewj
Dt1aVdi1cypT+IntZ3ucPaxKUn+yz2NZoAztQyGHoB25D4+fOYp9WeLngH2jiq6u
Tq9ltIkCgYEAwfRMouoDWj4l3Nriz5U6Hu+gV19LKlRxmGawcoo6sOSy60ov3EFq
u210zzl3yRNO9C0M4exBuWDVkXTgK3DRv4nVfYEVu91+uTr7s7EROs6BekYxPJgj
+hkD8GcDKwCZ4srFm65Rz4KvVWYBZp9EVjVbOC5ecnGoLCqbNQuL0eUCgYEAxQnz
jt2cyDaTrTxSNHog3VEMUsgQCezC8NtpSpIsZYdCuQULBuzF5cMIWttYlOvz61EV
eMmFSw9yshbyUx5mSet07/oBNt8cPilM7WUmao0d7B6eEeR+Rk3aIpz9zMNDZ1P2
+03sWyR5Lvvuf6EtfQOaSIS7inAawt9F79M5+UUCgYEAg9jV6/2Wr9cFmCA4BRMV
gog1AJAoIatr2UUdd4+eHDgrpKU26cySiLz8pg4T7t2wU274jfA0MZexNwMzjHRS
MZm6Rmnk42PLzJFbH6kj5E0TWZKzz9RAyLgOpHLyhV4QPkrHkHAs7xqQpEYGd8OX
Cd+Vlhh3XecDgpqoDaQ+tT0CgYBa2GO7EuIeTUt5K76bA1PztlKAOE1sxgR7GC5L
e2mMxfg1ZeXXo4L6lBleCpOk1cT4UcIclo0mNlEjWwEO4Y03t5+KpTG6ItPatSAK
tAAqUDXjj5pBlZ/CulJAczFxHvYMxeGxrBO1UfOtfepQXfejE+4mUUxGX7l274pH
MJQiIQKBgQCoc7C4DjvjhHuSIadLZxgp9p1pvdjpyWrlZ4KIp8d8FX7JGBWvUa1E
CLZYEZ6m6jsnK89VvRCh4wfYLqs/Gm1kPUiyYlCnxso3p//yvtduQXEKfQOGRvPR
Sm9b7nJ6dgEL001mNI1Y0Z6S3ZcQy0eVqs8hKVdVUBFO3p7RobXe/Q==
-----END RSA PRIVATE KEY-----
"""
}
