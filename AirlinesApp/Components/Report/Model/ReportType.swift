import Foundation

enum ReportType {
	case ticketsByCompanyAndMonth
	case clientsOfEachCompanyByDate
	case totalAmountOfEachCompany

	var description: String {
		switch self {
		case .ticketsByCompanyAndMonth:
			return "Билеты, проданные за указанный месяц указанной авиакомпании"
		case .clientsOfEachCompanyByDate:
			return "Список клиентов авиакомпаний на заданную дату"
			case .totalAmountOfEachCompany:
				return "Общая сумма от продаж билетов каждой авиакомпании"
		}
	}

	var url: String {
		let baseURL = "/reports"
		switch self {
		case .ticketsByCompanyAndMonth:
			return "\(baseURL)/tickets-by-company-and-month"
		case .clientsOfEachCompanyByDate:
			return "\(baseURL)/clients-of-each-company-by-date"
			case .totalAmountOfEachCompany:
				return "\(baseURL)/total-amount-of-each-company"
		}
	}
}
