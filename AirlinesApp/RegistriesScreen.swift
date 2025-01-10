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
		.init(
			id: "Авиакомпании", icon: "airplane.circle.fill",
			view: AnyView(CompaniesRegistry()), roles: [.admin]),
		.init(
			id: "Пользователи", icon: "person.2.fill",
			view: AnyView(UsersRegistry()), roles: [.admin]),
		.init(
			id: "Клиенты",
			icon: "person.crop.square.filled.and.at.rectangle.fill",
			view: AnyView(Text("")), roles: [.admin]
		),
		.init(
			id: "Кассы", icon: "rublesign.bank.building.fill",
			view: AnyView(CashDesksRegistry()), roles: [.admin]),
		.init(
			id: "Кассиры", icon: "person.2.wave.2.fill",
			view: AnyView(CashiersRegistry()), roles: [.admin]),
		.init(
			id: "Купоны",
			icon: "ticket.fill",
			view: AnyView(Text("")), roles: [.admin]
		),
	]

	var body: some View {
		NavigationStack {
			List(registries) { registry in
				if registry.roles.contains(userRole) {
					NavigationLink(value: registry.id) {
						HStack {
							Image(systemName: registry.icon)
								.foregroundStyle(.teal)
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
