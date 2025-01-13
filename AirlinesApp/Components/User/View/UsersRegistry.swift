import Combine
import SwiftUI

let roles = [
	UserRole.client,
	UserRole.admin,
	UserRole.employee,
	UserRole.cashier,
]

struct UsersRegistry: View {
	@StateObject var usersModel = UsersViewModel()
	@StateObject var formService = FormService(
		UserCreateUpdateDto(login: "", role: UserRole.client.rawValue)
	)
	@State var formPassword = ""

	var formFields: [FormField] {
		return [
			.init(label: "Логин", value: .string($formService.data.login)),
			.init(
				label: "Пароль", value: .string($formPassword), updatable: false
			),
			.init(
				label: "Роль",
				value: .choose(
					$formService.data.role,
					roles.map({ role in
						.init(label: role.localized, value: role.rawValue)
					}))),
		]
	}

	var body: some View {
		if !usersModel.users.isEmpty {
			RegistryView(
				data: usersModel.users,
				isLoading: false,
				formFields: formFields,
				canEdit: true,
				idKey: \User.id,
				onItemOpen: { user in
					formService.setData(
						.init(
							id: user.id,
							login: user.login,
							role: user.role.rawValue))
				},
				onItemCancel: {
					formService.setDefault()
					formPassword = ""
				},
				onItemCreate: { usersModel.create(formService.data) },
				onUpdateSave: { user in usersModel.update(formService.data) },
				onDelete: { user in usersModel.delete(user.id) },
				onRefresh: { usersModel.fetch() }
			) { user in
				Text("\(user.login)")
				KeyValueView("Роль", user.role.localized)
			}
		} else {
			ProgressView()
		}
	}
}

#Preview {
	UsersRegistry()
}
