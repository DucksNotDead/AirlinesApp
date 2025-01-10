import Foundation

struct Cashier: Codable, Hashable {
	var id: Int
	var fio: String
	var user_id: Int
}

struct CashierCreateUpdateForm: Codable {
	var fio: String
	var user_id: String
}

struct CashierCreateUpdateDto: Codable {
	var id: Int?
	var fio: String
	var user_id: Int
}
