import Combine
import Foundation

typealias Tickets = [Ticket]
typealias TicketStatuses = [TicketStatus]
typealias TicketTypes = [TicketType]

private enum TicketAction: String {
	case buy = "buy"
	case confirm = "confirm"
	case deny = "deny"
}

private struct paths {
	static let base = "/tickets"
	static func item(id: Int, prefix: TicketAction? = nil) -> String {
		return "\(base)\(prefix != nil ? "/\(prefix!.rawValue)" : "")/\(id)"
	}
	static func status(code: String?) -> String {
		return base + (code != nil ? "?status=\(code!)" : "")
	}
	static var statuses: String { "\(base)/statuses" }
	static var types: String { "\(base)/types" }
}

class TicketsViewModel: ObservableObject {
	@Published var tickets: Tickets = []
	@Published var statuses: TicketStatuses = []
	@Published var types: TicketTypes = []
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

	func getTypes() {
		api.get(path: paths.types, responseType: TicketTypes.self).sink {
			completion in
			switch completion {
			case .finished: break
			case .failure:
				self.toasts.error("Ошибка получения статусов")
			}
		} receiveValue: { types in
			self.types = types
		}
		.store(in: &cancellables)
	}

	func create(_ dto: TicketCreateUpdateDto) {
		isLoading = true
		api.post(
			path: paths.base,
			body: dto.toJSONObject()!,
			responseType: MessageResponse.self
		).sink { completion in
			self.isLoading = false
			switch completion {
			case .finished:
				self.toasts.append("Билет создан")
			case .failure:
				self.toasts.error("Ошибка создания билета")
			}
		} receiveValue: { _ in
			self.fetch()
		}
		.store(in: &cancellables)
	}

	func update(_ dto: TicketCreateUpdateDto) {
		guard let id = dto.id else { return }
		isLoading = true
		api.patch(
			path: paths.item(id: id),
			body: dto.toJSONObject()!,
			responseType: MessageResponse.self
		).sink { completion in
			self.isLoading = false
			switch completion {
			case .finished:
				self.toasts.append("Билет изменён")
			case .failure:
				self.toasts.error("Ошибка изменения билета")
			}
		} receiveValue: { _ in
			self.fetch()
		}
		.store(in: &cancellables)
	}

	func delete(_ id: Int) {
		isLoading = true
		api.delete(path: paths.item(id: id), responseType: DeleteResponse.self)
			.sink { completion in
				self.isLoading = false
				switch completion {
				case .finished:
					self.toasts.append("Билет удалён")
				case .failure:
					self.toasts.error("Ошибка удаления билета")
				}
			} receiveValue: { _ in
				self.tickets.removeAll(where: { $0.id == id })
			}
			.store(in: &cancellables)
	}

	func buy(_ id: Int, credits: TicketBuyCreditsDto) {
		isLoading = true
		api.post(
			path: paths.item(id: id, prefix: .buy),
			body: credits.toJSONObject()!,
			responseType: TicketBuyResponse.self
		).sink { completion in
			self.isLoading = false
			switch completion {
			case .finished:
				self.toasts.append("Заявка на покупку билета отправлена")
			case .failure:
				self.toasts.error("Ошибка покупки билета")
			}
		} receiveValue: { ticketBuyResponse in
			if let index = self.tickets.firstIndex(where: { $0.id == id }) {
				self.tickets[index].status = self.statuses[1]
				self.tickets[index].client = ticketBuyResponse.client
			}
		}
		.store(in: &cancellables)
	}

	func deny(_ id: Int) {
		isLoading = true
		api.post(
			path: paths.item(id: id, prefix: .deny),
			responseType: MessageResponse.self
		).sink { completion in
			self.isLoading = false
			switch completion {
			case .finished:
				self.toasts.append("Заявка на покупку билета отправлена")
			case .failure:
				self.toasts.error("Ошибка покупки билета")

			}
		} receiveValue: { message in
			self.fetch()
		}
		.store(in: &cancellables)
	}

	func confirm(_ id: Int) {
		isLoading = true
		api.post(
			path: paths.item(id: id, prefix: .confirm),
			responseType: MessageResponse.self
		).sink { completion in
			self.isLoading = false
			switch completion {
			case .finished:
				self.toasts.append("Заявка на покупку билета отправлена")
			case .failure:
				self.toasts.error("Ошибка покупки билета")
			}
		} receiveValue: { message in
			self.fetch()
		}
		.store(in: &cancellables)
	}
}
