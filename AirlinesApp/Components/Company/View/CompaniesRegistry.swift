import SwiftUI

struct CompaniesRegistry: View {
	@StateObject var companiesModel = CompaniesViewModel()
	@StateObject var formService = FormService(
		CompanyCreateUpdateDto(code: "", name: "", address: "")
	)
	@State var formCode = ""

	var formFields: [FormField] {
		return [
			.init(label: "Код", value: .string($formCode), updatable: false),
			.init(label: "Название", value: .string($formService.data.name)),
			.init(label: "Адрес", value: .string($formService.data.address)),
		]
	}

	var body: some View {
		RegistryView(
			data: companiesModel.companies,
			isLoading: companiesModel.isLoading,
			formFields: formFields,
			canEdit: true,
			idKey: \.code,
			itemTitle: { "\($0.code)" },
			onItemOpen: { company in
				formService.setData(
					.init(
						code: company.code, name: company.name,
						address: company.address))
			},
			onItemCancel: {
				formService.setDefault()
				formCode = ""
			},
			onItemCreate: {
				companiesModel.create(
					.init(
						code: formCode, name: formService.data.name,
						address: formService.data.address))
			},
			onUpdateSave: { company in
				companiesModel.update(
					.init(
						name: formService.data.name,
						address: formService.data.address))
			},
			onDelete: { company in companiesModel.delete(company.code) },
			label: { company in
				HStack {
					Text(company.code)
						.foregroundStyle(.orange)
					Text(company.name)
				}
			},
			detail: { company in
				Text("Название компании: \(company.name)")
				Text("Адрес компании: \(company.address)")
			}
		)
	}
}

#Preview {
	CompaniesRegistry()
}
