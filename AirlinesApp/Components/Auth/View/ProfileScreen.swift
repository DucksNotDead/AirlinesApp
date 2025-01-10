import Foundation
import SwiftUI

enum EnterMode {
	case login
	case register
}

struct ProfileScreen: View {
	@EnvironmentObject var authViewModel: AuthViewModel
	@State var login: String = ""
	@State var password: String = ""
	@State var enterMode: EnterMode = .login

	var body: some View {
		if authViewModel.currentUser != nil {
			if let user = authViewModel.currentUser {
				NavigationStack {
					VStack {
						HStack {
							Image(systemName: "person")
								.font(.system(size: 32))
								.foregroundStyle(.blue)
							VStack(alignment: .leading) {
								Text(user.login)
								Text(user.role.localized)
									.foregroundStyle(.secondary)
							}
							Spacer(minLength: 24)
							Button("выйти") {
								authViewModel.logout()
							}
						}
						.padding(.top)
					}
					.padding(.bottom, 16)
					.padding(.horizontal, 16)
					.background(Color.white)
					.navigationTitle("личный кабинет")
					Spacer()
				}
			}
		} else {
			NavigationStack {
				Form {
					Picker("тип входа", selection: $enterMode) {
						Text("войти").tag(EnterMode.login)
						Text("зарегестрироваться").tag(EnterMode.register)
					}.pickerStyle(.segmented).padding(.vertical, 4)
					TextField("введите логин", text: $login)
					SecureField("введите пароль", text: $password)
					HStack {
						Spacer()
						Button("отправить") {
							let credits = Credits(login: login, password: password)
							switch enterMode {
								case .login:
									authViewModel.login(credits)
								case .register:
									authViewModel.register(credits)
							}
						}
						.padding(.vertical, 6)
						.padding(.horizontal, 12)
						.background(Color.blue)
						.clipShape(.rect(cornerRadius: 12))
						.foregroundStyle(.white)
						.padding(.vertical, 4)
					}
				}
				.navigationTitle("авторизация")
			}
		}
	}
}

#Preview {
	ProfileScreen()
		.environmentObject(AuthViewModel())
}
