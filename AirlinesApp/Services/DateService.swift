import Foundation

class DateService {
	typealias Month = (index: Int, name: String)

	var months: [Month] = [
		(1, "Январь"),
		(2, "Февраль"),
		(3, "Март"),
		(4, "Апрель"),
		(5, "Май"),
		(6, "Июнь"),
		(7, "Июль"),
		(8, "Август"),
		(9, "Сентябрь"),
		(10, "Октябрь"),
		(11, "Ноябрь"),
		(12, "Декабрь"),
	]
	
	var now: Date { Date() }
	
	var currentYear: Int { Calendar.current.component(.year, from: now) }

	func nowString() -> String {
		let dateFormatter = DateFormatter()

		dateFormatter.dateFormat = "dd.MM.yyyy/HH:mm:ss"
		return dateFormatter.string(from: now)
	}
	
	func monthYearString(month: Int, year: Int) -> String {
		return String(format: "%02d.%04d", month, year)
	}
	
	func dateString(_ date: Date) -> String {
		let formatter = DateFormatter()
		formatter.dateFormat = "dd.MM.yyyy"
		return formatter.string(from: date)
	}
}

let dateService = DateService()
