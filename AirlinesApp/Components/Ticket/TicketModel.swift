import Foundation
import Combine

struct TicketType: Codable, Hashable {
	var id: Int
	var code: String
	var localized: String
}

struct TicketStatus: Codable, Hashable {
	var id: Int
	var code: String
	var localized: String
}

struct TicketClient: Codable, Hashable {
	var id: Int?
	var passport: Int?
	var fio: String?
	var user_id: Int?
}

struct Ticket: Codable, Hashable, Identifiable {	
	var id: Int
	var buy_date: String?
	var type: TicketType
	var status: TicketStatus
	var company: Company
	var coupons: [Coupon]
	var cashier: Cashier?
	var cash_desk: CashDesk?
	var client: TicketClient
}

struct TicketCreateUpdateDto: Codable {
	var id: Int?
	var company_code: String
	var type_id: Int
	var coupons: [Coupon]
}

struct TicketBuyCreditsDto: Codable {
	var email: String
	var passport: String
	var fio: String
}

struct TicketBuyConfirmDto: Codable {
	var cash_desk_id: Int
}

struct TicketBuyResponse: Codable {
	var isAccountCreated: Bool
	var client: TicketClient
}
