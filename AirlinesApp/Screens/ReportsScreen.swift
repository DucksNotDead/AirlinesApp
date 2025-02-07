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

	@Environment(\.modelContext) var modelContext
	@State var openedReportItem: ReportType? = nil
	@State var dataToExport: Data? = nil
	@StateObject var reportsModel = ReportsViewModel()
	@StateObject var tbcamForm = FormService(
		TicketsByCompanyAndMonthDto(
			company_code: "", month: 1, year: dateService.currentYear))
	@StateObject var coecbdForm = FormService(
		ClientsOfEachCompanyByDateDto(date: dateService.dateString(Date.now)))

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
					onCancel: tbcamForm.setDefault)),
			.init(
				id: .totalAmountOfEachCompany,
				loadFn: {
					reportsModel.loadTotalAmountOfEachCompany()
				}),
			.init(
				id: .clientsOfEachCompanyByDate,
				loadFn: {
					reportsModel.loadClientsOfEachCompanyByDate(
						dto: coecbdForm.data)
				},
				form: .init(
					body: AnyView(
						ClientsOfEachCompanyByDateForm(
							formData: $coecbdForm.data)),
					onCancel: coecbdForm.setDefault)),
		]
	}

	var reportName: String { reportsModel.openedReport?.name ?? "" }

	var defaultFilename: String { "file" }

	var body: some View {
		NavigationStack {
			BlurLoadingView(isPresented: $reportsModel.isLoading) {
				ScrollView {
					ForEach(items) { item in
						LoadReportItem(
							label: item.id.description,
							isOpen: openedReportItem == item.id,
							form: item.form != nil
								? .init(
									disabled: item.form!.disabled,
									fieldsView: item.form!.body,
									onCancel: {
										item.form!.onCancel()
										openedReportItem = nil
									}) : nil
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
					Spacer()
				}
				.animation(.default, value: openedReportItem)
			}
			.navigationTitle("Отчёты")
			.modifier(
				SheetModifier(
					isPresented: Binding(
						get: { reportsModel.openedReport != nil },
						set: { _ in reportsModel.openedReport = nil }
					),
					title: reportName, buttonLabel: "сохранить",
					buttonDisabled: false,
					content: {
						if let report = reportsModel.openedReport {
							ScrollView {
								report.preview
							}
						} else {
							Spacer()
							ProgressView()
						}
					},
					onDone: {
						dataToExport = pdfService.render(
							reportsModel.openedReport?.preview)
					},
					onDismiss: { reportsModel.openedReport = nil }
				)
			)
			.fileExporter(
				isPresented: Binding(
					get: { dataToExport != nil },
					set: { _ in dataToExport = nil }
				),
				document: (dataToExport != nil
					? PDFService.PDFDocument(data: dataToExport!) : nil),
				contentType: .pdf,
				defaultFilename: defaultFilename
			) { result in
				switch result {
				case .success:
					break
				case .failure:
					modelContext.insert(Toast("Ошибка экспорта", type: .error))
				}
			}
		}
	}
}
