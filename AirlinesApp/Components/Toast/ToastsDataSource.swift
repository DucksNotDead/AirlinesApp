import Foundation
import SwiftData

class ToastsDataSource {
	private let modelContainer: ModelContainer
	private let modelContext: ModelContext

	@MainActor
	static let shared = ToastsDataSource()

	@MainActor
	private init() {
		self.modelContainer = try! ModelContainer(for: Toast.self)
		self.modelContext = modelContainer.mainContext
	}

	private func add(_ toast: Toast) {
		modelContext.insert(toast)
		do {
			try modelContext.save()
		} catch {
			fatalError(error.localizedDescription)
		}
	}

	func append(_ message: String) {
		add(.init(message))
	}

	func error(_ message: String) {
		add(.init(message, type: .error))
	}

	func remove(_ item: Toast) {
		modelContext.delete(item)
	}
}
