import Combine
import Foundation

private struct paths {
	static let base = "/auth"
	static var login: String { "\(base)/login" }
	static var logout: String { "\(base)/logout" }
	static var register: String { "\(base)/register" }
}

class AuthViewModel: ObservableObject {
	@Published var currentUser: User?
	@Published var isLoading: Bool = false
	private var cancellables = Set<AnyCancellable>()
	private let toasts: ToastsDataSource

	@MainActor
	init(testUser: User? = nil) {
		toasts = ToastsDataSource.shared

		if let testUser {
			currentUser = testUser
		} else {
			authenticate()
		}
	}

	func authenticate() {
		isLoading = true
		api.get(
			path: paths.base,
			responseType: User.self
		)
		.sink(
			receiveCompletion: { completion in
				self.isLoading = false
				switch completion {
				case .finished:
					self.toasts.append("Авторизация успешна")
					break
				case .failure:
					self.toasts.error("Ошибка авторизации")
					break
				}
			},
			receiveValue: { user in
				self.currentUser = user
			}
		)
		.store(in: &cancellables)
	}

	func login(_ credits: Credits) {
		isLoading = true
		guard let body = credits.toJSONObject() else { return }
		api.post(path: paths.login, body: body, responseType: User.self)
			.sink { completion in
				self.isLoading = false
				switch completion {
				case .finished:
					self.toasts.append("Авторизация успешна")
					break
				case .failure:
					self.toasts.error("Ошибка авторизации")
					break
				}
			} receiveValue: { user in
				self.currentUser = user
			}
			.store(in: &cancellables)

	}

	func logout() {
		isLoading = true
		api.post(path: paths.logout, responseType: MessageResponse.self)
			.sink { completion in
				self.isLoading = false
				switch completion {
				case .finished:
					self.toasts.append("Выход успешен")
					break
				case .failure:
					self.toasts.error("Ошибка выхода")
					break
				}
			} receiveValue: { _ in
				self.currentUser = nil
			}
			.store(in: &cancellables)
	}

	func register(_ credits: Credits) {
		isLoading = true
		guard let body = credits.toJSONObject() else { return }
		api.post(path: paths.register, body: body, responseType: User.self)
			.sink { completion in
				self.isLoading = false
				switch completion {
				case .finished:
					self.toasts.append("Регистрация успешна")
					break
				case .failure:
					self.toasts.error("Ошибка регистрации")
					break
				}
			} receiveValue: { user in
				self.currentUser = user
			}
			.store(in: &cancellables)
	}
}
