import SwiftUI

struct ClientsRegistry: View {
	@StateObject var clientsModel = ClientsViewModel()
	@StateObject var formService = FormService(
		ClientFormData(passport: "", fio: "", user_id: "")
	)
	@StateObject var usersModel = UsersViewModel()

	var formFields: [FormField] {
		return [
			.init(label: "ФИО", value: .string($formService.data.fio)),
			.init(
				label: "Паспорт", value: .string($formService.data.passport)),
			.init(
				label: "Пользователь",
				optional: true,
				value: .choose(
					$formService.data.user_id,
					usersModel.users
						.filter({ $0.role == .client })
						.map({ user in
							.init(label: user.login, value: String(user.id))
						}))),
		]
	}

	var body: some View {
		RegistryView(
			data: clientsModel.clients,
			isLoading: clientsModel.isLoading,
			formFields: formFields,
			canEdit: true,
			idKey: \.id,
			onItemOpen: { client in
				formService.setData(
					.init(
						id: client.id,
						passport: client.passport,
						fio: client.fio,
						user_id: String(client.user_id ?? 0)))
			},
			onItemCancel: { formService.setDefault() },
			onItemCreate: {
				clientsModel.create(
					.init(
						passport: formService.data.passport,
						fio: formService.data.fio))
			},
			onUpdateSave: { client in
				clientsModel.update(
					.init(
						id: client.id,
						passport: formService.data.passport,
						fio: formService.data.fio,
						user_id: Int(formService.data.user_id)))
			},
			onDelete: { client in clientsModel.delete(client.id) },
			onRefresh: { clientsModel.fetch() }
		) { client in
			Text(client.fio)
			KeyValueView("Паспорт", client.passport)
			if let user = usersModel.users.first(where: {
				$0.id == client.user_id
			}) {
				KeyValueView("Логин", user.login)
			}
		}
	}
}

#Preview {
	ClientsRegistry()
}
