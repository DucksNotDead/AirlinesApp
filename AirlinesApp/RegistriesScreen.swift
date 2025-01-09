import SwiftUI

struct RegistriesScreen: View {
	let userRole: UserRole
	@State var selection: Set<String> = []
	
	struct Registry: Identifiable {
		var id: String
		var icon: String
		var view: AnyView
		var roles: [UserRole]
	}
	
	let registries: [Registry] = [
		.init(id: "Пользователи", icon: "person.2.fill", view: AnyView(UsersRegistry()), roles: [.admin])
	]
	
    var body: some View {
		NavigationStack {
			List(registries) { registry in
				if registry.roles.contains(userRole) {
					NavigationLink(value: registry.id) {
						HStack {
							Image(systemName: registry.icon)
							Text(registry.id)
							Spacer()
						}
					}
				}
			}
			.navigationTitle("разделы")
			.navigationDestination(for: Registry.self.ID) { id in
				if let registry = registries.first(where: { $0.id == id }) {
					registry.view
						.navigationTitle(registry.id.lowercased())
				}
			}
		}
    }
}

#Preview {
	RegistriesScreen(userRole: .admin)
}
