import Foundation

struct Client: Codable, Hashable {
	var id: Int
	var passport: Int
	var fio: String
	var user_id: Int?
}
