import Foundation
import SwiftUI

struct ToastItem: View {
	@Environment(\.modelContext) var modelContext

	let toast: Toast
	var typeTheme: (String, Color) {
		switch toast.type {
		case .info:
			return ("checkmark.circle.fill", .green)
		case .error:
			return ("xmark.circle.fill", .red)
		}
	}

	@State var offset = CGSize.zero

	init(_ toast: Toast) {
		self.toast = toast
	}

	var body: some View {
		HStack {
			Image(systemName: typeTheme.0)
				.foregroundStyle(typeTheme.1)
				.font(.system(size: 20))
			Text(toast.message)
				.font(.footnote)
		}
		.padding(.vertical, 8)
		.padding(.horizontal, 16)
		.background(Color.white)
		.clipShape(.rect(cornerRadius: 14))
		.shadow(radius: 10)
		.padding(.horizontal)
		.offset(y: offset.height)
		.gesture(
			DragGesture()
				.onChanged { value in
					offset = value.translation
				}
				.onEnded { value in
					if value.translation.height < -20 {
						modelContext.delete(toast)
					} else {
						withAnimation {
							offset = .zero
						}
					}
				}
		)
	}
}

#Preview {
	ToastItem(.init("Goood!"))
	ToastItem(.init("Baaad!", type: .error))
}
