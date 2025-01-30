import SwiftUI

private typealias PickerOption<T> = (T, String)

struct TicketsByCompanyAndMonthForm: View {
	@Binding var formData: TicketsByCompanyAndMonthDto
	@StateObject var companiesModel = CompaniesViewModel()

	var body: some View {
		Form {
			Section("Авиакомпания") {
				Picker("выбрать", selection: $formData.company_code)
				{
					Text("выбрать").tag("")
					ForEach(companiesModel.companies, id: \.code) {
						company in
						Text(company.name).tag(company.code)
					}
				}
				.frame(maxHeight: 140)
			}
			Section("Месяц") {
				Picker("выбрать", selection: $formData.month) {
					ForEach(dateService.months, id: \.index) {
						index, month in
						Text(month).tag(index)
					}
				}
				.frame(maxHeight: 140)
			}
			Section("Год") {
				Picker("выбрать", selection: $formData.year) {
					ForEach(
						(1970...dateService.currentYear).reversed(),
						id: \.self
					) {
						year in
						Text(String(year)).tag(year)
					}
				}
				.frame(maxHeight: 140)
			}
		}
		.pickerStyle(.wheel)
	}
}

#Preview {
	@Previewable @State var formData = FormService(
		TicketsByCompanyAndMonthDto(company_code: "", month: 0, year: 0))

	TicketsByCompanyAndMonthForm(formData: $formData.data)
}
