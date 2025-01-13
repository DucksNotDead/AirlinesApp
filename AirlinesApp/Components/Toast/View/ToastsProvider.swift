import SwiftData
import SwiftUI

struct ToastsProvider<Content>: View where Content: View {
	@Environment(\.modelContext) var modelContext
	@Query(sort: \Toast.creationDate) var toasts: [Toast]
	
	let content: () -> Content

	init(_ content: @escaping () -> Content) {
		self.content = content
	}
	
	private func save() {
		do {
			try modelContext.save()
		} catch {
			fatalError(error.localizedDescription)
		}
	}

	var body: some View {
		ZStack {
			content()
			VStack(spacing: 14) {
				ForEach(toasts.reversed()) { toast in
					ToastItem(toast) 
					.transition(
						.asymmetric(
							insertion: .push(from: .top),
							removal: .push(from: .bottom))
					)
				}
				Spacer()
			}
			.padding(.top, 14)
			.onChange(of: toasts) { oldValue, newValue in
				DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
					if let item = newValue.last {
						self.modelContext.delete(item)
						save()
					}
				}
			}
			.animation(.easeIn(duration: 0.15), value: toasts)
		}
		.onDisappear() {
			for toast in toasts {
				modelContext.delete(toast)
			}
			save()
		}
	}
}

struct TestView: View {
	@Environment(\.modelContext) var modelContext
	@Query var toasts: [Toast]
	@State var index: Int = 1

	var body: some View {
		ToastsProvider {
			NavigationStack {
				Button("Hello, World!") {
					modelContext.insert(Toast("Message \(index)"))
					index += 1
				}
				.navigationTitle("Page")
			}
		}
	}
}

#Preview {
	TestView()
		.modelContainer(for: Toast.self)
}
