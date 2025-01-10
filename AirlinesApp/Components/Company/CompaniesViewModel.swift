import Combine
import Foundation

typealias Companies = [Company]

private struct CompanyDeleteResponse: Codable {
	var code: String
}

private struct paths {
	static let base = "/companies"
	static func item(code: String) -> String {
		return "\(base)/\(code)"
	}
}

class CompaniesViewModel: ObservableObject {
	@Published var companies: [Company] = []
	@Published var isLoading: Bool = false
	private var cancellables: Set<AnyCancellable> = []
	private let toasts: ToastsDataSource

	@MainActor
	init() {
		self.toasts = ToastsDataSource.shared
		fetch()
	}

	func fetch() {
		api.get(path: paths.base, responseType: Companies.self).sink {
			completion in
			switch completion {
			case .finished: break
			case .failure:
				self.toasts.error("Ошибка получения компаний")
			}
		} receiveValue: { companies in
			self.companies = companies
		}
		.store(in: &cancellables)
	}

	func create(_ dto: CompanyCreateUpdateDto) {
		isLoading = true
		api.post(
			path: paths.base,
			body: dto.toJSONObject()!,
			responseType: Company.self
		).sink { completion in
			self.isLoading = false
			switch completion {
			case .finished:
				self.toasts.append("Компания создана")
			case .failure:
				self.toasts.error("Ошибка создания компании")
			}
		} receiveValue: { company in
			self.companies.append(company)
		}
		.store(in: &cancellables)

	}

	func update(_ dto: CompanyCreateUpdateDto) {
		isLoading = true
		let code = dto.code!
		api.patch(
			path: paths.item(code: code),
			body: dto.toJSONObject()!,
			responseType: Company.self
		).sink { completion in
			self.isLoading = false
			switch completion {
			case .finished:
				self.toasts.append("Компания изменена")
			case .failure:
				self.toasts.error("Ошибка изменения компании")
			}
		} receiveValue: { company in
			if let index = self.companies.firstIndex(where: { $0.code == code })
			{
				self.companies[index] = company
			}
		}
		.store(in: &cancellables)
	}

	func delete(_ code: String) {
		isLoading = true
		api.delete(
			path: paths.item(code: code),
			responseType: CompanyDeleteResponse.self
		)
		.sink { completion in
			self.isLoading = false
			switch completion {
			case .finished:
				self.toasts.append("Компания удалена")
			case .failure:
				self.toasts.error("Ошибка удаления компании")
			}
		} receiveValue: { deleted in
			self.companies = self.companies.filter { $0.code != deleted.code }
		}
		.store(in: &cancellables)
	}
}
