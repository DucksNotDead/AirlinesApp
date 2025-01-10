import Combine
import Foundation

typealias Tickets = [Ticket]

private struct paths {
	static let base = "/tickets"
	static func item(id: Int) -> String {
		return "\(base)/\(id)"
	}
}

class TicketsViewModel: ObservableObject {
	@Published var tickets: [Ticket] = []
	@Published var isLoading: Bool = false
	private var cancellables: Set<AnyCancellable> = []
	private let toasts: ToastsDataSource

	@MainActor
	init() {
		self.toasts = ToastsDataSource.shared
		fetch()
	}

	func fetch() {
		api.get(path: paths.base, responseType: Tickets.self).sink { completion in
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
