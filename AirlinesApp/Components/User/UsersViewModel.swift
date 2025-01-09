import Combine
import Foundation

typealias Users = [User]

private struct paths {
	static var base: String = "/users"
	static func item(id: Int) -> String {
		return "\(base)/\(id)"
	}
}

class UsersViewModel: ObservableObject {
	@Published var users: [User] = []
	private var cancellables: Set<AnyCancellable> = []

	init() {
		fetch()
	}

	func fetch() {
		api.get(path: paths.base, responseType: Users.self).sink { completion in
			switch completion {
			case .finished: break
			case .failure(let error): print(error)
			}
		} receiveValue: { users in
			self.users = users
		}
		.store(in: &cancellables)
	}

	func create(_ user: User) {

	}

	func update(_ user: User) {

	}

	func delete(_ user: User) {

	}
}
