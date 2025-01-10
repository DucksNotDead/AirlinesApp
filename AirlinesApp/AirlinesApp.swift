import SwiftUI
import SwiftData

@main
struct AirlinesApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
		.modelContainer(for: Toast.self, inMemory: false)
    }
}
