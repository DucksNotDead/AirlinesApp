import SwiftUI

struct UsersRegistry: View {
	@StateObject var usersModel = UsersViewModel()
	@State var formFields: [FormField] = []

	var body: some View {
		if !usersModel.users.isEmpty {
			RegistryView(
				data: $usersModel.users,
				formFields: $formFields,
				canEdit: true,
				idKey: \User.id,
				itemTitle: { $0.login },
				onUpdateCancel: {},
				onUpdateSave: { user in },
				onDelete: { user in },
				label: { user in
					Text("\(user.login)")
				},
				detail: { user in
					Text("Роль: \(user.role.localized)")
				}
			)
		} else {
			Spacer()
		}
	}
}

#Preview {
	UsersRegistry()
}
