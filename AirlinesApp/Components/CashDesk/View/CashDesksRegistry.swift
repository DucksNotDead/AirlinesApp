import SwiftUI

struct CashDesksRegistry: View {
	@StateObject var cashDesksModel = CashDesksViewModel()
	@StateObject var formService = FormService(
		CashDeskCreateUpdateDto(address: "")
	)

	var formFields: [FormField] {
		return [
			.init(label: "Адрес", value: .string($formService.data.address))
		]
	}

	var body: some View {
		RegistryView(
			data: cashDesksModel.cashDesks,
			isLoading: cashDesksModel.isLoading,
			formFields: formFields,
			canEdit: true,
			idKey: \.id,
			onItemOpen: { cashDesk in
				formService.setData(
					.init(address: cashDesk.address))
			},
			onItemCancel: { formService.setDefault() },
			onItemCreate: { cashDesksModel.create(formService.data) },
			onUpdateSave: { cashDesk in
				cashDesksModel.update(
					CashDeskCreateUpdateDto(
						id: cashDesk.id, address: formService.data.address))
			},
			onDelete: { cashDesksModel.delete($0.id) },
			onRefresh: { cashDesksModel.fetch() }
		) { cashDesk in
			Text(cashDesk.address)
		}
	}
}

#Preview {
	CashDesksRegistry()
}
