import Combine
import Foundation

typealias Cashiers = [Cashier]

private struct paths {
	static let base = "/cashiers"
	static func item(id: Int) -> String {
		return "\(base)/\(id)"
	}
}

class CashiersViewModel: ObservableObject {
	@Published var cashiers: [Cashier] = []
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
		api.get(path: paths.base, responseType: Cashiers.self).sink {
			completion in
			self.isLoading = false
			switch completion {
			case .finished: break
			case .failure:
				self.toasts.error("Ошибка получения кассиров")
			}
		} receiveValue: { cashiers in
			self.cashiers = cashiers
		}
		.store(in: &cancellables)
	}

	func create(_ dto: CashierCreateUpdateDto) {
		isLoading = true
		api.post(
			path: paths.base,
			body: dto.toJSONObject()!,
			responseType: Cashier.self
		).sink { completion in
			self.isLoading = false
			switch completion {
			case .finished:
				self.toasts.append("Кассир создан")
			case .failure:
				self.toasts.error("Ошибка создания кассира")
			}
		} receiveValue: { cashier in
			self.cashiers.append(cashier)
		}
		.store(in: &cancellables)

	}

	func update(_ dto: CashierCreateUpdateDto) {
		isLoading = true
		let id = dto.id!
		api.patch(
			path: paths.item(id: id),
			body: dto.toJSONObject()!,
			responseType: Cashier.self
		).sink { completion in
			self.isLoading = false
			switch completion {
			case .finished:
				self.toasts.append("Кассир изменён")
			case .failure:
				self.toasts.error("Ошибка изменения кассира")
			}
		} receiveValue: { cashier in
			if let index = self.cashiers.firstIndex(where: { $0.id == id }) {
				self.cashiers[index] = cashier
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
					self.toasts.append("Кассир удалён")
				case .failure:
					self.toasts.error("Ошибка удаления кассира")
				}
			} receiveValue: { deleted in
				self.cashiers = self.cashiers.filter { $0.id != deleted.id }
			}
			.store(in: &cancellables)
	}
}
