import Foundation

struct Client: Codable, Hashable {
	var id: Int
	var passport: String
	var fio: String
	var user_id: Int?
}

struct ClientFormData: Codable {
	var id: Int?
	var passport: String
	var fio: String
	var user_id: String
}

struct ClientCreateUpdateDto: Codable {
	var id: Int?
	var passport: String
	var fio: String
	var user_id: Int?
}
