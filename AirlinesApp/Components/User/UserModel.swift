import Foundation

struct User: Codable, Hashable {
	var id: Int
	var login: String
	var role: UserRole
}

let testAdmin = User(id: 1, login: "admin", role: .admin)
let testEmployee = User(id: 2, login: "employee", role: .employee)
