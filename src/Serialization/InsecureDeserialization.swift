// FIXTURE: CWE-502/611 insecure deserialization & XXE. Deliberately vulnerable — do not reuse.
import Foundation

final class Session: NSObject, NSCoding {
    var userId: String
    var isAdmin: Bool
    init(userId: String, isAdmin: Bool) { self.userId = userId; self.isAdmin = isAdmin }
    func encode(with coder: NSCoder) { coder.encode(userId, forKey: "userId"); coder.encode(isAdmin, forKey: "isAdmin") }
    required init?(coder: NSCoder) {
        userId = coder.decodeObject(forKey: "userId") as? String ?? ""
        isAdmin = coder.decodeBool(forKey: "isAdmin")
    }
}

enum Deserialization {
    // VULN: NSKeyedUnarchiver without secure coding on untrusted data (CWE-502)
    static func restoreSession(from untrusted: Data) -> Session? {
        NSKeyedUnarchiver.unarchiveObject(with: untrusted) as? Session
    }

    static func restoreLegacy(from untrusted: Data) throws -> Any? {
        let unarchiver = try NSKeyedUnarchiver(forReadingFrom: untrusted)
        unarchiver.requiresSecureCoding = false
        return unarchiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey)
    }

    // VULN: client-controlled privilege flag trusted from cookie/JSON (CWE-565)
    static func isAdmin(cookieJSON: Data) -> Bool {
        let obj = try? JSONSerialization.jsonObject(with: cookieJSON) as? [String: Any]
        return obj?["isAdmin"] as? Bool ?? false
    }

    // VULN: XML external entity resolution enabled (CWE-611)
    static func parse(xml: Data, delegate: XMLParserDelegate) -> Bool {
        let parser = XMLParser(data: xml)
        parser.shouldResolveExternalEntities = true
        parser.delegate = delegate
        return parser.parse()
    }
}
