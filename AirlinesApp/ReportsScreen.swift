import SwiftUI

struct ReportsScreen: View {
	struct Item: Identifiable {
		struct Form {
			var disabled: Bool = false
			var body: AnyView
			var onCancel: VoidClosure
		}

		var id: ReportType
		var loadFn: VoidClosure
		var form: Form?
	}

	@State var openedReportItem: ReportType? = nil
	@StateObject var reportsModel = ReportsViewModel()
	@StateObject var tbcamForm = FormService(
		TicketsByCompanyAndMonthDto(
			company_code: "", month: 1, year: dateService.currentYear))

	var tbcamDisabled: Bool {
		return tbcamForm.data.company_code == ""
	}

	var items: [Item] {
		return [
			.init(
				id: .ticketsByCompanyAndMonth,
				loadFn: {
					reportsModel.loadTicketsByCompanyAndMonth(
						dto: tbcamForm.data)
				},
				form: .init(
					disabled: tbcamDisabled,
					body: AnyView(
						TicketsByCompanyAndMonthForm(formData: $tbcamForm.data)),
					onCancel: tbcamForm.setDefault))
		]
	}

	var body: some View {
		BlurLoadingView(isPresented: $reportsModel.isLoading) {
			VStack {
				ForEach(items) { item in
					LoadReportItem(
						label: item.id.description,
						isOpen: openedReportItem == item.id,
						form: item.form != nil
							? .init(
								disabled: item.form!.disabled,
								fieldsView: item.form!.body,
								onCancel: item.form!.onCancel) : nil
					) {
						item.loadFn()
					} onToggle: {
						if openedReportItem == item.id {
							openedReportItem = nil
						} else {
							openedReportItem = item.id
						}
					}
				}
			}
			.animation(.default, value: openedReportItem)
		}
	}
}
