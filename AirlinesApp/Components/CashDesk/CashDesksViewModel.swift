import Combine
import Foundation

typealias CashDesks = [CashDesk]

private struct paths {
	static let base = "/cash-desks"
	static func item(id: Int) -> String {
		return "\(base)/\(id)"
	}
}

class CashDesksViewModel: ObservableObject {
	@Published var cashDesks: [CashDesk] = []
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
		api.get(path: paths.base, responseType: CashDesks.self).sink {
			completion in
			self.isLoading = false
			switch completion {
			case .finished: break
			case .failure:
				self.toasts.error("Ошибка получения касс")
			}
		} receiveValue: { cashDesks in
			self.cashDesks = cashDesks
		}
		.store(in: &cancellables)
	}

	func create(_ dto: CashDeskCreateUpdateDto) {
		isLoading = true
		api.post(
			path: paths.base,
			body: dto.toJSONObject()!,
			responseType: CashDesk.self
		).sink { completion in
			self.isLoading = false
			switch completion {
			case .finished:
				self.toasts.append("Касса создана")
			case .failure:
				self.toasts.error("Ошибка создания кассы")
			}
		} receiveValue: { cashDesk in
			self.cashDesks.append(cashDesk)
		}
		.store(in: &cancellables)

	}

	func update(_ dto: CashDeskCreateUpdateDto) {
		isLoading = true
		let id = dto.id!
		api.patch(
			path: paths.item(id: id),
			body: dto.toJSONObject()!,
			responseType: CashDesk.self
		).sink { completion in
			self.isLoading = false
			switch completion {
			case .finished:
				self.toasts.append("Касса изменена")
			case .failure:
				self.toasts.error("Ошибка изменения кассы")
			}
		} receiveValue: { cashDesk in
			if let index = self.cashDesks.firstIndex(where: { $0.id == id }) {
				self.cashDesks[index] = cashDesk
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
					self.toasts.append("Касса удалена")
				case .failure:
					self.toasts.error("Ошибка удаления кассы")
				}
			} receiveValue: { deleted in
				self.cashDesks = self.cashDesks.filter { $0.id != deleted.id }
			}
			.store(in: &cancellables)
	}
}
