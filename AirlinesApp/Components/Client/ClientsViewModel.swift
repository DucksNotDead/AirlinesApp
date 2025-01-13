import Combine
import Foundation

typealias Clients = [Client]

private struct paths {
	static let base = "/clients"
	static func item(id: Int) -> String {
		return "\(base)/\(id)"
	}
}

class ClientsViewModel: ObservableObject {
	@Published var clients: [Client] = []
	@Published var isLoading: Bool = false
	private var cancellables: Set<AnyCancellable> = []
	private let toasts: ToastsDataSource

	@MainActor
	init() {
		self.toasts = ToastsDataSource.shared
		fetch()
	}

	func fetch() {
		isLoading = true
		api.get(path: paths.base, responseType: Clients.self).sink {
			completion in
			self.isLoading = false
			switch completion {
			case .finished: break
			case .failure(let err):
				print(err)
				self.toasts.error("Ошибка получения клиентов")
			}
		} receiveValue: { clients in
			self.clients = clients
		}
		.store(in: &cancellables)
	}

	func create(_ dto: ClientCreateUpdateDto) {
		isLoading = true
		api.post(
			path: paths.base,
			body: dto.toJSONObject()!,
			responseType: Client.self
		).sink { completion in
			self.isLoading = false
			switch completion {
			case .finished:
				self.toasts.append("Клиент создан")
			case .failure:
				self.toasts.error("Ошибка создания клиента")
			}
		} receiveValue: { client in
			self.clients.append(client)
		}
		.store(in: &cancellables)

	}

	func update(_ dto: ClientCreateUpdateDto) {
		isLoading = true
		let id = dto.id!
		api.patch(
			path: paths.item(id: id),
			body: dto.toJSONObject()!,
			responseType: Client.self
		).sink { completion in
			self.isLoading = false
			switch completion {
			case .finished:
				self.toasts.append("Клиент изменён")
			case .failure:
				self.toasts.error("Ошибка изменения клиента")
			}
		} receiveValue: { client in
			if let index = self.clients.firstIndex(where: { $0.id == id }) {
				self.clients[index] = client
			}
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
					self.toasts.append("Клиент удалён")
				case .failure:
					self.toasts.error("Ошибка удаления клиента")
				}
			} receiveValue: { deleted in
				self.clients = self.clients.filter { $0.id != deleted.id }
			}
			.store(in: &cancellables)
	}

}
