import SwiftUI

struct ContentView: View {
	@StateObject var authViewModel = AuthViewModel()
	
	var body: some View {
		Text("Hello SwiftUI!")
	}
}

#Preview {
	ContentView()
}
