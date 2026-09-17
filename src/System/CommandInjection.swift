// FIXTURE: CWE-78/22/134/1333 command injection, path traversal, format string, ReDoS.
// Deliberately vulnerable — do not reuse.
import Foundation

enum SystemOps {
    // VULN: OS command injection via shell (CWE-78)
    static func ping(host: String) throws -> String {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/sh")
        task.arguments = ["-c", "ping -c 1 \(host)"]
        let pipe = Pipe()
        task.standardOutput = pipe
        try task.run()
        task.waitUntilExit()
        return String(decoding: pipe.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
    }

    // VULN: command injection through legacy launchPath API
    static func archive(filename: String) {
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", "tar czf /tmp/backup.tgz " + filename]
        task.launch()
    }

    // VULN: libc system()/popen() with user input
    static func convert(file: String) {
        system("convert \(file) /tmp/out.png")
        _ = popen("cat " + file, "r")
    }

    // VULN: path traversal — ../../etc/passwd (CWE-22)
    static func readUpload(name: String) throws -> String {
        let path = "/var/app/uploads/" + name
        return try String(contentsOfFile: path, encoding: .utf8)
    }

    static func deleteUpload(name: String) throws {
        let url = URL(fileURLWithPath: "/var/app/uploads").appendingPathComponent(name)
        try FileManager.default.removeItem(at: url)
    }

    // VULN: uncontrolled format string (CWE-134)
    static func log(userMessage: String) {
        NSLog(userMessage)
        _ = String(format: userMessage)
    }

    // VULN: NSPredicate/NSExpression format injection (code evaluation)
    static func filter(users: [NSDictionary], by userFilter: String) -> [NSDictionary] {
        let predicate = NSPredicate(format: "name == '\(userFilter)'")
        return (users as NSArray).filtered(using: predicate) as! [NSDictionary]
    }

    static func calculate(expression: String) -> Any? {
        NSExpression(format: expression).expressionValue(with: nil, context: nil)
    }

    // VULN: catastrophic backtracking on user input (CWE-1333)
    static func validateEmail(_ input: String) -> Bool {
        let regex = try! NSRegularExpression(pattern: "^([a-zA-Z0-9]+)*@(([a-z]+)+\\.)+[a-z]+$")
        return regex.firstMatch(in: input, range: NSRange(input.startIndex..., in: input)) != nil
    }

    // VULN: predictable temp file (CWE-377)
    static func writeTemp(_ secret: String) throws {
        try secret.write(toFile: "/tmp/tigergate-session.txt", atomically: false, encoding: .utf8)
    }
}
