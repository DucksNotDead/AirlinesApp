import SwiftData
import SwiftUI

@main
struct AirlinesApp: App {
	var body: some Scene {
		WindowGroup {
			ContentView()
		}
		.modelContainer(for: Toast.self)
	}
}
