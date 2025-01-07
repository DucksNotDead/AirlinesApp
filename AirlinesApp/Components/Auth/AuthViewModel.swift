import Combine
import Foundation

private struct Paths {
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
		api.post(
			path: Paths.base,
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

	func login() {

	}

	func logout() {
		print("logout")
	}

	func register() {

	}
}
