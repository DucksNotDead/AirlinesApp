import Foundation

struct CashDesk: Codable, Hashable {
	var id: Int
	var address: String
}

struct CashDeskCreateUpdateDto: Codable {
	var id: Int?
	var address: String
}
