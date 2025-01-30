import Combine
import Foundation

private enum Error: String {
	case load = "Ошибка получения отчёта"
	case save = "Ошибка сохранения отчёта"
}

class ReportsViewModel: ObservableObject {
	@Published var isLoading: Bool = false
	@Published var openedReport: URL? = nil
	private var cancellables: Set<AnyCancellable> = []
	private let toasts: ToastsDataSource

	@MainActor
	init() {
		self.toasts = ToastsDataSource.shared
	}
	
	private func filename(_ type: ReportType) -> String {
		return "\(type.description) \(dateService.nowString())"
	}
	
	private func error(_ type: Error) {
		self.toasts.error(type.rawValue)
	}
	
	private func load(type: ReportType, dto: Codable) {
		isLoading = true
		api.post(
			path: type.url,
			body: dto.toJSONObject()!,
			responseType: FileResponse.self
		).sink { completion in
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
				self.isLoading = false
			}
			switch completion {
			case .finished: break
			case .failure:
					self.error(.load)
			}
		} receiveValue: { response in
			if let fileURL = pdfService.save(
				file: response.file,
				as: self.filename(.ticketsByCompanyAndMonth)
			) {
				self.openedReport = fileURL
			} else {
				self.openedReport = nil
				self.error(.save)
			}
		}.store(in: &cancellables)
	}

	func loadTicketsByCompanyAndMonth(dto: TicketsByCompanyAndMonthDto) {
		self.load(type: .ticketsByCompanyAndMonth, dto: dto)
	}
}
