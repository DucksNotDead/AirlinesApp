import SwiftUI

struct CashiersRegistry: View {
	@StateObject var cashiersModel = CashiersViewModel()
	@StateObject var formService = FormService(
		CashierCreateUpdateForm(fio: "", user_id: ""))
	@StateObject var usersModel = UsersViewModel()

	var formFields: [FormField] {
		return [
			.init(label: "ФИО", value: .string($formService.data.fio)),
			.init(
				label: "Пользователь",
				value: .choose(
					$formService.data.user_id,
					usersModel.users.map({ user in
						.init(label: user.login, value: "\(user.id)")
					}))),
		]
	}

	var body: some View {
		RegistryView(
			data: cashiersModel.cashiers,
			isLoading: cashiersModel.isLoading || usersModel.isLoading,
			formFields: formFields,
			canEdit: true,
			idKey: \.id,
			itemTitle: { "\($0.fio)" },
			onItemOpen: { cashier in
				formService.setData(
					.init(
						fio: cashier.fio,
						user_id: String(describing: cashier.user_id)
					))
			},
			onItemCancel: { formService.setDefault() },
			onItemCreate: {
				cashiersModel.create(
					.init(
						fio: formService.data.fio,
						user_id: Int(formService.data.user_id)!
					))
			},
			onUpdateSave: { cashier in
				cashiersModel.update(
					.init(
						id: cashier.id, fio: formService.data.fio,
						user_id: Int(formService.data.user_id)!
					))
			},
			onDelete: { cashiersModel.delete($0.id) },
			label: { cashier in Text("\(cashier.fio)") },
			detail: { cashier in
				if let user = usersModel.users.first(where: {
					$0.id == cashier.user_id
				}
				) {
					VStack {
						Text("Пользователь")
							.font(.title3)
						Text("Логин: \(user.login)")
						Text("Роль: \(user.role.localized)")
					}
				} else {
					EmptyView()
				}
			})
	}
}

#Preview {
	CashiersRegistry()
}
