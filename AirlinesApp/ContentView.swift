import SwiftUI

enum Screens: String {
	case profile = "profile"
	case tickets = "tickets"
	case registries = "registries"
	case reports = "reports"
}

struct ContentView: View {
	@StateObject var authModel = AuthViewModel()
	@State var selectedTab: Screens = .tickets

	@ViewBuilder
	func content() -> some View {
		if authModel.isLoading {
			ProgressView()
		} else {
			TabView(selection: $selectedTab) {
				if let user = authModel.currentUser {
					if user.role == .admin {
						RegistriesScreen(userRole: user.role)
							.tabItem {
								Label(
									"Разделы",
									systemImage: "filemenu.and.selection"
								)
							}
							.tag(Screens.registries)

						ReportsScreen()
							.tabItem {
								Label(
									"Отчеты",
									systemImage: "chart.line.text.clipboard"
								)
							}
							.tag(Screens.reports)
					}
					TicketsScreen(user: user)
						.tabItem {
							Label(
								"Биллеты",
								systemImage: "checkmark.seal.text.page"
							)
						}
						.tag(Screens.tickets)
				}

				ProfileScreen()
					.environmentObject(authModel)
					.tabItem {
						Label(
							"Аккаунт",
							systemImage: "person.crop.circle"
						)
					}
					.tag(Screens.profile)
			}
		}
	}

	var body: some View {
		ToastsProvider {
			content()
		}
	}
}

#Preview {
	ContentView()
}
