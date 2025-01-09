import SwiftUI

struct ContentView: View {
	@StateObject var authViewModel = AuthViewModel()

	var body: some View {
		TabView {
			if let user = authViewModel.currentUser, user.role != .client {
				RegistriesScreen(userRole: user.role)
					.tabItem {
						Label("Разделы", systemImage: "chart.line.text.clipboard")
					}
			}
			TicketsScreen()
				.tabItem {
					Label("Биллеты", systemImage: "checkmark.seal.text.page")
				}
			
			ProfileScreen()
				.environmentObject(authViewModel)
				.tabItem {
					Label("Аккаунт", systemImage: "person.crop.circle")
				}
		}
	}
}

#Preview {
	ContentView()
}
