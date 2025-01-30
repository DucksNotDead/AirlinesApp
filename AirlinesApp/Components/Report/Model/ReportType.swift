import Foundation

enum ReportType {
	case ticketsByCompanyAndMonth

	var description: String {
		switch self {
		case .ticketsByCompanyAndMonth:
			return "Билеты, проданные за указанный месяц указанной авиакомпании"
		}
	}

	var url: String {
		let baseURL = "/reports"
		switch self {
		case .ticketsByCompanyAndMonth:
			return "\(baseURL)/tickets-by-company-and-month"
		}
	}
}
