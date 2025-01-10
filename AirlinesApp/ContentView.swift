import SwiftUI

struct ContentView: View {
	@StateObject var authModel = AuthViewModel()
	
	@ViewBuilder
	func content() -> some View {
		if authModel.isLoading {
			ProgressView()
		} else {
			TabView {
				if let user = authModel.currentUser,
					user.role != .client
				{
					RegistriesScreen(userRole: user.role)
						.tabItem {
							Label(
								"Разделы",
								systemImage: "filemenu.and.selection"
							)
						}

					if user.role == .admin {
						ReportsScreen()
							.tabItem {
								Label(
									"Отчеты",
									systemImage: "chart.line.text.clipboard"
								)
							}
					}
				}
				TicketsScreen()
					.tabItem {
						Label(
							"Биллеты",
							systemImage: "checkmark.seal.text.page")
					}

				ProfileScreen()
					.environmentObject(authModel)
					.tabItem {
						Label("Аккаунт", systemImage: "person.crop.circle")
					}
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
