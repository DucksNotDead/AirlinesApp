import SwiftUI

struct BlurLoadingView<Content: View>: View {
	@Binding var isPresented: Bool

	let content: () -> Content

	init(
		isPresented: Binding<Bool>,
		@ViewBuilder content: @escaping () -> Content
	) {
		self._isPresented = isPresented
		self.content = content
	}

	var body: some View {
		ZStack {
			VStack {
				content()
			}
			.blur(radius: isPresented ? 20 : 0)
			if isPresented {
				ProgressView {
					Text("Загрузка документа")
				}
				.background(Color.white.opacity(0.2))
				.scaleEffect(1.1)
				.ignoresSafeArea(.all)
				.frame(maxWidth: .infinity, maxHeight: .infinity)
			}
		}
		.animation(.easeInOut(duration: 0.5), value: isPresented)
	}
}

#Preview {
	@Previewable @State var isLoading = false

	BlurLoadingView(isPresented: $isLoading) {
		Text("Text&&&")
		Button("click") {
			isLoading.toggle()
		}
	}
}
