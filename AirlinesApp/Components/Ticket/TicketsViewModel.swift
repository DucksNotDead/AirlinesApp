import Combine
import Foundation

typealias Tickets = [Ticket]
typealias TicketStatuses = [TicketStatus]

private struct paths {
	static let base = "/tickets"
	static func item(id: Int) -> String {
		return "\(base)/\(id)"
	}
	static func status(code: String?) -> String {
		return base + (code != nil ? "?status=\(code!)" : "")
	}
	static var statuses: String { "\(base)/statuses" }
}

class TicketsViewModel: ObservableObject {
	@Published var tickets: Tickets = []
	@Published var statuses: TicketStatuses = []
	@Published var isLoading: Bool = false
	private var cancellables: Set<AnyCancellable> = []
	private let toasts: ToastsDataSource

	@MainActor
	init() {
		self.toasts = ToastsDataSource.shared
	}

	func fetch(statusCode: String? = nil) {
		api.get(
			path: paths.status(code: statusCode),
			responseType: Tickets.self
		).sink { completion in
			switch completion {
			case .finished: break
			case .failure(let err):
				print(err)
				self.toasts.error("Ошибка получения билетов")
			}
		} receiveValue: { tickets in
			self.tickets = tickets
		}
		.store(in: &cancellables)
	}

	func getStatuses() {
		api.get(path: paths.statuses, responseType: TicketStatuses.self).sink {
			completion in
			switch completion {
			case .finished: break
			case .failure:
				self.toasts.error("Ошибка получения статусов")
			}
		} receiveValue: { statuses in
			self.statuses = statuses
		}
		.store(in: &cancellables)
	}

	//	func create(_ dto: UserCreateUpdateDto) {
	//		isLoading = true
	//		api.post(
	//			path: paths.base,
	//			body: dto.toJSONObject()!,
	//			responseType: User.self
	//		).sink { completion in
	//			self.isLoading = false
	//			switch completion {
	//			case .finished:
	//				self.toasts.append("Пользователь создан")
	//			case .failure:
	//				self.toasts.error("Ошибка создания пользователя")
	//			}
	//		} receiveValue: { user in
	//			self.users.append(user)
	//		}
	//		.store(in: &cancellables)
	//
	//	}
	//
	//	func update(_ dto: UserCreateUpdateDto) {
	//		isLoading = true
	//		let id = dto.id!
	//		api.patch(
	//			path: paths.item(id: id),
	//			body: dto.toJSONObject()!,
	//			responseType: User.self
	//		).sink { completion in
	//			self.isLoading = false
	//			switch completion {
	//			case .finished:
	//				self.toasts.append("Пользователь изменён")
	//			case .failure:
	//				self.toasts.error("Ошибка изменения пользователя")
	//			}
	//		} receiveValue: { user in
	//			if let index = self.users.firstIndex(where: { $0.id == id }) {
	//				self.users[index] = user
	//			}
	//		}
	//		.store(in: &cancellables)
	//	}
	//
	//	func delete(_ id: Int) {
	//		isLoading = true
	//		api.delete(path: paths.item(id: id), responseType: DeleteResponse.self)
	//			.sink { completion in
	//				self.isLoading = false
	//				switch completion {
	//				case .finished:
	//					self.toasts.append("Пользователь удалён")
	//				case .failure:
	//					self.toasts.error("Ошибка удаления пользователя")
	//				}
	//			} receiveValue: { deleted in
	//				self.users = self.users.filter { $0.id != deleted.id }
	//			}
	//			.store(in: &cancellables)
	//	}
}
