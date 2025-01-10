import Foundation
import SwiftData

enum ToastType: Int, Codable {
	case info = 0
	case error = 1
}

@Model
final class Toast {
	var id: UUID
	var message: String
	var type: ToastType
	var creationDate: Date
	
	init(_ message: String, type: ToastType = .info) {
		self.id = UUID()
		self.message = message
		self.type = type
		self.creationDate = Date()
	}
}
