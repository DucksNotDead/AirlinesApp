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
	var cancellables = Set<AnyCancellable>()

	init(testUser: User? = nil) {
		if let testUser {
			currentUser = testUser
		} else {
			authenticate()
		}
	}

	func authenticate() {
		api.get(
			path: paths.base,
			responseType: User.self
		)
		.sink(
			receiveCompletion: { completion in
				switch completion {
				case .finished:
					print("Good job!")
					break
				case .failure:
					print("error!")
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
		guard let body = credits.toJSONObject() else { return }
		api.post(path: paths.login, body: body, responseType: User.self)
			.sink { completion in
				switch completion {
				case .finished:
					print("Good job!")
					break
				case .failure(let err):
					print("error!")
					break
				}
			} receiveValue: { user in
				self.currentUser = user
			}
			.store(in: &cancellables)

	}

	func logout() {
		print("logout")
	}

	func register(_ credits: Credits) {

	}
}
