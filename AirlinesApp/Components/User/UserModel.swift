import Foundation

struct User: Codable, Hashable, Identifiable {
	var id: Int
	var login: String
	var role: UserRole
}

struct UserCreateUpdateDto: Codable {
	var id: Int?
	var login: String
	var password: String = ""
	var role: String
}

let testAdmin = User(id: 1, login: "admin", role: .admin)
let testEmployee = User(id: 2, login: "employee", role: .employee)
