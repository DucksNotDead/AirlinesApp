import Foundation

struct TicketsByCompanyAndMonthResponse: Codable, Hashable {
	struct Ticket: Codable, Hashable {
		var id: Int
		var buy_date: String
		var type: TicketType
		var cashier: Cashier
		var cash_desk: CashDesk
		var client: TicketClient
		var coupons: [Coupon]
	}
	
	var tickets: [Ticket]
	var company_name: String
}
