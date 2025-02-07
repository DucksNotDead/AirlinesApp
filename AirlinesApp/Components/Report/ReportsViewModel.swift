import Combine
import Foundation
import SwiftUI

private enum Error: String {
	case load = "Ошибка получения отчёта"
	case save = "Ошибка сохранения отчёта"
}

class ReportsViewModel: ObservableObject {
	struct File {
		var preview: AnyView
		var name: String
	}

	struct NameAndPreview<C: View> {
		var name: String
		var preview: C
	}

	@Published var isLoading: Bool = false
	@Published var openedReport: File? = nil
	private var cancellables: Set<AnyCancellable> = []
	private let toasts: ToastsDataSource

	@MainActor
	init() {
		self.toasts = ToastsDataSource.shared
	}

	private func error(_ type: Error) {
		self.toasts.error(type.rawValue)
	}

	private func load<T, C>(
		type: ReportType,
		dto: Codable,
		responseType: T.Type,
		onLoad getNameAndPreview: @escaping (_ response: T) -> NameAndPreview<C>
	) where T: Codable, C: View {
		isLoading = true
		api.post(
			path: type.url,
			body: dto.toJSONObject()!,
			responseType: T.self
		).sink { completion in
			switch completion {
			case .finished: break
			case .failure:
				self.openedReport = nil
				self.isLoading = false
				self.error(.load)
			}
		} receiveValue: { response in
			let nameAndPreview = getNameAndPreview(response)
			self.openedReport = .init(
				preview: AnyView(nameAndPreview.preview),
				name: nameAndPreview.name)
			self.isLoading = false
		}
		.store(in: &cancellables)
	}
	
	func save() {
		guard
			let report = openedReport,
			let data = pdfService.render(report.preview)
		else {
			error(.save)
			return
		}
		
		
		let _ = pdfService.save(data, as: "filename")
	
		
		toasts.append("Отчёт сохранён в 'Документы'")
	}

	func loadTicketsByCompanyAndMonth(dto: TicketsByCompanyAndMonthDto) {
		self.load(
			type: .ticketsByCompanyAndMonth,
			dto: dto,
			responseType: TicketsByCompanyAndMonthResponse.self,
			onLoad: { response in
				let monthYear = dateService.monthYearString(month: dto.month, year: dto.year)
				let name = "Билеты, проданные за \(monthYear), \(response.company_name)"
				return .init(
					name: name,
					preview: TicketsByCompanyAndMonthReport(
						name: name,
						data: response.tickets
					)
				)
			}
		)
	}
}
