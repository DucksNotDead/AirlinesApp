import Combine
import SwiftUI

struct CurrentUserView: View {
	@EnvironmentObject var authViewModel: AuthViewModel

	var body: some View {
		if let user = authViewModel.currentUser {
			HStack {
				VStack(alignment: .leading) {
					Text(user.login)
					Text(user.role.localized)
						.foregroundStyle(.secondary)
				}
				Spacer(minLength: 30)
				Button("выйти", systemImage: "logout") {
					authViewModel.logout()
				}
			}
			.padding(.bottom, 16)
			.padding(.horizontal, 16)
			.background(Color.white)
			Spacer()
		}
	}
}

#Preview {
	CurrentUserView().environmentObject(
		AuthViewModel(testUser: testEmployee))
}
