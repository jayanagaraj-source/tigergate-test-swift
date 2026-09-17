// FIXTURE: CWE-89 SQL injection. Deliberately vulnerable — do not reuse.
import Foundation
import SQLite3

final class UserRepository {
    private var db: OpaquePointer?

    init(path: String) {
        sqlite3_open(path, &db)
    }

    // VULN: string interpolation into SQL passed to sqlite3_exec
    func deleteUser(named name: String) {
        let sql = "DELETE FROM users WHERE name = '\(name)'"
        sqlite3_exec(db, sql, nil, nil, nil)
    }

    // VULN: concatenation into SQL passed to sqlite3_prepare_v2
    func findUser(email: String) -> Bool {
        var stmt: OpaquePointer?
        let query = "SELECT id FROM users WHERE email = '" + email + "'"
        guard sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK else { return false }
        defer { sqlite3_finalize(stmt) }
        return sqlite3_step(stmt) == SQLITE_ROW
    }

    // VULN: auth bypass via ' OR '1'='1
    func authenticate(username: String, password: String) -> Bool {
        var stmt: OpaquePointer?
        let query = "SELECT 1 FROM users WHERE username = '\(username)' AND password = '\(password)'"
        sqlite3_prepare_v2(db, query, -1, &stmt, nil)
        defer { sqlite3_finalize(stmt) }
        return sqlite3_step(stmt) == SQLITE_ROW
    }

    // VULN: ORDER BY injection
    func listUsers(sortedBy column: String) {
        sqlite3_exec(db, "SELECT * FROM users ORDER BY \(column)", nil, nil, nil)
    }
}
