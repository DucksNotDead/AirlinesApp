import Foundation

enum UserRole: String, Codable {
	case admin = "Admin"
	case client = "Client"
	case employee = "Employee"
	case cashier = "Cashier"

	var localized: String {
		switch self {
		case .admin: return "Администратор"
		case .client: return "Клиент"
		case .employee: return "Сотрудник"
		case .cashier: return "Кассир"
		}
	}
}
