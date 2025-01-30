import Foundation

struct TicketsByCompanyAndMonthDto: Codable, Hashable {
	var company_code: String
	var month: Int
	var year: Int
}
