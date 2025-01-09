import Foundation
import Combine

struct TicketType {
	var id: Int
	var code: String
	var localized: String
}

struct TicketStatus {
	var id: Int
	var code: String
	var localized: String
}

struct Ticket {
	var id: Int
	var buy_date: String
	var type: TicketType
	var status: TicketStatus
	var company: Company
	var coupons: [Coupon]
	var cashier: Cashier
	var cash_desk: CashDesk
	var client: Client
}
